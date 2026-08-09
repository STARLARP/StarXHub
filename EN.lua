local KeyClient = License or "none"
local UserIdClient = UserId or "none"

local StartTime = os.clock()

local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Client = Players.LocalPlayer
local GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
local JobId = game.JobId

local UrlBase = "https://abstract-preventing-hip-actor.trycloudflare.com/"
local SECRET_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjoiYTNkOWYyZWQxMDFhNDAwOTgyMjk4OTRkYWE3MzIyYzQ3MDE4NDViNDU0MDA3YjFiN2EiLCJkZWNvZGVkIjoi77-977-977-977-9XHUwMDEwXHUwMDFhQFx077-9Ke-_vU3vv71zXCLvv71wXHUwMDE4Re-_vVRcdTAwMDB7XHUwMDFieiIsImlhdCI6MTc3NTkwMjY5NywiZXhwIjoxNzc1OTA2Mjk3fQ.bw8jL1HWrje5b8sV353HXfmjEh-k_kfvBg2W3glfA0Y"

local function Debug(message)
    warn('[ StarX ]:', message or "No message provided.")
end

Debug('Loading StarX Client..')

local function bxor(a, b)
    local res, bit = 0, 1
    while a > 0 or b > 0 do
        if a % 2 ~= b % 2 then res = res + bit end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bit = bit * 2
    end
    return res
end

local function xorWithKey(data, key)
    local result = {}
    for i = 1, #data do
        local db = string.byte(data, i)
        local kb = string.byte(key, ((i - 1) % #key) + 1)
        result[i] = string.char(bxor(db, kb))
    end
    return table.concat(result)
end

local function toHex(str)
    return string.gsub(str, ".", function(c)
        return string.format("%02x", string.byte(c))
    end)
end

local function fromHex(hex)
    if #hex % 2 ~= 0 then error("Hex string must have even length") end
    local result = {}
    for i = 1, #hex, 2 do
        local chunk = string.sub(hex, i, i + 1)
        local byte = tonumber(chunk, 16)
        if not byte then error("Invalid hex string: " .. chunk) end
        table.insert(result, string.char(byte))
    end
    return table.concat(result)
end

local function randomIV()
    local t = {}
    for i = 1, 16 do t[i] = string.char(math.random(0, 255)) end
    return table.concat(t)
end

local function encrypt(text)
    local iv = randomIV()
    local mixedKey = SECRET_KEY .. iv
    local encrypted = xorWithKey(tostring(text), mixedKey)
    return toHex(iv) .. "." .. toHex(encrypted)
end

local function decrypt(payload)
    local parts = string.split(payload, ".")
    if not parts[1] or not parts[2] then error("Invalid payload format") end
    
    local ivBinary = fromHex(parts[1])
    local mixedKey = SECRET_KEY .. ivBinary
    return xorWithKey(fromHex(parts[2]), mixedKey)
end

local function FlagTamperFunction(reason)
    Client:Kick("Tamper Detect: " .. (reason and (" (" .. reason .. ")") or ""))
    
    while true do 
        (" "):rep(1e908) 
    end

    return coroutine.yield()
end

if tostring(print):find("Lua") or debug.traceback():find('http') or debug.traceback():find('dump') then 
    FlagTamperFunction("Log/Traceback")
end

local request_original = (syn and syn.request) or (http and http.request) or request or (fluxus and fluxus.request) or (Krnl and Krnl.HttpRequest) or (getgenv and getgenv().request)

pcall(function()
    for _, v in next, {math.random, islclosure, isfunctionhooked, request_original, tonumber, tostring} do 
        if restorefunction then
            restorefunction(v)
        end
    end
end)

if math.random() == math.random() or (isfunctionhooked and isfunctionhooked(math.random)) or debug.getinfo(math.random).name ~= "random" then 
    FlagTamperFunction("math.random Hook")
end

pcall(function()
    local h = Instance.new("Hat")
    h.Name = "__tamper_test"
    h.Parent = workspace
    h:Destroy()
    if workspace:FindFirstChild("__tamper_test") then
        FlagTamperFunction("Instance Spoof")
    end
end)

if islclosure and not islclosure(function() end) then 
    FlagTamperFunction("islclosure Hook")
end

local RngF, RngS, RngT, RngFS, RngFi = math.random(1000000,9999999), math.random(1000000,9999999), math.random(1000000,9999999), math.random(1000000,9999999), math.random(1000000,9999999)

local function EncHttp(v)
    return HttpService:UrlEncode(encrypt(tostring(v)))
end

Debug('Connecting to Server..')

local Url = UrlBase .. "api/auth?g=" .. EncHttp(GameName) .. "&j=" .. EncHttp(JobId) .. "&t=" .. EncHttp(tostring(os.time(os.date("!*t")) * 1000)) .. "&n=" .. EncHttp(Client.Name)

local AuthUrlRequested = request_original({
    Url = Url,
    Method = "POST",
    Headers = { ["Content-Type"] = "application/json" },
    Body = HttpService:JSONEncode({
        Key = encrypt(KeyClient),
        DiscordId = encrypt(UserIdClient),
        Rng1 = RngF, Rng2 = RngS, Rng3 = RngT, Rng4 = RngFS, Rng5 = RngFi
    })
})

if not (AuthUrlRequested and AuthUrlRequested.Body) then 
    Debug("Server not responding.")
    return 
end

local State, Response = pcall(function()
    return HttpService:JSONDecode(AuthUrlRequested.Body)
end)

if not (State and Response) then
    Debug("Can't parse JSON.")
    return 
end

if not Response.success then 
    Debug(Response.text or "Unknown error.")
    return 
end 

if Response.message ~= "KEY_VALID" or Response.text ~= "The provided key is valid." then 
    Debug("Something went wrong A1.")
    return 
end

if not Response.token or not Response.sig then 
    Debug("Authentication failed (Missing Data).")
    return
end

local Rng1 = (Response.Rng + 32) / 2
local Rng2 = (Response.Rng2 - 256) / 5
local Rng3 = (Response.Rng3 - (Response.Rng * 3) - Response.Rng2 + 64) / 2
local Rng4 = (Response.Rng4 - (Response.Rng2 * 2) + Response.Rng + 128) * 2
local Rng5 = ((Response.Rng5 + 512) / 4) - Response.Rng3 - Response.Rng4

local TokenDecrypt = decrypt(Response.token)
local TokenPart = string.split(TokenDecrypt, ":")

if not (Rng1 and Rng2 and Rng3 and Rng4 and Rng5) or not TokenPart then 
    Debug("Failed to Authenticate (Can't Parsed Token).")
    return
end 

if TokenPart[1] ~= KeyClient or TokenPart[2] ~= UserIdClient or os.time(os.date("!*t")) > tonumber(TokenPart[3]) then
    Debug("Failed to Authenticate (Data Token Missmatch).")
    return
end

local SignatureDecrypt = decrypt(Response.sig)
local SignaturePart = string.split(SignatureDecrypt, ":")
local RngSig1 = (SignaturePart[4] + 32) / 2
local RngSig2 = (SignaturePart[5] - 256) / 5
local RngSig3 = (SignaturePart[6] - (SignaturePart[4] * 3) - SignaturePart[5] + 64) / 2
local RngSig4 = (SignaturePart[7] - (SignaturePart[5] * 2) + SignaturePart[4] + 128) * 2
local RngSig5 = ((SignaturePart[8] + 512) / 4) - SignaturePart[6] - SignaturePart[7]

if os.time(os.date("!*t")) > tonumber(SignaturePart[3]) or tostring(RngSig1) ~= tostring(RngF) or tostring(RngSig2) ~= tostring(RngS) or tostring(RngSig3) ~= tostring(RngT) or tostring(RngSig4) ~= tostring(RngFS) or tostring(RngSig5) ~= tostring(RngFi) or tostring(SignaturePart[4]) ~= tostring(Response.Rng) or tostring(SignaturePart[5]) ~= tostring(Response.Rng2) or tostring(SignaturePart[6]) ~= tostring(Response.Rng3) or tostring(SignaturePart[7]) ~= tostring(Response.Rng4) or tostring(SignaturePart[8]) ~= tostring(Response.Rng5) or Rng1 ~= RngF or Rng2 ~= RngS or Rng3 ~= RngT or Rng4 ~= RngFS or Rng5 ~= RngFi then
    Debug("Failed to Authenticate (Data Signature Mismatch).")
    return
end 

Debug("Authenticated in " .. (os.clock() - StartTime) .. "s")

-- วางสคริปต์ด้านล่างนี้

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local PlaceId = game.PlaceId
local GameId = game.GameId
local CoreGui = game:GetService("CoreGui")

local function NotifyLoad(mapName)
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "⭐ Star Hub Loader",
            Text = "wait: " .. mapName .. "\nlodeing...",
            Duration = 5
        })
    end)
    print("[Star Hub] Loading script for: " .. mapName)
end

-- ==========================================
-- 🔄 ระบบแยกทาง (Game Detection Routing)
-- ==========================================

if GameId == 994732206 then
    -- Blox Fruits
    NotifyLoad("Blox Fruits")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/nibamako08-code/xd/refs/heads/main/b1E", true))()

elseif GameId == 1720936166 then
    -- 1. All Star Tower Defense
    NotifyLoad("All Star Tower Defense")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/nibamako08-code/xd/refs/heads/main/a4T", true))()

elseif PlaceId == 73504898027860 then
    -- 7. GAG2
    NotifyLoad("grow a garden2")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/nibamako08-code/xd/refs/heads/main/G2a", true))()

elseif GameId == 4658598196 then
    -- 8. attack on titan revolution
    NotifyLoad("attack on titan revolution")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/nibamako08-code/xd/refs/heads/main/t2R", true))()



else
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "⭐ Star Hub",
            Text = "no map!\n(Place ID: " .. tostring(PlaceId) .. ")",
            Duration = 10
        })
    end)
    warn("[Star Hub] Unsupported Game. PlaceId: " .. tostring(PlaceId) .. " | GameId: " .. tostring(GameId))
end
