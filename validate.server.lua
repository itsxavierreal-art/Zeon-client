--// ServerScriptService > validate.server.lua
--// Validates keys from GitHub, burns them after single use

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GITHUB_RAW = "https://raw.githubusercontent.com/YOUR_USERNAME/zeon-client/main"

-- RemoteEvent (create once)
local validateEvent = Instance.new("RemoteEvent")
validateEvent.Name = "ZeonValidate"
validateEvent.Parent = ReplicatedStorage

-- In-memory used keys (persists across server sessions via DataStore in real deployment)
local UsedKeys = {}
local KeyStore -- Optional: DataStore for persistence

local function fetchKeys()
    local ok, res = pcall(function()
        return HttpService:GetAsync(GITHUB_RAW .. "/keys.json")
    end)
    if not ok then return nil end
    local data = HttpService:JSONDecode(res)
    return data.keys or {}
end

validateEvent.OnServerEvent:Connect(function(player, key)
    if type(key) ~= "string" then return end
    key = key:gsub("%s+", "")
    
    -- Check already used
    if UsedKeys[key] then
        validateEvent:FireClient(player, false, "Key already redeemed")
        return
    end
    
    -- Fetch fresh key list
    local validKeys = fetchKeys()
    if not validKeys then
        validateEvent:FireClient(player, false, "Server error — try again")
        return
    end
    
    local valid = false
    for _, k in ipairs(validKeys) do
        if key == k then valid = true break end
    end
    
    if valid then
        UsedKeys[key] = true
        -- TODO: Remove key from GitHub via API (requires token) or mark in DataStore
        validateEvent:FireClient(player, true, "Access granted")
        print(("[Zeon] %s redeemed key %s"):format(player.Name, key:sub(1,8).."..."))
    else
        validateEvent:FireClient(player, false, "Invalid key")
    end
end)
