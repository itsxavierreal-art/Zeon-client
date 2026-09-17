--// Zeon Client v2.1 — One-time key redemption with toast notifications
--// LocalScript in StarterPlayerScripts

local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider   = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer
local validateEvent = ReplicatedStorage:WaitForChild("ZeonValidate")

--========================
-- CONFIG
--========================
local CONFIG = {
    LogoId      = "rbxassetid://84215079084194",
    GitHubRaw   = "https://raw.githubusercontent.com/YOUR_USERNAME/zeon-client/main",
    AutoCheckSaved = true, -- auto-validate saved key on join
}

--========================
-- THEME
--========================
local C = {
    Bg      = Color3.fromRGB(10, 14, 24),
    Panel   = Color3.fromRGB(16, 22, 38),
    Input   = Color3.fromRGB(22, 30, 50),
    Stroke  = Color3.fromRGB(60, 90, 160),
    Accent  = Color3.fromRGB(70, 140, 255),
    Green   = Color3.fromRGB(60, 200, 130),
    Red     = Color3.fromRGB(230, 80, 90),
    Amber   = Color3.fromRGB(240, 180, 60),
    Text    = Color3.fromRGB(235, 240, 255),
    Dim     = Color3.fromRGB(130, 145, 180),
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

--========================
-- NOTIFICATION SYSTEM (toasts)
--========================
local notifGui = inst("ScreenGui", {
    Name = "ZeonNotifications",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 10000,
    Parent = LocalPlayer:WaitForChild("PlayerGui")
})

local notifHolder = inst("Frame", {
    Size = UDim2.fromOffset(320, 200),
    Position = UDim2.new(1, -20, 0, 20),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    Parent = notifGui
})
inst("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Parent = notifHolder
})

local function notify(title, msg, kind)
    local col = kind == "success" and C.Green or kind == "error" and C.Red or C.Accent
    local icon = kind == "success" and "✓" or kind == "error" and "✕" or "ℹ"
    
    local card = inst("Frame", {
        Size = UDim2.fromOffset(320, 0),
        BackgroundColor3 = C.Panel,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        LayoutOrder = tick(),
        ClipsDescendants = true,
        Parent = notifHolder
    })
    corner(card, 12)
    stroke(card, col, 1.2, 0.3)
    
    -- Icon
    local iconLbl = inst("TextLabel", {
        Size = UDim2.fromOffset(36, 36),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = col,
        BackgroundTransparency = 0.15,
        Font = Enum.Font.GothamBold,
        Text = icon,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 16,
        Parent = card
    })
    corner(iconLbl, 10)
    
    -- Texts
    inst("TextLabel", {
        Size = UDim2.new(1, -56, 0, 18),
        Position = UDim2.new(0, 52, 0, 8),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = C.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })
    inst("TextLabel", {
        Size = UDim2.new(1, -56, 0, 28),
        Position = UDim2.new(0, 52, 0, 26),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = msg,
        TextColor3 = C.Dim,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card
    })
    
    -- Animate in
    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(320, 64)}):Play()
    task.delay(3.2, function()
        TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(320, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.35)
        card:Destroy()
    end)
end

--========================
-- MAIN UI
--========================
local gui = inst("ScreenGui", {
    Name = "ZeonClient",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    Parent = LocalPlayer:WaitForChild("PlayerGui")
})

local backdrop = inst("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = gui
})

local PW, PH = 520, 250
local main = inst("Frame", {
    Size = UDim2.fromOffset(PW, PH),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.Panel,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 3,
    Parent = gui
})
corner(main, 18)
stroke(main, C.Stroke, 1.2, 0.3)

-- Left: Logo
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
    BackgroundColor3 = Color3.fromRGB(22, 30, 50),
    BackgroundTransparency = 0.2,
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

task.spawn(function()
    pcall(function() ContentProvider:PreloadAsync({logo}) end)
    task.wait(1)
    if not logo.IsLoaded then
        logo.Visible = false
        local fb = inst("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Font = Enum.Font.GothamBold,
            Text = "Z",
            TextColor3 = C.Accent,
            TextSize = 44,
            ZIndex = 5,
            Parent = logoHolder
        })
    end
end)

-- Right: Content
local right = inst("Frame", {
    Size = UDim2.new(1, -186, 1, -36),
    Position = UDim2.new(0, 168, 0, 18),
    BackgroundTransparency = 1,
    ZIndex = 4,
    Parent = main
})

inst("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 0, 2),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "Welcome to Zeon",
    TextColor3 = C.Text,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
    Parent = right
})

inst("TextLabel", {
    Size = UDim2.new(1, 0, 0, 44),
    Position = UDim2.new(0, 0, 0, 26),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Click 'Get Key' to receive a key.\nEach key works once — enter it below.",
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
    Position = UDim2.new(0, 0, 0, 76),
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

input.Focused:Connect(function()
    TweenService:Create(keyStroke, TweenInfo.new(0.2), {Color = C.Accent, Transparency = 0.1}):Play()
end)
input.FocusLost:Connect(function()
    TweenService:Create(keyStroke, TweenInfo.new(0.25), {Color = C.Stroke, Transparency = 0.5}):Play()
end)

-- Buttons (FIXED: proper spacing, working states)
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
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = btnRow
    })
    corner(b, 12)
    local st = stroke(b, col:Lerp(Color3.new(1,1,1), 0.25), 1, 0.5)
    
    local baseCol = col
    local baseTrans = primary and 0.05 or 0.3
    
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        TweenService:Create(st, TweenInfo.new(0.15), {Transparency = 0.2}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = baseTrans}):Play()
        TweenService:Create(st, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
    end)
    
    return b, function(newText, newCol)
        b.Text = newText
        if newCol then
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = newCol}):Play()
        end
    end
end

-- Properly spaced buttons: [Get Key] [Check Key]  (Account removed — was fake)
local getBtn, setGetBtn   = makeBtn("Get Key", 0, 110, C.Accent, false)
local checkBtn, setCheckBtn = makeBtn("Check Key", 120, 110, C.Green, true)

--========================
-- LOGIC (one-time use)
--========================
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

getBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(remoteCfg.getKeyLink) end
    notify("Link Copied", "Key link copied to clipboard.", "info")
    setGetBtn("Copied ✓")
    task.delay(1.4, function() setGetBtn("Get Key") end)
end)

local verifying = false
local function closeUI()
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Size = UDim2.fromOffset(PW, 0),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(backdrop, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
    task.wait(0.4)
    gui:Destroy()
end

checkBtn.MouseButton1Click:Connect(function()
    if verifying then return end
    local key = input.Text:gsub("%s+", "")
    
    if key == "" then
        notify("Missing Key", "Please paste a key first.", "error")
        return
    end
    
    verifying = true
    setCheckBtn("Checking…", C.Amber)
    
    validateEvent:FireServer(key)
end)

validateEvent.OnClientEvent:Connect(function(success, msg)
    verifying = false
    
    if success then
        setCheckBtn("Success ✓", C.Green)
        notify("Access Granted", "Key redeemed — welcome!", "success")
        
        -- Save so they don't need to re-enter (optional)
        LocalPlayer:SetAttribute("ZeonVerified", true)
        
        task.wait(0.9)
        closeUI()
        
        -- Continue your game logic here
        print("[Zeon] Player verified — grant access")
    else
        setCheckBtn("Failed", C.Red)
        notify("Verification Failed", msg or "Invalid key.", "error")
        task.delay(1.2, function()
            setCheckBtn("Check Key", C.Green)
        end)
    end
end)

-- Auto-check saved verification
if CONFIG.AutoCheckSaved and LocalPlayer:GetAttribute("ZeonVerified") then
    notify("Welcome Back", "Already verified — skipping key entry.", "success")
    task.wait(0.5)
    closeUI()
end

--========================
-- ENTRANCE
--========================
main.Size = UDim2.fromOffset(PW, 0)
main.BackgroundTransparency = 1

TweenService:Create(backdrop, TweenInfo.new(0.4), {BackgroundTransparency = 0.5}):Play()
TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = UDim2.fromOffset(PW, PH),
    BackgroundTransparency = 0.05
}):Play()

print("[Zeon v2.1] Client loaded")
