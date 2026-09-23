originalIO.naTransLatooor=function()
	const Http = Services.HttpService
	const translator = NAStuff.ChatTranslator or {}
	NAStuff.ChatTranslator = translator

	translator.messages = NAmanage.ensureWeakKeyTable(translator.messages)
	translator.enabled = opt.chatTranslateEnabled ~= false
	opt.chatTranslateEnabled = translator.enabled
	translator._controlPairs = type(translator._controlPairs) == "table" and translator._controlPairs or {}
	if next(translator._controlPairs) == nil and (translator.button or translator.input) then
		translator._controlPairs.chatLogs = {
			button = translator.button;
			input = translator.input;
			buttonConn = translator._buttonConn;
			inputConn = translator._inputConn;
		}
	end

	NAmanage.toIso=function(value)
		if not value then return nil end
		return tostring(value):lower()
	end

	const languages = {
		auto="Automatic",morse="Morse Code",af="Afrikaans",sq="Albanian",am="Amharic",ar="Arabic",hy="Armenian",az="Azerbaijani",eu="Basque",be="Belarusian",bn="Bengali",bs="Bosnian",bg="Bulgarian",ca="Catalan",ceb="Cebuano",ny="Chichewa",
		["zh-cn"]="Chinese Simplified",["zh-tw"]="Chinese Traditional",co="Corsican",hr="Croatian",cs="Czech",da="Danish",nl="Dutch",en="English",eo="Esperanto",et="Estonian",tl="Filipino",fi="Finnish",fr="French",fy="Frisian",
		gl="Galician",ka="Georgian",de="German",el="Greek",gu="Gujarati",ht="Haitian Creole",ha="Hausa",haw="Hawaiian",iw="Hebrew",he="Hebrew",hi="Hindi",hmn="Hmong",hu="Hungarian",is="Icelandic",ig="Igbo",id="Indonesian",ga="Irish",it="Italian",
		ja="Japanese",jw="Javanese",kn="Kannada",kk="Kazakh",km="Khmer",ko="Korean",ku="Kurdish (Kurmanji)",ky="Kyrgyz",lo="Lao",la="Latin",lv="Latvian",lt="Lithuanian",lb="Luxembourgish",mk="Macedonian",mg="Malagasy",ms="Malay",
		ml="Malayalam",mt="Maltese",mi="Maori",mr="Marathi",mn="Mongolian",my="Myanmar (Burmese)",ne="Nepali",no="Norwegian",ps="Pashto",fa="Persian",pl="Polish",pt="Portuguese",pa="Punjabi",ro="Romanian",ru="Russian",sm="Samoan",
		gd="Scots Gaelic",sr="Serbian",st="Sesotho",sn="Shona",sd="Sindhi",si="Sinhala",sk="Slovak",sl="Slovenian",so="Somali",es="Spanish",su="Sundanese",sw="Swahili",sv="Swedish",tg="Tajik",ta="Tamil",te="Telugu",th="Thai",tr="Turkish",
		uk="Ukrainian",ur="Urdu",uz="Uzbek",vi="Vietnamese",cy="Welsh",xh="Xhosa",yi="Yiddish",yo="Yoruba",zu="Zulu"
	}

	NAmanage.iso2=function(value)
		const lowered = NAmanage.toIso(value)
		if not lowered then
			return nil
		end
		if languages[lowered] then
			return lowered
		end
		for code, name in languages do
			if type(name) == "string" and name:lower() == lowered then
				return code
			end
		end
		return nil
	end

	originalIO.languageName=function(code)
		return languages[code] or code
	end

	const MORSE_MAP = {
		["A"]=".-",["B"]="-...",["C"]="-.-.",["D"]="-..",["E"]=".",["F"]="..-.",["G"]="--.",["H"]="....",
		["I"]="..",["J"]=".---",["K"]="-.-",["L"]=".-..",["M"]="--",["N"]="-.",["O"]="---",["P"]=".--.",
		["Q"]="--.-",["R"]=".-.",["S"]="...",["T"]="-",["U"]="..-",["V"]="...-",["W"]=".--",["X"]="-..-",
		["Y"]="-.--",["Z"]="--..",
		["1"]=".----",["2"]="..---",["3"]="...--",["4"]="....-",["5"]=".....",["6"]="-....",["7"]="--...",["8"]="---..",["9"]="----.",["0"]="-----",
		["."]=".-.-.-",[","]="--..--",["?"]="..--..",["'"]=".----.",["!"]="-.-.--",["/"]="-..-.",["("]="-.--.",[")"]="-.--.-",
		["&"]=".-...",[":"]="---...",[";"]="-.-.-.",["="]="-...-",["+"]=".-.-.",["-"]="-....-",["_"]="..--.-",["\""]=".-..-.",["$"]="...-..-",["@"]=".--.-."
	}
	const MORSE_REVERSE = {}
	for k,v in MORSE_MAP do
		MORSE_REVERSE[v] = k
	end

	const function isLikelyMorse(text)
		if not text or text == "" then return false end
		return not not text:match("^[%s%./%-]+$")
	end

	const function encodeMorse(text)
		text = tostring(text or "")
		if text == "" then return text end
		const words = {}
		for word in text:gmatch("%S+") do
			const letters = {}
			for i = 1, #word do
				const c = word:sub(i, i):upper()
				letters[#letters+1] = MORSE_MAP[c] or c
			end
			words[#words+1] = Concat(letters, " ")
		end
		return Concat(words, " / ")
	end

	const function decodeMorse(text)
		text = tostring(text or "")
		if text == "" then return text end
		const words = {}
		for word in text:gmatch("[^/]+") do
			const trimmed = word:match("^%s*(.-)%s*$") or ""
			if trimmed ~= "" then
				const letters = {}
				for token in trimmed:gmatch("%S+") do
					letters[#letters+1] = MORSE_REVERSE[token] or "?"
				end
				words[#words+1] = Concat(letters)
			end
		end
		return Concat(words, " ")
	end

	translator.chatTarget = NAmanage.iso2(opt.chatTranslateTarget) or translator.chatTarget or translator.target or "en"
	opt.chatTranslateTarget = translator.chatTarget
	translator.settingsTarget = NAmanage.iso2(opt.settingsTranslateTarget) or translator.settingsTarget or "en"
	opt.settingsTranslateTarget = translator.settingsTarget
	translator.target = translator.chatTarget

	translator.provider = tostring(opt.translateProvider or translator.provider or "mymemory"):lower()
	opt.translateProvider = translator.provider
	opt.translateFallbackGoogle = opt.translateFallbackGoogle == true
	opt.translateUseDeepLFree = opt.translateUseDeepLFree ~= false
	opt.translateLibreEndpoint = opt.translateLibreEndpoint or ""
	opt.translateLibreApiKey = opt.translateLibreApiKey or ""
	opt.translateApiKey = opt.translateApiKey or ""
	opt.translateMyMemoryEmail = opt.translateMyMemoryEmail or ""
	opt.translateMyMemoryKey = opt.translateMyMemoryKey or ""

	translator._state = translator._state or {
		gv = (isfile and isfile("googlev.txt") and readfile("googlev.txt")) or "";
		fsid = nil;
		bl = nil;
		rid = math.random(1000, 9999);
	}
	translator._cache = type(translator._cache) == "table" and translator._cache or {}
	translator._cacheOrder = type(translator._cacheOrder) == "table" and translator._cacheOrder or {}

	const state = translator._state
	const root = "https://translate.google.com/"
	const exec = "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute"
	const rpc = "MkEWBc"

	NAmanage.requestAsync=function(optArgs)
		local ok, res = NAmanage.HttpRequest(optArgs, { maxAttempts = 5, timeout = 10 })
		if ok and res then
			return res
		end
		return nil
	end

	const jsonEncode = function(x) return Http:JSONEncode(x) end
	const jsonDecode = function(x) return Http:JSONDecode(x) end

	const function cleanCfg(value)
		if value == nil then
			return nil
		end
		value = tostring(value)
		value = value:match("^%s*(.-)%s*$") or ""
		if value == "" then
			return nil
		end
		return value
	end

	const function cfgValue(...)
		const keys = {...}
		const hosts = { _na_env, _na_shared, _na_boot and _na_boot.hostEnv, translator, opt }
		for i = 1, #keys do
			const key = keys[i]
			for j = 1, #hosts do
				const host = hosts[j]
				if type(host) == "table" then
					const value = cleanCfg(rawget(host, key))
					if value then
						return value
					end
				end
			end
		end
		return nil
	end

	const function cfgBool(value, default)
		if value == nil then
			return default
		end
		if type(value) == "boolean" then
			return value
		end
		value = tostring(value):lower()
		if value == "true" or value == "1" or value == "yes" or value == "on" then
			return true
		end
		if value == "false" or value == "0" or value == "no" or value == "off" then
			return false
		end
		return default
	end

	const function readCfgFile(...)
		if type(isfile) ~= "function" or type(readfile) ~= "function" then
			return nil
		end
		const files = {...}
		for i = 1, #files do
			const name = files[i]
			local ok, exists = pcall(isfile, name)
			if ok and exists then
				local okRead, value = pcall(readfile, name)
				value = okRead and cleanCfg(value) or nil
				if value then
					return value
				end
			end
		end
		return nil
	end

	const function httpOk(res)
		if not res then
			return false
		end
		const code = tonumber(res.StatusCode or res.statusCode or res.Status or res.status)
		return code == nil or (code >= 200 and code < 300)
	end

	const function httpCode(res)
		return tonumber(res and (res.StatusCode or res.statusCode or res.Status or res.status)) or 0
	end

	const function getProvider()
		local provider = cfgValue("NATranslateProvider", "translateProvider", "translatorProvider") or "mymemory"
		provider = tostring(provider):lower()
		if provider == "memory" or provider == "mm" then
			provider = "mymemory"
		elseif provider == "libretranslate" then
			provider = "libre"
		end
		if provider == "mymemory" or provider == "deepl" or provider == "libre" or provider == "google" then
			return provider
		end
		return "mymemory"
	end

	const function getDeepLKey()
		return cfgValue("NADeepLKey", "DeepLKey", "translateApiKey", "translatorApiKey")
			or readCfgFile("NA_deepl_key.txt", "deepl_key.txt")
	end

	const function getLibreEndpoint()
		local endpoint = cfgValue("NALibreTranslateUrl", "LibreTranslateUrl", "translateLibreEndpoint", "translateLibreUrl")
			or readCfgFile("NA_libretranslate_url.txt", "libretranslate_url.txt")
		if not endpoint then
			return nil
		end
		endpoint = endpoint:gsub("/+$", "")
		if endpoint == "" then
			return nil
		end
		return endpoint
	end

	const function getLibreKey()
		return cfgValue("NALibreTranslateKey", "LibreTranslateKey", "translateLibreApiKey", "libreTranslateApiKey")
			or readCfgFile("NA_libretranslate_key.txt", "libretranslate_key.txt")
	end

	const function getMyMemoryEmail()
		return cfgValue("NAMyMemoryEmail", "MyMemoryEmail", "translateMyMemoryEmail", "translatorEmail")
			or readCfgFile("NA_mymemory_email.txt", "mymemory_email.txt")
	end

	const function getMyMemoryKey()
		return cfgValue("NAMyMemoryKey", "MyMemoryKey", "translateMyMemoryKey", "translatorMyMemoryKey")
			or readCfgFile("NA_mymemory_key.txt", "mymemory_key.txt")
	end

	const function getDeepLEndpoints(key)
		const forced = cfgValue("NADeepLEndpoint", "DeepLEndpoint", "translateDeepLEndpoint")
		if forced then
			return { forced:gsub("/+$", "") }
		end
		local freeDefault = opt.translateUseDeepLFree ~= false
		if type(key) == "string" and key:sub(-3) == ":fx" then
			freeDefault = true
		end
		const useFree = cfgBool(cfgValue("NADeepLFree", "translateUseDeepLFree", "DeepLFree"), freeDefault)
		if useFree then
			return { "https://api-free.deepl.com", "https://api.deepl.com" }
		end
		return { "https://api.deepl.com", "https://api-free.deepl.com" }
	end

	const function deeplLang(code, target)
		code = NAmanage.iso2(code) or tostring(code or ""):lower()
		if code == "" or code == "auto" or code == "morse" then
			return nil
		end
		if code == "zh-cn" then return "ZH-HANS" end
		if code == "zh-tw" then return "ZH-HANT" end
		if code == "zh" then return target and "ZH-HANS" or "ZH" end
		if code == "iw" or code == "he" then return "HE" end
		if code == "no" then return "NB" end
		if code == "en" then return target and "EN-US" or "EN" end
		if code == "pt" then return target and "PT-BR" or "PT" end
		return code:upper()
	end

	const function fromDeepLLang(code)
		code = tostring(code or ""):lower()
		if code == "zh-hans" or code == "zh" then return "zh-cn" end
		if code == "zh-hant" then return "zh-tw" end
		if code == "nb" then return "no" end
		if code == "he" then return "he" end
		const base = code:match("^([a-z][a-z])[-_]")
		return base or code
	end

	const function translateDeepL(text, target, source)
		const key = getDeepLKey()
		if not key then
			return nil
		end

		const targetLang = deeplLang(target, true)
		if not targetLang then
			return nil
		end

		const sourceLang = deeplLang(source, false)
		const payload = {
			text = { text };
			target_lang = targetLang;
			model_type = "prefer_quality_optimized";
		}
		if sourceLang then
			payload.source_lang = sourceLang
		end

		const headers = {
			["Authorization"] = "DeepL-Auth-Key "..key;
			["Content-Type"] = "application/json";
		}
		const endpoints = getDeepLEndpoints(key)

		for i = 1, #endpoints do
			const url = endpoints[i].."/v2/translate"
			const body = jsonEncode(payload)
			local res = NAmanage.requestAsync({
				Url = url;
				Method = "POST";
				Headers = headers;
				Body = body;
			})

			if not httpOk(res) and httpCode(res) == 400 and payload.model_type ~= nil then
				const retryPayload = {}
				for k, v in payload do
					if k ~= "model_type" then
						retryPayload[k] = v
					end
				end
				res = NAmanage.requestAsync({
					Url = url;
					Method = "POST";
					Headers = headers;
					Body = jsonEncode(retryPayload);
				})
			end

			if httpOk(res) then
				const raw = res.Body or res.body or ""
				local ok, data = pcall(jsonDecode, raw)
				if ok and type(data) == "table" and type(data.translations) == "table" then
					const first = data.translations[1]
					if type(first) == "table" and type(first.text) == "string" and first.text ~= "" then
						return first.text, fromDeepLLang(first.detected_source_language or source or "auto")
					end
				end
			elseif httpCode(res) ~= 403 and httpCode(res) ~= 404 then
				break
			end
		end

		return nil
	end

	const function translateLibre(text, target, source)
		const endpoint = getLibreEndpoint()
		if not endpoint then
			return nil
		end

		local targetCode = NAmanage.iso2(target) or "en"
		local sourceCode = NAmanage.iso2(source) or "auto"
		if targetCode == "morse" then
			return nil
		end
		if targetCode == "zh-cn" then targetCode = "zh" end
		if targetCode == "zh-tw" then targetCode = "zt" end
		if sourceCode == "zh-cn" then sourceCode = "zh" end
		if sourceCode == "zh-tw" then sourceCode = "zt" end

		const payload = {
			q = text;
			source = sourceCode;
			target = targetCode;
			format = "text";
		}

		const key = getLibreKey()
		if key then
			payload.api_key = key
		end

		const res = NAmanage.requestAsync({
			Url = endpoint.."/translate";
			Method = "POST";
			Headers = { ["Content-Type"] = "application/json" };
			Body = jsonEncode(payload);
		})
		if not httpOk(res) then
			return nil
		end

		const raw = res.Body or res.body or ""
		local ok, data = pcall(jsonDecode, raw)
		if not ok or type(data) ~= "table" then
			return nil
		end

		const translated = data.translatedText or data.translation
		if type(translated) ~= "string" or translated == "" then
			return nil
		end

		local detected = sourceCode
		if type(data.detectedLanguage) == "table" then
			detected = data.detectedLanguage.language or data.detectedLanguage.lang or detected
		end
		return translated, detected
	end

	const function myMemoryLang(code)
		code = NAmanage.iso2(code) or tostring(code or ""):lower()
		if code == "" or code == "morse" or code == "auto" then
			return nil
		end
		if code == "zh-cn" then return "zh-CN" end
		if code == "zh-tw" then return "zh-TW" end
		if code == "iw" then return "he" end
		return code
	end

	const function hasCp(text, ranges)
		if type(utf8) ~= "table" or type(utf8.codes) ~= "function" then
			return false
		end
		local ok, hit = pcall(function()
			for _, cp in utf8.codes(text) do
				for i = 1, #ranges do
					const r = ranges[i]
					if cp >= r[1] and cp <= r[2] then
						return true
					end
				end
			end
			return false
		end)
		return ok and hit == true
	end

	const function hasAny(text, list)
		for i = 1, #list do
			if text:find(list[i], 1, true) then
				return true
			end
		end
		return false
	end

	const function hasWord(text, list)
		const padded = " "..text:gsub("[%p%c]", " ").." "
		for i = 1, #list do
			if padded:find(" "..list[i].." ", 1, true) then
				return true
			end
		end
		return false
	end

	const function guessMyMemorySource(text, targetCode)
		text = tostring(text or "")
		if text == "" then
			return nil
		end
		targetCode = tostring(targetCode or ""):lower()
		const low = text:lower()
		if hasCp(text, {{0x3040,0x30ff},{0x31f0,0x31ff}}) then return "ja" end
		if hasCp(text, {{0xac00,0xd7af},{0x1100,0x11ff},{0x3130,0x318f}}) then return "ko" end
		if hasCp(text, {{0x4e00,0x9fff},{0x3400,0x4dbf}}) then return "zh-CN" end
		if hasCp(text, {{0x0370,0x03ff}}) then return "el" end
		if hasCp(text, {{0x0590,0x05ff}}) then return "he" end
		if hasCp(text, {{0x0600,0x06ff},{0x0750,0x077f},{0x08a0,0x08ff}}) then return "ar" end
		if hasCp(text, {{0x0900,0x097f}}) then return "hi" end
		if hasCp(text, {{0x0e00,0x0e7f}}) then return "th" end
		if hasCp(text, {{0x0400,0x04ff},{0x0500,0x052f}}) then
			if hasAny(low, {"ъ", "щ", "ѝ"}) then
				return "bg"
			end
			if hasAny(low, {"і", "ї", "є", "ґ"}) then
				return "uk"
			end
			return "ru"
		end
		if hasAny(low, {"¿", "¡", "ñ"}) or hasWord(low, {"que", "los", "las", "una", "para", "pero", "estoy", "eres"}) then return "es" end
		if hasAny(low, {"ç", "ã", "õ"}) or hasWord(low, {"você", "obrigado", "obrigada", "não", "para"}) then return "pt" end
		if hasAny(low, {"à", "â", "ê", "ë", "î", "ï", "ô", "ù", "û", "œ", "æ"}) or hasWord(low, {"bonjour", "merci", "avec", "pour", "mais", "être"}) then return "fr" end
		if hasAny(low, {"ä", "ö", "ü", "ß"}) or hasWord(low, {"und", "ich", "nicht", "danke", "bitte", "mit"}) then return "de" end
		if hasAny(low, {"ą", "ć", "ę", "ł", "ń", "ś", "ź", "ż"}) then return "pl" end
		if hasAny(low, {"ğ", "ı", "ş"}) then return "tr" end
		if hasAny(low, {"ă", "ș", "ţ", "ț"}) then return "ro" end
		if hasAny(low, {"đ", "č", "ć", "š", "ž"}) then return "hr" end
		if targetCode ~= "en" then
			return "en"
		end
		if hasWord(low, {"the", "and", "you", "your", "are", "is", "not", "what", "that", "this", "have", "with", "from", "larp"}) or low:find("i'm", 1, true) then
			return "en"
		end
		return nil
	end

	const function translateMyMemory(text, target, source)
		const targetCode = myMemoryLang(target) or "en"
		const sourceCode = myMemoryLang(source) or guessMyMemorySource(text, targetCode)
		if targetCode == "morse" or not sourceCode then
			return nil
		end
		if tostring(sourceCode):lower() == tostring(targetCode):lower() then
			return nil
		end

		const pair = sourceCode.."|"..targetCode
		local url = "https://api.mymemory.translated.net/get?q="..Http:UrlEncode(text).."&langpair="..Http:UrlEncode(pair).."&mt=1"
		const email = getMyMemoryEmail()
		if email then
			url ..= "&de="..Http:UrlEncode(email)
		end
		const key = getMyMemoryKey()
		if key then
			url ..= "&key="..Http:UrlEncode(key)
		end

		const res = NAmanage.requestAsync({
			Url = url;
			Method = "GET";
		})
		if not httpOk(res) then
			return nil
		end

		const raw = res.Body or res.body or ""
		local ok, data = pcall(jsonDecode, raw)
		if not ok or type(data) ~= "table" then
			return nil
		end

		const status = tonumber(data.responseStatus or data.responseCode or data.status or data.code)
		const details = tostring(data.responseDetails or data.message or ""):lower()
		if (status and status >= 400) or details:find("invalid source language", 1, true) then
			return nil
		end

		local translated = nil
		local detected = sourceCode
		const responseData = data.responseData
		if type(responseData) == "table" then
			translated = responseData.translatedText or responseData.translation
			detected = responseData.detectedLanguage or responseData.detectedSourceLanguage or detected
		end

		if (type(translated) ~= "string" or translated == "") and type(data.matches) == "table" then
			local bestText = nil
			local bestScore = -1
			for _, item in data.matches do
				if type(item) == "table" and type(item.translation) == "string" and item.translation ~= "" then
					const score = tonumber(item.match) or 0
					if score > bestScore then
						bestScore = score
						bestText = item.translation
						detected = item.source or detected
					end
				end
			end
			translated = bestText
		end

		if type(translated) ~= "string" or translated == "" then
			return nil
		end

		const bad = translated:lower()
		if bad:find("invalid source language", 1, true) or bad:find("langpair=", 1, true) then
			return nil
		end

		return translated, detected
	end

	const function handleConsent(body)
		const tokens = {}
		for tag in body:gmatch('<input type="hidden" name=".-" value=".-">') do
			local k, v = tag:match('<input type="hidden" name="(.-)" value="(.-)">')
			if k and v then
				tokens[k] = v
			end
		end
		state.gv = tokens.v or state.gv or ""
		if writefile then
			pcall(writefile, "googlev.txt", state.gv)
		end
	end

	const function fetch(url, method, body)
		local res = NAmanage.requestAsync({
			Url = url;
			Method = method or "GET";
			Headers = { cookie = "CONSENT=YES+"..(state.gv or "") };
			Body = body;
		})
		if not res then
			return nil
		end
		local b = res.Body or res.body or ""
		if type(b) ~= "string" then
			b = tostring(b)
		end
		if b:find("https://consent.google.com/s") then
			handleConsent(b)
			res = NAmanage.requestAsync({
				Url = url;
				Method = "GET";
				Headers = { cookie = "CONSENT=YES+"..(state.gv or "") };
			})
			if not res then
				return nil
			end
		end
		return res
	end

	const function ensureSession()
		if state.fsid and state.bl then
			return true
		end
		const res = fetch(root)
		if not res then
			return false
		end
		local body = res.Body or res.body or ""
		if type(body) ~= "string" then
			body = tostring(body)
		end
		state.fsid = body:match('"FdrFJe":"(.-)"')
		state.bl = body:match('"cfb2h":"(.-)"')
		return state.fsid ~= nil and state.bl ~= nil
	end

	const function encodeQuery(data)
		local s = ""
		for k, v in data do
			if type(v) == "table" then
				for _, vv in v do
					s ..= "&"..Http:UrlEncode(k).."="..Http:UrlEncode(vv)
				end
			else
				s ..= "&"..Http:UrlEncode(k).."="..Http:UrlEncode(v)
			end
		end
		return s:sub(2)
	end

	const function translateGoogleLegacy(text, target, source)
		target = NAmanage.iso2(target) or "en"
		source = NAmanage.iso2(source) or "auto"

		const url = ("https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s")
			:format(Http:UrlEncode(source), Http:UrlEncode(target), Http:UrlEncode(text))
		local res = NAmanage.requestAsync({Url = url, Method = "GET"})
		local translated = nil
		local detected = nil

		if res then
			const body = res.Body or res.body or ""
			local ok, data = pcall(jsonDecode, body)
			if ok and type(data) == "table" then
				const segments = data[1]
				detected = data[3]
				const parts = {}
				if type(segments) == "table" then
					for _, seg in segments do
						if type(seg) == "table" and type(seg[1]) == "string" then
							Insert(parts, seg[1])
						end
					end
				end
				translated = Concat(parts, "")
				if translated == "" then
					translated = nil
				end
			end
		end

		if translated and translated ~= "" then
			return translated, detected
		end

		if not ensureSession() then
			return translated, detected
		end

		state.rid += 10000
		const data = { { text, source, target, true }, { nil } }
		const freq = { { { rpc, jsonEncode(data), nil, "generic" } } }
		const reqUrl = exec.."?"..encodeQuery({
			rpcids = rpc;
			["f.sid"] = state.fsid;
			bl = state.bl;
			hl = "en";
			_reqid = state.rid - 10000;
			rt = "c";
		})
		const body = encodeQuery({ ["f.req"] = jsonEncode(freq) })
		res = fetch(reqUrl, "POST", body)
		if not res then
			return translated, detected
		end

		local raw = res.Body or res.body or ""
		if type(raw) ~= "string" then
			raw = tostring(raw)
		end
		local ok, parsed = pcall(function()
			const arr = jsonDecode(raw:match("%[.-%]\n"))
			return jsonDecode(arr[1][3])
		end)
		if not ok or type(parsed) ~= "table" then
			return translated, detected
		end

		local fallTranslated = nil
		pcall(function()
			fallTranslated = parsed[2][1][1][6][1][1]
		end)
		if type(fallTranslated) ~= "string" or fallTranslated == "" then
			return translated, detected
		end
		return fallTranslated, parsed[3] or detected
	end

	const function cachePut(key, translated, detected)
		local cache = translator._cache
		if type(cache) ~= "table" then
			cache = {}
			translator._cache = cache
		end
		cache[key] = {
			text = translated;
			detected = detected;
		}

		local order = translator._cacheOrder
		if type(order) ~= "table" then
			order = {}
			translator._cacheOrder = order
		end
		order[#order + 1] = key
		if #order > 300 then
			const old = table.remove(order, 1)
			if old then
				cache[old] = nil
			end
		end
	end

	const function cacheGet(key)
		const cache = translator._cache
		const item = type(cache) == "table" and cache[key] or nil
		if type(item) == "table" and type(item.text) == "string" then
			return item.text, item.detected
		end
		return nil
	end

	const function translatePayload(text, target, source)
		if not text or text == "" then
			return nil
		end

		const targetCode = NAmanage.iso2(target) or "en"
		local sourceCode = NAmanage.iso2(source) or "auto"

		if targetCode == "morse" then
			return encodeMorse(text), "morse"
		end

		const isMorseMsg = isLikelyMorse(text)
		if sourceCode == "morse" or isMorseMsg then
			const decoded = decodeMorse(text)
			if not decoded or decoded == "" then
				return nil
			end
			if targetCode == "auto" or targetCode == nil or targetCode == "en" then
				return decoded, "morse"
			end
			text = decoded
			sourceCode = "auto"
		end

		const provider = getProvider()
		const list = {}
		if provider == "mymemory" then
			list[#list + 1] = "mymemory"
			list[#list + 1] = "libre"
			list[#list + 1] = "deepl"
		elseif provider == "libre" then
			list[#list + 1] = "libre"
			list[#list + 1] = "mymemory"
			list[#list + 1] = "deepl"
		elseif provider == "deepl" then
			list[#list + 1] = "deepl"
			list[#list + 1] = "mymemory"
			list[#list + 1] = "libre"
		elseif provider == "google" then
			list[#list + 1] = "google"
		else
			list[#list + 1] = "mymemory"
			list[#list + 1] = "libre"
			list[#list + 1] = "deepl"
		end

		const googleFallback = cfgBool(cfgValue("NATranslateFallbackGoogle", "translateFallbackGoogle", "translatorFallbackGoogle"), opt.translateFallbackGoogle == true)
		if googleFallback and provider ~= "google" then
			list[#list + 1] = "google"
		end

		for i = 1, #list do
			const name = list[i]
			const cacheKey = name.."|"..sourceCode.."|"..targetCode.."|"..text
			local cached, cachedDetected = cacheGet(cacheKey)
			if cached then
				return cached, cachedDetected
			end

			local translated, detected
			if name == "mymemory" then
				translated, detected = translateMyMemory(text, targetCode, sourceCode)
			elseif name == "deepl" then
				translated, detected = translateDeepL(text, targetCode, sourceCode)
			elseif name == "libre" then
				translated, detected = translateLibre(text, targetCode, sourceCode)
			elseif name == "google" then
				translated, detected = translateGoogleLegacy(text, targetCode, sourceCode)
			end
			if type(translated) == "string" and translated ~= "" then
				cachePut(cacheKey, translated, detected)
				return translated, detected
			end
		end

		return nil
	end

	const function resizeLabel(label)
		if not (label and label.Parent and NAgui and NAgui.txtSize) then
			return
		end
		local ok, size = pcall(NAgui.txtSize, label, label.AbsoluteSize.X, 200)
		if ok and size then
			label.Size = UDim2.new(1, -5, 0, size.Y)
		end
	end

	const function normalizeRichTextEntities(text)
		text = tostring(text or "")
		if text == "" then
			return text
		end
		text = text:gsub("&amp;lt;", "&lt;")
		text = text:gsub("&amp;gt;", "&gt;")
		text = text:gsub("&amp;quot;", "&quot;")
		text = text:gsub("&amp;apos;", "&apos;")
		text = text:gsub("&amp;amp;", "&amp;")
		return text
	end

	const function escapeForRichText(text)
		const raw = tostring(text or "")
		const safe = originalIO.escapeRichTextText and originalIO.escapeRichTextText(raw) or raw
		return normalizeRichTextEntities(safe)
	end

	function translator:isEnabled()
		return self.enabled == true
	end

	function translator:updateUI()
		local controls = self._controlPairs
		if type(controls) == "table" then
			for _, pair in pairs(controls) do
				if type(pair) == "table" then
					if pair.button and not pair.button.Parent then
						pair.buttonConn = NAmanage.tryDisconnect(pair.buttonConn)
						pair.button = nil
					end
					if pair.button then
						if self:isEnabled() then
							pair.button.Text = "TR: "..string.upper(self.chatTarget or "EN")
							pair.button.BackgroundColor3 = Color3.fromRGB(68, 108, 68)
							pair.button.TextColor3 = Color3.fromRGB(234, 234, 244)
						else
							pair.button.Text = "TR: OFF"
							pair.button.BackgroundColor3 = Color3.fromRGB(54, 54, 64)
							pair.button.TextColor3 = Color3.fromRGB(178, 178, 188)
						end
					end
					if pair.input and not pair.input.Parent then
						pair.inputConn = NAmanage.tryDisconnect(pair.inputConn)
						pair.input = nil
					end
					if pair.input and not pair.input:IsFocused() then
						pair.input.Text = string.upper(self.chatTarget or "EN")
					end
				end
			end
		end

		local legacy = controls and controls.chatLogs
		if legacy then
			self.button = legacy.button
			self.input = legacy.input
			self._buttonConn = legacy.buttonConn
			self._inputConn = legacy.inputConn
		end
	end

	function translator:updateAllMessages()
		for label, info in self.messages do
			if self:isEnabled() then
				self:ensureTranslation(label, info)
			end
			self:applyDisplay(label, info)
		end
	end

	function translator:setEnabled(state)
		const newState = state and true or false
		if self.enabled == newState then
			self.enabled = newState
			self:updateUI()
			return
		end
		self.enabled = newState
		opt.chatTranslateEnabled = newState
		pcall(NAmanage.NASettingsSet, "chatTranslate", newState)
		self:updateUI()
		self:updateAllMessages()
	end

	function translator:toggle()
		self:setEnabled(not self:isEnabled())
		return self.enabled
	end

	function translator:applyDisplay(label, info)
		if not (label and info) then return end
		if not (label and label.Parent) then
			if self.messages[label] == info then
				self.messages[label] = nil
			end
			return
		end
		local text = normalizeRichTextEntities(info.base or "")
		if self:isEnabled() and info.translationLine and info.target == self.chatTarget then
			text = text.."\n"..normalizeRichTextEntities(info.translationLine)
		end
		label.Text = text
		resizeLabel(label)
		if type(info.onDisplay) == "function" then
			pcall(info.onDisplay, label, info)
		end
	end

	function translator:ensureTranslation(label, info)
		if not (label and info) or info.translating then
			return
		end
		if info.translationLine and info.target == self.chatTarget then
			return
		end
		if not info.message or info.message == "" then
			return
		end
		info.revision = tonumber(info.revision) or 0
		local requestRevision = info.revision
		local requestTarget = self.chatTarget
		info.translating = true
		info.translatingRevision = requestRevision
		info.target = requestTarget
		Spawn(function()
			local ok, translated, detected = pcall(translatePayload, info.message, requestTarget, "auto")
			if info.revision ~= requestRevision or info.target ~= requestTarget then
				return
			end
			info.translating = false
			info.translatingRevision = nil
			local function applyActive()
				local activeLabel = info.boundLabel or label
				if activeLabel and self.messages[activeLabel] == info then
					self:applyDisplay(activeLabel, info)
				end
			end
			if not ok then
				info.translationLine = nil
				applyActive()
				return
			end
			if not translated or translated == "" then
				info.translationLine = nil
				applyActive()
				return
			end
			const code = NAmanage.iso2(detected) or detected or "AUTO"
			const tag = tostring(code):upper()
			info.translationLine = ("[%s] %s"):format((requestTarget or "en"):upper(), escapeForRichText(translated))
			info.detected = tag
			applyActive()
		end)
	end

	function translator:registerMessage(label, baseText, rawMessage, persistentInfo)
		if not label then return nil end
		local existing = self.messages[label]
		local info = type(persistentInfo) == "table" and persistentInfo or existing
		local isNew = type(info) ~= "table"
		if isNew then
			info = {
				base = baseText or "";
				message = rawMessage or "";
				translationLine = nil;
				translating = false;
				translatingRevision = nil;
				target = nil;
				revision = 0;
			}
		end

		local nextBase = baseText or info.base or ""
		local nextMessage = rawMessage or info.message or ""
		local changed = not isNew and (info.base ~= nextBase or info.message ~= nextMessage)
		if changed then
			info.revision = (tonumber(info.revision) or 0) + 1
			info.translationLine = nil
			info.translating = false
			info.translatingRevision = nil
			info.target = nil
		end
		info.base = nextBase
		info.message = nextMessage
		info.revision = tonumber(info.revision) or 0
		local previousLabel = info.boundLabel
		if previousLabel and previousLabel ~= label and self.messages[previousLabel] == info then
			self.messages[previousLabel] = nil
		end
		info.boundLabel = label
		self.messages[label] = info

		if existing == nil then
			if label.Destroying then
				label.Destroying:Connect(function()
					if self.messages[label] == info then
						self.messages[label] = nil
					end
				end)
			end
			label.AncestryChanged:Connect(function(_, parent)
				if not parent and self.messages[label] == info then
					self.messages[label] = nil
				end
			end)
		end

		self:applyDisplay(label, info)
		self:ensureTranslation(label, info)
		return info
	end

	function translator:setChatTarget(lang)
		const code = NAmanage.iso2(lang)
		if not code then
			return false
		end
		if self.chatTarget == code then
			self:updateUI()
			if self.updateSettingsUI then
				self:updateSettingsUI()
			end
			return true, code, originalIO.languageName(code)
		end
		self.chatTarget = code
		self.target = code
		opt.chatTranslateTarget = code
		pcall(NAmanage.NASettingsSet, "chatTranslateTarget", code)
		for label, info in self.messages do
			info.revision = (tonumber(info.revision) or 0) + 1
			info.translationLine = nil
			info.target = nil
			info.translating = false
			info.translatingRevision = nil
			self:applyDisplay(label, info)
			self:ensureTranslation(label, info)
		end
		self:updateUI()
		if self.updateSettingsUI then
			self:updateSettingsUI()
		end
		return true, code, originalIO.languageName(code)
	end

	function translator:setSettingsTarget(lang)
		const code = NAmanage.iso2(lang)
		if not code then
			return false
		end
		if self.settingsTarget == code then
			self:updateSettingsUI()
			return true, code, originalIO.languageName(code)
		end
		self.settingsTarget = code
		opt.settingsTranslateTarget = code
		pcall(NAmanage.NASettingsSet, "settingsTranslateTarget", code)
		self:updateSettingsUI()
		return true, code, originalIO.languageName(code)
	end

	function translator:setTarget(lang)
		return self:setChatTarget(lang)
	end

	const function sanitizeUiText(text)
		text = tostring(text or "")
		text = text:match("^%s*(.-)%s*$") or ""
		return text
	end

	const function shouldTranslateUiText(text)
		const cleaned = sanitizeUiText(text)
		if cleaned == "" then
			return false, cleaned
		end
		if not cleaned:match("[%a]") then
			return false, cleaned
		end
		return true, cleaned
	end

	const function cacheOriginalText(inst, attrName, text)
		if not (inst and attrName and type(text) == "string") then
			return
		end
		pcall(function()
			local existing = nil
			if NAmanage and NAmanage.GetAttr then
				existing = NAmanage.GetAttr(inst, attrName)
			else
				existing = inst:GetAttribute(attrName)
			end
			if existing == nil then
				NAmanage.SetAttr(inst, attrName, text)
			end
		end)
	end

	const function usesBuilderIconFont(inst)
		local family = nil
		pcall(function()
			if inst and inst.FontFace then
				family = inst.FontFace.Family
			end
		end)
		return type(family) == "string" and family:find("BuilderIcons/BuilderIcons.json", 1, true) ~= nil
	end

	const function isRichTextEnabled(inst)
		local rich = false
		pcall(function()
			rich = inst and inst.RichText == true
		end)
		return rich
	end

	const function getElementAttr(inst, attrName)
		if not (inst and attrName) then
			return nil
		end
		local out = nil
		pcall(function()
			if NAmanage and NAmanage.GetAttr then
				out = NAmanage.GetAttr(inst, attrName)
			else
				out = inst:GetAttribute(attrName)
			end
		end)
		return out
	end

	const function findTaggedSettingsAncestor(inst, root)
		local current = inst
		while current and current ~= root do
			const tabName = getElementAttr(current, "NAOriginalTab")
			if type(tabName) == "string" and tabName ~= "" then
				return current, tabName
			end
			current = current.Parent
		end
		return nil, nil
	end

	const BUILDER_ICON_MARKER = "BuilderIcons/BuilderIcons.json"

	const function parseRichTextTokens(rawText)
		const tokens = {}
		const text = tostring(rawText or "")
		if text == "" then
			return tokens
		end

		local i = 1
		const length = #text
		const fontStack = {}
		local builderDepth = 0

		while i <= length do
			const lt = Find(text, "<", i, true)
			if not lt then
				Insert(tokens, {
					kind = "text";
					value = text:sub(i);
					inBuilder = builderDepth > 0;
				})
				break
			end

			if lt > i then
				Insert(tokens, {
					kind = "text";
					value = text:sub(i, lt - 1);
					inBuilder = builderDepth > 0;
				})
			end

			const gt = Find(text, ">", lt + 1, true)
			if not gt then
				Insert(tokens, {
					kind = "text";
					value = text:sub(lt);
					inBuilder = builderDepth > 0;
				})
				break
			end

			const tag = text:sub(lt, gt)
			Insert(tokens, {
				kind = "tag";
				value = tag;
			})

			const inner = text:sub(lt + 1, gt - 1)
			const trimmed = inner:match("^%s*(.-)%s*$") or ""
			const isClosing = trimmed:sub(1, 1) == "/"
			const isSelfClosing = (not isClosing) and trimmed:sub(-1) == "/"
			local tagName = nil

			if isClosing then
				tagName = (trimmed:match("^/%s*([%w]+)") or ""):lower()
			else
				tagName = (trimmed:match("^([%w]+)") or ""):lower()
			end

			if tagName == "font" then
				if isClosing then
					const popped = table.remove(fontStack)
					if popped then
						builderDepth = math.max(0, builderDepth - 1)
					end
				elseif not isSelfClosing then
					const family = trimmed:match("[Ff][Aa][Mm][Ii][Ll][Yy]%s*=%s*\"([^\"]+)\"")
						or trimmed:match("[Ff][Aa][Mm][Ii][Ll][Yy]%s*=%s*'([^']+)'")
					const isBuilder = type(family) == "string" and family:find(BUILDER_ICON_MARKER, 1, true) ~= nil
					Insert(fontStack, isBuilder)
					if isBuilder then
						builderDepth += 1
					end
				end
			end

			i = gt + 1
		end

		return tokens
	end

	function translator:updateSettingsUI()
		if self.settingsInput then
			if not self.settingsInput.Parent then
				self.settingsInput = nil
			elseif not self.settingsInput:IsFocused() then
				self.settingsInput.Text = string.upper(self.settingsTarget or "EN")
			end
		end

		if self.settingsButton then
			if not self.settingsButton.Parent then
				self.settingsButton = nil
			else
				self.settingsButton.Text = "Translate"
			end
		end
	end

	function translator:translateText(text, target, source)
		local canTranslate, cleaned = shouldTranslateUiText(text)
		if not canTranslate then
			return nil
		end
		return translatePayload(cleaned, target or self.settingsTarget or self.chatTarget or "en", source or "auto")
	end

	function translator:translateSettingsFrame(root, lang)
		if not (root and root.Parent) then
			return
		end
		const targetCode = NAmanage.iso2(lang) or self.settingsTarget or self.chatTarget or "en"
		const items = {}
		const richItems = {}
		const fflagNameMap = {}
		const tabButtonMap = {}
		do
			const fflags = NAmanage and NAmanage.NAFFlags
			const whitelist = fflags and fflags.whitelist
			if type(whitelist) == "table" then
				for _, entry in whitelist do
					local entryName = nil
					if type(entry) == "table" then
						entryName = entry.name or entry.flag or entry[1]
					end
					if type(entryName) == "string" and entryName ~= "" then
						fflagNameMap[entryName] = true
						fflagNameMap[Lower(entryName)] = true
					end
				end
			end
		end
		do
			const tabs = TabManager and TabManager.tabs
			if type(tabs) == "table" then
				for _, info in tabs do
					if info and info.button then
						tabButtonMap[info.button] = info
					end
				end
			end
		end

		const function findTabInfoForDescendant(inst)
			local current = inst
			while current and current ~= root do
				const info = tabButtonMap[current]
				if info then
					return info
				end
				current = current.Parent
			end
			return nil
		end

		for _, obj in NAmanage.QueryDescendants(root, "Instance") do
			local _, rowTab = findTaggedSettingsAncestor(obj, root)
			const isFflagsRow = rowTab == (NA_TABS and NA_TABS.TAB_FFLAGS or "FFlags")

			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				if obj.Name ~= "Translate" then
					const tabInfo = findTabInfoForDescendant(obj)
					const isTabTitle = tabInfo ~= nil and obj:IsA("TextLabel") and obj.Name == "Title"
					if isTabTitle then
						const baseTabTitle = tostring(tabInfo.displayName or tabInfo.name or "")
						local okTabTitle, normalizedTabTitle = shouldTranslateUiText(baseTabTitle)
						if okTabTitle then
							Insert(items, {
								inst = obj;
								prop = "Text";
								source = normalizedTabTitle;
								tabInfo = tabInfo;
							})
						end
						continue
					end

					const objectUsesBuilderFont = usesBuilderIconFont(obj)
					const richEnabled = isRichTextEnabled(obj)
					local originalText = (NAmanage.GetAttr and NAmanage.GetAttr(obj, "NAOriginalText")) or obj:GetAttribute("NAOriginalText")
					if type(originalText) ~= "string" or originalText == "" then
						originalText = tostring(obj.Text or "")
						if originalText ~= "" then
							cacheOriginalText(obj, "NAOriginalText", originalText)
						end
					end
					local skipWhitelistedFflag = false
					if isFflagsRow and type(originalText) == "string" and originalText ~= "" then
						const normalizedOriginal = sanitizeUiText(originalText)
						if normalizedOriginal ~= "" then
							skipWhitelistedFflag = fflagNameMap[normalizedOriginal] == true
								or fflagNameMap[Lower(normalizedOriginal)] == true
						end
					end
					const hasRichTags = type(originalText) == "string"
						and Find(originalText, "<", 1, true) ~= nil
						and Find(originalText, ">", 1, true) ~= nil
					if skipWhitelistedFflag then
						if type(originalText) == "string" and originalText ~= "" and obj.Text ~= originalText then
							pcall(function()
								obj.Text = originalText
							end)
						end
					elseif richEnabled and hasRichTags then
						Insert(richItems, {
							inst = obj;
							prop = "Text";
							source = originalText;
						})
					elseif objectUsesBuilderFont then
						if type(originalText) == "string" and originalText ~= "" and obj.Text ~= originalText then
							pcall(function()
								obj.Text = originalText
							end)
						end
					else
						local okText, normalizedText = shouldTranslateUiText(originalText)
						if okText then
							Insert(items, {
								inst = obj;
								prop = "Text";
								source = normalizedText;
							})
						end
					end
				end
			elseif obj:IsA("TextBox") then
				if obj.Name ~= "TranslateInput" then
					local originalPlaceholder = (NAmanage.GetAttr and NAmanage.GetAttr(obj, "NAOriginalPlaceholder")) or obj:GetAttribute("NAOriginalPlaceholder")
					if type(originalPlaceholder) ~= "string" or originalPlaceholder == "" then
						originalPlaceholder = tostring(obj.PlaceholderText or "")
						if originalPlaceholder ~= "" then
							cacheOriginalText(obj, "NAOriginalPlaceholder", originalPlaceholder)
						end
					end
					local skipWhitelistedFflagPlaceholder = false
					if isFflagsRow and type(originalPlaceholder) == "string" and originalPlaceholder ~= "" then
						const normalizedPlaceholder = sanitizeUiText(originalPlaceholder)
						if normalizedPlaceholder ~= "" then
							skipWhitelistedFflagPlaceholder = fflagNameMap[normalizedPlaceholder] == true
								or fflagNameMap[Lower(normalizedPlaceholder)] == true
						end
					end
					if skipWhitelistedFflagPlaceholder then
						if type(originalPlaceholder) == "string" and originalPlaceholder ~= "" and obj.PlaceholderText ~= originalPlaceholder then
							pcall(function()
								obj.PlaceholderText = originalPlaceholder
							end)
						end
					else
						local okPlaceholder, normalizedPlaceholder = shouldTranslateUiText(originalPlaceholder)
						if okPlaceholder then
							Insert(items, {
								inst = obj;
								prop = "PlaceholderText";
								source = normalizedPlaceholder;
							})
						end
					end
				end
			end
		end

		if #items == 0 and #richItems == 0 then
			DoNotif("No translatable settings text was found.", 1.75)
			return
		end

		self._settingsTranslateJob = (self._settingsTranslateJob or 0) + 1
		const jobId = self._settingsTranslateJob

		Spawn(function()
			const translateCache = self._settingsTranslateCache or {}
			self._settingsTranslateCache = translateCache
			const targetCache = translateCache[targetCode] or {}
			translateCache[targetCode] = targetCache

			const function getOrTranslate(sourceText)
				if type(sourceText) ~= "string" or sourceText == "" then
					return nil
				end
				const cached = targetCache[sourceText]
				if type(cached) == "string" and cached ~= "" then
					return cached
				end
				if cached == false then
					return nil
				end

				local ok, result = pcall(function()
					return self:translateText(sourceText, targetCode, "auto")
				end)
				if ok and type(result) == "string" and result ~= "" then
					targetCache[sourceText] = result
					return result
				end
				targetCache[sourceText] = false
				return nil
			end

			const sourceTargets = {}
			for _, item in items do
				local list = sourceTargets[item.source]
				if not list then
					list = {}
					sourceTargets[item.source] = list
				end
				Insert(list, item)
			end

			const sourceList = {}
			for sourceText in sourceTargets do
				Insert(sourceList, sourceText)
			end
			table.sort(sourceList)

			local nextIndex = 1
			local activeWorkers = 0
			local workerCount = math.clamp(math.floor(#sourceList / 10), 2, 7)
			if #sourceList < 2 then
				workerCount = 1
			end

			for _ = 1, workerCount do
				activeWorkers += 1
				Spawn(function()
					while true do
						if self._settingsTranslateJob ~= jobId then
							break
						end
						const i = nextIndex
						if i > #sourceList then
							break
						end
						nextIndex += 1

						const sourceText = sourceList[i]
						const translated = getOrTranslate(sourceText)
						const targets = sourceTargets[sourceText]
						if targets then
							for _, item in targets do
								if self._settingsTranslateJob ~= jobId then
									break
								end
								if item.inst and item.inst.Parent then
									if type(translated) == "string" and translated ~= "" then
										const okApply = pcall(function()
											if item.tabInfo then
												item.tabInfo.localizedDisplay = item.tabInfo.localizedDisplay or {}
												item.tabInfo.localizedDisplay[targetCode] = translated
												if originalIO and originalIO.applyTabDisplayText then
													originalIO.applyTabDisplayText(item.tabInfo, {
														isActive = item.tabInfo._isActive;
														defaultColor = NAUISTROKER or DEFAULT_UI_STROKE_COLOR;
													})
												else
													item.inst[item.prop] = translated
												end
											else
												item.inst[item.prop] = translated
											end
										end)
										item._ok = okApply and true or false
										if not okApply then
											item._failed = true
										end
									else
										item._failed = true
									end
								else
									item._failed = true
								end
							end
						end
					end
					activeWorkers -= 1
				end)
			end

			while activeWorkers > 0 do
				if self._settingsTranslateJob ~= jobId then
					return
				end
				Wait()
			end

			const function translateRichTextOutsideBuilder(sourceText)
				const tokens = parseRichTextTokens(sourceText)
				if #tokens == 0 then
					return nil, false, false
				end

				local changed = false
				local hadCandidate = false
				for _, token in tokens do
					if token.kind == "text" and token.inBuilder ~= true then
						const segment = tostring(token.value or "")
						const lead = segment:match("^(%s*)") or ""
						const trail = segment:match("(%s*)$") or ""
						const core = segment:match("^%s*(.-)%s*$") or ""
						local canTranslate, normalizedCore = shouldTranslateUiText(core)
						if canTranslate then
							hadCandidate = true
							local translatedCore = getOrTranslate(normalizedCore)
							if type(translatedCore) == "string" and translatedCore ~= "" then
								if originalIO and type(originalIO.escapeRichTextText) == "function" then
									translatedCore = originalIO.escapeRichTextText(translatedCore)
								end
								const updated = lead..translatedCore..trail
								if updated ~= segment then
									token.value = updated
									changed = true
								end
							else
								token._failed = true
							end
						end
					end
				end

				const rebuilt = {}
				for _, token in tokens do
					Insert(rebuilt, tostring(token.value or ""))
				end

				return Concat(rebuilt, ""), changed, hadCandidate
			end

			for index, item in richItems do
				if self._settingsTranslateJob ~= jobId then
					return
				end
				if item.inst and item.inst.Parent and type(item.source) == "string" then
					local translatedRich, changed, hadCandidate = translateRichTextOutsideBuilder(item.source)
					if changed and type(translatedRich) == "string" and translatedRich ~= "" then
						pcall(function()
							item.inst[item.prop] = translatedRich
						end)
						item._ok = true
					else
						item._failed = hadCandidate == true
					end
				else
					item._failed = true
				end
				if index % 8 == 0 then
					Wait()
				end
			end

			local translatedCount = 0
			local failedCount = 0
			for _, item in items do
				if item._ok then
					translatedCount += 1
				elseif item._failed then
					failedCount += 1
				end
			end
			for _, item in richItems do
				if item._ok then
					translatedCount += 1
				elseif item._failed then
					failedCount += 1
				end
			end

			const totalItems = #items + #richItems
			if self._settingsTranslateJob == jobId then
				DoNotif(("Settings translated to %s (%d/%d)."):format(string.upper(targetCode), translatedCount, totalItems), 2.5)
				if failedCount > 0 then
					DebugNotif(("Settings translation skipped/failed for %d item(s)."):format(failedCount), 2)
				end
			end
		end)
	end

	function translator:attachSettingsControls(button, input, root)
		if not root then
			return
		end
		self.settingsRoot = root

		if button and self.settingsButton ~= button then
			self._settingsButtonConn = NAmanage.tryDisconnect(self._settingsButtonConn)
			self.settingsButton = button
			self._settingsButtonConn = MouseButtonFix(button, function()
				local langText = self.settingsInput and self.settingsInput.Text or ""
				langText = langText:match("^%s*(.-)%s*$") or ""
				if langText == "" then
					langText = self.settingsTarget or "en"
				end

				local ok, code, name = self:setSettingsTarget(langText)
				if not ok then
					DoNotif("Invalid language code. Example: en, bg, ja", 1.5)
					self:updateSettingsUI()
					return
				end
				DoNotif(("Translating settings to %s (%s)..."):format(code:upper(), name), 1.5)
				self:translateSettingsFrame(self.settingsRoot or root, code)
				self:updateSettingsUI()
			end)
		end

		if input and self.settingsInput ~= input then
			if self._settingsInputConn then
				self._settingsInputConn:Disconnect()
				self._settingsInputConn = nil
			end
			self.settingsInput = input
			input.PlaceholderText = "Lang"
			input.ClearTextOnFocus = false
			self._settingsInputConn = input.FocusLost:Connect(function(enterPressed)
				local text = input.Text or ""
				text = text:match("^%s*(.-)%s*$") or ""
				if text == "" then
					self:updateSettingsUI()
					return
				end
				local ok, code, name = self:setSettingsTarget(text)
				if not ok then
					DoNotif("Invalid language code. Example: en, bg, ja", 1.5)
				else
					DoNotif(("Settings translator target set to %s (%s)"):format(code:upper(), name), 1.5)
				end
				self:updateSettingsUI()
				if enterPressed then
					input:ReleaseFocus()
				end
			end)
		end

		self:updateSettingsUI()
	end

	function translator:attachControls(button, input, key)
		key = key or "chatLogs"
		self._controlPairs = type(self._controlPairs) == "table" and self._controlPairs or {}
		local pair = self._controlPairs[key] or {}
		self._controlPairs[key] = pair

		if button and pair.button ~= button then
			pair.buttonConn = NAmanage.tryDisconnect(pair.buttonConn)
			pair.button = button
			pair.buttonConn = MouseButtonFix(button, function()
				const nowEnabled = self:toggle()
				self:updateUI()
				DebugNotif("Chat translation "..(nowEnabled and "enabled" or "disabled"), 2)
			end)
		end
		if input and pair.input ~= input then
			pair.inputConn = NAmanage.tryDisconnect(pair.inputConn)
			pair.input = input
			input.PlaceholderText = "Lang"
			input.ClearTextOnFocus = false
			pair.inputConn = input.FocusLost:Connect(function(enterPressed)
				local text = input.Text or ""
				text = text:match("^%s*(.-)%s*$") or ""
				if text == "" then
					self:updateUI()
					return
				end
				local ok, code, name = self:setChatTarget(text)
				if not ok then
					DoNotif("Invalid language code. Example: en, bg, ja", 1.5)
				else
					DoNotif(("Chat translator target set to %s (%s)"):format(code:upper(), name), 1.5)
				end
				self:updateUI()
				if enterPressed then
					input:ReleaseFocus()
				end
			end)
		end
		if key == "chatLogs" then
			self.button = pair.button
			self.input = pair.input
			self._buttonConn = pair.buttonConn
			self._inputConn = pair.inputConn
		end
		self:updateUI()
	end

	function translator:tryAttach()
		const chatFrame = NAUIMANAGER and NAUIMANAGER.chatLogsFrame
		if chatFrame then
			const button = chatFrame:FindFirstChild("Translate", true)
			const input = chatFrame:FindFirstChild("TranslateInput", true)
			if button or input then
				self:attachControls(button, input, "chatLogs")
			end
		end

		const naChatFrame = NAUIMANAGER and NAUIMANAGER.NAchatFrame
		if naChatFrame then
			const button = (NAUIMANAGER and NAUIMANAGER.NAchatTranslateButton) or naChatFrame:FindFirstChild("NAChatTranslate", true)
			const input = (NAUIMANAGER and NAUIMANAGER.NAchatTranslateInput) or naChatFrame:FindFirstChild("NAChatTranslateInput", true)
			if button or input then
				self:attachControls(button, input, "naChat")
			end
		end

		const settingsFrame = NAUIMANAGER and NAUIMANAGER.SettingsFrame
		if settingsFrame then
			const settingsButton = settingsFrame:FindFirstChild("Translate", true)
			const settingsInput = settingsFrame:FindFirstChild("TranslateInput", true)
			if settingsButton or settingsInput then
				self:attachSettingsControls(settingsButton, settingsInput, settingsFrame)
			end
		end
	end

	function translator:showLanguages()
		const entries = {}
		for code, name in languages do
			if code ~= "auto" then
				Insert(entries, { code, name })
			end
		end
		table.sort(entries, function(a, b)
			return a[1] < b[1]
		end)
		const lines = {}
		for _, info in entries do
			Insert(lines, info[1]:upper().." - "..info[2])
		end
		const text = Concat(lines, "\n")
		if typeof(DoWindow) == "function" then
			DoWindow("Supported chat translator languages:\n\n"..text)
		else
			print("[ChatTranslator languages]\n"..text)
			DoNotif("Supported languages printed to console output.", 4)
		end
	end

	translator:tryAttach()
	const function onTranslatorDesc(inst)
		if inst and (inst.Name == "Translate" or inst.Name == "TranslateInput" or inst.Name == "NAChatTranslate" or inst.Name == "NAChatTranslateInput") then
			Defer(function()
				translator:tryAttach()
			end)
		end
	end
	if NAlib and NAlib.connect and NAlib.disconnect then
		NAlib.disconnect("chat_translator_watch")
		if NAStuff.NASCREENGUI then
			NAlib.connect("chat_translator_watch", NAmanage.descSub(NAStuff.NASCREENGUI, {
				added = onTranslatorDesc,
				filterAdded = function(inst)
					return inst and (inst.Name == "Translate" or inst.Name == "TranslateInput" or inst.Name == "NAChatTranslate" or inst.Name == "NAChatTranslateInput")
				end,
			}))
			NAlib.connect("chat_translator_watch", NAStuff.NASCREENGUI.AncestryChanged:Connect(function(_, parent)
				if not parent then
					NAlib.disconnect("chat_translator_watch")
				end
			end))
		end
	elseif NAStuff.NASCREENGUI and not translator._hookedWatcher then
		translator._hookedWatcher = true
		if translator._watchConn and translator._watchConn.Connected then
			translator._watchConn:Disconnect()
		end
		translator._watchConn = NAmanage.descSub(NAStuff.NASCREENGUI, {
			added = onTranslatorDesc,
			filterAdded = function(inst)
				return inst and (inst.Name == "Translate" or inst.Name == "TranslateInput" or inst.Name == "NAChatTranslate" or inst.Name == "NAChatTranslateInput")
			end,
		})
	end
	translator:updateUI()
end
originalIO.naTransLatooor()

NAmanage.CommandKeybindsAdd=function()
	const UIS = Services.UserInputService
	if not UIS then return end
	local listening = true
	local bindConn
	DoNotif("Press a key, key combo, or click combo to bind to a command...", 3)
	NAStuff._capturingCommandKeybind = true
	bindConn = UIS.InputBegan:Connect(function(input, gameProcessed)
		if not listening then return end
		if gameProcessed and input and input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		const keyName = NAmanage.CKBBind(input, UIS)
		if not keyName then
			return
		end
		listening = false
		if bindConn then bindConn:Disconnect() bindConn = nil end
		Defer(function()
			NAStuff._capturingCommandKeybind = false
		end)
		Window({
			Title = "Command Keybind",
			Description = "Enter a command to run when "..keyName.." is pressed.",
			InputField = true,
			Buttons = {{
				Text = "Save",
				Callback = function(text)
					const raw = tostring(text or ""):match("^%s*(.-)%s*$")
					if raw == "" then
						DoNotif("Command cannot be empty.", 2)
						return
					end
					const args = ParseArguments(raw) or {}
					if #args == 0 then
						DoNotif("Command could not be parsed.", 2)
						return
					end
					CommandKeybinds[keyName] = args
					NAmanage.SaveCommandKeybinds()
					NAmanage.ApplyCommandKeybinds()
					DoNotif(("Bound %s to '%s'"):format(keyName, raw), 2)
				end
			}}
		})
	end)
	Spawn(function()
		Wait(5)
		if listening then
			listening = false
			if bindConn then bindConn:Disconnect() bindConn = nil end
			if NAStuff._capturingCommandKeybind then
				NAStuff._capturingCommandKeybind = false
				DoNotif("Command keybind capture timed out.", 2)
			end
		end
	end)
end

NAmanage.CommandKeybindsRemove=function()
	if type(CommandKeybinds) ~= "table" or not next(CommandKeybinds) then
		DoNotif("No command keybinds to remove.", 2)
		return
	end
	const buttons = {}
	for keyName, args in CommandKeybinds do
		local label = (type(args) == "table" and #args > 0) and Concat(args, " ") or ""
		const opt = CommandKeybindOptions[keyName]
		if opt and opt.spam then
			const spamTag = opt.hold and "[spam hold]" or "[spam]"
			label = spamTag.." "..(label ~= "" and label or "(empty)")
		elseif opt and opt.toggle then
			const toggleTag = opt.hold and "[hold]" or "[toggle]"
			const mainCmd = (type(args) == "table" and tostring(args[1] or "")) or ""
			local secondCmd = ""
			if opt.args2 and type(opt.args2) == "table" and opt.args2[1] then
				secondCmd = tostring(opt.args2[1])
			end
			if mainCmd ~= "" and secondCmd ~= "" then
				label = ("%s %s / %s"):format(toggleTag, mainCmd, secondCmd)
			else
				label = toggleTag.." "..label
			end
		end
		if opt and opt.disabled then
			if label == "" then
				label = "[disabled]"
			else
				label = label.." [disabled]"
			end
		end
		Insert(buttons, {
			Text = keyName.." -> "..label,
			Callback = function()
				CommandKeybinds[keyName] = nil
				CommandKeybindOptions[keyName] = nil
				NAmanage.SaveCommandKeybinds()
				NAmanage.ApplyCommandKeybinds()
				DoNotif("Removed keybind for "..keyName, 2)
			end
		})
	end
	Window({
		Title = "Remove Command Keybind",
		Description = "Select a keybind to remove:",
		Buttons = buttons,
	})
end

NAmanage.CommandKeybindsList=function()
	if type(CommandKeybinds) ~= "table" or not next(CommandKeybinds) then
		DoNotif("No command keybinds set.", 2)
		return
	end
	const lines = {}
	for keyName, args in CommandKeybinds do
		local label = (type(args) == "table" and #args > 0) and Concat(args, " ") or ""
		const opt = CommandKeybindOptions[keyName]
		if opt and opt.spam then
			const spamTag = opt.hold and "[spam hold]" or "[spam]"
			label = spamTag.." "..(label ~= "" and label or "(empty)")
		elseif opt and opt.toggle then
			const toggleTag = opt.hold and "[hold]" or "[toggle]"
			const mainCmd = (type(args) == "table" and tostring(args[1] or "")) or ""
			local secondCmd = ""
			if opt.args2 and type(opt.args2) == "table" and opt.args2[1] then
				secondCmd = tostring(opt.args2[1])
			end
			if mainCmd ~= "" and secondCmd ~= "" then
				label = ("%s %s / %s"):format(toggleTag, mainCmd, secondCmd)
			else
				label = toggleTag.." "..label
			end
		end
		if opt and opt.disabled then
			if label == "" then
				label = "[disabled]"
			else
				label = label.." [disabled]"
			end
		end
		Insert(lines, keyName.." > "..label)
	end
	const text = Concat(lines, "\n")
	if type(DoWindow) == "function" then
		DoWindow(text, "Command Keybinds")
	else
		print("[Command Keybinds]\n"..text)
		DoNotif("Command keybinds printed to console output.", 3)
	end
end

NAmanage.CommandKeybindsUIInit=function()
	const root = NAUIMANAGER and NAUIMANAGER.CommandKeybindsContainer
	if not root then
		return false
	end

	NAStuff._commandKeybindUI = NAStuff._commandKeybindUI or {}
	const ui = NAStuff._commandKeybindUI

	if ui._initialized and ui.listFrame and ui.listFrame.Parent == root then
		return true
	end

	const function applyResponsiveText(obj, minSize, maxSize)
		if not obj then
			return
		end
		obj.TextScaled = true
		const constraint = obj:FindFirstChildOfClass("UITextSizeConstraint") or InstanceNew("UITextSizeConstraint", obj)
		constraint.MinTextSize = minSize or 10
		constraint.MaxTextSize = maxSize or 16
	end

	const function cloneSearchBox(parent, placeholder)
		const template = NAUIMANAGER and NAUIMANAGER.SettingsSearchBox
		local box
		if template and template.Parent then
			box = template:Clone()
		else
			box = InstanceNew("TextBox")
			box.BorderSizePixel = 0
			box.BackgroundColor3 = Color3.fromRGB(54, 54, 64)
			box.BackgroundTransparency = 0.2
			box.TextColor3 = Color3.fromRGB(234, 234, 244)
			box.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			box.TextSize = 16
			box.ClearTextOnFocus = false
			const corner = InstanceNew("UICorner", box)
			corner.CornerRadius = UDim.new(0, 6)
			const stroke = InstanceNew("UIStroke", box)
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			stroke.Thickness = 1.5
			stroke.Color = NAUISTROKER or DEFAULT_UI_STROKE_COLOR or Color3.fromRGB(154, 99, 255)
			NAgui.RegisterColoredStroke(stroke)
		end
		box.Parent = parent
		box.Text = ""
		box.PlaceholderText = placeholder or ""
		box.ClearTextOnFocus = false
		applyResponsiveText(box, 11, 16)
		NAgui.RegisterStrokesFrom(box)
		return box
	end

	const keyBox = cloneSearchBox(root, "Key / Combo")
	keyBox.Name = "KeyBox"
	keyBox.TextEditable = false
	keyBox.Size = UDim2.new(0.28, -10, 0, 30)
	keyBox.Position = UDim2.new(0, 10, 0, 8)

	const cmdBox = cloneSearchBox(root, "Command")
	cmdBox.Name = "CmdBox"
	cmdBox.Size = UDim2.new(0.34, -10, 0, 30)
	cmdBox.Position = UDim2.new(0.28, 10, 0, 8)

	const argsBox = cloneSearchBox(root, "Args (space separated)")
	argsBox.Name = "ArgsBox"
	argsBox.Size = UDim2.new(0.38, -10, 0, 30)
	argsBox.Position = UDim2.new(0.62, 10, 0, 8)

	const toggleCmdBox = cloneSearchBox(root, "Toggle Command")
	toggleCmdBox.Name = "ToggleCmdBox"
	toggleCmdBox.Size = UDim2.new(0.34, -10, 0, 30)
	toggleCmdBox.Position = UDim2.new(0.28, 10, 0, 46)
	toggleCmdBox.Visible = false

	const toggleArgsBox = cloneSearchBox(root, "Toggle Args (space separated)")
	toggleArgsBox.Name = "ToggleArgsBox"
	toggleArgsBox.Size = UDim2.new(0.38, -10, 0, 30)
	toggleArgsBox.Position = UDim2.new(0.62, 10, 0, 46)
	toggleArgsBox.Visible = false

	const function makeActionButton(parent, text, pos, size, color)
		const btn = InstanceNew("TextButton", parent)
		btn.BorderSizePixel = 0
		btn.BackgroundTransparency = 0.2
		btn.BackgroundColor3 = color or Color3.fromRGB(54, 54, 64)
		btn.TextColor3 = Color3.fromRGB(234, 234, 244)
		btn.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		btn.TextSize = 14
		btn.Text = text
		btn.Position = pos
		btn.Size = size
		applyResponsiveText(btn, 10, 16)
		const c = InstanceNew("UICorner", btn)
		c.CornerRadius = UDim.new(0, 6)
		const s = InstanceNew("UIStroke", btn)
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Thickness = 1.5
		s.Color = NAUISTROKER or DEFAULT_UI_STROKE_COLOR or Color3.fromRGB(154, 99, 255)
		NAgui.RegisterColoredStroke(s)
		NAgui.RegisterStrokesFrom(btn)
		return btn
	end

	const setKeyBtn = makeActionButton(root, "Set Key/Combo", UDim2.new(0, 10, 0, 46), UDim2.new(0.16, -10, 0, 30), Color3.fromRGB(54, 54, 64))
	const newBtn = makeActionButton(root, "New", UDim2.new(0.16, 10, 0, 46), UDim2.new(0.10, -10, 0, 30), Color3.fromRGB(54, 54, 64))
	const saveBtn = makeActionButton(root, "Save", UDim2.new(0.26, 10, 0, 46), UDim2.new(0.14, -10, 0, 30), Color3.fromRGB(80, 120, 80))
	const toggleBtn = makeActionButton(root, "Toggle: Off", UDim2.new(0.40, 10, 0, 46), UDim2.new(0.14, -10, 0, 30), Color3.fromRGB(54, 54, 64))
	const spamBtn = makeActionButton(root, "Spam: Off", UDim2.new(0.54, 10, 0, 46), UDim2.new(0.14, -10, 0, 30), Color3.fromRGB(54, 54, 64))
	const holdBtn = makeActionButton(root, "Hold: Off", UDim2.new(0.68, 10, 0, 46), UDim2.new(0.14, -10, 0, 30), Color3.fromRGB(54, 54, 64))
	const delBtn = makeActionButton(root, "Delete", UDim2.new(0.82, 10, 0, 46), UDim2.new(0.18, -10, 0, 30), Color3.fromRGB(184, 54, 54))

	const searchBox = cloneSearchBox(root, "Search keybinds...")
	searchBox.Name = "Search"
	searchBox.Size = UDim2.new(1, -20, 0, 30)
	searchBox.Position = UDim2.new(0, 10, 0, 122)

	const listFrame = InstanceNew("ScrollingFrame", root)
	listFrame.Name = "List"
	listFrame.BackgroundTransparency = 1
	listFrame.BorderSizePixel = 0
	listFrame.Size = UDim2.new(1, -28, 1, -170)
	listFrame.Position = UDim2.new(0, 5, 0, 160)
	listFrame.ScrollBarThickness = 0
	listFrame.ScrollBarImageColor3 = Color3.fromRGB(104, 104, 114)
	listFrame.ScrollBarImageTransparency = 1
	listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	const layout = InstanceNew("UIListLayout", listFrame)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	ui.root = root
	ui.searchBox = searchBox
	ui.listFrame = listFrame
	ui.keyBox = keyBox
	ui.cmdBox = cmdBox
	ui.argsBox = argsBox
	ui.toggleCmdBox = toggleCmdBox
	ui.toggleArgsBox = toggleArgsBox
	ui.setKeyBtn = setKeyBtn
	ui.newBtn = newBtn
	ui.saveBtn = saveBtn
	ui.toggleBtn = toggleBtn
	ui.spamBtn = spamBtn
	ui.holdBtn = holdBtn
	ui.delBtn = delBtn
	ui.selectedKey = nil
	ui.toggleState = false
	ui.spamState = false
	ui.holdState = false
	ui.disabledState = false
	ui._initialized = true
	if NAUIMANAGER then
		NAUIMANAGER.CommandKeybindsList = listFrame
	end

	NAgui.RegisterStrokesFrom(root)
	do
		const canvasKey = "CommandKeybinds_canvas"
		NAlib.disconnect(canvasKey)
		const function refreshCanvas()
			if not root or not root.Parent then return end
			pcall(function()
				updateCanvasSize(listFrame)
			end)
			pcall(function()
				if NAmanage.CommandKeybindsScroll and NAmanage.CommandKeybindsScroll.setTarget then
					NAmanage.CommandKeybindsScroll.setTarget(listFrame)
				end
				if NAmanage.CommandKeybindsScroll and NAmanage.CommandKeybindsScroll.scheduleRefresh then
					NAmanage.CommandKeybindsScroll.scheduleRefresh()
				elseif NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
					NAmanage.CustomScroll.refreshByTarget(listFrame)
				end
			end)
		end
		refreshCanvas()
		NAlib.connect(canvasKey, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas))
		NAlib.connect(canvasKey, listFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshCanvas))
		NAlib.connect(canvasKey, root:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshCanvas))
		NAlib.connect(canvasKey, root.AncestryChanged:Connect(function(_, parent)
			if not parent then
				Defer(function() NAlib.disconnect(canvasKey) end)
			end
		end))
	end

	return true
end

NAmanage.CommandKeybindsRefreshScroll=function()
	const ui = NAStuff._commandKeybindUI
	const list = ui and ui.listFrame or (NAUIMANAGER and NAUIMANAGER.CommandKeybindsList)
	if not (list and list.Parent) then
		return
	end
	const function refresh()
		if not (list and list.Parent) then
			return
		end
		pcall(function()
			updateCanvasSize(list, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
		end)
		pcall(function()
			if NAmanage.CommandKeybindsScroll and NAmanage.CommandKeybindsScroll.setTarget then
				NAmanage.CommandKeybindsScroll.setTarget(list)
			end
			if NAmanage.CommandKeybindsScroll and NAmanage.CommandKeybindsScroll.scheduleRefresh then
				NAmanage.CommandKeybindsScroll.scheduleRefresh()
			elseif NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
				NAmanage.CustomScroll.refreshByTarget(list)
			end
		end)
	end
	refresh()
	Defer(refresh)
end

NAmanage.CommandKeybindsUpdateToggleLayout=function(ui)
	if not ui then return end
	const show = ui.toggleState and not ui.spamState and ui.toggleCmdBox and ui.toggleArgsBox
	if ui.toggleCmdBox then ui.toggleCmdBox.Visible = show and true or false end
	if ui.toggleArgsBox then ui.toggleArgsBox.Visible = show and true or false end

	const rowY = show and 84 or 46

	const function place(btn, pos, size)
		if not btn then return end
		btn.Position = UDim2.new(pos, 10, 0, rowY)
		btn.Size = UDim2.new(size, -10, 0, 30)
	end

	if show then
		if ui.toggleCmdBox then
			ui.toggleCmdBox.Position = UDim2.new(0.28, 10, 0, 46)
		end
		if ui.toggleArgsBox then
			ui.toggleArgsBox.Position = UDim2.new(0.62, 10, 0, 46)
		end
	end

	place(ui.setKeyBtn, 0, 0.16)
	place(ui.newBtn, 0.16, 0.10)
	place(ui.saveBtn, 0.26, 0.14)
	place(ui.toggleBtn, 0.40, 0.14)
	place(ui.spamBtn, 0.54, 0.14)
	place(ui.holdBtn, 0.68, 0.14)
	place(ui.delBtn, 0.82, 0.18)

	if ui.toggleBtn then
		ui.toggleBtn.Text = ui.toggleState and "Toggle: On" or "Toggle: Off"
	end
	if ui.spamBtn then
		ui.spamBtn.Text = ui.spamState and "Spam: On" or "Spam: Off"
	end
	if ui.holdBtn then
		const modeActive = ui.toggleState or ui.spamState
		ui.holdBtn.AutoButtonColor = modeActive and true or false
		ui.holdBtn.BackgroundTransparency = modeActive and 0.2 or 0.5
		ui.holdBtn.TextColor3 = modeActive and Color3.fromRGB(234, 234, 244) or Color3.fromRGB(180, 180, 190)
		ui.holdBtn.Text = ui.holdState and "Hold: On" or "Hold: Off"
	end
end

NAmanage.CommandKeybindsUIRefresh=function()
	const ui = NAStuff._commandKeybindUI
	if not (ui and ui.listFrame and ui.listFrame.Parent) then
		return
	end

	local filter = ""
	if ui.searchBox then
		filter = Lower(tostring(ui.searchBox.Text or "")):match("^%s*(.-)%s*$") or ""
	end

	for _, child in ui.listFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	const keys = {}
	for keyName in CommandKeybinds do
		Insert(keys, keyName)
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)

	const function isDisabled(keyName)
		const opt = CommandKeybindOptions[keyName]
		return opt and opt.disabled == true
	end

	const function normalizeLabel(args)
		if type(args) ~= "table" or #args == 0 then
			return ""
		end
		return Concat(args, " ")
	end

	const function buildDisplayLabel(keyName, args)
		const baseLabel = normalizeLabel(args)
		const opt = CommandKeybindOptions[keyName]
		if opt and opt.spam then
			const label = (opt.hold and "[spam hold]" or "[spam]").." "..(baseLabel ~= "" and baseLabel or "(empty)")
			if isDisabled(keyName) then
				return label.." (disabled)"
			end
			return label
		end
		if not (opt and opt.toggle) then
			const label = baseLabel ~= "" and baseLabel or "(empty)"
			if isDisabled(keyName) then
				return label.." (disabled)"
			end
			return label
		end

		const mainCmd = (type(args) == "table" and tostring(args[1] or "")) or ""
		local secondCmd = ""
		if opt.args2 and type(opt.args2) == "table" and opt.args2[1] then
			secondCmd = tostring(opt.args2[1])
		end

		const tag = (opt and opt.hold) and "[hold]" or "[toggle]"

		if mainCmd ~= "" and secondCmd ~= "" then
			const label = ("%s %s / %s"):format(tag, mainCmd, secondCmd)
			if isDisabled(keyName) then
				return label.." (disabled)"
			end
			return label
		end

		const label = tag.." "..(baseLabel ~= "" and baseLabel or "(empty)")
		if isDisabled(keyName) then
			return label.." (disabled)"
		end
		return label
	end

	local idx = 0
	for _, keyName in keys do
		const args = CommandKeybinds[keyName]
		const label = normalizeLabel(args)
		const hay = Lower(keyName.." "..label)
		if filter ~= "" and not Find(hay, filter, 1, true) then
			continue
		end

		const disabled = isDisabled(keyName)

		idx += 1
		const row = InstanceNew("Frame", ui.listFrame)
		row.Name = "Row_"..tostring(keyName)
		row.BorderSizePixel = 0
		row.BackgroundColor3 = Color3.fromRGB(49, 49, 54)
		row.BackgroundTransparency = disabled and 0.35 or 0.25
		row.Size = UDim2.new(0.98, 0, 0, 32)
		row.LayoutOrder = idx
		const rc = InstanceNew("UICorner", row)
		rc.CornerRadius = UDim.new(0, 6)
		const rs = InstanceNew("UIStroke", row)
		rs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		rs.Thickness = 1
		NAgui.RegisterColoredStroke(rs)

		const keyLbl = InstanceNew("TextLabel", row)
		keyLbl.BackgroundTransparency = 1
		keyLbl.Size = UDim2.new(0, 130, 1, 0)
		keyLbl.Position = UDim2.new(0, 10, 0, 0)
		keyLbl.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		keyLbl.TextSize = 14
		keyLbl.TextWrapped = true
		keyLbl.TextXAlignment = Enum.TextXAlignment.Left
		keyLbl.TextColor3 = disabled and Color3.fromRGB(184, 184, 194) or Color3.fromRGB(234, 234, 244)
		keyLbl.Text = tostring(keyName)

		const cmdLbl = InstanceNew("TextLabel", row)
		cmdLbl.BackgroundTransparency = 1
		cmdLbl.Size = UDim2.new(1, -310, 1, 0)
		cmdLbl.Position = UDim2.new(0, 140, 0, 0)
		cmdLbl.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		cmdLbl.TextSize = 14
		cmdLbl.TextWrapped = true
		cmdLbl.TextXAlignment = Enum.TextXAlignment.Left
		cmdLbl.TextColor3 = disabled and Color3.fromRGB(170, 170, 182) or Color3.fromRGB(214, 214, 224)
		cmdLbl.Text = buildDisplayLabel(keyName, args)

		const editBtn = InstanceNew("TextButton", row)
		editBtn.BorderSizePixel = 0
		editBtn.BackgroundColor3 = Color3.fromRGB(54, 54, 64)
		editBtn.BackgroundTransparency = 0.2
		editBtn.Size = UDim2.new(0, 50, 0, 24)
		editBtn.Position = UDim2.new(1, -190, 0.5, -12)
		editBtn.Text = "Edit"
		editBtn.TextColor3 = Color3.fromRGB(234, 234, 244)
		editBtn.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		editBtn.TextSize = 13
		const ec = InstanceNew("UICorner", editBtn)
		ec.CornerRadius = UDim.new(0, 6)
		NAgui.RegisterStrokesFrom(editBtn)

		const disableBtn = InstanceNew("TextButton", row)
		disableBtn.BorderSizePixel = 0
		disableBtn.BackgroundColor3 = disabled and Color3.fromRGB(80, 120, 80) or Color3.fromRGB(184, 124, 54)
		disableBtn.BackgroundTransparency = 0.2
		disableBtn.Size = UDim2.new(0, 60, 0, 24)
		disableBtn.Position = UDim2.new(1, -130, 0.5, -12)
		disableBtn.Text = disabled and "Enable" or "Disable"
		disableBtn.TextColor3 = Color3.fromRGB(244, 244, 244)
		disableBtn.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		disableBtn.TextSize = 13
		const dbc = InstanceNew("UICorner", disableBtn)
		dbc.CornerRadius = UDim.new(0, 6)
		NAgui.RegisterStrokesFrom(disableBtn)

		const remBtn = InstanceNew("TextButton", row)
		remBtn.BorderSizePixel = 0
		remBtn.BackgroundColor3 = Color3.fromRGB(184, 54, 54)
		remBtn.BackgroundTransparency = 0.2
		remBtn.Size = UDim2.new(0, 60, 0, 24)
		remBtn.Position = UDim2.new(1, -60, 0.5, -12)
		remBtn.Text = "Delete"
		remBtn.TextColor3 = Color3.fromRGB(244, 244, 244)
		remBtn.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		remBtn.TextSize = 13
		const dc = InstanceNew("UICorner", remBtn)
		dc.CornerRadius = UDim.new(0, 6)
		NAgui.RegisterStrokesFrom(remBtn)

		MouseButtonFix(editBtn, function()
			ui.selectedKey = tostring(keyName)
			if ui.keyBox then ui.keyBox.Text = tostring(keyName) end
			if ui.cmdBox then ui.cmdBox.Text = (type(args) == "table" and tostring(args[1] or "")) or "" end
			if ui.argsBox then
				if type(args) == "table" and #args > 1 then
					const parts = {}
					for i = 2, #args do
						Insert(parts, tostring(args[i]))
					end
					ui.argsBox.Text = Concat(parts, " ")
				else
					ui.argsBox.Text = ""
				end
			end

			const opt = CommandKeybindOptions[tostring(keyName)]
			const isToggle = opt and opt.toggle or false
			const isSpam = opt and opt.spam or false
			ui.disabledState = (opt and opt.disabled == true) or false

			if ui.toggleBtn then
				ui.toggleState = isToggle
			end
			ui.spamState = isSpam and true or false
			ui.holdState = (opt and opt.hold == true) or false
			if not (ui.toggleState or ui.spamState) then
				ui.holdState = false
			end

			const args2 = (opt and type(opt.args2) == "table") and opt.args2 or nil
			if ui.toggleCmdBox then
				ui.toggleCmdBox.Text = args2 and tostring(args2[1] or "") or ""
			end
			if ui.toggleArgsBox then
				if args2 and #args2 > 1 then
					const tparts = {}
					for i = 2, #args2 do
						Insert(tparts, tostring(args2[i]))
					end
					ui.toggleArgsBox.Text = Concat(tparts, " ")
				else
					ui.toggleArgsBox.Text = ""
				end
			end

			NAmanage.CommandKeybindsUpdateToggleLayout(ui)
		end)

		MouseButtonFix(disableBtn, function()
			const k = tostring(keyName)
			const opt = CommandKeybindOptions[k] or {}
			opt.disabled = not (opt.disabled == true)
			if not opt.toggle and not opt.spam and not opt.disabled then
				CommandKeybindOptions[k] = nil
			else
				CommandKeybindOptions[k] = opt
			end
			if ui.selectedKey == k then
				ui.disabledState = opt and opt.disabled == true or false
			end
			NAmanage.SaveCommandKeybinds()
			NAmanage.ApplyCommandKeybinds()
			NAmanage.CommandKeybindsUIRefresh()
			DoNotif(opt.disabled and ("Disabled keybind "..k) or ("Enabled keybind "..k), 2)
		end)

		MouseButtonFix(remBtn, function()
			CommandKeybinds[tostring(keyName)] = nil
			CommandKeybindOptions[tostring(keyName)] = nil
			NAmanage.SaveCommandKeybinds()
			NAmanage.ApplyCommandKeybinds()
			if ui.selectedKey == tostring(keyName) then
				ui.selectedKey = nil
				if ui.keyBox then ui.keyBox.Text = "" end
				if ui.cmdBox then ui.cmdBox.Text = "" end
				if ui.argsBox then ui.argsBox.Text = "" end
				if ui.toggleCmdBox then ui.toggleCmdBox.Text = "" end
				if ui.toggleArgsBox then ui.toggleArgsBox.Text = "" end
				ui.disabledState = false
				ui.toggleState = false
				ui.spamState = false
				ui.holdState = false
				NAmanage.CommandKeybindsUpdateToggleLayout(ui)
			end
			NAmanage.CommandKeybindsUIRefresh()
		end)
	end
	if NAmanage.CommandKeybindsRefreshScroll then
		NAmanage.CommandKeybindsRefreshScroll()
	end
end

NAmanage.CommandKeybindsUIWire=function()
	const ui = NAStuff._commandKeybindUI
	if not (ui and ui.root and ui.root.Parent) then
		return
	end
	if ui._wired then
		return
	end
	ui._wired = true

	if ui.searchBox then
		ui.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			NAmanage.CommandKeybindsUIRefresh()
		end)
	end

	const function clearEditor()
		ui.selectedKey = nil
		if ui.keyBox then ui.keyBox.Text = "" end
		if ui.cmdBox then ui.cmdBox.Text = "" end
		if ui.argsBox then ui.argsBox.Text = "" end
		if ui.toggleCmdBox then ui.toggleCmdBox.Text = "" end
		if ui.toggleArgsBox then ui.toggleArgsBox.Text = "" end
		ui.disabledState = false
		ui.toggleState = false
		ui.spamState = false
		ui.holdState = false
		NAmanage.CommandKeybindsUpdateToggleLayout(ui)
	end

	if ui.newBtn then
		MouseButtonFix(ui.newBtn, function()
			clearEditor()
		end)
	end

	if ui.toggleBtn then
		MouseButtonFix(ui.toggleBtn, function()
			ui.toggleState = not ui.toggleState
			if ui.toggleState then
				ui.spamState = false
			end
			if not ui.toggleState then
				if not ui.spamState then
					ui.holdState = false
				end
			end
			NAmanage.CommandKeybindsUpdateToggleLayout(ui)
		end)
	end

	if ui.spamBtn then
		MouseButtonFix(ui.spamBtn, function()
			ui.spamState = not ui.spamState
			if ui.spamState then
				ui.toggleState = false
			elseif not ui.toggleState then
				ui.holdState = false
			end
			NAmanage.CommandKeybindsUpdateToggleLayout(ui)
		end)
	end

	if ui.holdBtn then
		MouseButtonFix(ui.holdBtn, function()
			if not (ui.toggleState or ui.spamState) then
				DoNotif("Enable Toggle or Spam before using Hold mode.", 1.5)
				return
			end
			ui.holdState = not ui.holdState
			NAmanage.CommandKeybindsUpdateToggleLayout(ui)
		end)
	end

	-- ensure initial layout matches default toggle state
	NAmanage.CommandKeybindsUpdateToggleLayout(ui)

	if ui.setKeyBtn then
		MouseButtonFix(ui.setKeyBtn, function()
			if ui._cap then
				ui._cap = false
				NAStuff._capturingCommandKeybind = false
				ui.setKeyBtn.Text = "Set Key/Combo"
				DoNotif("Cancelled", 1.5)
				return
			end

			ui._cap = true
			ui._capTok = (ui._capTok or 0) + 1
			const tok = ui._capTok

			NAStuff._capturingCommandKeybind = true
			ui.setKeyBtn.Text = "Cancel"
			DoNotif("Press a key, key combo, or click combo to set...", 2)

			local conn
			const function stop(msg)
				if tok ~= ui._capTok then return end
				ui._capTok = (ui._capTok or 0) + 1
				ui._cap = false
				ui.setKeyBtn.Text = "Set Key/Combo"
				if conn then conn:Disconnect() conn = nil end
				Defer(function()
					NAStuff._capturingCommandKeybind = false
				end)
				if msg then DoNotif(msg, 1.5) end
			end

			conn = Services.UserInputService.InputBegan:Connect(function(input, gp)
				if tok ~= ui._capTok then return end
				if gp and input and input.UserInputType ~= Enum.UserInputType.Keyboard then return end

				const keyName = NAmanage.CKBBind(input, Services.UserInputService)
				if not keyName then
					return
				end
				if ui.keyBox then ui.keyBox.Text = keyName end
				stop()
			end)

			Spawn(function()
				Wait(5)
				if tok ~= ui._capTok then return end
				stop("Key capture timed out.")
			end)
		end)
	end

	if ui.saveBtn then
		MouseButtonFix(ui.saveBtn, function()
			const rawKey = ui.keyBox and tostring(ui.keyBox.Text or ""):match("^%s*(.-)%s*$") or ""
			const keyName = NAmanage.CKBNorm(rawKey) or ""
			const cmdName = ui.cmdBox and tostring(ui.cmdBox.Text or ""):match("^%s*(.-)%s*$") or ""
			const argsRaw = ui.argsBox and tostring(ui.argsBox.Text or "") or ""
			const toggleCmdName = ui.toggleCmdBox and tostring(ui.toggleCmdBox.Text or ""):match("^%s*(.-)%s*$") or ""
			const toggleArgsRaw = ui.toggleArgsBox and tostring(ui.toggleArgsBox.Text or "") or ""

			if keyName == "" then
				DoNotif("Pick a valid key or key combo first.", 2)
				return
			end
			if ui.keyBox and ui.keyBox.Text ~= keyName then
				ui.keyBox.Text = keyName
			end
			if cmdName == "" then
				DoNotif("Command cannot be empty.", 2)
				return
			end
			const args = { cmdName }
			const extra = ParseArguments(argsRaw)
			if extra then
				for _, v in extra do
					Insert(args, v)
				end
			end

			const prevKey = ui.selectedKey
			if prevKey and prevKey ~= "" and prevKey ~= keyName then
				CommandKeybinds[prevKey] = nil
				CommandKeybindOptions[prevKey] = nil
			end
			CommandKeybinds[keyName] = args
			const opt = CommandKeybindOptions[keyName] or {}
			if ui.spamState then
				opt.spam = true
				opt.toggle = nil
				opt.state = false
				opt.args2 = nil
				opt.hold = ui.holdState and true or nil
			elseif ui.toggleState then
				opt.toggle = true
				opt.spam = nil
				opt.state = false
				opt.hold = ui.holdState and true or nil
				-- build second layer: either from explicit toggle fields or just reuse the first command
				local args2 = nil
				if toggleCmdName ~= "" then
					args2 = { toggleCmdName }
					const extra2 = ParseArguments(toggleArgsRaw)
					if extra2 then
						for _, v in extra2 do
							Insert(args2, v)
						end
					end
				else
					args2 = {}
					for i, v in args do
						args2[i] = v
					end
				end
				opt.args2 = args2
			else
				opt.spam = nil
				opt.toggle = nil
				opt.state = nil
				opt.args2 = nil
				opt.hold = nil
				ui.holdState = false
			end
			opt.disabled = ui.disabledState and true or nil
			if not opt.toggle and not opt.spam and not opt.disabled then
				CommandKeybindOptions[keyName] = nil
			else
				CommandKeybindOptions[keyName] = opt
			end
			ui.selectedKey = keyName
			ui.disabledState = opt and opt.disabled == true or false

			NAmanage.SaveCommandKeybinds()
			NAmanage.ApplyCommandKeybinds()
			NAmanage.CommandKeybindsUIRefresh()
			DoNotif(("Saved %s > %s"):format(keyName, Concat(args, " ")), 2)
		end)
	end

	if ui.delBtn then
		MouseButtonFix(ui.delBtn, function()
			const rawKey = ui.keyBox and tostring(ui.keyBox.Text or ""):match("^%s*(.-)%s*$") or ""
			const keyName = NAmanage.CKBNorm(rawKey) or rawKey
			if keyName == "" then
				DoNotif("No key or combo selected.", 2)
				return
			end
			CommandKeybinds[keyName] = nil
			CommandKeybindOptions[keyName] = nil
			NAmanage.SaveCommandKeybinds()
			NAmanage.ApplyCommandKeybinds()
			clearEditor()
			NAmanage.CommandKeybindsUIRefresh()
			DoNotif("Deleted keybind "..keyName, 2)
		end)
	end
end

--[[ CHAT TO USE COMMANDS ]]--
NAmanage.formatLogPlayerName=function(plr, opts)
	opts = type(opts) == "table" and opts or {}
	local baseName = nameChecker(plr)
	if opts.useDisplayName == false then
		baseName = "@"..tostring((plr and plr.Name) or "Unknown")
	end
	if opts.showUserId == true then
		baseName = baseName.." [UserId: "..tostring((plr and plr.UserId) or "Unknown").."]"
	end
	return baseName
end

NAmanage.bindToChat=function(plr, msg)
	const shouldDisplay = NAmanage.jlCfg.ChatLog ~= false
	const shouldSave = NAmanage.jlCfg.SaveChatLog == true
	NAStuff.ChatLogState = NAStuff.ChatLogState or {
		entries = {};
		nextOrder = 0;
		maxMessages = 200;
	}
	const chatLogState = NAStuff.ChatLogState
	const logOwnMessages = NAmanage.jlCfg.ChatLogLocalPlayer ~= false
	const includeGameInfo = NAmanage.jlCfg.LogIncludeGameInfo ~= false

	if plr == LocalPlayer and not logOwnMessages then
		return
	end

	chatLogState.maxMessages = tonumber(NAmanage.jlCfg.ChatMaxMessages) or chatLogState.maxMessages or 200

	if not shouldDisplay and not shouldSave then
		return
	end

	const currentTime = os.date("%Y-%m-%d %H:%M:%S")
	const chatName = NAmanage.formatLogPlayerName(plr, {
		useDisplayName = NAmanage.jlCfg.ChatUseDisplayNames ~= false;
		showUserId = NAmanage.jlCfg.ChatShowUserIds == true;
	})
	const baseText = ("%s: %s"):format(chatName, msg)
	local displayText = baseText
	if NAmanage.jlCfg.ChatShowTimestamps ~= false then
		displayText = ("[%s] %s"):format(os.date("%H:%M:%S"), baseText)
	end

	local chatMsg = nil
	if shouldDisplay then
		chatMsg = NAUIMANAGER.chatExample:Clone()

		chatMsg.Name = ((NAgui.rStringgg and NAgui.rStringgg()) or "\0")
		chatMsg.Parent = NAUIMANAGER.chatLogs
		chatLogState.nextOrder = (chatLogState.nextOrder or 0) + 1
		chatMsg.LayoutOrder = chatLogState.nextOrder
		chatMsg.Text = displayText

		if NAmanage.AttachMessageCopy then
			NAmanage.AttachMessageCopy(chatMsg, tostring(msg or ""))
		end

		local isNAadmin = false
		if _na_env.NAadminsLol then
			for _, id in _na_env.NAadminsLol do
				if plr.UserId == id then
					isNAadmin = true
					break
				end
			end
		end

		if isNAadmin then
			const function rainbowColor(now)
				const r = math.sin(now * 0.5) * 127 + 128
				const g = math.sin(now * 0.5 + 2 * math.pi / 3) * 127 + 128
				const b = math.sin(now * 0.5 + 4 * math.pi / 3) * 127 + 128
				return Color3.fromRGB(r, g, b)
			end

			NAStuff.AdminChatRainbowMessages = NAStuff.AdminChatRainbowMessages or {}
			Insert(NAStuff.AdminChatRainbowMessages, chatMsg)

			if not NAStuff.AdminChatRainbowConnection then
				local lastUpdate = 0
				NAStuff.AdminChatRainbowConnection = NAlib.reconnect("admin_chat_rainbow", Services.RunService.Heartbeat:Connect(function()
					const now = tick()
					if now - lastUpdate < 0.12 then
						return
					end
					lastUpdate = now

					const list = NAStuff.AdminChatRainbowMessages
					if not list then
						return
					end
					for i = #list, 1, -1 do
						const label = list[i]
						if not label or not label.Parent then
							table.remove(list, i)
						else
							label.TextColor3 = rainbowColor(now)
						end
					end
					if #list == 0 and NAStuff.AdminChatRainbowConnection then
						NAStuff.AdminChatRainbowConnection:Disconnect()
						NAlib.disconnect("admin_chat_rainbow")
						NAStuff.AdminChatRainbowConnection = nil
					end
				end))
			end
		else
			if plr == LocalPlayer then
				chatMsg.TextColor3 = Color3.fromRGB(0, 155, 255)
			elseif LocalPlayer:IsFriendsWith(plr.UserId) then
				chatMsg.TextColor3 = Color3.fromRGB(255, 255, 0)
			end
		end

		const translator = NAStuff.ChatTranslator
		if translator then
			translator:registerMessage(chatMsg, displayText, msg)
		end
	end

	pcall(function()
		if shouldSave and FileSupport and appendfile then
			local cEntry = ("[%s] %s"):format(currentTime, baseText)
			if includeGameInfo then
				cEntry = cEntry..Format(
					" | Game: %s | PlaceId: %s | GameId: %s | JobId: %s",
					placeName() or "unknown",
					tostring(PlaceId),
					tostring(GameId),
					tostring(JobId)
				)
			end
			cEntry = cEntry.."\n"
			if isfile(NAfiles.NACHATLOGS) then
				appendfile(NAfiles.NACHATLOGS, cEntry)
			else
				writefile(NAfiles.NACHATLOGS, cEntry)
			end
		end
	end)

	if shouldDisplay and chatMsg then
		const logsFrame = NAUIMANAGER and NAUIMANAGER.chatLogs;
		local followBottom = false;
		if logsFrame and logsFrame.Parent then
			const logPos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(logsFrame) or logsFrame.CanvasPosition;
			const logView = NAmanage.GetLogicalWindowSize and NAmanage.GetLogicalWindowSize(logsFrame) or logsFrame.AbsoluteSize;
			const bottomY = (tonumber(logPos.Y) or 0) + (logView and logView.Y or 0);
			const canvasY = tonumber(logsFrame.CanvasSize.Y.Offset) or 0;
			followBottom = bottomY >= math.max(0, canvasY - 32);
		end
		const txtSize = NAgui.txtSize(chatMsg, chatMsg.AbsoluteSize.X, 200)
		chatMsg.Size = UDim2.new(1, -5, 0, txtSize.Y)

		const entries = chatLogState.entries
		while #entries > 0 and (not entries[1] or not entries[1].Parent) do
			table.remove(entries, 1)
		end
		for i = #entries, 1, -1 do
			const item = entries[i]
			if not (item and item.Parent) then
				table.remove(entries, i)
			end
		end
		Insert(entries, chatMsg)

		local maxMessages = tonumber(chatLogState.maxMessages) or 200
		if maxMessages < 20 then
			maxMessages = 20
		end
		while #entries > maxMessages do
			const old = table.remove(entries, 1)
			if old and old.Parent then
				old:Destroy()
			end
		end
		if logsFrame and logsFrame.Parent then
			updateCanvasSize(logsFrame, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
			if followBottom then
				const targetY = math.max(0, (logsFrame.CanvasSize.Y.Offset or 0) - ((NAmanage.GetLogicalWindowSize and NAmanage.GetLogicalWindowSize(logsFrame).Y) or (logsFrame.AbsoluteSize.Y or 0)))
				if NAmanage.SetLogicalCanvasPosition then
					NAmanage.SetLogicalCanvasPosition(logsFrame, 0, targetY)
				else
					logsFrame.CanvasPosition = Vector2.new(0, targetY)
				end
			end
		end
		if NAmanage.ChatScroll and NAmanage.ChatScroll.scheduleRefresh then
			NAmanage.ChatScroll.scheduleRefresh();
		end
	end
end

NAmanage.bindToDevConsole = function()
	NAStuff = NAStuff or {}
	const CONN_KEY = "dev_console"
	if NAStuff._devConsoleCleanup then
		pcall(NAStuff._devConsoleCleanup)
		NAStuff._devConsoleCleanup = nil
	end
	NAlib.disconnect(CONN_KEY)
	const bindGeneration = (tonumber(NAStuff._devConsoleBindGeneration) or 0) + 1
	NAStuff._devConsoleBindGeneration = bindGeneration

	if not NAUIMANAGER.NAconsoleLogs or (not NAUIMANAGER.NAconsoleExample) then
		return;
	end;
	for _, child in NAUIMANAGER.NAconsoleLogs:GetChildren() do
		if NAmanage.GetAttr and (NAmanage.GetAttr(child, "NA_DevConsoleLog") == true or NAmanage.GetAttr(child, "NA_DevConsoleVirtual") == true) then
			pcall(function()
				child:Destroy()
			end)
		end
	end
	const logsFrame = NAUIMANAGER.NAconsoleLogs;
	local logsLayout = logsFrame:FindFirstChildOfClass("UIListLayout");
	if not logsLayout then
		logsLayout = InstanceNew("UIListLayout");
		logsLayout.SortOrder = Enum.SortOrder.LayoutOrder;
		logsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		logsLayout.Parent = logsFrame;
	end;
	const pool, visibleLabels = {}, {};
	local allMessages, filteredMessages = {}, {};
	NAStuff.NAConsoleRuntimeRecords = allMessages;
	local pending = {};
	local pendingHead = 1;
	local pendingTail = 0;
	local pendingProcessing = false;
	local overflowCounts = {};
	local overflowTotal = 0;
	local messageCounter = 0;
	const buttonTypes = {
		"Output",
		"Info",
		"Warn",
		"Error"
	};
	const clampNumber = (NAmanage and NAmanage.clampNumber) or function(value, minValue, maxValue, fallback)
		local num = tonumber(value);
		if num == nil then
			return fallback;
		end;
		if minValue ~= nil and num < minValue then
			num = minValue;
		end;
		if maxValue ~= nil and num > maxValue then
			num = maxValue;
		end;
		return num;
	end;
	const MAX_MESSAGES = math.floor(clampNumber(NAStuff.DevConsoleLogLimit, 200, 5000, 1200) or 1200);
	const MAX_PENDING = math.floor(clampNumber(NAStuff.DevConsoleQueueLimit, 100, 4000, 600) or 600);
	const overscanPx = math.floor(clampNumber(NAStuff.DevConsoleOverscan, 60, 2000, 320) or 320);
	const minConsoleRows = 12;
	local savedFilters;
	if NAmanage and NAmanage.NASettingsGet then
		local ok, result = pcall(function()
			return NAmanage.NASettingsGet("devConsoleFilters");
		end);
		if ok and type(result) == "table" then
			savedFilters = result;
		end;
	end;
	const toggles = {};
	for _, logType in buttonTypes do
		const savedValue = savedFilters and savedFilters[logType];
		if type(savedValue) == "boolean" then
			toggles[logType] = savedValue;
		else
			toggles[logType] = true;
		end;
	end;
	const SELECTED_COLOR = Color3.fromRGB(0, 255, 0);
	const DESELECTED_COLOR = Color3.fromRGB(255, 255, 255);
	const virtualCanvas = InstanceNew("Frame");
	virtualCanvas.Name = "VirtualCanvas";
	virtualCanvas.BackgroundTransparency = 1;
	virtualCanvas.BorderSizePixel = 0;
	virtualCanvas.Size = UDim2.new(1, 0, 0, 0);
	virtualCanvas.Position = UDim2.new(0, 0, 0, 0);
	virtualCanvas.Parent = logsFrame;
	NAmanage.SetAttr(virtualCanvas, "NA_DevConsoleVirtual", true);
	const FilterButtons = InstanceNew("Frame");
	FilterButtons.Name = "FilterButtons";
	FilterButtons.Size = UDim2.new(1, -10, 0, 22);
	FilterButtons.Position = UDim2.new(0.5, 0, 0, 30);
	FilterButtons.AnchorPoint = Vector2.new(0.5, 0);
	FilterButtons.BackgroundTransparency = 1;
	FilterButtons.Parent = logsFrame.Parent;
	const filterLayout = InstanceNew("UIListLayout");
	filterLayout.FillDirection = Enum.FillDirection.Horizontal;
	filterLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
	filterLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	filterLayout.Padding = UDim.new(0, 6);
	filterLayout.Parent = FilterButtons;
	const function getQuery()
		const filterBox = NAUIMANAGER.NAfilter;
		return tostring((filterBox and filterBox.Text) or ""):lower();
	end;
	const function matchesQuery(record, needle)
		return NAmanage.NAConsoleRecordMatchesQuery(record, needle);
	end;
	const function getTagInfo(msgTYPE)
		local tagColor = "#cccccc";
		local tagText = "Output";
		if msgTYPE == Enum.MessageType.MessageError then
			tagColor = "#ff6464";
			tagText = "Error";
		elseif msgTYPE == Enum.MessageType.MessageWarning then
			tagColor = "#ffcc00";
			tagText = "Warn";
		elseif msgTYPE == Enum.MessageType.MessageInfo then
			tagColor = "#66ccff";
			tagText = "Info";
		end;
		return tagText, tagColor;
	end;
	const function shouldCaptureTag(tagText)
		return toggles[tagText] == true;
	end;
	const function getMeasureWidth()
		const logicalSize = NAmanage.GetLogicalAbsoluteSize and NAmanage.GetLogicalAbsoluteSize(logsFrame) or nil;
		const width = logicalSize and logicalSize.X or (logsFrame.AbsoluteSize.X or 0);
		return math.max(1, math.floor(width + 0.5));
	end;
	const function getPadding()
		return (logsLayout and logsLayout.Padding and logsLayout.Padding.Offset) or 0;
	end;
	const function isBindActive()
		return NAStuff and NAStuff._devConsoleBindGeneration == bindGeneration;
	end;
	const function escape(s)
		return ((s:gsub("&", "&amp;")):gsub("<", "&lt;")):gsub(">", "&gt;");
	end;
	const function measureHeightFromText(plain, width)
		const baseSize = NAUIMANAGER.NAconsoleExample.TextSize or 14;
		const vec = __lt.cm("TextService", "GetTextSize", plain, baseSize, NAUIMANAGER.NAconsoleExample.Font, Vector2.new(width, 1000000));
		local h = vec.Y;
		if h < 18 then
			h = 18;
		end;
		return math.floor(h + 0.5);
	end;
	const function ensureRecordHeight(record, width, force)
		if not record then
			return 18;
		end;
		width = width or getMeasureWidth();
		if (not force) and record.height and record.measureWidth == width then
			return record.height;
		end;
		record.measureWidth = width;
		record.height = measureHeightFromText(record.plainText, width);
		return record.height;
	end;
	const function getVisibleHeight()
		local logicalSize = nil;
		if NAmanage.GetLogicalWindowSize then
			logicalSize = NAmanage.GetLogicalWindowSize(logsFrame);
		elseif NAmanage.GetLogicalAbsoluteSize then
			logicalSize = NAmanage.GetLogicalAbsoluteSize(logsFrame);
		end;
		return math.max(0, logicalSize and logicalSize.Y or (logsFrame.AbsoluteSize.Y or 0));
	end;
	const function isNearBottom()
		const logPos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(logsFrame) or logsFrame.CanvasPosition;
		const bottomY = logPos.Y + getVisibleHeight();
		const canvasY = logsFrame.CanvasSize.Y.Offset;
		return bottomY >= math.max(0, canvasY - 32);
	end;
	const function releaseLabel(lbl)
		if not lbl then
			return;
		end;
		lbl.Visible = false;
		lbl.Parent = nil;
		Insert(pool, lbl);
	end;
	const function acquireLabel()
		if (not isBindActive()) or not logsFrame or (not logsFrame.Parent) or (not virtualCanvas) or (not virtualCanvas.Parent) then
			return nil;
		end;
		const function attachLabel(lbl)
			return pcall(function()
				lbl.Parent = virtualCanvas;
			end);
		end
		local lbl = table.remove(pool);
		while lbl do
			if attachLabel(lbl) then
				return lbl;
			end;
			lbl = table.remove(pool);
		end;
		lbl = NAUIMANAGER.NAconsoleExample:Clone();
		lbl.RichText = true;
		lbl.AutoLocalize = false;
		pcall(function()
			lbl.Active = true;
		end);
		lbl.TextWrapped = true;
		lbl.TextScaled = true;
		NAmanage.SetAttr(lbl, "NA_DevConsoleLog", true);
		if NAmanage.AttachMessageCopy and NAmanage.GetAttr(lbl, "NA_CopyHooked") ~= true then
			NAmanage.AttachMessageCopy(lbl, function(target)
				return (NAmanage.GetAttr and NAmanage.GetAttr(target, "NA_CopyText")) or "";
			end);
			NAmanage.SetAttr(lbl, "NA_CopyHooked", true);
		end;
		if not attachLabel(lbl) then
			return nil;
		end;
		return lbl;
	end;
	const function applyRecordToLabel(lbl, record)
		if not (lbl and record) then
			return;
		end;
		const currentId = NAmanage.GetAttr and NAmanage.GetAttr(lbl, "NA_RecordId");
		const currentRevision = NAmanage.GetAttr and NAmanage.GetAttr(lbl, "NA_RecordRevision");
		if currentId ~= record.id or currentRevision ~= record.revision then
			lbl.Name = "Log_" .. tostring(record.id);
			lbl.Text = record.richText;
			NAmanage.SetAttr(lbl, "Tag", record.tag);
			NAmanage.SetAttr(lbl, "NA_CopyText", record.copyText);
			NAmanage.SetAttr(lbl, "NA_RecordId", record.id);
			NAmanage.SetAttr(lbl, "NA_RecordRevision", record.revision);
		end;
		lbl.Size = UDim2.new(1, 0, 0, record.height or 18);
		lbl.Position = UDim2.new(0, 0, 0, record.top or 0);
		lbl.Visible = true;
	end;
	const function removeFilteredRecord(record)
		for i = 1, #filteredMessages do
			if filteredMessages[i] == record then
				table.remove(filteredMessages, i);
				return true;
			end;
		end;
		return false;
	end;
	local layoutDirty = true;
	local layoutWidth = 0;
	local layoutContentHeight = 0;
	local syncQueued = false;
	local syncQueuedFollowBottom = false;
	const function rebuildRecordLayout(force)
		if (not isBindActive()) or not logsFrame or (not logsFrame.Parent) then
			return;
		end;
		const width = getMeasureWidth();
		if (not force) and (not layoutDirty) and layoutWidth == width then
			return;
		end;
		layoutWidth = width;
		const count = #filteredMessages;
		const padding = getPadding();
		local totalHeight = 0;
		for i = 1, count do
			const record = filteredMessages[i];
			const height = ensureRecordHeight(record, width, force);
			record.top = totalHeight;
			totalHeight += height;
			if i < count then
				totalHeight += padding;
			end;
		end;
		layoutContentHeight = totalHeight;
		layoutDirty = false;
		if virtualCanvas then
			virtualCanvas.Size = UDim2.new(1, 0, 0, layoutContentHeight);
		end;
	end;
	local syncVisibleMessages;
	const function requestSync(opts)
		opts = opts or {};
		if opts.followBottom == true then
			syncQueuedFollowBottom = true;
		end;
		if syncQueued then
			return;
		end;
		syncQueued = true;
		syncQueued = false;
		if not isBindActive() then
			syncQueuedFollowBottom = false;
			return;
		end;
		const followBottom = syncQueuedFollowBottom;
		syncQueuedFollowBottom = false;
		syncVisibleMessages({
			followBottom = followBottom
		});
	end;
	const function rebuildFilteredMessages()
		filteredMessages = {};
		const width = getMeasureWidth();
		const query = getQuery();
		for i = 1, #allMessages do
			const record = allMessages[i];
			if record and (record.forceVisible == true or toggles[record.tag]) and matchesQuery(record, query) then
				ensureRecordHeight(record, width);
				filteredMessages[#filteredMessages + 1] = record;
			end;
		end;
		layoutDirty = true;
		requestSync({
			followBottom = isNearBottom()
		});
	end;
	const function appendRecord(rawText, tagText, tagColor, forceVisible, context, timestamp)
		rawText = tostring(rawText or "");
		context = NAmanage.NAConsoleNormalizeContext(context);
		const contextText = NAmanage.NAConsoleContextText(context);
		const source, subsystem = NAmanage.NAConsoleResolveSource(context, rawText);
		const timeText, timestampValue = NAmanage.NAConsoleTimeInfo(timestamp);
		const fingerprint = Lower(tostring(tagText or "Output")).."\0"..rawText.."\0"..contextText;
		const previous = allMessages[#allMessages];
		if NAStuff.DevConsoleCollapseDuplicates ~= false and previous and previous.fingerprint == fingerprint then
			previous.duplicateCount = math.max(1, tonumber(previous.duplicateCount) or 1) + 1;
			previous.lastTimeText = timeText;
			previous.lastTimestamp = timestampValue;
			NAmanage.NAConsoleRefreshRecord(previous);
			const query = getQuery();
			removeFilteredRecord(previous);
			if (previous.forceVisible == true or toggles[previous.tag]) and matchesQuery(previous, query) then
				ensureRecordHeight(previous, getMeasureWidth(), true);
				filteredMessages[#filteredMessages + 1] = previous;
			end;
			layoutDirty = true;
			return previous, true;
		end;
		messageCounter += 1;
		const record = {
			id = messageCounter,
			raw = rawText,
			tag = tagText,
			color = tagColor,
			forceVisible = forceVisible == true,
			context = context,
			contextText = contextText,
			source = source,
			subsystem = subsystem,
			timestamp = timestampValue,
			lastTimestamp = timestampValue,
			timeText = timeText,
			lastTimeText = timeText,
			duplicateCount = 1,
			fingerprint = fingerprint,
			revision = 0,
		};
		NAmanage.NAConsoleRefreshRecord(record);
		allMessages[#allMessages + 1] = record;
		const query = getQuery();
		if (record.forceVisible == true or toggles[tagText]) and matchesQuery(record, query) then
			ensureRecordHeight(record, getMeasureWidth());
			filteredMessages[#filteredMessages + 1] = record;
		end;
		while #allMessages > MAX_MESSAGES do
			const oldest = table.remove(allMessages, 1);
			if oldest then
				removeFilteredRecord(oldest);
			end;
		end;
		layoutDirty = true;
		return record, false;
	end;
	const function flushOverflowSummary()
		if overflowTotal <= 0 then
			return false;
		end;
		const parts = {};
		for _, logType in buttonTypes do
			const count = overflowCounts[logType];
			if count and count > 0 then
				parts[#parts + 1] = tostring(count) .. " " .. logType;
			end;
		end;
		const suffix = (#parts > 0) and (" (" .. Concat(parts, ", ") .. ")") or "";
		appendRecord("[NA] Skipped " .. tostring(overflowTotal) .. " console messages while rate-limiting spam." .. suffix, "Warn", "#ffcc00", { source = "NamelessAdmin"; subsystem = "Console"; event = "queue_overflow"; dropped = overflowTotal; }, os.time and os.time() or nil);
		overflowCounts = {};
		overflowTotal = 0;
		return true;
	end;
	const function clearConsoleState()
		allMessages = {};
		filteredMessages = {};
		NAStuff.NAConsoleRuntimeRecords = allMessages;
		pending = {};
		pendingHead = 1;
		pendingTail = 0;
		overflowCounts = {};
		overflowTotal = 0;
		while #visibleLabels > 0 do
			releaseLabel(table.remove(visibleLabels));
		end;
		if virtualCanvas then
			virtualCanvas.Size = UDim2.new(1, 0, 0, 0);
		end;
		layoutDirty = true;
		layoutWidth = 0;
		layoutContentHeight = 0;
		if logsFrame and logsFrame.Parent then
			if NAmanage.SetLogicalCanvasPosition then
				NAmanage.SetLogicalCanvasPosition(logsFrame, 0, 0);
			else
				logsFrame.CanvasPosition = Vector2.new(0, 0);
			end
			updateCanvasSize(logsFrame, NAUIMANAGER.AUTOSCALER.Scale);
		end;
	end;
	syncVisibleMessages = function(opts)
		opts = opts or {};
		if (not isBindActive()) or not logsFrame or (not logsFrame.Parent) then
			return;
		end;
		const count = #filteredMessages;
		if count <= 0 then
			while #visibleLabels > 0 do
				releaseLabel(table.remove(visibleLabels));
			end;
			if virtualCanvas then
				virtualCanvas.Size = UDim2.new(1, 0, 0, 0);
			end;
			updateCanvasSize(logsFrame, NAUIMANAGER.AUTOSCALER.Scale);
			return;
		end;
		rebuildRecordLayout(false);
		const logPos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(logsFrame) or logsFrame.CanvasPosition;
		local scrollY = logPos.Y;
		local viewHeight = getVisibleHeight();
		if NAmanage.virtView then
			viewHeight, scrollY = NAmanage.virtView(logsFrame, viewHeight, layoutContentHeight, 54);
		end;
		const rowFloor = math.max(18, math.floor(viewHeight / math.max(1, minConsoleRows) + 0.5));
		const dynOverscan = math.max(overscanPx, viewHeight, rowFloor * minConsoleRows);
		const startY = math.max(0, scrollY - dynOverscan);
		const endY = scrollY + viewHeight + dynOverscan;
		local firstIndex, lastIndex;
		for i = 1, count do
			const record = filteredMessages[i];
			const rowStart = record.top or 0;
			const rowEnd = rowStart + (record.height or 18);
			if (not firstIndex) and rowEnd >= startY then
				firstIndex = i;
			end;
			if firstIndex and rowStart <= endY then
				lastIndex = i;
			end;
			if firstIndex and rowStart > endY then
				break;
			end;
		end;
		if not firstIndex then
			firstIndex = count;
			lastIndex = count;
		end;
		lastIndex = math.max(firstIndex, lastIndex or firstIndex);
		const needed = math.max(0, lastIndex - firstIndex + 1);
		while #visibleLabels > needed do
			releaseLabel(table.remove(visibleLabels));
		end;
		if virtualCanvas then
			virtualCanvas.Size = UDim2.new(1, 0, 0, layoutContentHeight);
			virtualCanvas.LayoutOrder = 1;
		end;
		for offset = 1, needed do
			const record = filteredMessages[firstIndex + offset - 1];
			local lbl = visibleLabels[offset];
			if not lbl then
				lbl = acquireLabel();
				visibleLabels[offset] = lbl;
			end;
			if lbl then
				if lbl.Parent ~= virtualCanvas then
					const ok = pcall(function()
						lbl.Parent = virtualCanvas;
					end)
					if not ok then
						lbl = acquireLabel();
						visibleLabels[offset] = lbl;
					end
				end;
				if lbl then
					applyRecordToLabel(lbl, record);
					lbl.LayoutOrder = offset;
				end;
			end;
		end;
		updateCanvasSize(logsFrame, NAUIMANAGER.AUTOSCALER.Scale);
		if opts.followBottom == true then
			local followH = getVisibleHeight();
			if NAmanage.virtView then
				followH = NAmanage.virtView(logsFrame, followH, logsFrame.CanvasSize.Y.Offset, 54);
			end;
			const targetY = math.max(0, logsFrame.CanvasSize.Y.Offset - followH);
			if NAmanage.SetLogicalCanvasPosition then
				NAmanage.SetLogicalCanvasPosition(logsFrame, 0, targetY);
			else
				logsFrame.CanvasPosition = Vector2.new(0, targetY);
			end
		end;
	end;
	for _, logType in buttonTypes do
		const btnContainer = InstanceNew("Frame");
		btnContainer.Name = logType;
		btnContainer.Size = UDim2.new(0, 90, 1, 0);
		btnContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
		btnContainer.Parent = FilterButtons;
		const corner = InstanceNew("UICorner");
		corner.CornerRadius = UDim.new(0, 6);
		corner.Parent = btnContainer;
		const checkbox = InstanceNew("Frame");
		checkbox.Name = "Checkbox";
		checkbox.Size = UDim2.new(0, 18, 0, 18);
		checkbox.Position = UDim2.new(0, 5, 0.5, 0);
		checkbox.AnchorPoint = Vector2.new(0, 0.5);
		checkbox.BackgroundColor3 = toggles[logType] and SELECTED_COLOR or DESELECTED_COLOR;
		checkbox.BorderSizePixel = 0;
		checkbox.Parent = btnContainer;
		const boxCorner = InstanceNew("UICorner");
		boxCorner.CornerRadius = UDim.new(0, 6);
		boxCorner.Parent = checkbox;
		const label = InstanceNew("TextLabel");
		label.Name = "Label";
		label.Text = logType;
		label.Position = UDim2.new(0, 28, 0, 0);
		label.Size = UDim2.new(1, -28, 1, 0);
		label.BackgroundTransparency = 1;
		label.Font = Enum.Font.Gotham;
		label.TextSize = 14;
		label.TextColor3 = Color3.fromRGB(255, 255, 255);
		label.TextXAlignment = Enum.TextXAlignment.Center;
		label.Parent = btnContainer;
		const clickZone = InstanceNew("TextButton");
		clickZone.Name = "ClickArea";
		clickZone.Size = UDim2.new(1, 0, 1, 0);
		clickZone.BackgroundTransparency = 1;
		clickZone.Text = "";
		clickZone.Parent = btnContainer;
		MouseButtonFix(clickZone, function()
			toggles[logType] = not toggles[logType];
			if NAmanage and NAmanage.NASettingsSet then
				local ok, saved = pcall(function()
					return NAmanage.NASettingsSet("devConsoleFilters", toggles);
				end);
				if ok and type(saved) == "table" then
					for _, key in buttonTypes do
						const savedValue = saved[key];
						if type(savedValue) == "boolean" then
							toggles[key] = savedValue;
						end;
					end;
				end;
			end;
			const targetColor = toggles[logType] and SELECTED_COLOR or DESELECTED_COLOR;
			const tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);
			(__lt.cm("TweenService", "Create", checkbox, tweenInfo, {
				BackgroundColor3 = targetColor
			})):Play();
			rebuildFilteredMessages();
		end);
	end;
	NAlib.connect(CONN_KEY, (NAUIMANAGER.NAfilter:GetPropertyChangedSignal("Text")):Connect(function()
		rebuildFilteredMessages();
	end));
	const function reflowConsole()
		const logs = NAUIMANAGER.NAconsoleLogs;
		const filterBox = NAUIMANAGER.NAfilter;
		if not logs or (not logs.Parent) or (not FilterButtons) or (not FilterButtons.Parent) then
			return;
		end;
		const container = logs.Parent;
		const containerPos = container.AbsolutePosition;
		local cursorY = 0;
		if filterBox and filterBox.Parent == container then
			cursorY = filterBox.AbsolutePosition.Y - containerPos.Y + filterBox.AbsoluteSize.Y;
		end;
		cursorY = cursorY + 6;
		FilterButtons.AnchorPoint = Vector2.new(0.5, 0);
		FilterButtons.Position = UDim2.new(0.5, 0, 0, cursorY);
		cursorY = cursorY + FilterButtons.AbsoluteSize.Y + 6;
		logs.AnchorPoint = Vector2.new(0.5, 0);
		logs.Position = UDim2.new(0.5, 0, 0, cursorY);
		const availableHeight = math.max(0, container.AbsoluteSize.Y - cursorY - 8);
		logs.Size = UDim2.new(1, -28, 0, availableHeight);
		const width = getMeasureWidth();
		for i = 1, #filteredMessages do
			const record = filteredMessages[i];
			if record then
				ensureRecordHeight(record, width, true);
			end;
		end;
		layoutDirty = true;
		requestSync({
			followBottom = isNearBottom()
		});
		if NAmanage.ConsoleScroll and NAmanage.ConsoleScroll.scheduleRefresh then
			NAmanage.ConsoleScroll.scheduleRefresh();
		end;
	end;
	const function enqueueMessage(msg, msgTYPE, forceVisible, context, timestamp)
		const rawText = tostring(msg or "");
		local tagText, tagColor = getTagInfo(msgTYPE);
		if forceVisible ~= true and not shouldCaptureTag(tagText) then
			return;
		end;
		const pendingSize = pendingTail - pendingHead + 1;
		if pendingSize >= MAX_PENDING then
			overflowTotal += 1;
			overflowCounts[tagText] = (overflowCounts[tagText] or 0) + 1;
			return;
		end;
		pendingTail += 1;
		pending[pendingTail] = {
			raw = rawText,
			t = tagText,
			c = tagColor,
			f = forceVisible == true,
			ctx = NAmanage.NAConsoleNormalizeContext(context),
			ts = timestamp,
		};
	end;
	const function processPendingQueue()
		if pendingProcessing then
			return;
		end;
		pendingProcessing = true;
		if not isBindActive() or not NAUIMANAGER.NAconsoleLogs or (not NAUIMANAGER.NAconsoleLogs.Parent) then
			pendingProcessing = false;
			return;
		end;
		const followBottom = isNearBottom();
		while pendingHead <= pendingTail do
			const item = pending[pendingHead];
			pending[pendingHead] = nil;
			pendingHead += 1;
			if item then
				appendRecord(item.raw, item.t, item.c, item.f, item.ctx, item.ts);
			end;
		end;
		flushOverflowSummary();
		requestSync({
			followBottom = followBottom
		});
		pending = {};
		pendingHead = 1;
		pendingTail = 0;
		pendingProcessing = false;
	end;
	const function externalMessageTypeFromTag(tag)
		tag = NAmanage.NAConsoleNormalizeTag(tag)
		if tag == "Error" then
			return Enum.MessageType.MessageError
		elseif tag == "Warn" then
			return Enum.MessageType.MessageWarning
		elseif tag == "Info" then
			return Enum.MessageType.MessageInfo
		end
		return nil
	end
	NAmanage._NAConsoleExternalWrite = function(text, tag, context)
		tag = NAmanage.NAConsoleNormalizeTag(tag)
		enqueueMessage(tostring(text or ""), externalMessageTypeFromTag(tag), true, context, os.time and os.time() or nil)
		processPendingQueue()
		return true
	end
	NAmanage._NAConsoleExternalExport = function(formatName)
		return NAmanage.NAConsoleExportRecords(allMessages, formatName)
	end
	NAmanage._NAConsoleExternalClear = function()
		clearConsoleState()
		return true
	end
	do
		const externalPending = NAStuff.NAConsoleExternalPending
		if type(externalPending) == "table" and #externalPending > 0 then
			for i = 1, #externalPending do
				const item = externalPending[i]
				if item then
					enqueueMessage(item.text, externalMessageTypeFromTag(item.tag), true, item.context, item.timestamp)
				end
			end
			NAStuff.NAConsoleExternalPending = {}
		end
	end
	const logService = SafeGetService("LogService");
	NAmanage._menuClearHandlers = NAmanage._menuClearHandlers or setmetatable({}, {
		__mode = "k"
	});
	if NAUIMANAGER.NAconsoleFrame then
		NAmanage._menuClearHandlers[NAUIMANAGER.NAconsoleFrame] = clearConsoleState;
	end;
	do
		local ok, history = pcall(function()
			if logService then
				return __lt.cm("LogService", "GetLogHistory");
			end;
			return nil;
		end);
		if ok and type(history) == "table" then
			for i = 1, #history do
				const entry = history[i];
				if entry then
					const text = entry.message or entry.Message or entry[1];
					const msgType = entry.messageType or entry.MessageType or entry.type;
					const context = entry.context or entry.Context;
					const timestamp = entry.timestamp or entry.Timestamp;
					if text ~= nil then
						const tagText = getTagInfo(msgType);
						if shouldCaptureTag(tagText) then
							enqueueMessage(text, msgType, false, context, timestamp);
						end;
					end;
				end;
			end;
		end;
	end;
	processPendingQueue();
	if logService then
		NAlib.connect(CONN_KEY, logService.MessageOut:Connect(function(msg, msgTYPE, context)
			const tagText = getTagInfo(msgTYPE);
			if not shouldCaptureTag(tagText) then
				return;
			end;
			enqueueMessage(msg, msgTYPE, false, context, os.time and os.time() or nil);
			processPendingQueue();
		end));
	end;
	reflowConsole();
	pcall(function()
		if NAUIMANAGER.NAconsoleFrame then
			NAlib.connect(CONN_KEY, (NAUIMANAGER.NAconsoleFrame:GetPropertyChangedSignal("AbsoluteSize")):Connect(reflowConsole));
		end;
	end);
	pcall(function()
		NAlib.connect(CONN_KEY, (NAUIMANAGER.NAconsoleLogs:GetPropertyChangedSignal("AbsoluteSize")):Connect(function()
			const width = getMeasureWidth();
			for i = 1, #filteredMessages do
				const record = filteredMessages[i];
				if record then
					ensureRecordHeight(record, width, true);
				end;
			end;
			layoutDirty = true;
			requestSync({
				followBottom = isNearBottom()
			});
		end));
	end);
	pcall(function()
		NAlib.connect(CONN_KEY, (NAUIMANAGER.NAconsoleLogs:GetPropertyChangedSignal("CanvasPosition")):Connect(function()
			requestSync();
		end));
	end);

	const function cleanup()
		NAlib.disconnect(CONN_KEY)
		if NAStuff and NAStuff._devConsoleBindGeneration == bindGeneration then
			NAStuff._devConsoleBindGeneration = bindGeneration + 1
		end
		pending = {}
		pendingHead = 1
		pendingTail = 0
		pendingProcessing = false
		syncQueued = false
		syncQueuedFollowBottom = false
		if NAmanage and NAmanage._menuClearHandlers and NAUIMANAGER.NAconsoleFrame and NAmanage._menuClearHandlers[NAUIMANAGER.NAconsoleFrame] == clearConsoleState then
			NAmanage._menuClearHandlers[NAUIMANAGER.NAconsoleFrame] = nil
		end
		if NAmanage and NAmanage._NAConsoleExternalWrite then
			NAmanage._NAConsoleExternalWrite = nil
		end
		if NAmanage and NAmanage._NAConsoleExternalClear then
			NAmanage._NAConsoleExternalClear = nil
		end
		if NAmanage and NAmanage._NAConsoleExternalExport then
			NAmanage._NAConsoleExternalExport = nil
		end
		if NAStuff then
			NAStuff.NAConsoleRuntimeRecords = nil
		end
		while #visibleLabels > 0 do
			releaseLabel(table.remove(visibleLabels))
		end
		while #pool > 0 do
			const pooled = table.remove(pool)
			pcall(function()
				pooled:Destroy()
			end)
		end
		allMessages = {}
		filteredMessages = {}
		pcall(function()
			if FilterButtons then
				FilterButtons:Destroy()
			end
		end)
		pcall(function()
			if virtualCanvas then
				virtualCanvas:Destroy()
			end
		end)
	end
	NAStuff._devConsoleCleanup = cleanup
end;

--[[function NAUISCALEUPD()
	if not Workspace.CurrentCamera then return end

	screenHeight = Workspace.CurrentCamera.ViewportSize.Y
	baseHeight = 720
	AUTOSCALER.Scale = math.clamp(screenHeight / baseHeight, 0.75, 1.25)
end]]

NAStuff.logClrs=NAStuff.logClrs or {
	GREEN   = "#00FF00";
	WHITE   = "#FFFFFF";
	RED     = "#FF0000";
}

NAStuff.binderKillerTags = NAStuff.binderKillerTags or {
	"creator",
	"Creator",
	"creatorPlayer",
	"creatorTag",
	"killer",
	"Killer",
	"attacker",
	"Attacker",
	"DamageOwner",
	"DamageTag",
	"LastDamager",
	"lastDamager",
}

originalIO.binderResolvePlayerFromValue=function(value)
	if typeof(value) == "Instance" then
		if value:IsA("Player") then
			return value
		end
		return __lt.cm("Players", "GetPlayerFromCharacter", value)
	end
	if type(value) == "number" then
		local ok, plr = pcall(function()
			return __lt.cm("Players", "GetPlayerByUserId", value)
		end)
		if ok and plr then
			return plr
		end
	elseif type(value) == "string" then
		const targets = NAmanage.getPlr and NAmanage.getPlr("exactuser:"..value) or {}
		return targets[1]
	end
	return nil
end

originalIO.binderFindPlayerInTag=function(tag)
	if not tag then
		return nil
	end
	if tag:IsA("ObjectValue") then
		return originalIO.binderResolvePlayerFromValue(tag.Value)
	end
	if tag:IsA("StringValue") then
		const targets = NAmanage.getPlr and NAmanage.getPlr("exactuser:"..tag.Value) or {}
		return targets[1]
	end
	if tag:IsA("IntValue") or tag:IsA("NumberValue") then
		local ok, plr = pcall(function()
			return __lt.cm("Players", "GetPlayerByUserId", tag.Value)
		end)
		if ok and plr then
			return plr
		end
	end
	if tag:IsA("ValueBase") then
		return originalIO.binderResolvePlayerFromValue(tag.Value)
	end
	if tag:IsA("Folder") or tag:IsA("Model") then
		for _, child in tag:GetChildren() do
			const result = originalIO.binderFindPlayerInTag(child)
			if result then
				return result
			end
		end
	end
	return originalIO.binderResolvePlayerFromValue(tag)
end

originalIO.binderFindKiller=function(humanoid)
	if not humanoid then
		return nil
	end
	for _, name in NAStuff.binderKillerTags do
		const tag = humanoid:FindFirstChild(name)
		const killer = originalIO.binderFindPlayerInTag(tag)
		if killer then
			return killer
		end
	end
	for _, child in humanoid:GetChildren() do
		const killer = originalIO.binderFindPlayerInTag(child)
		if killer then
			return killer
		end
	end
	return nil
end

originalIO.binderAttachHumanoidListeners=function(plr, hum)
	if not (plr and hum) then
		return
	end
	if not NAmanage.BinderNeedsHumanoidHooks() then
		return
	end
	NAStuff.bHum = NAStuff.bHum or setmetatable({}, {
		__mode = "k"
	})
	const bHumMeta = getmetatable(NAStuff.bHum)
	if not (bHumMeta and bHumMeta.__mode == "k") then
		setmetatable(NAStuff.bHum, {
			__mode = "k"
		})
	end
	NAStuff.bHumCons = NAStuff.bHumCons or setmetatable({}, {
		__mode = "k"
	})
	const bHumConsMeta = getmetatable(NAStuff.bHumCons)
	if not (bHumConsMeta and bHumConsMeta.__mode == "k") then
		setmetatable(NAStuff.bHumCons, {
			__mode = "k"
		})
	end

	const wantDeath = NAmanage.BinderHasEntries("OnDeath")
	const wantKill = NAmanage.BinderHasEntries("OnKill")
	const wantDamage = NAmanage.BinderHasEntries("OnDamage")
	const wantJump = NAmanage.BinderHasEntries("OnJump")

	if not (wantDeath or wantKill or wantDamage or wantJump) then
		return
	end

	const old = NAStuff.bHum[hum]
	if old then
		if old.wantDeath == wantDeath
			and old.wantKill == wantKill
			and old.wantDamage == wantDamage
			and old.wantJump == wantJump then
			return
		end
		if type(old.conns) == "table" then
			for i = 1, #old.conns do
				old.conns[i] = NAmanage.tryDisconnect(old.conns[i])
			end
		end
		if NAStuff.bHum[hum] == old then
			NAStuff.bHum[hum] = nil
		end
		if NAStuff.bHumCons[hum] == old then
			NAStuff.bHumCons[hum] = nil
		end
	end

	const rec = {
		lastHP = hum.Health,
		lastJump = 0,
		dead = false,
		conns = {},
		wantDeath = wantDeath,
		wantKill = wantKill,
		wantDamage = wantDamage,
		wantJump = wantJump,
	}
	NAStuff.bHum[hum] = rec
	NAStuff.bHumCons[hum] = rec

	const function cleanup()
		if NAStuff.bHum[hum] == rec then
			NAStuff.bHum[hum] = nil
		end
		if NAStuff.bHumCons[hum] == rec then
			NAStuff.bHumCons[hum] = nil
		end
		for i = 1, #rec.conns do
			rec.conns[i] = NAmanage.tryDisconnect(rec.conns[i])
		end
	end

	const function alive()
		if not (plr and plr.Parent and hum and hum.Parent) then
			return false
		end
		local ok, hp = pcall(function()
			return hum.Health
		end)
		if ok and tonumber(hp) and hp <= 0 then
			return false
		end
		return true
	end

	const function fireJump()
		if not (wantJump and alive()) then
			return
		end
		const now = tick()
		if now - (tonumber(rec.lastJump) or 0) < 0.12 then
			return
		end
		rec.lastJump = now
		NAmanage.ExecuteBindings("OnJump", plr, hum)
	end

	const function fireDeath()
		if rec.dead then
			return
		end
		rec.dead = true
		const killer = wantKill and originalIO.binderFindKiller(hum) or nil
		Defer(function()
			if wantDeath then
				NAmanage.ExecuteBindings("OnDeath", plr)
			end
			if wantKill and killer then
				NAmanage.ExecuteBindings("OnKill", killer, plr)
			end
		end)
	end

	if wantDamage or wantDeath or wantKill then
		rec.conns[#rec.conns + 1] = hum.HealthChanged:Connect(function(newHP)
			const oldHP = rec.lastHP
			if rec.dead and tonumber(newHP) and newHP > 0 then
				rec.dead = false
			end
			if wantDamage and tonumber(newHP) and tonumber(oldHP) and newHP < oldHP then
				NAmanage.ExecuteBindings("OnDamage", plr, oldHP, newHP)
			end
			rec.lastHP = newHP
		end)
	end
	if wantDeath or wantKill then
		rec.conns[#rec.conns + 1] = hum.Died:Connect(function()
			fireDeath()
		end)
	end
	if wantJump then
		rec.conns[#rec.conns + 1] = hum.Jumping:Connect(function(active)
			if active ~= false then
				fireJump()
			end
		end)
		if plr == LocalPlayer and Services.UserInputService and Services.UserInputService.JumpRequest then
			rec.conns[#rec.conns + 1] = Services.UserInputService.JumpRequest:Connect(function()
				fireJump()
			end)
		end
	end
	if wantJump or wantDeath or wantKill then
		rec.conns[#rec.conns + 1] = hum.StateChanged:Connect(function(_, newState)
			if wantJump and newState == Enum.HumanoidStateType.Jumping then
				fireJump()
			end
			if (wantDeath or wantKill) and newState == Enum.HumanoidStateType.Dead then
				fireDeath()
			end
		end)
	end
	rec.conns[#rec.conns + 1] = hum.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			cleanup()
		end
	end)
	if hum.Health <= 0 and (wantDeath or wantKill) then
		fireDeath()
	end
end

originalIO.binderAttachToolListeners=function(plr, char)
	if not (plr and char) then
		return
	end
	if not NAmanage.BinderNeedsToolHooks() then
		return
	end
	NAStuff.bTool = NAStuff.bTool or setmetatable({}, {
		__mode = "k"
	})
	const bToolMeta = getmetatable(NAStuff.bTool)
	if not (bToolMeta and bToolMeta.__mode == "k") then
		setmetatable(NAStuff.bTool, {
			__mode = "k"
		})
	end
	NAStuff.bToolCons = NAStuff.bToolCons or setmetatable({}, {
		__mode = "k"
	})
	const bToolConsMeta = getmetatable(NAStuff.bToolCons)
	if not (bToolConsMeta and bToolConsMeta.__mode == "k") then
		setmetatable(NAStuff.bToolCons, {
			__mode = "k"
		})
	end

	const wantEquip = NAmanage.BinderHasEntries("OnEquipItem")
	const wantUnequip = NAmanage.BinderHasEntries("OnUnequipItem")

	if not (wantEquip or wantUnequip) then
		return
	end

	const old = NAStuff.bTool[char]
	if old then
		if old.wantEquip == wantEquip and old.wantUnequip == wantUnequip then
			return
		end
		if type(old.conns) == "table" then
			for i = 1, #old.conns do
				old.conns[i] = NAmanage.tryDisconnect(old.conns[i])
			end
		end
		if NAStuff.bTool[char] == old then
			NAStuff.bTool[char] = nil
		end
		if NAStuff.bToolCons[char] == old then
			NAStuff.bToolCons[char] = nil
		end
	end

	const rec = {
		conns = {},
		wantEquip = wantEquip,
		wantUnequip = wantUnequip,
	}
	NAStuff.bTool[char] = rec
	NAStuff.bToolCons[char] = rec

	const function cleanup()
		if NAStuff.bTool[char] == rec then
			NAStuff.bTool[char] = nil
		end
		if NAStuff.bToolCons[char] == rec then
			NAStuff.bToolCons[char] = nil
		end
		for i = 1, #rec.conns do
			rec.conns[i] = NAmanage.tryDisconnect(rec.conns[i])
		end
	end

	if wantEquip then
		rec.conns[#rec.conns + 1] = NAmanage.childAdd(char, function(child)
			if child and child:IsA("Tool") then
				NAmanage.ExecuteBindings("OnEquipItem", plr, child)
			end
		end, function(child)
			return child and child:IsA("Tool")
		end)
	end
	if wantUnequip then
		rec.conns[#rec.conns + 1] = NAmanage.childRem(char, function(child)
			if child and child:IsA("Tool") then
				NAmanage.ExecuteBindings("OnUnequipItem", plr, child)
			end
		end, function(child)
			return child and child:IsA("Tool")
		end)
	end
	rec.conns[#rec.conns + 1] = char.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			cleanup()
		end
	end)
end

originalIO.binderSetupCharacter=function(plr, char)
	if not char then
		return
	end
	if not NAmanage.BinderNeedsCharacterHooks() then
		return
	end
	NAStuff.bSet = NAStuff.bSet or setmetatable({}, {
		__mode = "k"
	})
	const bSetMeta = getmetatable(NAStuff.bSet)
	if not (bSetMeta and bSetMeta.__mode == "k") then
		setmetatable(NAStuff.bSet, {
			__mode = "k"
		})
	end
	NAStuff.bSetCons = NAStuff.bSetCons or setmetatable({}, {
		__mode = "k"
	})
	const bSetConsMeta = getmetatable(NAStuff.bSetCons)
	if not (bSetConsMeta and bSetConsMeta.__mode == "k") then
		setmetatable(NAStuff.bSetCons, {
			__mode = "k"
		})
	end
	if NAStuff.bSet[char] then
		originalIO.binderAttachToolListeners(plr, char)
		const hum = getHum(char)
		if hum then
			originalIO.binderAttachHumanoidListeners(plr, hum)
		end
		return
	end
	NAStuff.bSet[char] = true
	NAStuff.bSetCons[char] = char.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			if NAStuff.bSetCons[char] then
				NAmanage.tryDisconnect(NAStuff.bSetCons[char])
				NAStuff.bSetCons[char] = nil
			end
			NAStuff.bSet[char] = nil
		end
	end)
	originalIO.binderAttachToolListeners(plr, char)
	const hum = getHum(char)
	if hum then
		originalIO.binderAttachHumanoidListeners(plr, hum)
	end
end

NAmanage.RefreshBinderHooks = function()
	if not Services.Players then
		return
	end
	if not NAmanage.BinderNeedsCharacterHooks() then
		return
	end
	for _, plr in __lt.cm("Players", "GetPlayers") do
		const char = plr and plr.Character
		if char then
			originalIO.binderSetupCharacter(plr, char)
		end
	end
end

originalIO.waitForCharacterReady=function(plr)
	if not plr then
		return nil
	end
	while plr.Parent do
		const char = plr.Character
		if char and NAmanage.IsValidESPModel(char, false) then
			return char
		end
		Wait(0.25)
	end
	return nil
end

NAmanage.lcKey = NAmanage.lcKey or function(prefix, plr)
	local id = "unknown"
	if plr then
		const uid = tonumber(plr.UserId)
		if uid and uid > 0 then
			id = tostring(uid)
		elseif plr.Name then
			id = tostring(plr.Name)
		end
	end
	return prefix.."_"..id
end

NAmanage._charAddHub = NAmanage._charAddHub or {
	q = {},
	pending = {},
	set = setmetatable({}, {
		__mode = "k"
	}),
	head = 1,
	tail = 0,
	busy = false,
	kick = false,
}

NAmanage._charAddRun = NAmanage._charAddRun or function()
	const hub = NAmanage._charAddHub
	if type(hub) ~= "table" then
		return
	end
	if hub.busy then
		return
	end
	hub.busy = true
	Spawn(function()
		while hub.head <= hub.tail do
			local budget, waitDelay = NAmanage._evtHubBudget(72, {
				delay = 0,
				ldSc = 0.35,
				ldDel = 0.01,
			})
			while budget > 0 and hub.head <= hub.tail do
				const plr = hub.q[hub.head]
				hub.q[hub.head] = nil
				hub.head += 1
				if plr then
					hub.set[plr] = nil
					const rec = hub.pending[plr]
					hub.pending[plr] = nil
					if rec then
						const char = rec.char
						const fireSpawn = rec.fireSpawn == true
						if plr and char and plr.Parent and char.Parent and plr.Character == char then
							if fireSpawn and NAmanage.BinderHasEntries("OnSpawn") then
								NAmanage.ExecuteBindings("OnSpawn", plr, char)
							end
							if NAmanage.BinderNeedsCharacterHooks() then
								originalIO.binderSetupCharacter(plr, char)
							end
						end
					end
				end
				budget -= 1
			end
			if waitDelay > 0 then
				Wait(waitDelay)
			else
				Wait()
			end
		end
		hub.q = {}
		hub.head = 1
		hub.tail = 0
		hub.busy = false
	end)
end

NAmanage.queueCharacterWork = NAmanage.queueCharacterWork or function(plr, char, fireSpawn)
	if not (plr and char and typeof(char) == "Instance") then
		return
	end
	const hub = NAmanage._charAddHub
	if type(hub) ~= "table" then
		return
	end
	if type(hub.set) ~= "table" then
		hub.set = setmetatable({}, {
			__mode = "k"
		})
	end
	if type(hub.pending) ~= "table" then
		hub.pending = {}
	end
	const prev = hub.pending[plr]
	hub.pending[plr] = {
		char = char,
		fireSpawn = fireSpawn == true or (prev and prev.fireSpawn == true) or false,
	}
	if hub.set[plr] then
		return
	end
	hub.set[plr] = true
	hub.tail += 1
	hub.q[hub.tail] = plr
	if hub.kick then
		return
	end
	hub.kick = true
	Defer(function()
		hub.kick = false
		NAmanage._charAddRun()
	end)
end

originalIO.setupPlayer=function(plr,bruh)
	NAmanage.ExecuteBindings("OnJoin", plr)

	const chatKey = NAmanage.lcKey("playerLifecycle_chat", plr)
	const charKey = NAmanage.lcKey("playerLifecycle_char", plr)
	NAlib.disconnect(chatKey)
	NAlib.disconnect(charKey)

	NAlib.connect(chatKey, plr.Chatted:Connect(function(msg)
		NAmanage.bindToChat(plr, msg)
		NAmanage.ExecuteBindings("OnChatted", plr, msg)
		if NAmanage.WebhookChat then
			NAmanage.WebhookChat(plr, msg)
		end
	end))

	if plr ~= LocalPlayer then
		SpawnCall(function() CheckPermissions(plr) end)
	end

	if ESPPlayersEnabled and ESPAutoTrackAll and (not NAmanage.ESP_ShouldTrackPlayer or NAmanage.ESP_ShouldTrackPlayer(plr)) then
		SpawnCall(function()
			const char = originalIO.waitForCharacterReady(plr)
			if char and (not NAmanage.ESP_ShouldTrackPlayer or NAmanage.ESP_ShouldTrackPlayer(plr)) then
				NAmanage.ESP_Add(plr,true)
			end
		end)
	end

	NAlib.connect(charKey, plr.CharacterAdded:Connect(function(char)
		if NAmanage.BinderHasEntries("OnSpawn") or NAmanage.BinderNeedsCharacterHooks() then
			NAmanage.queueCharacterWork(plr, char, true)
		end
	end))

	if not bruh and plr.Character and NAmanage.BinderNeedsCharacterHooks() then
		NAmanage.queueCharacterWork(plr, plr.Character, false)
	end

	const suppressJoinLeave = NAStuff and NAStuff.StreamerModeEnabled == true
	if NAmanage.jlCfg.JoinLog and not bruh and not suppressJoinLeave then
		NAmanage.NotifyJoinLeave(plr, "Join", "joined")
	end
	if not bruh and not suppressJoinLeave and plr ~= LocalPlayer and NAmanage.jlCfg.NotifyFollowed == true then
		local okFollow, followIdRaw = pcall(function()
			return plr.FollowUserId
		end)
		const followId = okFollow and tonumber(followIdRaw) or 0
		if followId and followId ~= 0 and followId == LocalPlayer.UserId then
			DoNotif(nameChecker(plr).." followed you into game", 3, "Followed Into")
		end
	end
end

for _, plr in __lt.cm("Players", "GetPlayers") do
	originalIO.setupPlayer(plr, true)
	if plr.Character and NAmanage.BinderNeedsCharacterHooks() then
		NAmanage.queueCharacterWork(plr, plr.Character, false)
	end
end

NAlib.disconnect("playerLifecycle")
NAlib.connect("playerLifecycle", NAmanage.playersSub({
	added = function(plr)
		originalIO.setupPlayer(plr)
		if NAmanage.WebhookJoinLeave then
			NAmanage.WebhookJoinLeave(plr, "join")
		end
	end,
	removing = function(plr)
		NAlib.disconnect(NAmanage.lcKey("playerLifecycle_chat", plr))
		NAlib.disconnect(NAmanage.lcKey("playerLifecycle_char", plr))
		const charHub = NAmanage._charAddHub
		if type(charHub) == "table" then
			if type(charHub.pending) == "table" then
				charHub.pending[plr] = nil
			end
			if type(charHub.set) == "table" then
				charHub.set[plr] = nil
			end
		end
		NAmanage.ExecuteBindings("OnLeave", plr)
		NAmanage.ESP_Disconnect(plr)
		const suppressJoinLeave = NAStuff and NAStuff.StreamerModeEnabled == true
		if NAmanage.jlCfg.LeaveLog and not suppressJoinLeave then
			NAmanage.NotifyJoinLeave(plr, "Leave", "left")
		end
		if NAmanage.WebhookJoinLeave then
			NAmanage.WebhookJoinLeave(plr, "leave")
		end
	end,
}))

	SpawnCall(function()
		const HUI = NAlib.distinctHuiGrabber and NAlib.distinctHuiGrabber(Services.CoreGui) or nil;
	const iIdx = {
		click = NAmanage.ensureWeakTable(nil, "k");
		proxy = NAmanage.ensureWeakTable(nil, "k");
		touch = NAmanage.ensureWeakTable(nil, "k");
	};
	NAmanage._interactionIndexActive = NAmanage._interactionIndexActive == true;
	NAmanage._interactionIndexReady = NAmanage._interactionIndexReady == true;
	const function pruneI(kind)
		const list = InstancesTbl[kind];
		const idxMap = iIdx[kind];
		if type(list) ~= "table" or type(idxMap) ~= "table" then
			return;
		end;
		local write = 1;
		for read = 1, #list do
			const inst = list[read];
			const keep = NAmanage.isLiveInstance(inst) and not (HUI and inst:IsDescendantOf(HUI));
			if keep then
				list[write] = inst;
				idxMap[inst] = write;
				write += 1;
			elseif inst then
				idxMap[inst] = nil;
			end;
		end;
		for i = write, #list do
			list[i] = nil;
		end;
	end;
	NAmanage.pruneInteractionIndex = function()
		pruneI("click");
		pruneI("proxy");
		pruneI("touch");
	end;
	const function addI(kind, inst)
		const list = InstancesTbl[kind];
		const idxMap = iIdx[kind];
		if (not list) or (not idxMap) or idxMap[inst] then
			return;
		end;
		const idx = #list + 1;
		list[idx] = inst;
		idxMap[inst] = idx;
	end;
	const function remI(kind, inst)
		const list = InstancesTbl[kind];
		const idxMap = iIdx[kind];
		const idx = idxMap and idxMap[inst];
		if (not list) or (not idxMap) or (not idx) then
			return;
		end;
		const last = #list;
		const lastInst = list[last];
		list[last] = nil;
		if idx ~= last then
			list[idx] = lastInst;
			if lastInst then
				idxMap[lastInst] = idx;
			end;
		end;
		idxMap[inst] = nil;
	end;
	const function regI(inst)
		if not inst or (not inst.Parent) then
			return;
		end;
		if HUI and inst:IsDescendantOf(HUI) then
			return;
		end;
		if inst:IsA("ClickDetector") then
			addI("click", inst);
		elseif inst:IsA("ProximityPrompt") then
			addI("proxy", inst);
		elseif inst:IsA("TouchTransmitter") then
			addI("touch", inst);
		end;
	end;
	const function unregI(inst)
		if not inst then
			return;
		end;
		if inst:IsA("ClickDetector") then
			remI("click", inst);
		elseif inst:IsA("ProximityPrompt") then
			remI("proxy", inst);
		elseif inst:IsA("TouchTransmitter") then
			remI("touch", inst);
		end;
	end;
	const function isITgt(inst)
		if not inst then
			return false
		end
		const cn = inst.ClassName
		return cn == "ClickDetector" or cn == "ProximityPrompt" or cn == "TouchTransmitter"
	end;
	NAmanage.ensureInteractionIndex = function(opts)
		opts = type(opts) == "table" and opts or {};
		if NAmanage._interactionIndexReady == true and opts.force ~= true then
			return true;
		end;
		if opts.force == true then
			for _, kind in { "click", "proxy", "touch" } do
				InstancesTbl[kind] = {};
				iIdx[kind] = NAmanage.ensureWeakTable(nil, "k");
			end;
		end;
		NAmanage._interactionIndexActive = true;
		NAmanage._interactionIndexReady = true;
		NAmanage.ForEachWorkspaceYield(function(inst)
			if isITgt(inst) then
				regI(inst);
			end;
		end, {
			yieldEvery = tonumber(opts.yieldEvery) or 160;
			delayTime = tonumber(opts.delayTime) or 0;
		});
		NAmanage.pruneInteractionIndex();
		return true;
	end;
	const bulkAddRoots = NAmanage.ensureWeakTable(nil, "k");
	const function scanNow(root, fn, onDone)
		if not root or (not fn) then
			return;
		end;
		const q = { root };
		local qi = 1;
		local qn = 1;
		Spawn(function()
			while qi <= qn do
				local budget, waitDelay = NAmanage._evtHubBudget(64, {
					delay = 0,
					ldSc = 0.25,
					ldDel = 0.012,
				});
				while budget > 0 and qi <= qn do
					const inst = q[qi];
					q[qi] = nil;
					qi += 1;
					if inst and (inst == root or inst.Parent) then
						fn(inst);
						local ok, children = pcall(inst.GetChildren, inst);
						if ok and type(children) == "table" then
							for i = 1, #children do
								qn += 1;
								q[qn] = children[i];
							end;
						end;
					end;
					budget -= 1;
				end;
				if qi <= qn then
					if waitDelay > 0 then
						Wait(waitDelay);
					else
						Wait();
					end;
				end;
			end;
			if type(onDone) == "function" then
				pcall(onDone);
			end;
		end);
	end;
	const function runWsH(kind, inst)
		const handlers = (kind == "added") and InstancesTbl.wsAdd or InstancesTbl.wsRem;
		if type(handlers) ~= "table" then
			return;
		end;
		const gateKind = (kind == "added") and "add" or "rem"
		for key, fn in handlers do
			if type(fn) == "function" and (not NAmanage._wsHPasses or NAmanage._wsHPasses(gateKind, key, inst)) then
				pcall(fn, inst);
			end;
		end;
	end;
	const function enqueueDesc(inst, interactState, wsAddFlag, wsRemFlag)
		if not (inst and typeof(inst) == "Instance") then
			return;
		end;
		if interactState ~= nil and isITgt(inst) then
			if interactState then
				regI(inst);
			else
				unregI(inst);
			end;
		end;
		if wsAddFlag == true and NAmanage.hasWsH("add", inst) then
			runWsH("added", inst);
		end;
		if wsRemFlag == true and NAmanage.hasWsH("rem", inst) then
			runWsH("removing", inst);
		end;
	end;
	const function hasBulkAddRoot(inst)
		const RawWorkspace = __lt.gs("Workspace")
		local parent = inst and inst.Parent;
		while parent and parent ~= RawWorkspace do
			if bulkAddRoots[parent] then
				return true;
			end;
			parent = parent.Parent;
		end;
		return false;
	end;
	const function shouldBulkAddScan(inst, interactState, wsAddFlag, wsRemFlag)
		if wsRemFlag == true then
			return false;
		end;
		if not (interactState ~= nil or wsAddFlag == true) then
			return false;
		end;
		if not (inst and inst.Parent) then
			return false;
		end;
		if not (inst:IsA("Model") or inst:IsA("Folder")) then
			return false;
		end;
		local ok, children = pcall(inst.GetChildren, inst);
		return ok and children and #children > 0;
	end;
	const function handleDesc(inst, interactState, wsAddFlag, wsRemFlag)
		if not (inst and typeof(inst) == "Instance") then
			return;
		end;
		if shouldBulkAddScan(inst, interactState, wsAddFlag, wsRemFlag) then
			if hasBulkAddRoot(inst) then
				return;
			end;
			bulkAddRoots[inst] = true;
			scanNow(inst, function(desc)
				enqueueDesc(desc, interactState, wsAddFlag, wsRemFlag);
			end, function()
				bulkAddRoots[inst] = nil;
			end);
			return;
		end;
		if wsRemFlag ~= true and hasBulkAddRoot(inst) then
			return;
		end;
		enqueueDesc(inst, interactState, wsAddFlag, wsRemFlag);
	end;
	NAlib.disconnect("NA_InteractAdded");
	NAlib.connect("NA_InteractAdded", NAmanage.wsSub({
		added = function(inst)
			handleDesc(inst, NAmanage._interactionIndexActive == true and true or nil, true, nil);
		end,
		filterAdded = function(inst)
			if NAmanage.hasWsH("add", inst) then
				return true
			end
			return NAmanage._interactionIndexActive == true and isITgt(inst)
		end,
	}));
	NAlib.disconnect("NA_InteractRemoved");
	NAlib.connect("NA_InteractRemoved", NAmanage.wsSub({
		removing = function(inst)
			handleDesc(inst, NAmanage._interactionIndexActive == true and false or nil, nil, true);
		end,
		filterRemoving = function(inst)
			if NAmanage.hasWsH("rem", inst) then
				return true
			end
			return NAmanage._interactionIndexActive == true and isITgt(inst)
		end,
	}));
end);

SpawnCall(function()
	const fbHumCons = {}
	const function clrFbHum()
		for i = 1, #fbHumCons do
			const con = fbHumCons[i]
			if con then
				pcall(function()
					con:Disconnect()
				end)
				fbHumCons[i] = nil
			end
		end
	end

	const function saveFb(c, fallback)
		const root = c and getRoot(c)
		const cf = root and (NAmanage.UG_clientCFrame(root) or root.CFrame) or fallback
		if cf then
			deathCFrame = cf
			NAStuff.fba_cf = cf
		end
	end

	const function setupFLASHBACK(c)
		if not c then return end
		clrFbHum()
		local hum = c:FindFirstChildOfClass("Humanoid")
		if not hum then
			local okWait, waited = pcall(function()
				return c:WaitForChild("Humanoid", 3)
			end)
			if okWait then
				hum = waited
			end
		end
		if not hum then
			return
		end
		local lastSafe = 0
		const safeSampleInterval = 0.35
		fbHumCons[#fbHumCons + 1] = Services.RunService.Heartbeat:Connect(function()
			const now = os.clock()
			if now - lastSafe < safeSampleInterval then
				return
			end
			lastSafe = now
			if not c.Parent or hum.Health <= 0 then
				return
			end
			const root = getRoot(c)
			if NAmanage.fbaSafe and NAmanage.fbaSafe(root, hum, c) then
				NAStuff.fba_safe = NAmanage.UG_clientCFrame(root) or root.CFrame
			end
		end)
		fbHumCons[#fbHumCons + 1] = hum.HealthChanged:Connect(function(hp)
			if tonumber(hp) and hp <= 0 then
				saveFb(c, NAStuff.fba_safe)
			end
		end)
		fbHumCons[#fbHumCons + 1] = NAmanage.ConnectHumanoidDeath(hum, function()
			saveFb(c, NAStuff.fba_cf or NAStuff.fba_safe)
			NAmanage._persist.lastMode=NAmanage._state and NAmanage._state.mode or "none"
			NAmanage._persist.wasFlying=(FLYING==true)
			if FLYING then
				NAmanage.pauseCurrent()
			end
			NAmanage._clearPhysics(true)
			NAmanage._persist.resumeAfterSpawn=false
		end)
	end

	NAlib.disconnect("flashback_char_added")
	NAlib.connect("flashback_char_added", LocalPlayer.CharacterAdded:Connect(function(c)
		setupFLASHBACK(c)
		NAmanage.ExecuteBindings("OnSpawn", LocalPlayer, c)
		if NAmanage.abQueue then
			NAmanage.abQueue(c)
		end

		NAmanage.connectFlyKey()
		NAmanage.connectVFlyKey()
		NAmanage.connectCFlyKey()
		NAmanage.connectTFlyKey()
		NAmanage.connectTPFlyKey()
		NAmanage.startWatcher()

		SpawnCall(function()
			if not NAmanage._persist or NAmanage._persist.resumeAfterSpawn then
				return
			end
			if not NAmanage._persist.wasFlying then
				return
			end
			const desired=NAmanage._persist.lastMode
			if not desired or desired=="none" then
				NAmanage._persist.wasFlying=false
				return
			end
			if not NAmanage._modeEnabled(desired) then
				NAmanage._persist.wasFlying=false
				return
			end
			local elapsed=0
			while elapsed<5 and (not getChar() or not getRoot(getChar()) or not getHum()) do
				elapsed+=(Wait() or 0.03)
			end
			if not getChar() or not getRoot(getChar()) or not getHum() then
				return
			end
			NAmanage._clearPhysics(true)
			NAmanage._applyMode(desired,true)
			NAmanage._persist.wasFlying=false
		end)
	end))

	NAlib.disconnect("flashback_char_removing")
	NAlib.connect("flashback_char_removing", LocalPlayer.CharacterRemoving:Connect(function()
		clrFbHum()
	end))

	if LocalPlayer.Character then
		setupFLASHBACK(LocalPlayer.Character)
		if NAmanage.abQueue then
			NAmanage.abQueue(LocalPlayer.Character)
		end
	end

	NAmanage.startWatcher()
end)

do
	NAStuff.dTick = NAStuff.dTick or 0
	NAlib.disconnect("NA_MouseDesc")
	if mouse and NAUIMANAGER and NAUIMANAGER.description then
		const desc = NAUIMANAGER.description
		local lastDescText = desc.Text or ""
		local lastDescX = nil
		local lastDescY = nil
		NAlib.connect("NA_MouseDesc", NAmanage.mouseMoveSub(mouse, {
			minInterval = 0.016,
			minDelta = 1,
			fn = function(x, y, now)
			if not desc.Visible then
				return
			end
			x = tonumber(x) or mouse.X or 0
			y = tonumber(y) or mouse.Y or 0
			if x ~= lastDescX or y ~= lastDescY then
				desc.Position = UDim2.fromOffset(x, y)
				lastDescX = x
				lastDescY = y
			end
			now = tonumber(now) or os.clock()
			const textNow = desc.Text or ""
			if textNow ~= lastDescText or now - NAStuff.dTick > 0.12 then
				lastDescText = textNow
				NAStuff.dTick = now
				const sz = NAgui.txtSize(desc, 200, 100)
				desc.Size = UDim2.new(0, sz.X, 0, sz.Y)
			end
		end,
		}))
	end
end

NAgui.badPfx=function(prefix)
	if type(prefix) ~= "string" then
		return true
	end
	local okLen, prefixLen = pcall(utf8.len, prefix)
	if not okLen or prefixLen ~= 1 then
		return true
	end
	return prefix:match("[%w]")
		or prefix:match("[%[%]%(%)%*%^%$%%{}<>]")
		or prefix:match("&amp;")
		or prefix:match("&lt;")
		or prefix:match("&gt;")
		or prefix:match("&quot;")
		or prefix:match("&#x27;")
		or prefix:match("&#x60;")
end

do
	NAStuff.pfTick = NAStuff.pfTick or 0
	NAStuff.canvasTick = NAStuff.canvasTick or 0
	NAStuff.memCleanTick = NAStuff.memCleanTick or 0
	NAStuff.pfxCache = NAStuff.pfxCache or {
		value = nil;
		invalid = nil;
	}
	const function isFrameVisible(frame)
		local node = frame
		while node do
			local okVisible, visible = pcall(function()
				return node.Visible
			end)
			if okVisible and visible == false then
				return false
			end
			node = node.Parent
			if node == nil or node == NAStuff.NASCREENGUI then
				break
			end
		end
		return true
	end
	local canvasFrames = {}
	local canvasIndex = 1
	const function rebuildCanvasFrames()
		canvasFrames = {}
		if NAUIMANAGER then
			canvasFrames[#canvasFrames + 1] = NAUIMANAGER.chatLogs
			canvasFrames[#canvasFrames + 1] = NAUIMANAGER.NAconsoleLogs
			canvasFrames[#canvasFrames + 1] = NAUIMANAGER.commandsList
			canvasFrames[#canvasFrames + 1] = NAUIMANAGER.SettingsList
			canvasFrames[#canvasFrames + 1] = NAUIMANAGER.WaypointList
			canvasFrames[#canvasFrames + 1] = NAUIMANAGER.BindersList
			canvasFrames[#canvasFrames + 1] = NAUIMANAGER.PluginsList
		end
	end
	const function updateNextCanvas(scale)
		if #canvasFrames == 0 then
			rebuildCanvasFrames()
		end
		const total = #canvasFrames
		if total == 0 then
			return
		end
		if canvasIndex > total then
			canvasIndex = 1
		end
		const frame = canvasFrames[canvasIndex]
		canvasIndex += 1
		if frame and frame.Parent and isFrameVisible(frame) and not (NAmanage.GetAttr and NAmanage.GetAttr(frame, "NAManualCanvasSize") == true) then
			updateCanvasSize(frame, scale)
		end
	end
	NAlib.disconnect("NA_RenderStepMain")
	const mainLoopToken = (tonumber(NAStuff._mainLoopToken) or 0) + 1
	NAStuff._mainLoopToken = mainLoopToken
	const watcher = {
		Connected = true,
	}
	function watcher:Disconnect()
		if not self.Connected then
			return
		end
		self.Connected = false
		if NAStuff and NAStuff._mainLoopToken == mainLoopToken then
			NAStuff._mainLoopToken = mainLoopToken + 1
		end
	end
	NAlib.connect("NA_RenderStepMain", watcher)
	Spawn(function()
		local nextCanvasAt = 0
		local nextMemAt = 0
		local nextPrefixAt = 0
		local maintenancePhase = 0
		while watcher.Connected and NAStuff and NAStuff._mainLoopToken == mainLoopToken do
			const now = os.clock()
			const uiVisible = NAStuff and NAStuff.NASCREENGUI and NAStuff.NASCREENGUI.Parent and NAStuff.NASCREENGUI.Enabled ~= false
			const canvasInterval = uiVisible and 0.22 or 1.2
			const prefixInterval = uiVisible and 0.75 or 1.6

			if now >= nextCanvasAt then
				nextCanvasAt = now + canvasInterval
				if NAUIMANAGER then
					const s = NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or 1
					updateNextCanvas(s)
				end
			end

			if now >= nextMemAt then
				nextMemAt = now + 2.5
				maintenancePhase = (maintenancePhase % 4) + 1
				if maintenancePhase == 1 then
					if NAgui and type(NAgui.pruneRegisteredStrokes) == "function" then
						pcall(NAgui.pruneRegisteredStrokes, false)
					end
					if NAmanage and type(NAmanage.prnAllCon) == "function" then
						pcall(NAmanage.prnAllCon, 128)
					end
				elseif maintenancePhase == 2 then
					if NAmanage and type(NAmanage.wsReleaseCacheIfIdle) == "function" then
						pcall(NAmanage.wsReleaseCacheIfIdle)
					end
					if NAmanage and type(NAmanage.pruneBlockedRemoteState) == "function" then
						pcall(NAmanage.pruneBlockedRemoteState)
					end
				elseif maintenancePhase == 3 then
					if NAmanage and type(NAmanage.pruneRuntimeInstanceState) == "function" then
						pcall(NAmanage.pruneRuntimeInstanceState)
					end
				else
					if NAAssetsLoading and type(NAAssetsLoading._trimRemoteStatus) == "function" then
						pcall(NAAssetsLoading._trimRemoteStatus)
					end
					if NAAssetsLoading and type(NAAssetsLoading._trimKnownRemotes) == "function" then
						pcall(NAAssetsLoading._trimKnownRemotes)
					end
					if NAAssetsLoading and type(NAAssetsLoading._trimPrefetchedRemoteCache) == "function" then
						pcall(NAAssetsLoading._trimPrefetchedRemoteCache)
					end
				end
			end

			if now >= nextPrefixAt then
				nextPrefixAt = now + prefixInterval
				const p = opt.prefix
				const pfxSt = NAStuff.pfxCache
				if pfxSt.value ~= p then
					pfxSt.value = p
					pfxSt.invalid = NAgui.badPfx(p)
				end

				if pfxSt.invalid then
					if opt.prefix ~= ";" then
						opt.prefix = ";"
						pfxSt.value = ";"
						pfxSt.invalid = false
						DoNotif("Invalid prefix detected. Resetting to default ';'")
						lastPrefix = ";"
						if NAmanage.SyncPrefixUI then
							NAmanage.SyncPrefixUI()
						end
						const storedPrefix = NAmanage.NASettingsGet("prefix")
						if NAgui.badPfx(storedPrefix) then
							NAmanage.NASettingsSet("prefix", ";")
						end
					end
				else
					lastPrefix = p
				end
			end

			const wakeAt = math.min(nextCanvasAt, nextMemAt, nextPrefixAt)
			local sleepFor = wakeAt - os.clock()
			const minSleep = uiVisible and 0.08 or 0.25
			const maxSleep = uiVisible and 0.22 or 0.75
			if sleepFor < minSleep then
				sleepFor = minSleep
			elseif sleepFor > maxSleep then
				sleepFor = maxSleep
			end
			Wait(sleepFor)
		end
		watcher.Connected = false
	end)
end

--RunService.RenderStepped:Connect(NAUISCALEUPD)

NACaller(function()
	if NAStuff.NAjson and NAStuff.NAjson.annc and NAStuff.NAjson.annc ~= "" then
		DoPopup(NAStuff.NAjson.annc, adminName .. " Announcement");
	end;
end);

--[[ COMMAND BAR BUTTON ]]--
TextLabel = InstanceNew("TextLabel")
UICorner = InstanceNew("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UIStroke = InstanceNew("UIStroke")
TextButton = nil
IconFallbackText = nil
UICorner2 = InstanceNew("UICorner")
UICorner2.CornerRadius = UDim.new(0, 6)

NAgui.getIconShapeOptions = NAgui.getIconShapeOptions or function()
	return {
		"Square",
		"Rounded",
		"Squircle",
		"Circle",
	}
end

NAgui.sanitizeIconShape = NAgui.sanitizeIconShape or function(shape)
	const raw = Lower(tostring(shape or ""))
	if raw == "square" then
		return "Square"
	elseif raw == "rounded" or raw == "round" then
		return "Rounded"
	elseif raw == "squircle" then
		return "Squircle"
	elseif raw == "circle" then
		return "Circle"
	end
	return "Circle"
end

NAgui.getIconShapeCornerRadius = NAgui.getIconShapeCornerRadius or function(shape)
	const normalized = NAgui.sanitizeIconShape(shape)
	if normalized == "Square" then
		return UDim.new(0, 0)
	elseif normalized == "Rounded" then
		return UDim.new(0.18, 0)
	elseif normalized == "Squircle" then
		return UDim.new(0.3, 0)
	end
	return UDim.new(1, 0)
end

NAStuff.IconShape = NAgui.sanitizeIconShape(NAStuff.IconShape)

NAICONASSET = nil

pcall(function()
	const key = isAprilFools() and "nilsongamer99" or "Icon"
	NAICONASSET = NAmanage.getNAImageAsset(key, nil)
end)

TextButton = InstanceNew("ImageButton")
TextButton.Image = NAICONASSET or ""

if NAICONASSET then
	TextButton.Image = NAICONASSET;
else
	IconFallbackText = InstanceNew("TextLabel");
	IconFallbackText.Name = "NAFallbackIconText";
	IconFallbackText.BackgroundTransparency = 1;
	IconFallbackText.AnchorPoint = Vector2.new(0.5, 0.5);
	IconFallbackText.Position = UDim2.new(0.5, 0, 0.5, 0);
	IconFallbackText.Size = UDim2.new(1, 0, 1, 0);
	IconFallbackText.Font = Enum.Font.SourceSansBold;
	IconFallbackText.TextColor3 = Color3.fromRGB(241, 241, 241);
	IconFallbackText.TextSize = 22;
	if isAprilFools() then
		cringyahhnamesidk = {
			"IY",
			"FE",
			"F3X",
			"HD",
			"CMD",
			"Ω",
			"R6",
			"Ø",
			"NA",
			"CMDX"
		};
		IconFallbackText.Text = cringyahhnamesidk[math.random(1, #cringyahhnamesidk)];
	else
		IconFallbackText.Text = "NA";
	end;
	IconFallbackText.TextStrokeTransparency = 0.7;
	IconFallbackText.Parent = TextButton;
end;

NAStuff.NAICONMAIN = TextButton
NAStuff.IconFallbackLabel = IconFallbackText

NAmanage.btUpdate()

TextLabel.Parent = NAStuff.NASCREENGUI
TextLabel.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
TextLabel.BackgroundTransparency = 0.1
TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
TextLabel.Size = UDim2.new(0, 0, 0, 0)
TextLabel.Font = Enum.Font.FredokaOne
TextLabel.Text = NAmanage.getSeasonEmoji().." "..adminName..curVer.." "..NAmanage.getSeasonEmoji()
TextLabel.TextColor3 = Color3.fromRGB(241, 241, 241)
TextLabel.TextSize = 22
TextLabel.TextWrapped = true
TextLabel.TextStrokeTransparency = 0.7
TextLabel.TextTransparency = 1
TextLabel.ZIndex = 9999
TextLabel.Active = true
TextLabel.Selectable = false

UICorner2.CornerRadius = UDim.new(0, 6)
UICorner2.Parent = TextLabel

UIStroke.Parent = TextLabel
UIStroke.Thickness = 2
UIStroke.Color = NAUISTROKER
UIStroke.Transparency = 0.4
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

TextButton.Parent = NAStuff.NASCREENGUI
TextButton.BackgroundTransparency = 0
TextButton.AnchorPoint = Vector2.new(0.5, 0)
TextButton.BorderSizePixel = 0
TextButton.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
TextButton.Position = UDim2.new(0.5, 0, -1, 0)
TextButton.Size = UDim2.new(0, 32 * NAScale, 0, 32 * NAScale)
TextButton.ZIndex = 9999
if IconFallbackText then
	IconFallbackText.ZIndex = TextButton.ZIndex + 1
end

UICorner.CornerRadius = NAgui.getIconShapeCornerRadius(NAStuff.IconShape)
UICorner.Parent = TextButton

TextButton.MouseEnter:Connect(function()
	__lt.cm("TweenService", "Create", TextButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 35 * NAScale, 0, 35 * NAScale)
	}):Play()
end)

TextButton.MouseLeave:Connect(function()
	__lt.cm("TweenService", "Create", TextButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 32 * NAScale, 0, 32 * NAScale)
	}):Play()
end)

NAStuff.iconAppearance = NAStuff.iconAppearance or  {
	background = TextButton.BackgroundTransparency;
	text = (IconFallbackText and IconFallbackText.TextTransparency) or (TextButton:IsA("TextButton") and TextButton.TextTransparency) or nil;
	stroke = (IconFallbackText and IconFallbackText.TextStrokeTransparency) or (TextButton:IsA("TextButton") and TextButton.TextStrokeTransparency) or nil;
	image = TextButton:IsA("ImageButton") and TextButton.ImageTransparency or nil;
}

do
	const prefs = NAStuff.iconAppearancePrefs or {}
	const function clamp01(v)
		local n = tonumber(v)
		if not n then return nil end
		if n < 0 then n = 0 elseif n > 1 then n = 1 end
		return n
	end
	const bg = clamp01(prefs.background)
	const img = clamp01(prefs.image)
	const txt = clamp01(prefs.text)
	const stroke = clamp01(prefs.stroke)
	if bg then
		NAStuff.iconAppearance.background = bg
		TextButton.BackgroundTransparency = bg
	end
	if img and TextButton:IsA("ImageButton") then
		NAStuff.iconAppearance.image = img
		TextButton.ImageTransparency = img
	end
	if txt and IconFallbackText then
		NAStuff.iconAppearance.text = txt
		IconFallbackText.TextTransparency = txt
	end
	if stroke and IconFallbackText then
		NAStuff.iconAppearance.stroke = stroke
		IconFallbackText.TextStrokeTransparency = stroke
	end
end

NAStuff.CustomIcon = NAStuff.CustomIcon or {}

if NAmanage and type(NAmanage.NASettingsGet) == "function" then
	const storedAsset = NAmanage.NASettingsGet("customIconAssetId")
	if typeof(storedAsset) == "string" and storedAsset ~= "" then
		NAStuff.CustomIcon.assetId = storedAsset
	end
	const storedEnabled = NAmanage.NASettingsGet("customIconEnabled")
	if typeof(storedEnabled) == "boolean" then
		NAStuff.CustomIcon.enabled = storedEnabled
	end
end

function NAgui.iconSupported()
	return TextButton and TextButton:IsA("ImageButton")
end

if not NAgui.iconSupported() then
	NAStuff.CustomIcon.enabled = false
else
	if typeof(TextButton.Image) == "string" and TextButton.Image ~= "" then
		NAStuff.CustomIcon.defaultImage = NAStuff.CustomIcon.defaultImage or TextButton.Image
	end
	if typeof(NAStuff.CustomIcon.assetId) ~= "string" or NAStuff.CustomIcon.assetId == "" then
		NAStuff.CustomIcon.assetId = nil
		NAStuff.CustomIcon.enabled = false
	end
end

if typeof(NAStuff.CustomIcon.enabled) ~= "boolean" then
	NAStuff.CustomIcon.enabled = false
end

function NAgui._saveIconSettings()
	if not (NAmanage and type(NAmanage.NASettingsSet) == "function") then
		return
	end
	local assetValue = NAStuff.CustomIcon.assetId
	if typeof(assetValue) ~= "string" or assetValue == "" then
		assetValue = ""
	end
	pcall(NAmanage.NASettingsSet, "customIconAssetId", assetValue)
	pcall(NAmanage.NASettingsSet, "customIconLocalPath", typeof(NAStuff.CustomIcon.localPath) == "string" and NAStuff.CustomIcon.localPath or "")
	pcall(NAmanage.NASettingsSet, "customIconEnabled", NAStuff.CustomIcon.enabled == true)
end

function NAgui.getIconDigits()
	if typeof(NAStuff.CustomIcon.assetId) == "string" then
		return NAStuff.CustomIcon.assetId:match("(%d+)$") or ""
	end
	return ""
end

function NAgui._applyIconState()
	if not NAgui.iconSupported() then
		return false
	end
	const state = NAStuff.CustomIcon
	local targetImage
	if state.enabled and typeof(state.assetId) == "string" and state.assetId ~= "" then
		targetImage = state.assetId
	elseif typeof(state.defaultImage) == "string" and state.defaultImage ~= "" then
		targetImage = state.defaultImage
	end
	local applied = false
	if targetImage and targetImage ~= "" then
		TextButton.Image = targetImage
		applied = true
	else
		TextButton.Image = ""
	end
	if NAStuff.IconFallbackLabel then
		NAStuff.IconFallbackLabel.Visible = not applied
	end
	return applied
end

function NAgui.setIconEnabled(enabled, opts)
	opts = opts or {}
	if not NAgui.iconSupported() then
		return false, "Custom icon requires \"getcustomasset\" support for the NA icon."
	end
	enabled = enabled and true or false
	if enabled and not NAStuff.CustomIcon.assetId then
		if not opts.skipToggle and NAgui.setToggleState then
			NAgui.setToggleState("Use Custom NA Icon", false, { force = true, fire = false })
		end
		return false, "Add an asset id before enabling the custom icon."
	end
	if NAStuff.CustomIcon.enabled == enabled and not opts.force then
		return true
	end
	NAStuff.CustomIcon.enabled = enabled
	NAgui._applyIconState()
	if not opts.skipToggle and NAgui.setToggleState then
		NAgui.setToggleState("Use Custom NA Icon", enabled, { force = true, fire = false })
	end
	NAgui._saveIconSettings()
	return true
end

function NAgui.setIconAsset(inputValue, opts)
	opts = opts or {}
	if not NAgui.iconSupported() then
		return false, "Custom icon requires \"getcustomasset\" support for the NA icon."
	end
	local raw = typeof(inputValue) == "string" and inputValue or tostring(inputValue)
	if typeof(raw) ~= "string" then
		return false, "Enter a valid numeric asset id."
	end
	raw = raw:match("^%s*(.-)%s*$")
	if raw == "" then
		return false, "Enter a valid numeric asset id."
	end
	const digits = raw:match("^rbxassetid://(%d+)$") or raw:match("id=(%d+)") or raw:match("(%d+)$")
	if not digits then
		return false, "Enter a valid numeric asset id."
	end
	const newAsset = "rbxassetid://"..digits
	NAStuff.CustomIcon.assetId = newAsset
	if opts.autoEnable ~= false then
		NAStuff.CustomIcon.enabled = true
	end
	NAgui._applyIconState()
	if opts.autoEnable ~= false and not opts.skipToggle and NAgui.setToggleState then
		NAgui.setToggleState("Use Custom NA Icon", true, { force = true, fire = false })
	end
	NAgui._saveIconSettings()
	return true, digits
end

if NAStuff.CustomIcon.enabled and NAStuff.CustomIcon.assetId and NAgui.iconSupported() then
	NAgui._applyIconState()
end

NAgui.clampIconPositionUDim=function(pos)
	if typeof(pos) ~= "UDim2" then
		return pos
	end
	if not TextButton or not TextButton.Parent then
		return UDim2.new(math.clamp(pos.X.Scale, 0, 1), 0, math.clamp(pos.Y.Scale, 0, 1), 0)
	end
	const container = TextButton.Parent
	local parentSize = container.AbsoluteSize
	if parentSize.X <= 0 or parentSize.Y <= 0 then
		const cam = Services.Workspace and Services.Workspace.CurrentCamera
		if cam then
			parentSize = cam.ViewportSize
		end
	end
	if parentSize.X <= 0 or parentSize.Y <= 0 then
		return UDim2.new(math.clamp(pos.X.Scale, 0, 1), 0, math.clamp(pos.Y.Scale, 0, 1), 0)
	end
	const anchor = TextButton.AnchorPoint or Vector2.new(0, 0)
	local buttonSizeX = TextButton.AbsoluteSize.X
	local buttonSizeY = TextButton.AbsoluteSize.Y
	if buttonSizeX <= 0 then buttonSizeX = 32 * NAScale end
	if buttonSizeY <= 0 then buttonSizeY = 32 * NAScale end
	const absX = pos.X.Scale * parentSize.X + pos.X.Offset
	const absY = pos.Y.Scale * parentSize.Y + pos.Y.Offset
	const minX = anchor.X * buttonSizeX
	local maxX = parentSize.X - (1 - anchor.X) * buttonSizeX
	const minY = anchor.Y * buttonSizeY
	local maxY = parentSize.Y - (1 - anchor.Y) * buttonSizeY
	if maxX < minX then maxX = minX end
	if maxY < minY then maxY = minY end
	const clampedX = math.clamp(absX, minX, maxX)
	const clampedY = math.clamp(absY, minY, maxY)
	return UDim2.new(clampedX / parentSize.X, 0, clampedY / parentSize.Y, 0)
end

NAgui.getClampedIconPosition=function()
	if not TextButton then return nil end
	const clamped = NAgui.clampIconPositionUDim(TextButton.Position)
	if clamped and clamped ~= TextButton.Position then
		TextButton.Position = clamped
	end
	return clamped or TextButton.Position
end

NAgui.applyIconVisibility=function(hidden)
	if not TextButton then return end
	const fallbackText = NAStuff.IconFallbackLabel
	const function setFallbackTrans()
		if not fallbackText then return end
		const defaultText = NAStuff.iconAppearance.text
		const defaultStroke = NAStuff.iconAppearance.stroke
		fallbackText.TextTransparency = hidden and 1 or (defaultText ~= nil and defaultText or 0)
		if defaultStroke ~= nil then
			fallbackText.TextStrokeTransparency = hidden and 1 or defaultStroke
		end
	end
	if IsOnMobile and not IsOnPC then
		TextButton.Visible = true
		TextButton.BackgroundTransparency = hidden and 1 or NAStuff.iconAppearance.background
		if TextButton:IsA("ImageButton") then
			if hidden then
				TextButton.ImageTransparency = 1
			elseif NAStuff.iconAppearance.image ~= nil then
				TextButton.ImageTransparency = NAStuff.iconAppearance.image
			end
		else
			TextButton.TextTransparency = hidden and 1 or (NAStuff.iconAppearance.text or 0)
			if NAStuff.iconAppearance.stroke ~= nil then
				TextButton.TextStrokeTransparency = hidden and 1 or NAStuff.iconAppearance.stroke
			end
		end
	else
		TextButton.Visible = not hidden
		TextButton.BackgroundTransparency = NAStuff.iconAppearance.background
		if TextButton:IsA("ImageButton") then
			if NAStuff.iconAppearance.image ~= nil then
				TextButton.ImageTransparency = NAStuff.iconAppearance.image
			end
		else
			if NAStuff.iconAppearance.text ~= nil then
				TextButton.TextTransparency = NAStuff.iconAppearance.text
			end
			if NAStuff.iconAppearance.stroke ~= nil then
				TextButton.TextStrokeTransparency = NAStuff.iconAppearance.stroke
			end
		end
	end
	setFallbackTrans()
end

NAgui.setIconHidden=function(hidden, opts)
	opts = opts or {}
	hidden = hidden and true or false
	if NAStuff.IconInvisible == hidden and not opts.force then
		return
	end
	NAStuff.IconInvisible = hidden
	NAgui.applyIconVisibility(hidden)
	if FileSupport then
		pcall(NAmanage.NASettingsSet, "iconInvisible", hidden)
	end
	if not opts.skipToggle and NAgui.setToggleState then
		NAgui.setToggleState("Hide NA Icon", hidden, { force = true, fire = false })
	end
end

NAmanage.IconSetInvisible = NAgui.setIconHidden

NAgui.setIconHidden(NAStuff.IconInvisible, { force = true, skipToggle = true })

NAStuff.IconLocked = NAStuff.IconLocked or false

NAgui._NAIconConnName=function()
	return TextButton and "DraggerV2_"..TextButton:GetDebugId() or "DraggerV2_ICON"
end

NAgui.applyIconLock=function(locked)
	if not TextButton then return end
	if locked then
		NAlib.disconnect(NAgui._NAIconConnName())
	else
		NAgui.draggerV2(TextButton)
	end
end

NAgui.setIconLocked=function(locked, opts)
	opts = opts or {}
	locked = locked and true or false
	if NAStuff.IconLocked == locked and not opts.force then return end
	NAStuff.IconLocked = locked
	NAgui.applyIconLock(locked)
	if FileSupport then
		NAmanage.NASettingsSet("iconLocked", locked)
	end
	if not opts.skipToggle and NAgui.setToggleState then
		NAgui.setToggleState("Lock NA Icon", locked, { force = true, fire = false })
	end
end

NAmanage.IconSetLocked = NAgui.setIconLocked

swooshySWOOSH = false

function Swoosh()
	__lt.cm("TweenService", "Create", TextButton, TweenInfo.new(1.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Rotation = 720}):Play()
	if not NAStuff.IconLocked then
		NAgui.draggerV2(TextButton)
	end
	if swooshySWOOSH then return end
	swooshySWOOSH = true
	TextButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local endConn
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					if FileSupport and NAiconSaveEnabled then
						const pos = NAgui.getClampedIconPosition() or TextButton.Position
						pcall(NAmanage.NASettingsSet, "iconPosition", {
							X = pos.X.Scale;
							Y = pos.Y.Scale;
						})
						pcall(NAmanage.NASettingsSet, "iconKeepPosition", true)
					end
					if endConn then
						endConn:Disconnect()
						endConn = nil
					end
				end
			end)
		end
	end)
end

function mainNameless()
	const txtLabel = TextLabel
	const hideStartup = type(NAmanage.isStartupHidden) == "function" and NAmanage.isStartupHidden() == true
	const showIntroLabel = not hideStartup and not (NAmanage.jlCfg and NAmanage.jlCfg.IconLabel == false)
	if txtLabel and not showIntroLabel then
		txtLabel.Visible = false
	end
	local fadeOutStarted = false

	const function fadeOut()
		if fadeOutStarted or not showIntroLabel or not txtLabel then return end
		fadeOutStarted = true
		const fadeOutTween = __lt.cm("TweenService", "Create", txtLabel, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut), {
			TextTransparency = 1,
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.52, 20),
			Size = UDim2.new(0, 0, 0, 0)
		})
		fadeOutTween:Play()
		fadeOutTween.Completed:Once(function()
			txtLabel:Destroy()
		end)
	end

	if showIntroLabel and txtLabel then
		txtLabel.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				fadeOut()
			end
		end)

		const textWidth = __lt.cm("TextService", "GetTextSize", txtLabel.Text, txtLabel.TextSize, txtLabel.Font, Vector2.new(math.huge, math.huge)).X
		const finalSize = UDim2.new(0, textWidth + 80, 0, 40)

		const appearTween = __lt.cm("TweenService", "Create", txtLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Size = finalSize,
			BackgroundTransparency = 0.1,
			TextTransparency = 0,
		})

		const riseTween = __lt.cm("TweenService", "Create", txtLabel, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, 0, 0.48, 0)
		})

		appearTween:Play()
		riseTween:Play()
	end

	TextButton.Size = UDim2.new(0, 0, 0, 0)
	if TextButton:IsA("TextButton") then
		TextButton.TextTransparency = 1
	end

	local targetPos = UDim2.new(0.5, 0, 0.1, 0)

	if NAmanage and type(NAmanage.NASettingsGet) == "function" then
		const data = NAmanage.NASettingsGet("iconPosition")
		if type(data) == "table" then
			const x = math.clamp(tonumber(data.X) or 0.5, 0, 1)
			const y = math.clamp(tonumber(data.Y) or 0.1, 0, 1)
			targetPos = UDim2.new(x, 0, y, 0)
		end
	end

	targetPos = NAgui.clampIconPositionUDim(targetPos)
	if FileSupport and NAiconSaveEnabled then
		pcall(NAmanage.NASettingsSet, "iconPosition", {
			X = targetPos.X.Scale;
			Y = targetPos.Y.Scale;
		})
		pcall(NAmanage.NASettingsSet, "iconKeepPosition", true)
	end
	const introPos = NAgui.clampIconPositionUDim(UDim2.new(targetPos.X.Scale, 0, targetPos.Y.Scale - 0.15, -20)) or targetPos
	TextButton.Position = introPos

	const tweenProps = {
		Size = UDim2.new(0, 32 * NAScale, 0, 32 * NAScale),
		Position = targetPos
	}

	if TextButton:IsA("TextButton") then
		tweenProps.TextTransparency = 0
	end

	const appearBtnTween = __lt.cm("TweenService", "Create", TextButton, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), tweenProps)
	appearBtnTween:Play()

	Swoosh()

	if showIntroLabel and txtLabel then
		Wait(2.5)
		fadeOut()
	end
end

NAmanage.Wrap(mainNameless)()
if NAmanage.Topbar_Init then
	if not (TopBarApp and TopBarApp.top and TopBarApp.top.Parent) then
		pcall(NAmanage.Topbar_Init)
	elseif NAmanage.Topbar_ClampToggle then
		pcall(NAmanage.Topbar_ClampToggle)
	end
end
if NAmanage.SideSwipe_Init then
	if not (SideSwipeApp and SideSwipeApp.gui and SideSwipeApp.gui.Parent) then
		pcall(NAmanage.SideSwipe_Init)
	elseif NAmanage.SideSwipe_PositionHandles then
		pcall(NAmanage.SideSwipe_PositionHandles)
	end
end
if NAmanage.finishLoadingUI then
	NAStuff._mainNamelessReady = true
	if NAmanage.completeStartupLoading then
		NAmanage.completeStartupLoading("ready")
	end
end

NAgui.setIconLocked(NAStuff.IconLocked, { force = true, skipToggle = true })

MouseButtonFix(TextButton,function()
	NAgui.activateCmdInput({
		clear = true,
		prefixChar = tostring(opt.prefix or ""):sub(1, 1)
	})
end)

-- ownership trail is generated from _sourceTrail in the Contributors settings tab
