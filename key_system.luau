--!nocheck
-- Cold War [VIETNAM] key system (PlatoBoost).
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/nem1k9/roblox-scripts/main/key_system.luau"))()
-- On success loads the main (obfuscated) script.

---------------------------------------------------------------------------------------------------
-- CONFIG
---------------------------------------------------------------------------------------------------
local SERVICE = 33823
local SECRET  = "6652969a-8d36-436f-8de4-f4c57f14dc04"
local USE_NONCE = true

-- Where the obfuscated main script lives.
local MAIN_URL = "https://raw.githubusercontent.com/nem1k9/roblox-scripts/main/cold_war_vietnam.luau"

-- Folder you already created in the workspace. Change to whatever yours is called.
local SAVE_FOLDER = "coldwar"
local KEY_FILE    = SAVE_FOLDER .. "/key.txt"

---------------------------------------------------------------------------------------------------
-- json + sha256 (compact, from PlatoBoost reference)
---------------------------------------------------------------------------------------------------
local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}
local function w(x)return(string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end))end
local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end
local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end
local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;return F end
local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end
local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end
local function sha256(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end

local JSON do
	local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local Bn=function()return"null"end;local v2=function(M,z)local _={}z=z or{}if z[M]then error("circular")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\"]',S)..'"'end;local a1=function(M)return string.format("%.14g",M)end;local j={["nil"]=Bn,["table"]=v2,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local a2=j[type(M)]if a2 then return a2(M,z)end;error("bad type")end
	local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=true then return a0 end end;return#a8+1 end;local function ac(_,__,J)error(J)end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)else return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al,"bad u")_=_..ag(an)al=al+#an else _=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"unterminated string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)return tonumber(ah),am end;local ap=function(a8,a0)local am=a7(a8,a0,p)return a6[a8:sub(a0,am-1)],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do a0=a7(a8,a0,L)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;local am;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do a0=a7(a8,a0,L)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;local au,M;au,a0=a4(a8,a0)a0=a7(a8,a0,L)a0=a0+1;a0=a7(a8,a0,L)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)return av[a8:sub(a9,a9)](a8,a9)end
	JSON={encode=function(x)return e(x)end,decode=function(x)local _,a9=a4(x,a7(x,1,L))return _ end}
end

---------------------------------------------------------------------------------------------------
-- Executor shims
---------------------------------------------------------------------------------------------------
local fRequest   = (syn and syn.request) or request or http_request or (http and http.request)
local fClipboard = setclipboard or toclipboard or (Clipboard and Clipboard.set)
local fWritefile = writefile
local fReadfile  = readfile
local fIsfile    = isfile
local fMakefolder= makefolder
local fHwid      = gethwid or function() return tostring(game:GetService("Players").LocalPlayer.UserId) end

if not fRequest then error("executor has no http request function") end

if fMakefolder and (not fIsfile or not fIsfile(SAVE_FOLDER .. "/.probe")) then
	pcall(fMakefolder, SAVE_FOLDER)
end

---------------------------------------------------------------------------------------------------
-- PlatoBoost client
---------------------------------------------------------------------------------------------------
local host = "https://api.platoboost.com"
do
	local ok, r = pcall(fRequest, { Url = host .. "/public/connectivity", Method = "GET" })
	if not ok or (r.StatusCode ~= 200 and r.StatusCode ~= 429) then
		host = "https://api.platoboost.net"
	end
end

local function nonce()
	local s = ""
	for _ = 1, 16 do s = s .. string.char(math.random(97, 122)) end
	return s
end

local status = function(_) end

local function cacheLink()
	local resp = fRequest({
		Url = host .. "/public/start",
		Method = "POST",
		Body = JSON.encode({ service = SERVICE, identifier = sha256(fHwid()) }),
		Headers = { ["Content-Type"] = "application/json" },
	})
	if resp.StatusCode == 200 then
		local d = JSON.decode(resp.Body)
		if d.success then return true, d.data.url end
		return false, d.message
	end
	return false, "start failed (" .. tostring(resp.StatusCode) .. ")"
end

local function verifyKey(key)
	local n = nonce()
	local url = host .. "/public/whitelist/" .. tostring(SERVICE)
		.. "?identifier=" .. sha256(fHwid())
		.. "&key=" .. key
		.. (USE_NONCE and ("&nonce=" .. n) or "")
	local resp = fRequest({ Url = url, Method = "GET" })
	if resp.StatusCode ~= 200 then return false, "status " .. tostring(resp.StatusCode) end
	local d = JSON.decode(resp.Body)
	if not d.success then return false, d.message end
	if d.data.valid then
		if USE_NONCE and d.data.hash ~= sha256("true-" .. n .. "-" .. SECRET) then
			return false, "integrity check failed"
		end
		return true
	end
	-- Not whitelisted yet, try redeeming (KEY_* prefix = fresh key).
	if key:sub(1, 4) == "KEY_" then
		local n2 = nonce()
		local body = { identifier = sha256(fHwid()), key = key }
		if USE_NONCE then body.nonce = n2 end
		local r2 = fRequest({
			Url = host .. "/public/redeem/" .. tostring(SERVICE),
			Method = "POST",
			Body = JSON.encode(body),
			Headers = { ["Content-Type"] = "application/json" },
		})
		if r2.StatusCode ~= 200 then return false, "redeem status " .. tostring(r2.StatusCode) end
		local d2 = JSON.decode(r2.Body)
		if d2.success and d2.data.valid then
			if USE_NONCE and d2.data.hash ~= sha256("true-" .. n2 .. "-" .. SECRET) then
				return false, "integrity check failed"
			end
			return true
		end
		return false, d2.message or "invalid key"
	end
	return false, "invalid key"
end

---------------------------------------------------------------------------------------------------
-- Launch main under a verified key.
---------------------------------------------------------------------------------------------------
local function launch(key)
	-- Hand the key to the main script. It will re-verify against PlatoBoost itself,
	-- so a leaked main.luau without a live key does nothing.
	getgenv().__CW_AUTH = {
		key = key,
		hwid_hash = sha256(fHwid()),
		-- Stamp so main can detect it was reached through this loader and refuse a stale env.
		stamp = sha256(key .. "|" .. tostring(os.time()) .. "|" .. SECRET),
		ts = os.time(),
	}

	local ok, body = pcall(game.HttpGet, game, MAIN_URL, true)
	if not ok or type(body) ~= "string" or #body < 32 then
		warn("[CW] failed to fetch main: " .. tostring(body))
		return
	end
	local fn, err = loadstring(body, "=cw_main")
	if not fn then warn("[CW] loadstring: " .. tostring(err)); return end
	local okRun, errRun = pcall(fn)
	if not okRun then warn("[CW] main error: " .. tostring(errRun)) end
end

---------------------------------------------------------------------------------------------------
-- Try saved key first (silent path).
---------------------------------------------------------------------------------------------------
if fIsfile and fReadfile and fIsfile(KEY_FILE) then
	local saved = fReadfile(KEY_FILE)
	if type(saved) == "string" and #saved > 0 then
		local ok = verifyKey(saved)
		if ok then
			launch(saved)
			return
		else
			pcall(function() delfile(KEY_FILE) end)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- GUI. Minimal: TextBox + Copy Link + Verify + status line.
---------------------------------------------------------------------------------------------------
local CoreGui do
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
frame.Size = UDim2.fromOffset(360, 190)
frame.Position = UDim2.new(0.5, -180, 0.5, -95)
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
local bc = Instance.new("UICorner", box); bc.CornerRadius = UDim.new(0, 6)
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
	local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0, 6)
	return b
end

local copyBtn   = mkBtn("Copy Link",      12,  165, Color3.fromRGB(50, 90, 160))
local verifyBtn = mkBtn("Verify & Load",  183, 165, Color3.fromRGB(60, 140, 80))

local statusLbl = Instance.new("TextLabel", frame)
statusLbl.BackgroundTransparency = 1
statusLbl.Size = UDim2.new(1, -24, 0, 46)
statusLbl.Position = UDim2.fromOffset(12, 130)
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 13
statusLbl.TextColor3 = Color3.fromRGB(190, 190, 200)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextYAlignment = Enum.TextYAlignment.Top
statusLbl.TextWrapped = true
statusLbl.Text = "Press Copy Link, complete the checkpoint, paste the key, then Verify."

status = function(msg) statusLbl.Text = msg end

copyBtn.MouseButton1Click:Connect(function()
	copyBtn.Text = "..."
	task.spawn(function()
		local ok, link = cacheLink()
		if ok then
			if fClipboard then pcall(fClipboard, link) end
			status("Link copied. Open it in your browser and complete the checkpoint.")
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
