local hubEnv = getgenv()
hubEnv.__CODEX_ATTEMPT_TOKEN = nil
hubEnv.__CODEX_MENU_TARGET = nil
if not game:IsLoaded() then game.Loaded:Wait() end
local isColdWar = game.PlaceId == 13687899540 or game.GameId == 4750561026
local isPyramid = game.PlaceId == 123720558354386 or game.GameId == 10765012427
local isBlox = game.GameId == 994732206
local isSlayers = game.PlaceId == 136406881576517
if not isColdWar and not isPyramid and not isBlox and not isSlayers then
    getgenv().SCRIPT_KEY = nil
    getgenv().UI_CLOSED = true
    warn("[Hub] Supported games: Cold War [VIETNAM], Build the Pyramid!, Blox Fruits, Slayers 2 (Ouwland)")
    return
end
local accessGameName = isSlayers and "Slayers 2 | Ouwland" or isBlox and "Blox Fruits" or (isPyramid and "Build the Pyramid!" or "Cold War Vietnam")
-- JNKIE inline UI: public interface only; no private API keys.
getgenv().SCRIPT_KEY = nil
getgenv().UI_CLOSED = false
local KEY_LINK = "https://jnkie.com/get-key/codexhub"
local Junkie
local function boundedCall(fn, seconds)
    local done, result = false, nil
    local thread = task.spawn(function()
        result = table.pack(pcall(fn))
        done = true
    end)
    local deadline = os.clock() + seconds
    repeat task.wait(0.05) until done or os.clock() >= deadline
    if not done then
        pcall(task.cancel, thread)
        error("Request timed out. Wait before trying again.", 0)
    end
    if not result[1] then error(tostring(result[2]), 0) end
    return table.unpack(result, 2, result.n)
end
local function getSDK()
    if Junkie then return Junkie end
    local module = boundedCall(function()
        local source = game:HttpGet("https://jnkie.com/sdk/library.lua")
        local compiled, err = loadstring(source)
        if not compiled then error("JNKIE SDK download failed: " .. tostring(err)) end
        return compiled()
    end, 15)
    if type(module) ~= "table" then error("JNKIE SDK unavailable") end
    module.service, module.identifier, module.provider = "Cold War Vietnam", "1213798", "Work.ink"
    Junkie = module
    return module
end
local function jnkieCopy()
    local copy = setclipboard or toclipboard
    if type(copy) ~= "function" then error("Open this link: " .. KEY_LINK) end
    copy(KEY_LINK)
end
local function jnkieVerify(key)
    local sdk = getSDK()
    local result = boundedCall(function() return sdk.check_key(key) end, 15)
    if type(result) ~= "table" then error("Unexpected validation response") end
    if result.valid ~= true then error(tostring(result.error or "Key rejected")) end
    return true
end

-- Shared workspace cache for both games. Always validate online before using it.
local keyCacheFolder = "GameHub"
local keyCacheFile = keyCacheFolder .. "/jnkie_1213798_101025.key"
local function saveHubKey(key)
    if type(writefile) ~= "function" then
        warn("[Hub] This executor has no writefile; the key cannot be saved.")
        return
    end
    local ok, err = pcall(function()
        if type(makefolder) == "function" then
            local exists = false
            if type(isfolder) == "function" then
                local checked, found = pcall(isfolder, keyCacheFolder)
                exists = checked and found
            end
            if not exists then pcall(makefolder, keyCacheFolder) end
        end
        writefile(keyCacheFile, key)
    end)
    if not ok then warn("[Hub] Could not save key: " .. tostring(err)) end
end
local function readHubKey()
    if type(readfile) ~= "function" then return nil end
    local ok, value = pcall(readfile, keyCacheFile)
    if not ok or type(value) ~= "string" then return nil end
    value = value:match("^%s*(.-)%s*$")
    if value == "" or #value > 4096 then return nil end
    return value
end
local cachedKey = readHubKey()

local keyAccepted, gateClosed, busy = false, false, false
local enteredKey = cachedKey or ""
local okUI, GateMaclib = pcall(function()
    return boundedCall(function()
        return loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()
    end, 15)
end)
if not okUI or type(GateMaclib) ~= "table" then
    getgenv().UI_CLOSED = true
    warn("[Hub] Access menu could not load. Key link: " .. KEY_LINK)
    return
end
local previousGate = getgenv().__CODEX_GATE_WINDOW
if previousGate then pcall(function() previousGate:Unload() end) end
if type(hubEnv.__CODEX_GATE_CLOSE) == "function" then pcall(hubEnv.__CODEX_GATE_CLOSE) end
if type(hubEnv.__CODEX_MENU_CLEANUP) == "function" then pcall(hubEnv.__CODEX_MENU_CLEANUP) end
local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
local beforeGui = {}
for _, child in ipairs(guiParent:GetChildren()) do beforeGui[child] = true end
local gateWindow = GateMaclib:Window({
    Title = "Codex Hub",
    Subtitle = accessGameName .. " | Access",
    Size = UDim2.fromOffset(868, 600),
    DragStyle = 1,
    DisabledWindowControls = {},
    ShowUserInfo = false,
    Keybind = Enum.KeyCode.RightAlt,
    AcrylicBlur = false,
})
local gateRoot
for _, child in ipairs(guiParent:GetChildren()) do
    if child:IsA("ScreenGui") and not beforeGui[child] then gateRoot = child end
end
if gateRoot then gateRoot.Name = "CodexHubAccess" end
local function closeGate()
    -- Run from the UI's own thread: game modules may change the loader's capabilities.
    pcall(function() gateWindow:SetKeybind(Enum.KeyCode.Unknown) end)
    pcall(function() gateWindow:SetState(false) end)
    local ok, err = pcall(function() gateWindow:Unload() end)
    if gateRoot and gateRoot.Parent then gateRoot:Destroy() end
    if not ok then warn("[Codex Hub] Access window cleanup: " .. tostring(err)) end
    gateClosed = true
    if hubEnv.__CODEX_GATE_WINDOW == gateWindow then hubEnv.__CODEX_GATE_WINDOW = nil end
end
hubEnv.__CODEX_GATE_CLOSE = closeGate
getgenv().__CODEX_GATE_WINDOW = gateWindow
local gateTabs = gateWindow:TabGroup()
local accessTab = gateTabs:Tab({ Name = "Access", Image = "rbxassetid://10723416652" })
local featuresTab = gateTabs:Tab({ Name = "Features", Image = "rbxassetid://10734950309" })
local access = accessTab:Section({ Side = "Left" })
local guide = accessTab:Section({ Side = "Right" })
access:Header({ Text = "Unlock Codex Hub" })
access:SubLabel({ Text = "One key for all supported games. One checkpoint. Access lasts 24 hours." })
local keyInput = access:Input({
    Name = "Access key",
    Placeholder = "Paste your JNKIE key",
    AcceptedCharacters = "All",
    onChanged = function(value) enteredKey = value end,
    Callback = function(value) enteredKey = value end,
}, "cw_access_key")
if cachedKey then keyInput:UpdateText(cachedKey) end
local status = access:Paragraph({ Header = "Ready", Body = "Get a key, complete Work.ink, then paste the key here." })
local function setStatus(title, message)
    if gateClosed then return end
    status:UpdateHeader(title)
    status:UpdateBody(tostring(message))
end
getgenv().__CODEX_GATE_STATUS = setStatus

access:Button({ Name = "Get key", Callback = function()
    if gateClosed then return end
    local ok, err = pcall(jnkieCopy)
    setStatus(ok and "Link copied" or "Get your key", ok and KEY_LINK or err)
end })
local function verifyKey(key)
    if busy or gateClosed then return end
    local now = os.clock()
    local retryAt = getgenv().__CODEX_KEY_RETRY_AT or 0
    if now < retryAt then
        setStatus("Please wait", ("Try verification again in %d seconds. Get key still works."):format(math.ceil(retryAt-now)))
        return
    end
    if key == "" then setStatus("Key required", "Paste your key in the field above.") return end
    busy = true
    getgenv().__CODEX_KEY_RETRY_AT = now + 5
    setStatus("Checking key", "Contacting JNKIE...")
    task.spawn(function()
        local ok, valid = pcall(jnkieVerify, key)
        if not gateClosed then
            if ok and valid == true then
                saveHubKey(key)
                getgenv().SCRIPT_KEY = key
                keyAccepted = true
                setStatus("Key accepted", "Downloading the protected script from JNKIE...")
            elseif not ok then
                local message = tostring(valid)
                local limited = message:find("RATE_LIMIT", 1, true) or message:find("429", 1, true)
                getgenv().__CODEX_KEY_RETRY_AT = os.clock() + (limited and 60 or 10)
                setStatus(limited and "JNKIE rate limit" or "Verification failed", limited and "Wait at least 60 seconds before retrying. Get key works without an API request." or message)
            else
                setStatus("Access denied", "The key was not accepted. Check the key or obtain a new one. If rate limited, wait 20 seconds.")
            end
        end
        busy = false
    end)
end
access:Button({ Name = "Verify key", Callback = function()
    verifyKey(enteredKey:match("^%s*(.-)%s*$"))
end })
guide:Header({ Text = "How to get access" })
guide:Paragraph({ Header = "1. Get your link", Body = KEY_LINK .. "\nGet key copies this public link without contacting the API." })
guide:Paragraph({ Header = "2. Complete Work.ink", Body = "Finish the checkpoint and return to JNKIE to receive your key." })
guide:Paragraph({ Header = "3. Unlock the menu", Body = "Paste the key into Access key and click Verify key." })
guide:Divider()
guide:SubLabel({ Text = "Key provider: JNKIE\nAdvertising: Work.ink\nDuration: 24 hours\nMenu shortcut: Right Alt" })
local featuresLeft = featuresTab:Section({ Side = "Left" })
local featuresRight = featuresTab:Section({ Side = "Right" })
featuresLeft:Paragraph({ Header = "Slayers 2 | Ouwland", Body = "Auto level-based kill quests, optional boss hunts, boss chest collection, weapon selection, optional katana purchase, adaptive hover combat and low-health retreat. Rayfield menu." })
featuresLeft:Paragraph({ Header = "Blox Fruits", Body = "Auto level quests, material farming, sea detection, island travel, farming above enemies, faster attack readiness checks, fruit gacha and special quests. Current-race V2/V3 assistance; PvP, Sea Beast skills and V4 trials need manual completion. Maclib menu." })
featuresLeft:Paragraph({ Header = "Build the Pyramid!", Body = "Auto farm blocks, auto train strength and speed, coin upgrades, redeem codes, skip cutscenes and block Robux prompts. Rayfield menu." })
featuresLeft:Paragraph({ Header = "Cold War: Combat", Body = "Silent aim and mouse aim, FOV control, target selection, team and visibility checks, bullet drop and movement prediction." })
featuresLeft:Paragraph({ Header = "Visuals", Body = "ESP boxes, names, distance, limb health, tracers, team and downed-player colours." })
featuresRight:Paragraph({ Header = "Weapons", Body = "No recoil, no spread, full auto and instant equip. Availability depends on the current game build." })
featuresRight:Paragraph({ Header = "Movement & vehicles", Body = "Fly, speed boost, noclip, vehicle acceleration, traction and instant vehicle entry." })
featuresRight:Paragraph({ Header = "Settings", Body = "Saved configurations, staff alerts, menu shortcuts and unload controls." })
gateWindow.onUnloaded(function()
    gateClosed = true
    if getgenv().__CODEX_GATE_WINDOW == gateWindow then getgenv().__CODEX_GATE_WINDOW = nil end
    if getgenv().__CODEX_GATE_STATUS == setStatus then getgenv().__CODEX_GATE_STATUS = nil end
end)
accessTab:Select()
-- The toggle lives outside either window, so hiding a menu cannot hide its button.
local menuGui = Instance.new("ScreenGui")
menuGui.Name = "CodexHubMenuToggle"
menuGui.ResetOnSpawn = false
menuGui.DisplayOrder = 2147483647
menuGui.Parent = guiParent
local menuButton = Instance.new("TextButton")
menuButton.Name = "ToggleMenu"
menuButton.Size = UDim2.fromOffset(112, 42)
menuButton.AnchorPoint = Vector2.new(1, 0)
menuButton.Position = UDim2.new(1, -16, 0, 64)
menuButton.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
menuButton.TextColor3 = Color3.fromRGB(240, 240, 240)
menuButton.Text = "Codex Hub"
menuButton.TextSize = 15
menuButton.Font = Enum.Font.GothamMedium
menuButton.Visible = game:GetService("UserInputService").TouchEnabled
menuButton.Parent = menuGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = menuButton
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(65, 65, 70)
border.Parent = menuButton
local target = { window = gateWindow, kind = "Maclib" }
local active, handedOff = true, false
local clicked = menuButton.Activated:Connect(function()
    if not active or target.closed then return end
    if target.kind == "Rayfield" then target.window:ToggleHide()
    else target.window:SetState(not target.window:GetState()) end
end)
local function cleanupMenu()
    active = false
    clicked:Disconnect()
    menuGui:Destroy()
end
hubEnv.__CODEX_MENU_CLEANUP = cleanupMenu
task.spawn(function()
    while active do
        local token = hubEnv.__CODEX_ATTEMPT_TOKEN
        if not handedOff and keyAccepted and token and hubEnv.__CODEX_HUB_READY == token then
            closeGate()
            handedOff = true
            target = hubEnv.__CODEX_MENU_TARGET or {closed = true}
        end
        if (handedOff and (target.closed or target.window.unloaded)) or (gateClosed and not handedOff) then
            cleanupMenu()
            break
        end
        task.wait(0.2)
    end
end)
if cachedKey then verifyKey(cachedKey) end
repeat task.wait(0.1) until keyAccepted or gateClosed

if not keyAccepted then getgenv().UI_CLOSED = true return end
