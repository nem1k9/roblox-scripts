-- Codex Hub: GitHub key menu, JNKIE protected gameplay code.
-- Release: 2026-10-06, shared key and automatic game selection.
local env = getgenv()
local existing = env.__CODEX_BOOT
if existing and existing.running then
    if env.__CODEX_GATE_WINDOW then pcall(function() env.__CODEX_GATE_WINDOW:SetState(true) end) end
    warn("[Codex Hub] A startup is already in progress. Use the open menu.")
    return
end
local boot = {running=true}
env.__CODEX_BOOT = boot
local function run()
    local completed, reply = false, nil
    local fetch = task.spawn(function()
        reply = table.pack(pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/nem1k9/roblox-scripts/main/codexhub_key.luau")
        end))
        completed = true
    end)
    local deadline = os.clock()+20
    repeat task.wait(.05) until completed or os.clock()>=deadline
    if not completed then pcall(task.cancel,fetch) error("GitHub menu download timed out.",0) end
    if not reply[1] then error("GitHub menu download failed: "..tostring(reply[2]),0) end
    local menu,err = loadstring(reply[2])
    if not menu then error("Menu could not compile: "..tostring(err),0) end
    menu()
    if env.UI_CLOSED or type(env.SCRIPT_KEY)~="string" or env.SCRIPT_KEY=="" then return end
    local token = {}
    env.__CODEX_ATTEMPT_TOKEN = token
    local function downloadProtectedScript()
-- Codex Hub: one download at a time; no automatic request spam.
local env = getgenv()
local previous = env.__CODEX_LOADER
local keyLink = "https://jnkie.com/get-key/codexhub"
local function message(text)
    warn("[Codex Hub] " .. text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Codex Hub", Text = text, Duration = 8,
        })
    end)
end
if previous and previous.running then
    local window = env.__CODEX_GATE_WINDOW
    if window then pcall(function() window:SetState(true) end) end
    message("Already loading. Do not run another copy.")
    return
end
if previous and (previous.retryAt or 0) > os.clock() then
    message(("JNKIE cooldown: %d seconds. Key link: %s"):format(math.ceil(previous.retryAt-os.clock()), keyLink))
    return
end
local state = { running = true, retryAt = 0 }
env.__CODEX_LOADER = state
local url = "https://api.jnkie.com/api/v1/luascripts/public/c3f3e624cc381c6762b30ef31ec75e12de99ff9ce9e2d2842f54b29f97b5effd/download"
local done, result = false, nil
local fetchThread = task.spawn(function()
    result = table.pack(pcall(function()
        local fetch = request or http_request
        if type(fetch) == "function" then
            local response = fetch({ Url = url, Method = "GET" })
            if type(response) ~= "table" then error("Download failed: " .. tostring(response), 0) end
            local code = tonumber(response.StatusCode)
            if code == 429 then
                local waitTime = 60
                for name, value in pairs(response.Headers or {}) do
                    if tostring(name):lower() == "retry-after" then waitTime = math.max(waitTime, tonumber(value) or 0) end
                end
                state.retryAt = os.clock() + waitTime
                error("JNKIE returned HTTP 429. Wait " .. math.ceil(waitTime) .. " seconds before trying again.", 0)
            end
            if not code or code < 200 or code >= 300 then error("JNKIE download failed (HTTP " .. tostring(code) .. ")", 0) end
            return response.Body
        end
        return game:HttpGet(url)
    end))
    done = true
end)
local deadline = os.clock() + 20
repeat task.wait(0.05) until done or os.clock() >= deadline
if not done then
    pcall(task.cancel, fetchThread)
    state.running, state.retryAt = false, os.clock() + 15
    message("JNKIE download timed out. Try again later. Key link: " .. keyLink)
    return
end
if not result[1] then
    state.running = false
    state.retryAt = math.max(state.retryAt, os.clock() + 15)
    message(tostring(result[2]) .. " Key link: " .. keyLink)
    return
end
local source = result[2]
if type(source) ~= "string" or source == "" or source:match("^%s*<") then
    state.running, state.retryAt = false, os.clock() + 60
    message("JNKIE returned an empty response or a web page instead of Lua. Key link: " .. keyLink)
    return
end
local compiled, compileError = loadstring(source)
if not compiled then
    state.running, state.retryAt = false, os.clock() + 15
    message("Downloaded code could not compile: " .. tostring(compileError))
    return
end
local ok, runtimeError = pcall(compiled)
state.running = false
if not ok then message("Startup failed: " .. tostring(runtimeError)) end

    end
    downloadProtectedScript()
    -- JNKIE may start its protected chunk asynchronously. Its UI-owner thread closes
    -- the access window when the matching ready acknowledgement arrives.
    local readyDeadline = os.clock() + 30
    local loaderState = env.__CODEX_LOADER
    if loaderState and (loaderState.retryAt or 0) <= os.clock() then
        while env.__CODEX_HUB_READY ~= token and os.clock() < readyDeadline and not env.UI_CLOSED do
            task.wait(0.1)
        end
    end
    if env.__CODEX_HUB_READY ~= token and type(env.__CODEX_GATE_STATUS)=="function" then
        local remaining=env.__CODEX_LOADER and math.max(0,(env.__CODEX_LOADER.retryAt or 0)-os.clock()) or 0
        env.__CODEX_GATE_STATUS("Script not started", "JNKIE did not finish startup. See the executor console. Wait "..math.ceil(remaining).." seconds before rerunning. Get key still works.")
    end
end
local ok,err=pcall(run)
boot.running=false
if not ok then
    warn("[Codex Hub] "..tostring(err))
    if type(env.__CODEX_GATE_STATUS)=="function" then pcall(env.__CODEX_GATE_STATUS,"Startup failed",tostring(err)) end
end
