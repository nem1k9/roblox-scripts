--!nocheck
-- Cold War [VIETNAM] key system (PlatoBoost).
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/nem1k9/roblox-scripts/main/key_system.luau"))()

local SERVICE   = 33823
local SECRET    = "6652969a-8d36-436f-8de4-f4c57f14dc04"
local USE_NONCE = true
local MAIN_URL  = "https://raw.githubusercontent.com/nem1k9/roblox-scripts/main/cold_war_vietnam.luau"
local SAVE_FOLDER = "coldwar"
local KEY_FILE    = SAVE_FOLDER .. "/key.txt"

local function LOG(...) warn("[CW/key] ", ...) end

----------------------------------------------------------------------
-- sha256 (bit32 if available, pure-Lua fallback otherwise).
----------------------------------------------------------------------
local sha256
do
	local band, bor, bxor, bnot, rshift, lshift
	if type(bit32) == "table" then
		band, bor, bxor, bnot, rshift, lshift =
			bit32.band, bit32.bor, bit32.bxor, bit32.bnot, bit32.rshift, bit32.lshift
	else
		-- Pure-Lua. 32-bit modular.
		local MOD = 2^32
		local MASK = MOD - 1
		local function _xor2(x, y)
			local r, p = 0, 1
			while x > 0 or y > 0 do
				local xa, yb = x % 2, y % 2
				if xa ~= yb then r = r + p end
				x = (x - xa) / 2
				y = (y - yb) / 2
				p = p * 2
			end
			return r
		end
		local function _and2(x, y)
			local r, p = 0, 1
			while x > 0 and y > 0 do
				if x % 2 == 1 and y % 2 == 1 then r = r + p end
				x = (x - x % 2) / 2
				y = (y - y % 2) / 2
				p = p * 2
			end
			return r
		end
		band = function(a, b, c, d)
			local r = _and2(a % MOD, b % MOD)
			if c then r = _and2(r, c % MOD) end
			if d then r = _and2(r, d % MOD) end
			return r
		end
		bxor = function(a, b, c, d)
			local r = _xor2(a % MOD, b % MOD)
			if c then r = _xor2(r, c % MOD) end
			if d then r = _xor2(r, d % MOD) end
			return r
		end
		bnot = function(x) return MASK - (x % MOD) end
		rshift = function(x, n)
			if n >= 32 then return 0 end
			return math.floor((x % MOD) / 2^n)
		end
		lshift = function(x, n)
			if n >= 32 then return 0 end
			return (x * 2^n) % MOD
		end
	end

	local function rrotate(x, n)
		return bor(rshift(x, n), lshift(x, 32 - n)) % 2^32
	end

	local K = {
		0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
		0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
		0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
		0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
		0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
		0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
		0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
		0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
	}

	local function u32be(n, len)
		local out = ""
		for i = 1, len do
			local b = n % 256
			out = string.char(b) .. out
			n = (n - b) / 256
		end
		return out
	end

	local function readu32(s, i)
		return s:byte(i) * 0x1000000 + s:byte(i+1) * 0x10000 + s:byte(i+2) * 0x100 + s:byte(i+3)
	end

	sha256 = function(msg)
		local len = #msg
		local pad = 64 - ((len + 9) % 64)
		msg = msg .. "\128" .. string.rep("\0", pad) .. u32be(8 * len, 8)
		local H = {0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}
		for i = 1, #msg, 64 do
			local w = {}
			for j = 1, 16 do w[j] = readu32(msg, i + (j-1)*4) end
			for j = 17, 64 do
				local s0 = bxor(rrotate(w[j-15], 7), rrotate(w[j-15], 18), rshift(w[j-15], 3))
				local s1 = bxor(rrotate(w[j-2], 17), rrotate(w[j-2], 19), rshift(w[j-2], 10))
				w[j] = (w[j-16] + s0 + w[j-7] + s1) % 2^32
			end
			local a,b,c,d,e,f,g,h = H[1],H[2],H[3],H[4],H[5],H[6],H[7],H[8]
			for j = 1, 64 do
				local S1 = bxor(rrotate(e,6), rrotate(e,11), rrotate(e,25))
				local ch = bxor(band(e,f), band(bnot(e),g))
				local t1 = (h + S1 + ch + K[j] + w[j]) % 2^32
				local S0 = bxor(rrotate(a,2), rrotate(a,13), rrotate(a,22))
				local mj = bxor(band(a,b), band(a,c), band(b,c))
				local t2 = (S0 + mj) % 2^32
				h = g; g = f; f = e; e = (d + t1) % 2^32
				d = c; c = b; b = a; a = (t1 + t2) % 2^32
			end
			H[1]=(H[1]+a)%2^32 H[2]=(H[2]+b)%2^32 H[3]=(H[3]+c)%2^32 H[4]=(H[4]+d)%2^32
			H[5]=(H[5]+e)%2^32 H[6]=(H[6]+f)%2^32 H[7]=(H[7]+g)%2^32 H[8]=(H[8]+h)%2^32
		end
		return string.format("%08x%08x%08x%08x%08x%08x%08x%08x",
			H[1],H[2],H[3],H[4],H[5],H[6],H[7],H[8])
	end
end

----------------------------------------------------------------------
-- Minimal JSON. Robust against BOM/leading whitespace. We only need
-- small flat objects, so this is intentionally not a full parser.
----------------------------------------------------------------------
local json = {}

do
	local function esc_str(s)
		return '"' .. s:gsub('[%z\1-\31\\"]', function(c)
			local b = c:byte()
			if c == "\\" then return "\\\\" end
			if c == "\"" then return "\\\"" end
			if c == "\n" then return "\\n" end
			if c == "\r" then return "\\r" end
			if c == "\t" then return "\\t" end
			return string.format("\\u%04x", b)
		end) .. '"'
	end

	local enc_v
	enc_v = function(v)
		local t = type(v)
		if t == "string" then return esc_str(v) end
		if t == "number" or t == "boolean" then return tostring(v) end
		if t == "nil" then return "null" end
		if t == "table" then
			if v[1] ~= nil or next(v) == nil then
				local parts = {}
				for i, x in ipairs(v) do parts[i] = enc_v(x) end
				return "[" .. table.concat(parts, ",") .. "]"
			end
			local parts = {}
			for k, x in pairs(v) do
				parts[#parts+1] = esc_str(tostring(k)) .. ":" .. enc_v(x)
			end
			return "{" .. table.concat(parts, ",") .. "}"
		end
		error("cannot encode " .. t)
	end
	json.encode = enc_v
end

-- Strip BOM and trim both ends.
local function clean_body(s)
	if type(s) ~= "string" then return "" end
	-- UTF-8 BOM
	if s:sub(1,3) == "\239\187\191" then s = s:sub(4) end
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Narrow JSON decoder: only what PlatoBoost returns.
-- Supports {} [] "str" number true false null nested arbitrarily.
do
	local parse_value
	local function skip_ws(s, i)
		while i <= #s do
			local c = s:sub(i,i)
			if c ~= " " and c ~= "\t" and c ~= "\n" and c ~= "\r" then return i end
			i = i + 1
		end
		return i
	end

	local function parse_str(s, i)
		assert(s:sub(i,i) == '"', "expected string")
		local out, j = {}, i + 1
		while j <= #s do
			local c = s:sub(j,j)
			if c == '"' then
				return table.concat(out), j + 1
			elseif c == '\\' then
				local n = s:sub(j+1,j+1)
				if     n == '"' then out[#out+1] = '"'
				elseif n == '\\' then out[#out+1] = '\\'
				elseif n == '/' then out[#out+1] = '/'
				elseif n == 'n' then out[#out+1] = '\n'
				elseif n == 't' then out[#out+1] = '\t'
				elseif n == 'r' then out[#out+1] = '\r'
				elseif n == 'b' then out[#out+1] = '\b'
				elseif n == 'f' then out[#out+1] = '\f'
				elseif n == 'u' then
					local hex = s:sub(j+2, j+5)
					out[#out+1] = string.char(tonumber(hex, 16) % 256)
					j = j + 4
				else out[#out+1] = n end
				j = j + 2
			else
				out[#out+1] = c
				j = j + 1
			end
		end
		error("unterminated string in json")
	end

	local function parse_num(s, i)
		local a = i
		while i <= #s do
			local c = s:sub(i,i)
			if not c:match("[%d%.%-%+eE]") then break end
			i = i + 1
		end
		return tonumber(s:sub(a, i-1)), i
	end

	local function parse_lit(s, i)
		if s:sub(i, i+3) == "true"  then return true,  i + 4 end
		if s:sub(i, i+4) == "false" then return false, i + 5 end
		if s:sub(i, i+3) == "null"  then return nil,   i + 4 end
		error("bad literal at " .. i)
	end

	local function parse_arr(s, i)
		local out, n = {}, 0
		i = skip_ws(s, i + 1)
		if s:sub(i,i) == "]" then return out, i + 1 end
		while true do
			local v
			v, i = parse_value(s, i)
			n = n + 1
			out[n] = v
			i = skip_ws(s, i)
			local c = s:sub(i,i)
			if c == "]" then return out, i + 1 end
			if c ~= "," then error("expected , or ] in array at " .. i) end
			i = skip_ws(s, i + 1)
		end
	end

	local function parse_obj(s, i)
		local out = {}
		i = skip_ws(s, i + 1)
		if s:sub(i,i) == "}" then return out, i + 1 end
		while true do
			i = skip_ws(s, i)
			local k
			k, i = parse_str(s, i)
			i = skip_ws(s, i)
			if s:sub(i,i) ~= ":" then error("expected : at " .. i) end
			i = skip_ws(s, i + 1)
			local v
			v, i = parse_value(s, i)
			out[k] = v
			i = skip_ws(s, i)
			local c = s:sub(i,i)
			if c == "}" then return out, i + 1 end
			if c ~= "," then error("expected , or } in object at " .. i) end
			i = i + 1
		end
	end

	parse_value = function(s, i)
		i = skip_ws(s, i)
		local c = s:sub(i,i)
		if c == '"' then return parse_str(s, i) end
		if c == '{' then return parse_obj(s, i) end
		if c == '[' then return parse_arr(s, i) end
		if c == 't' or c == 'f' or c == 'n' then return parse_lit(s, i) end
		if c == '-' or c:match("%d") then return parse_num(s, i) end
		error("unexpected char " .. tostring(c) .. " at " .. i .. " (near: " .. s:sub(math.max(1, i-5), i+20) .. ")")
	end

	function json.decode(s)
		s = clean_body(s)
		if s == "" then error("empty json body") end
		local v = parse_value(s, 1)
		return v
	end
end

----------------------------------------------------------------------
-- Executor shims (be generous with aliases, Roblox is a zoo).
----------------------------------------------------------------------
local fRequest   = (syn and syn.request) or (http and http.request) or request or http_request or fluxus and fluxus.request
local fClipboard = setclipboard or toclipboard or set_clipboard
	or (Clipboard and Clipboard.set) or (syn and syn.write_clipboard)
local fWritefile = writefile
local fReadfile  = readfile
local fIsfile    = isfile
local fDelfile   = delfile
local fMakefolder= makefolder
local fIsfolder  = isfolder
local fHwid      = gethwid or (syn and syn.hwid) or function()
	return tostring(game:GetService("Players").LocalPlayer.UserId)
end

if not fRequest then
	error("[CW/key] executor has no http request function")
end
if not fClipboard then
	LOG("warning: executor has no setclipboard — Copy Link will not fill clipboard, link will be printed to console")
end

if fMakefolder and fIsfolder and not fIsfolder(SAVE_FOLDER) then
	pcall(fMakefolder, SAVE_FOLDER)
end

----------------------------------------------------------------------
-- PlatoBoost client.
----------------------------------------------------------------------
local host = "https://api.platoboost.com"
do
	local ok, r = pcall(fRequest, { Url = host .. "/public/connectivity", Method = "GET" })
	if not ok or not r or (r.StatusCode or r.Status or r.status_code) ~= 200 then
		host = "https://api.platoboost.net"
		LOG("primary host unreachable, falling back to " .. host)
	end
end

-- Response unification. Executors use StatusCode/Body, status_code/body, Status, etc.
local function unwrap(resp)
	if type(resp) ~= "table" then return nil, "no response" end
	local status = resp.StatusCode or resp.status_code or resp.Status or resp.status
	local body   = resp.Body or resp.body
	return status, body
end

local function nonce()
	local s = {}
	for i = 1, 16 do s[i] = string.char(math.random(97, 122)) end
	return table.concat(s)
end

local function cacheLink()
	local payload = json.encode({ service = SERVICE, identifier = sha256(fHwid()) })
	local resp = fRequest({
		Url = host .. "/public/start",
		Method = "POST",
		Body = payload,
		Headers = { ["Content-Type"] = "application/json" },
	})
	local status, body = unwrap(resp)
	if status ~= 200 then
		LOG("start failed, status=" .. tostring(status) .. " body=" .. tostring(body))
		return false, "server returned status " .. tostring(status)
	end
	local ok, d = pcall(json.decode, body)
	if not ok then
		LOG("start: json decode failed. raw body:", body)
		return false, "bad response from server"
	end
	if d.success and d.data and d.data.url then
		return true, d.data.url
	end
	return false, tostring(d.message or "server rejected request")
end

local function verifyKey(key)
	local n = nonce()
	local url = host .. "/public/whitelist/" .. tostring(SERVICE)
		.. "?identifier=" .. sha256(fHwid())
		.. "&key=" .. key
		.. (USE_NONCE and ("&nonce=" .. n) or "")
	local resp = fRequest({ Url = url, Method = "GET" })
	local status, body = unwrap(resp)
	if status ~= 200 then
		LOG("whitelist failed, status=" .. tostring(status) .. " body=" .. tostring(body))
		return false, "server status " .. tostring(status)
	end
	local ok, d = pcall(json.decode, body)
	if not ok then
		LOG("whitelist: json decode failed. raw body:", body)
		return false, "bad response from server"
	end
	if not d.success then return false, tostring(d.message or "rejected") end
	if d.data and d.data.valid then
		if USE_NONCE then
			local want = sha256("true-" .. n .. "-" .. SECRET)
			if d.data.hash ~= want then return false, "integrity check failed" end
		end
		return true
	end
	-- Not whitelisted. Try redeeming if key starts with KEY_.
	if key:sub(1,4) == "KEY_" then
		local n2 = nonce()
		local body2 = { identifier = sha256(fHwid()), key = key }
		if USE_NONCE then body2.nonce = n2 end
		local r2 = fRequest({
			Url = host .. "/public/redeem/" .. tostring(SERVICE),
			Method = "POST",
			Body = json.encode(body2),
			Headers = { ["Content-Type"] = "application/json" },
		})
		local s2, b2 = unwrap(r2)
		if s2 ~= 200 then
			LOG("redeem failed, status=" .. tostring(s2) .. " body=" .. tostring(b2))
			return false, "redeem status " .. tostring(s2)
		end
		local ok2, d2 = pcall(json.decode, b2)
		if not ok2 then
			LOG("redeem: json decode failed. raw body:", b2)
			return false, "bad response from server"
		end
		if d2.success and d2.data and d2.data.valid then
			if USE_NONCE then
				local want = sha256("true-" .. n2 .. "-" .. SECRET)
				if d2.data.hash ~= want then return false, "integrity check failed" end
			end
			return true
		end
		return false, tostring(d2.message or "key rejected")
	end
	return false, "key is invalid"
end

----------------------------------------------------------------------
-- Launch main under a verified key.
----------------------------------------------------------------------
local function launch(key)
	getgenv().__CW_AUTH = {
		key = key,
		hwid_hash = sha256(fHwid()),
		ts = os.time(),
	}
	local ok, body = pcall(game.HttpGet, game, MAIN_URL, true)
	if not ok or type(body) ~= "string" or #body < 32 then
		LOG("failed to fetch main: " .. tostring(body))
		return
	end
	local fn, err = loadstring(body, "=cw_main")
	if not fn then LOG("loadstring: " .. tostring(err)); return end
	local okRun, errRun = pcall(fn)
	if not okRun then LOG("main error: " .. tostring(errRun)) end
end

----------------------------------------------------------------------
-- Try saved key first.
----------------------------------------------------------------------
if fIsfile and fReadfile and fIsfile(KEY_FILE) then
	local saved = fReadfile(KEY_FILE)
	if type(saved) == "string" and #saved > 0 then
		local ok = verifyKey(saved)
		if ok then
			launch(saved)
			return
		else
			if fDelfile then pcall(fDelfile, KEY_FILE) end
		end
	end
end

----------------------------------------------------------------------
-- GUI.
----------------------------------------------------------------------
local CoreGui
do
	local okHui, hui = pcall(function() return gethui and gethui() end)
	if okHui and hui then CoreGui = hui else CoreGui = game:GetService("CoreGui") end
end

for _, old in ipairs(CoreGui:GetChildren()) do
	if old.Name == "CW_KEY_GUI" then pcall(function() old:Destroy() end) end
end

local gui = Instance.new("ScreenGui")
gui.Name = "CW_KEY_GUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(380, 210)
frame.Position = UDim2.new(0.5, -190, 0.5, -105)
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", frame); stroke.Color = Color3.fromRGB(60, 60, 70); stroke.Thickness = 1

local title = Instance.new("TextLabel", frame)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -16, 0, 28)
title.Position = UDim2.fromOffset(8, 6)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(230, 230, 235)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Cold War [VIETNAM] — Key System"

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(1, -24, 0, 34)
box.Position = UDim2.fromOffset(12, 42)
box.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
box.BorderSizePixel = 0
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.TextColor3 = Color3.fromRGB(230, 230, 235)
box.PlaceholderText = "paste key here"
box.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
box.Text = ""
box.ClearTextOnFocus = false
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
local bp = Instance.new("UIPadding", box); bp.PaddingLeft = UDim.new(0, 10); bp.PaddingRight = UDim.new(0, 10)

local function mkBtn(text, x, w, color)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.fromOffset(w, 34)
	b.Position = UDim2.fromOffset(x, 86)
	b.BackgroundColor3 = color
	b.BorderSizePixel = 0
	b.AutoButtonColor = true
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(240, 240, 245)
	b.Text = text
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local copyBtn   = mkBtn("Copy Link",     12,  175, Color3.fromRGB(50, 90, 160))
local verifyBtn = mkBtn("Verify & Load", 193, 175, Color3.fromRGB(60, 140, 80))

local statusLbl = Instance.new("TextLabel", frame)
statusLbl.BackgroundTransparency = 1
statusLbl.Size = UDim2.new(1, -24, 0, 82)
statusLbl.Position = UDim2.fromOffset(12, 128)
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 13
statusLbl.TextColor3 = Color3.fromRGB(190, 190, 200)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextYAlignment = Enum.TextYAlignment.Top
statusLbl.TextWrapped = true
statusLbl.Text = "Press Copy Link, complete the checkpoint in your browser, paste the key here, then Verify."

local function status(msg) statusLbl.Text = msg end

copyBtn.MouseButton1Click:Connect(function()
	copyBtn.Text = "..."
	task.spawn(function()
		local ok, link = cacheLink()
		if ok then
			local copied = false
			if fClipboard then
				local ok2 = pcall(fClipboard, link)
				copied = ok2
			end
			if copied then
				status("Link copied to clipboard. Open it in your browser.")
			else
				status("Clipboard not available on this executor. Link printed to F9 console:\n" .. link)
				print("[CW/key] LINK:", link)
			end
		else
			status("Error: " .. tostring(link))
		end
		copyBtn.Text = "Copy Link"
	end)
end)

verifyBtn.MouseButton1Click:Connect(function()
	local key = box.Text
	if #key < 4 then status("Enter a key first.") return end
	verifyBtn.Text = "..."
	task.spawn(function()
		local ok, err = verifyKey(key)
		if ok then
			status("Key accepted. Loading...")
			if fWritefile then pcall(fWritefile, KEY_FILE, key) end
			pcall(function() gui:Destroy() end)
			launch(key)
		else
			status("Rejected: " .. tostring(err))
			verifyBtn.Text = "Verify & Load"
		end
	end)
end)
