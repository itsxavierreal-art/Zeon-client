--// Zeon Client v2.0 — ScriptWare-style key panel (legitimate in-game use)
--// Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/zeon-client/main/client.lua"))()

local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local ContentProvider  = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--========================
-- CONFIG
--========================
local CONFIG = {
    GitHubRaw = "https://raw.githubusercontent.com/YOUR_USERNAME/zeon-client/main", -- no trailing slash
    LogoId    = "rbxassetid://84215079084194", -- your logo (SW-style)
    SaveKey   = true, -- remember valid key via DataStore-like (uses Player attributes in this demo)
}

--========================
-- THEME (ScriptWare iOS palette)
--========================
local C = {
    Bg        = Color3.fromRGB(12, 16, 28),
    Panel     = Color3.fromRGB(18, 24, 40),
    PanelHi   = Color3.fromRGB(26, 34, 56),
    Input     = Color3.fromRGB(22, 30, 50),
    Stroke    = Color3.fromRGB(60, 90, 160),
    Accent    = Color3.fromRGB(70, 140, 255),
    Green     = Color3.fromRGB(60, 200, 130),
    Red       = Color3.fromRGB(230, 80, 90),
    Text      = Color3.fromRGB(235, 240, 255),
    Dim       = Color3.fromRGB(130, 145, 180),
}

--========================
-- HELPERS
--========================
local function inst(class, props)
    local i = Instance.new(class)
    for k, v in pairs(props) do i[k] = v end
    return i
end
local function corner(p, r) return inst("UICorner", {CornerRadius = UDim.new(0, r or 14), Parent = p}) end
local function stroke(p, col, th, tr) return inst("UIStroke", {Color = col or C.Stroke, Thickness = th or 1, Transparency = tr or 0.35, Parent = p}) end
local function tween(obj, t, style)
    return TweenService:Create(obj, TweenInfo.new(t or 0.35, style or Enum.EasingStyle.Quint), {})
end

local function ripple(btn)
    local m = UserInputService:GetMouseLocation()
    local r = inst("Frame", {
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.8,
        Size = UDim2.fromOffset(0,0),
        Position = UDim2.fromOffset(m.X - btn.AbsolutePosition.X, m.Y - btn.AbsolutePosition.Y),
        AnchorPoint = Vector2.new(0.5,0.5),
        ZIndex = 20,
        Parent = btn
    })
    corner(r, 999)
    local s = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.4
    TweenService:Create(r, TweenInfo.new(0.5), {Size = UDim2.fromOffset(s,s), BackgroundTransparency = 1}):Play()
    task.delay(0.55, function() r:Destroy() end)
end

--========================
-- SCREEN GUI
--========================
local gui = inst("ScreenGui", {
    Name = "ZeonClient_v2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    Parent = LocalPlayer:WaitForChild("PlayerGui") -- legitimate: uses PlayerGui, not CoreGui
})

-- Backdrop
local backdrop = inst("Frame", {
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.new(0,0,0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = gui
})

--========================
-- MAIN PANEL  (ScriptWare proportions)
--========================
local PW, PH = 520, 240   -- wide, short — like your screenshot

local main = inst("Frame", {
    Size = UDim2.fromOffset(PW, PH),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.Panel,
    BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
    ZIndex = 3,
    Parent = gui
})
corner(main, 18)
stroke(main, C.Stroke, 1.2, 0.3)

-- Soft top glow
inst("ImageLabel", {
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = C.Accent,
    ImageTransparency = 0.9,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24,24,276,276),
    Size = UDim2.new(1, 50, 1, 50),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ZIndex = 2,
    Parent = main
})

--========================
-- LEFT: LOGO (SW-style)
--========================
local left = inst("Frame", {
    Size = UDim2.new(0, 150, 1, -36),
    Position = UDim2.new(0, 18, 0, 18),
    BackgroundTransparency = 1,
    ZIndex = 4,
    Parent = main
})

local logoHolder = inst("Frame", {
    Size = UDim2.fromOffset(120, 120),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.PanelHi,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    ZIndex = 4,
    Parent = left
})
corner(logoHolder, 20)
stroke(logoHolder, C.Stroke, 1, 0.4)

local logo = inst("ImageLabel", {
    BackgroundTransparency = 1,
    Image = CONFIG.LogoId,
    Size = UDim2.fromOffset(92, 92),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 5,
    Parent = logoHolder
})

local logoFallback = inst("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1,1),
    Font = Enum.Font.GothamBold,
    Text = "ZW",
    TextColor3 = C.Accent,
    TextSize = 40,
    Visible = false,
    ZIndex = 5,
    Parent = logoHolder
})

task.spawn(function()
    pcall(function() ContentProvider:PreloadAsync({logo}) end)
    task.wait(1)
    if not logo.IsLoaded then
        logo.Visible = false
        logoFallback.Visible = true
    end
end)

--========================
-- RIGHT: CONTENT
--========================
local right = inst("Frame", {
    Size = UDim2.new(1, -186, 1, -36),
    Position = UDim2.new(0, 168, 0, 18),
    BackgroundTransparency = 1,
    ZIndex = 4,
    Parent = main
})

-- Title
inst("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 0, 2),
    Font = Enum.Font.GothamBold,
    Text = "Welcome to Zeon",
    TextColor3 = C.Text,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
    Parent = right
})

-- Subtitle (like ScriptWare instructions)
inst("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 48),
    Position = UDim2.new(0, 0, 0, 26),
    Font = Enum.Font.Gotham,
    Text = "Please click 'Get Key' to get a key.\nOnce you've completed the key system, enter your key below, then click 'Check Key'.",
    TextColor3 = C.Dim,
    TextSize = 12,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 4,
    Parent = right
})

-- Key input
local keyBox = inst("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 82),
    BackgroundColor3 = C.Input,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 4,
    Parent = right
})
corner(keyBox, 12)
local keyStroke = stroke(keyBox, C.Stroke, 1, 0.5)

local input = inst("TextBox", {
    Size = UDim2.new(1, -24, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    PlaceholderText = "Paste your key here",
    PlaceholderColor3 = C.Dim,
    Text = "",
    TextColor3 = C.Text,
    TextSize = 14,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
    Parent = keyBox
})

-- Focus glow
input.Focused:Connect(function()
    TweenService:Create(keyStroke, TweenInfo.new(0.2), {Color = C.Accent, Transparency = 0.1}):Play()
end)
input.FocusLost:Connect(function()
    TweenService:Create(keyStroke, TweenInfo.new(0.25), {Color = C.Stroke, Transparency = 0.5}):Play()
end)

-- Status
local status = inst("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 2, 0, 128),
    Font = Enum.Font.GothamMedium,
    Text = "",
    TextColor3 = C.Dim,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
    Parent = right
})

--========================
-- BUTTONS (bottom row, ScriptWare style)
--========================
local btnRow = inst("Frame", {
    Size = UDim2.new(1, 0, 0, 38),
    Position = UDim2.new(0, 0, 1, -42),
    BackgroundTransparency = 1,
    ZIndex = 4,
    Parent = right
})

local function makeBtn(text, x, w, col, primary)
    local b = inst("TextButton", {
        Size = UDim2.fromOffset(w, 36),
        Position = UDim2.new(0, x, 0, 0),
        BackgroundColor3 = col,
        BackgroundTransparency = primary and 0.05 or 0.3,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 13,
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = btnRow
    })
    corner(b, 12)
    local st = stroke(b, col:Lerp(Color3.new(1,1,1), 0.25), 1, 0.5)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = primary and 0 or 0.1}):Play()
        TweenService:Create(st, TweenInfo.new(0.15), {Transparency = 0.2}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = primary and 0.05 or 0.3}):Play()
        TweenService:Create(st, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
    end)
    b.MouseButton1Click:Connect(function() ripple(b) end)
    return b
end

local accountBtn = makeBtn("Account Login", 0, 118, C.PanelHi, false)
local getKeyBtn  = makeBtn("Get Key", 128, 100, C.Accent, false)
local checkBtn   = makeBtn("Check Key", 238, 118, C.Green, true)

--========================
-- LOGIC
--========================
local function setStatus(txt, col)
    status.Text = txt
    status.TextColor3 = col or C.Dim
end

-- Load remote config
local remoteCfg = { getKeyLink = "https://linkvertise.com/your-key-link" }
task.spawn(function()
    local ok, res = pcall(function()
        return game:HttpGet(CONFIG.GitHubRaw .. "/config.json")
    end)
    if ok and res then
        local d = HttpService:JSONDecode(res)
        if d.getKeyLink then remoteCfg.getKeyLink = d.getKeyLink end
    end
end)

-- "Account Login" — legitimate alternative: sign in with Roblox account (open profile / verify ownership)
accountBtn.MouseButton1Click:Connect(function()
    setStatus("Account login: verify your Roblox profile instead.", C.Accent)
    -- Legit approach: check if player owns a game pass / is in a group
    -- Example: check group membership
    local groupId = 0000000 -- your group
    if LocalPlayer:IsInGroup(groupId) then
        setStatus("Group member detected — access granted.", C.Green)
        task.wait(0.8)
        -- close and continue
    else
        setStatus("Join our group to use account login.", C.Red)
    end
end)

getKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(remoteCfg.getKeyLink) end
    setStatus("Key link copied to clipboard.", C.Accent)
    getKeyBtn.Text = "Copied ✓"
    task.delay(1.3, function() getKeyBtn.Text = "Get Key" end)
end)

local verifying = false
checkBtn.MouseButton1Click:Connect(function()
    if verifying then return end
    local key = input.Text:gsub("%s+", "")
    if key == "" then
        setStatus("Please enter a key.", C.Red)
        return
    end

    verifying = true
    checkBtn.Text = "Checking…"
    setStatus("Verifying key…", C.Accent)

    task.spawn(function()
        local ok, res = pcall(function()
            return game:HttpGet(CONFIG.GitHubRaw .. "/keys.json")
        end)

        if not ok or not res then
            setStatus("Network error. Try again.", C.Red)
            checkBtn.Text = "Check Key"
            verifying = false
            return
        end

        local data = HttpService:JSONDecode(res)
        local valid = false
        for _, k in ipairs(data.keys or {}) do
            if key == k then valid = true break end
        end

        if valid then
            setStatus("Key accepted! Loading…", C.Green)
            checkBtn.Text = "Success ✓"
            checkBtn.BackgroundColor3 = C.Green

            -- Remember key (uses attribute; swap for DataStore in real game)
            if CONFIG.SaveKey then
                LocalPlayer:SetAttribute("ZeonKey", key)
            end

            task.wait(0.9)

            -- Close animation
            TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
                Size = UDim2.fromOffset(PW, 0),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(backdrop, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
            task.wait(0.4)
            gui:Destroy()

            print("[Zeon] Key valid — continue to your main game logic here")
            -- Example: fire a RemoteEvent to server to grant access
            -- game.ReplicatedStorage.ZeonAccess:FireServer(key)
        else
            setStatus("Invalid key. Please try again.", C.Red)
            checkBtn.Text = "Invalid"
            checkBtn.BackgroundColor3 = C.Red
            task.wait(1.2)
            checkBtn.Text = "Check Key"
            checkBtn.BackgroundColor3 = C.Green
            verifying = false
        end
    end)
end)

--========================
-- ENTRANCE
--========================
main.Size = UDim2.fromOffset(PW, 0)
main.BackgroundTransparency = 1

TweenService:Create(backdrop, TweenInfo.new(0.4), {BackgroundTransparency = 0.5}):Play()
TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = UDim2.fromOffset(PW, PH),
    BackgroundTransparency = 0.06
}):Play()

print("[Zeon v2] Client key panel loaded")
