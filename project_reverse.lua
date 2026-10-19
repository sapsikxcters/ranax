-- Recovered Luau source by ZeroVector (Patched & Stabilized by VANTA)
local genv = typeof(getgenv) == "function" and getgenv() or _G

-- Secure UI Library Loader with fallbacks and custom headers
local function loadLibrary()
    local cdnUrl = "https://cdn.project-reverse.org/Library.luau"
    local rawCode = nil

    local reqFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if reqFunc then
        local ok, resp = pcall(function()
            return reqFunc({
                Url = cdnUrl,
                Method = "GET",
                Headers = {["User-Agent"] = "Roblox/WinInet"}
            })
        end)
        if ok and resp and resp.Body and #resp.Body > 500 then
            rawCode = resp.Body
        end
    end

    if not rawCode then
        local ok, res = pcall(function()
            return game:HttpGet(cdnUrl)
        end)
        if ok and res and #res > 500 then
            rawCode = res
        end
    end

    if rawCode then
        local ok, libInstance = pcall(function()
            return loadstring(rawCode)()
        end)
        if ok and libInstance then
            return libInstance
        end
    end

    return nil
end

local lib = loadLibrary()
if not lib then
    warn("[Project Reverse] Failed to load UI Library from CDN. Please check executor network access.")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Project Reverse",
            Text = "UI Library failed to load. Check your connection or executor.",
            Duration = 6
        })
    end)
    return
end

-- Universal Game Support (All Games Supported - No PlaceId/GameId Lock)
if genv.mm2VisualLibraryLoaded then
    lib:Notify({
        Title = "Already loaded",
        Content = "Project Reverse is already loaded in this session.",
        Type = "Warning",
        Duration = 4,
    })
    return
end

local Players, ReplicatedStorage, RunService, Workspace, TweenService, TeleportService, localPlayer, fn, fn2, v, tbl, fn3, fn4, fn5, fn6, fn7, v2, fn8, flag, fn9
local vector2, v3

do
            genv.mm2VisualLibraryLoaded = true
            local HttpService = game:GetService("HttpService")
            Players = game:GetService("Players")
            local realRS = game:GetService("ReplicatedStorage")

            -- Universal Mock Hierarchy for non-MM2 games
            local function createMockRemote(name)
                local dummyEvent = {
                    Connect = function(self, fn)
                        return {
                            Disconnect = function() end,
                            disconnect = function() end,
                            Connected = true
                        }
                    end,
                    connect = function(self, fn)
                        return {
                            Disconnect = function() end,
                            disconnect = function() end,
                            Connected = true
                        }
                    end,
                    Wait = function() task.wait(999999) end,
                    wait = function() task.wait(999999) end,
                    Once = function() return { Disconnect = function() end } end
                }

                local mock = {}
                local meta = {}

                meta.__index = function(tbl, key)
                    if key == "OnClientEvent" or key == "onClientEvent" or key == "Event" or key == "Changed" then
                        return dummyEvent
                    elseif key == "FireServer" or key == "fireServer" or key == "Fire" or key == "fire" then
                        return function() end
                    elseif key == "InvokeServer" or key == "invokeServer" then
                        return function() return {} end
                    elseif key == "FindFirstChild" or key == "findFirstChild" or key == "WaitForChild" or key == "waitForChild" then
                        return function(self, childName)
                            return tbl[childName]
                        end
                    elseif key == "Name" then
                        return name or "Mock"
                    elseif key == "ClassName" then
                        return "RemoteEvent"
                    elseif key == "IsA" or key == "isA" then
                        return function(self, cls) return true end
                    end
                    local child = createMockRemote(tostring(key))
                    rawset(tbl, key, child)
                    return child
                end

                meta.__call = function()
                    return {}
                end

                return setmetatable(mock, meta)
            end

            local function wrapInstance(inst)
                if typeof(inst) ~= "Instance" then
                    return inst
                end
                local proxy = {}
                local meta = {}
                meta.__index = function(_, key)
                    local child = inst:FindFirstChild(key)
                    if child then
                        return wrapInstance(child)
                    end
                    local ok, val = pcall(function() return inst[key] end)
                    if ok and val ~= nil then
                        if typeof(val) == "function" then
                            return function(_, ...)
                                return val(inst, ...)
                            end
                        end
                        return val
                    end
                    return createMockRemote(tostring(key))
                end
                return setmetatable(proxy, meta)
            end

            ReplicatedStorage = wrapInstance(realRS)
            RunService = game:GetService("RunService")
            Workspace = game:GetService("Workspace")
            TweenService = game:GetService("TweenService")
            local VirtualUser = game:GetService("VirtualUser")
            TeleportService = game:GetService("TeleportService")
            local CoreGui = game:GetService("CoreGui")
            local StarterGui = game:GetService("StarterGui")
            local UserInputService = game:GetService("UserInputService")
            localPlayer = Players.LocalPlayer

            repeat
                task.wait()
            until game:IsLoaded()

            localPlayer:WaitForChild("PlayerGui")

            local function fn10()
                return localPlayer.Character
            end

            fn = function()
                local v4 = fn10()
                local humanoid = v4 and v4:FindFirstChildOfClass("Humanoid")
                return humanoid
            end

            fn2 = function()
                local v4 = fn10()
                local humanoidRootPart = v4 and v4:FindFirstChild("HumanoidRootPart")
                return humanoidRootPart
            end

            local coinCollected = ReplicatedStorage.Remotes.Gameplay.CoinCollected
            local roundStart = ReplicatedStorage.Remotes.Gameplay.RoundStart
            local tbl2 = {"MouseButton1Click", "MouseButton1Down", "Activated"}

            local function fn11(arg)
                if not arg then
                    return
                end
                local flag2 = false
                local v4, v5, v6 = ipairs(tbl2)
                local v7 = v6
                local v8 = v4
                local v9 = v5

                while true do
                    local v10, v11 = v8(v9, v7)
                    if v10 == nil then
                        break
                    end
                    v7 = v10
                    local v12 = arg[v11]

                    if v12 and typeof(getconnections) == "function" then
                        local ok, result = pcall(getconnections, v12)

                        if ok then
                            for k, v13 in pairs(result) do
                                if v13 and typeof(v13.Function) == "function" then
                                    flag2 = true
                                    pcall(v13.Function)
                                end
                            end

                            v7 = v10
                        end
                    end

                    if v12 and typeof(firesignal) == "function" then
                        flag2 = true
                        pcall(firesignal, v12)
                    end
                end

                if not flag2 then
                    pcall(function()
                        if typeof(arg.Activate) == "function" then
                            arg:Activate()
                        end
                    end)
                end
            end

            repeat
                pcall(function()
                    fn11(localPlayer.PlayerGui.DeviceSelect.Container.Tablet.Button)
                end)

                pcall(function()
                    fn11(localPlayer.PlayerGui.Join.Friends.Play)
                end)

                task.wait(1)
            until localPlayer.PlayerGui:FindFirstChild("MainGUI")

            local tbl3 = {
                SelectedEmote = "zen",
                AutoPlayEmotes = false,
                AutoPlaySelectedEmote = false,
                EmoteSpamSpeed = 1,
            }

            v = (function(arg)
                local v4 = table.clone(arg)

                for k, v5 in pairs(v4) do
                    if type(v5) == "table" then
                        v4[k] = tbl3(v5)
                    end
                end

                return v4
            end)({
                AutoRevealRoles = false,
                CoinFarm = {
                    StatsOverlay = false,
                    State = false,
                    Settings = {
                        Speed = 22.5,
                        DestroyMap = false,
                        DestroyPlayers = false,
                        Fly = false,
                        DieAtFullBag = false,
                    },
                },
                CoinFarm2 = {
                    Disable3DRendering = false,
                    State = false,
                    Settings = {
                        Speed = 22.5,
                        DestroyMap = false,
                        DestroyPlayers = false,
                        DieAtFullBag = false,
                        Disable3DRendering = false,
                    },
                },
                ESP = {Players = false, Traps = false, DroppedGun = false},
                Noclip = false,
                Gameplay = {AutoPickUpGun = false, AutoShooting = false},
                AutoFarm = {
                    TeleportSpawn = false,
                    KillEveryoneAsAMurderer = false,
                    AutoFlingMurderer = false,
                    AutoFlingSheriff = false,
                    AutoPrestige = false,
                    KillEveryoneAsAMurdererAtFullBag = false,
                    TeleportUnderMap = false,
                    AutoTeleportToRandomServerIfServerIsEmpty = false,
                    AutoFlingMurdererAtFullBag = false,
                    PlayersToAutoServerHop = 2,
                },
                AnnoyingStuff = {Fling = {PickedPlayer = nil, LoopFlingAllPlayers = false}},
                Sliders = {Speed = 16, Jump = 50},
                AutoOpenCrates = {
                    State = false,
                    Crate = "MysteryBox1",
                    CrateType = "MysteryBox",
                },
                VisualGun = false,
                ShuffleWeapons = false,
                Emotes = tbl3,
            })

            localPlayer.Idled:Connect(function()
                VirtualUser:ClickButton2(Vector2.new())
            end)

            local centeredLabelGui = CoreGui:FindFirstChild("CenteredLabelGui")
            local screenGui = centeredLabelGui or Instance.new("ScreenGui")
            screenGui.Name = "CenteredLabelGui"
            screenGui.Parent = CoreGui
            local centeredTextLabel = screenGui:FindFirstChild("CenteredTextLabel")
            local textLabel = centeredTextLabel or Instance.new("TextLabel")
            textLabel.Name = "CenteredTextLabel"
            textLabel.Visible = false
            textLabel.Text = ""
            textLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
            textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextStrokeTransparency = 0.35
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextSize = 42
            textLabel.Parent = screenGui
            local now = tick()
            local n = 0
            local n2 = 0
            local n3 = 40

            coinCollected.OnClientEvent:Connect(function(arg, arg2, arg3)
                n = n + 1
                local num = tonumber(arg2)
                local v4 = num or n2
                n2 = v4
                local num2 = tonumber(arg3)
                local v5 = num2 or n3
                n3 = v5
            end)

            RunService.RenderStepped:Connect(function()
                local n4 = math.max(tick() - now, 1)
                local n5 = math.floor(n * 3600 / n4)
                textLabel.Text = string.format("Coins Collected: %d/%d\nTotal Coins: %d\nCoins Per Hour: %d", n2, n3, n, n5)
            end)

            local v4 = nil

            local function fn12()
                local v5 = fn2()
                if not v5 then
                    return
                end

                if Workspace:FindFirstChild("safespot") then
                    v5.CFrame = CFrame.new(-106, 87.5, 2)
                else
                    local part = Instance.new("Part")
                    part.Name = "safespot"
                    part.Size = Vector3.new(25, 3, 25)
                    part.Position = Vector3.new(-106, 83, 2)
                    part.Parent = Workspace
                    part.Anchored = true
                    part.CanCollide = true
                    part.Transparency = 0
                    task.wait()

                    for i = 1, 3 do
                        local v6 = fn2()
                        if not v6 then
                            return
                        end
                        v6.CFrame = CFrame.new(-106, 87.5, 2)
                        task.wait(0.1)
                    end
                end
            end

            tbl = {
                "sit",
                "ninja",
                "dab",
                "zen",
                "floss",
                "headless",
                "zombie",
                "wave",
                "cheer",
                "laugh",
            }

            local function fn13(arg)
                ReplicatedStorage.Remotes.Misc.PlayEmote:Fire(arg)
            end

            task.spawn(function()
                while true do
                    task.wait(1 / math.max(v.Emotes.EmoteSpamSpeed, 1))

                    if v.Emotes.AutoPlayEmotes then
                        fn13(tbl[math.random(1, #tbl)])
                    end
                end
            end)

            local function fn14()
                for k, player in pairs(Players:GetPlayers()) do
                    if player ~= localPlayer and Workspace:WaitForChild(player.Name, 0.01) then
                        Workspace[player.Name]:Destroy()
                    end
                end
            end

            local function fn15()
                local v5, v6, v7 = pairs(Workspace:GetChildren())
                local v8 = v7
                local v9 = v5
                local v10 = v6

                while true do
                    local v11, v12 = v9(v10, v8)
                    if v11 == nil then
                        break
                    end
                    v8 = v11

                    if v12:IsA("Model") and v12:FindFirstChild("CoinContainer") then
                        for k, child in pairs(v12:GetChildren()) do
                            if child.Name ~= "CoinContainer" then
                                child:Destroy()
                            end
                        end

                        v8 = v11
                    end
                end
            end

            local function fn16()
                if not localPlayer.Character then
                    return
                end

                for k, descendant in pairs(localPlayer.Character:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.CanCollide then
                        descendant.CanCollide = false
                    end
                end
            end

            RunService.Stepped:Connect(function()
                local v5 = fn()

                if v.Noclip and v5 and v5.Health > 0 and fn2() then
                    fn16()
                end
            end)

            local function fn17()
                local tbl4 = {}

                local ok, result = pcall(function()
                    return require(ReplicatedStorage.Modules.InventoryModule).MyInventory.Data.Weapons
                end)

                if not ok or not result then
                    return nil
                end
                local v5, v6, v7 = pairs(result)
                local v8 = v7
                local v9 = v5
                local v10 = v6

                while true do
                    local v11, v12 = v9(v10, v8)
                    if v11 == nil then
                        break
                    end

                    for k in pairs(v12) do
                        table.insert(tbl4, k)
                    end

                    v8 = v11
                end

                if #tbl4 == 0 then
                    return nil
                end
                return tbl4[math.random(1, #tbl4)]
            end

            RunService.Stepped:Connect(function()
                if v.Emotes.AutoPlaySelectedEmote then
                    fn13(v.Emotes.SelectedEmote)
                end

                if v.ShuffleWeapons then
                    local v5 = fn17()

                    if v5 then
                        pcall(function()
                            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                            local inventory = remotes and remotes:FindFirstChild("Inventory")
                            local equip = inventory and inventory:FindFirstChild("Equip")

                            if equip then
                                equip:FireServer(v5, "Weapons")
                            end
                        end)
                    end
                end

                local centeredLabelGui2 = CoreGui:FindFirstChild("CenteredLabelGui")

                if centeredLabelGui2 and centeredLabelGui2:FindFirstChild("CenteredTextLabel") then
                    centeredLabelGui2.CenteredTextLabel.Visible = v.CoinFarm.StatsOverlay
                end

                local character = localPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if not character or not humanoid or humanoid.Health <= 0 or not character:FindFirstChild("HumanoidRootPart") then
                    return
                end

                if v.Sliders.Speed ~= humanoid.WalkSpeed then
                    humanoid.WalkSpeed = v.Sliders.Speed
                end

                if v.Sliders.Jump ~= humanoid.JumpPower then
                    humanoid.JumpPower = v.Sliders.Jump
                end
            end)

            RunService.Stepped:Connect(function()
                if v.CoinFarm.Settings.DestroyPlayers then
                    fn14()
                end
            end)

            RunService.Heartbeat:Connect(function()
                if v.CoinFarm.Settings.DestroyMap then
                    fn15()
                end
            end)

            local function fn18()
                if not localPlayer.Character then
                    return
                end
                local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then
                    return
                end
                local tbl4 = {}
                local children, v5, v6 = Workspace:GetChildren()
                local v7 = v6
                local v8 = children
                local v9 = v5

                while true do
                    local v10, v11 = v8(v9, v7)
                    if v10 == nil then
                        break
                    end
                    v7 = v10

                    if v11:IsA("Model") and v11:FindFirstChild("CoinContainer") then
                        for k, v12 in v11.CoinContainer:GetChildren() do
                            if v12.Name == "Coin_Server" and not v12:FindFirstChild("CollectedCoin") and v12:FindFirstChild("TouchInterest") then
                                local magnitude = (humanoidRootPart.Position - v12.Position).Magnitude

                                if magnitude < 100 then
                                    table.insert(tbl4, {Coin = v12, Distance = magnitude})
                                end
                            end
                        end

                        v7 = v10
                    end
                end

                table.sort(tbl4, function(arg, arg2)
                    local flag2 = arg.Distance < arg2.Distance
                    return flag2
                end)

                local v10 = tbl4[1]
                local coin = v10 and tbl4[1].Coin
                return coin
            end

            local connection = nil
            local tbl4 = {}

            local function fn19()
                for i, v5 in ipairs(tbl4) do
                    if v5 then
                        pcall(function()
                            v5:Disconnect()
                        end)
                    end
                end

                table.clear(tbl4)
                connection = nil
                local v5 = fn2()

                if v5 then
                    v5.Anchored = false
                    local mm2CoinFarmVelocity = v5:FindFirstChild("MM2_CoinFarmVelocity")

                    if mm2CoinFarmVelocity then
                        mm2CoinFarmVelocity:Destroy()
                    end
                end
            end

            local function fn20()
                fn19()
                local connection2 = nil

                local connection3 = RunService.Heartbeat:Connect(function()
                    if not v.CoinFarm.State then
                        return
                    end
                    local mainGUI = localPlayer.PlayerGui:FindFirstChild("MainGUI")
                    local game_ = mainGUI and mainGUI:FindFirstChild("Game")

                    local ok, result, result2 = pcall(function()
                        return game_.CoinBags.Visible, game_.CoinBags.Container.Candy.Full.Visible
                    end)

                    local v5 = fn2()

                    if ok and result and not result2 and v5 then
                        if not v5:FindFirstChild("MM2_CoinFarmVelocity") then
                            local bodyVelocity = Instance.new("BodyVelocity", v5)
                            bodyVelocity.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
                            bodyVelocity.Name = "MM2_CoinFarmVelocity"
                        end

                        fn16()
                        local v6 = fn18()

                        if v6 then
                            v5.Anchored = false

                            task.spawn(function()
                                local v7 = fn2()
                                if not v7 then
                                    return
                                end
                                local n4 = (v7.Position - v6.Position).Magnitude / v.CoinFarm.Settings.Speed
                                local cframe = CFrame.new(v6.Position + Vector3.new(0, -1, 0))
                                TweenService:Create(v7, TweenInfo.new(n4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = cframe}):Play()

                                if v6 and v6.Parent then
                                    local connection3 = nil

                                    connection3 = v6.Touched:Connect(function()
                                        task.wait(0.1)

                                        if v6 then
                                            v6:Destroy()
                                            connection3:Disconnect()
                                        end
                                    end)
                                end
                            end)
                        else
                            v5.Anchored = true
                        end

                        task.wait(0.02)
                    end
                end)

                local connection4 = coinCollected.OnClientEvent:Connect(function(arg, arg2, arg3)
                    if arg2 == arg3 then
                        fn19()
                    end
                end)

                local v5 = fn()

                if v5 then
                    connection2 = v5.Died:Connect(function()
                        task.wait(1)

                        repeat
                            task.wait()
                        until localPlayer.Character ~= nil

                        repeat
                            task.wait()
                        until localPlayer.PlayerGui ~= nil

                        task.wait(1)

                        repeat
                            task.wait()
                        until localPlayer.PlayerGui:FindFirstChild("MainGUI")

                        task.wait(1)

                        if Teleport_to_map then
                            Teleport_to_map()
                        end
                    end)
                end

                connection = ReplicatedStorage.Remotes.Gameplay.RoundEndFade.OnClientEvent:Connect(function()
                    fn19()
                end)

                table.insert(tbl4, connection3)
                table.insert(tbl4, connection4)

                if connection2 then
                    table.insert(tbl4, connection2)
                end

                table.insert(tbl4, connection)
            end

            local vector = Vector3.new(1, -100, 1)
            local part = Instance.new("Part", Workspace)
            part.Anchored = true
            part.Position = vector
            part.Size = Vector3.new(100, 1.2, 100)
            local flag2 = false

            local function fn21()
                local v5 = fn2()

                if v5 then
                    v5.CFrame = CFrame.new(part.Position + Vector3.new(math.random(-10, 5), 5, math.random(-10, 5)))
                end
            end

            local function fn22(arg)
                local v5 = fn2()

                if arg and v5 then
                    v5.CFrame = CFrame.new(arg.Position + Vector3.new(0, -6, 0))
                end
            end

            local function fn23()
                for i, child in ipairs(Workspace:GetChildren()) do
                    if child:FindFirstChild("CoinContainer") then
                        return child
                    end
                end
            end

            local flag3 = nil

            local function fn24()
                if flag3 then
                    return
                end
                flag3 = true
                flag2 = false

                if v.CoinFarm2.State then
                    fn21()
                end

                while not flag2 do
                    local v5 = fn23()

                    if not v5 then
                        task.wait(1)
                        if not v.CoinFarm2.State then
                            break
                        end
                        continue
                    end

                    if not v.CoinFarm2.State then
                        break
                    end

                    task.spawn(function()
                        pcall(fn15)
                    end)

                    local v6 = nil
                    local huge = math.huge

                    for i, child in ipairs(v5.CoinContainer:GetChildren()) do
                        if child:FindFirstChild("TouchInterest") and child.Position.Y < huge then
                            huge = child.Position.Y
                            v6 = child
                        end
                    end

                    if not v6 then
                        task.wait(0.1)
                        continue
                    end
                    local flag4 = false
                    fn22(v6)

                    local connection2 = coinCollected.OnClientEvent:Connect(function(arg, arg2, arg3)
                        flag4 = true

                        if arg2 == arg3 then
                            flag2 = true
                        end
                    end)

                    if not flag2 then
                        repeat
                            task.wait()

                            task.spawn(function()
                                local v7 = fn2()

                                if v7 then
                                    pcall(firetouchinterest, v7, v6, 0)
                                    pcall(firetouchinterest, v7, v6, 1)
                                end
                            end)

                            task.wait()
                            fn16()
                            fn22(v6)
                        until flag4 or not v6:FindFirstChild("TouchInterest")

                        connection2:Disconnect()
                        fn21()
                        task.wait(2)
                        continue
                    end

                    connection2:Disconnect()
                    break
                end

                flag3 = false
            end

            ReplicatedStorage.Remotes.Gameplay.RoundStart.OnClientEvent:Connect(function()
                task.spawn(fn24)
            end)

            localPlayer.CharacterAdded:Connect(function()
                if v.CoinFarm2.State then
                    fn21()
                end
            end)

            task.spawn(fn20)

            local function fn25()
                for i, player in ipairs(Players:GetPlayers()) do
                    if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife") then
                        return player
                    end
                end

                for i, player in ipairs(Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("Knife") then
                        return player
                    end
                end

                if v4 then
                    for k, v5 in pairs(v4) do
                        if v5.Role == "Murderer" and Players:FindFirstChild(k) then
                            return Players:FindFirstChild(k)
                        end
                    end
                end
            end

            local function fn26()
                for i, player in ipairs(Players:GetPlayers()) do
                    if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun") then
                        return player
                    end
                end

                for i, player in ipairs(Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("Gun") then
                        return player
                    end
                end

                if v4 then
                    for k, v5 in pairs(v4) do
                        if v5.Role == "Sheriff" and Players:FindFirstChild(k) then
                            return Players:FindFirstChild(k)
                        end
                    end
                end
            end

            local function fn27()
                for i, child in ipairs(Workspace:GetChildren()) do
                    if child.Name == "PlayerESP" then
                        child:Destroy()
                    end
                end

                for i, player in ipairs(Players:GetPlayers()) do
                    if player.Character and not player.Character:FindFirstChild("PlayerESP") then
                        local highlight = Instance.new("Highlight", Workspace)
                        highlight.Name = "PlayerESP"
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Adornee = player.Character
                        highlight.FillColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5

                        task.spawn(function()
                            if player == fn25() then
                                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                            elseif player == fn26() then
                                highlight.FillColor = Color3.fromRGB(0, 150, 255)
                                highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
                            else
                                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                            end

                            if highlight and player then
                                local character = player.Character
                                local adornee = character or player.CharacterAdded:Wait()
                                highlight.Adornee = adornee
                            end
                        end)
                    end
                end
            end

            local function fn28()
                if not v4 then
                    lib:Notify({
                        Title = "No data",
                        Content = "playerData has not loaded yet.",
                        Type = "Warning",
                        Duration = 3,
                    })

                    return
                end

                local tbl5 = {}

                for k, v5 in pairs(v4) do
                    table.insert(tbl5, string.format("%s - %s", k, tostring(v5.Role)))
                end

                lib:Notify({
                    Title = "Roles",
                    Content = table.concat(tbl5, "\n"),
                    Type = "Info",
                    Duration = 6,
                })
            end

            local highlight = Instance.new("Highlight")
            highlight.Name = "TrapESP"
            highlight.OutlineTransparency = 1
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.4
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

            Workspace.DescendantAdded:Connect(function(descendant)
                if v.ESP.Traps and descendant.Name == "Trap" and descendant.Parent:IsDescendantOf(Workspace) then
                    descendant.Transparency = 0
                    local clone = highlight:Clone()
                    clone.Parent = Workspace
                    clone.Adornee = descendant
                end

                if v.ESP.DroppedGun and descendant.Name == "GunDrop" then
                    local gunESP = Workspace:FindFirstChild("GunESP")
                    local v5 = gunESP

                    if not gunESP then
                        local highlight2 = Instance.new("Highlight", Workspace)
                        v5 = highlight2
                        highlight2.OutlineTransparency = 1
                        highlight2.FillColor = Color3.fromRGB(255, 255, 0)
                        highlight2.Name = "GunESP"
                        highlight2.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end

                    v5.Adornee = descendant
                    v5.Enabled = true

                    if v.Gameplay.AutoPickUpGun then
                        task.wait(0.5)

                        for i = 1, 5 do
                            if pickupgun then
                                pickupgun()
                            end
                        end
                    end
                end
            end)

            Workspace.DescendantRemoving:Connect(function(descendant)
                if v.ESP.DroppedGun and descendant.Name == "GunDrop" then
                    local gunESP = Workspace:FindFirstChild("GunESP")

                    if gunESP then
                        gunESP:Destroy()
                    end

                    task.wait(0.6)

                    if v.ESP.Players then
                        for i, child in ipairs(Workspace:GetChildren()) do
                            if child:IsA("Highlight") then
                                child:Destroy()
                            end
                        end

                        fn27()
                    end
                end
            end)

            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local remotes2 = remotes or ReplicatedStorage:WaitForChild("Remotes", 5)
            local gameplay = remotes2

            if remotes2 then
                local gameplay2 = remotes2:FindFirstChild("Gameplay")
                gameplay = gameplay2 or remotes2:WaitForChild("Gameplay", 5)
            end

            local playerDataChanged = gameplay and gameplay:WaitForChild("PlayerDataChanged", 5)

            if playerDataChanged then
                playerDataChanged.OnClientEvent:Connect(function(arg)
                    v4 = arg

                    if v.ESP.Players then
                        fn27()
                    end
                end)
            else
                warn("[MM2] PlayerDataChanged remote was not found; role ESP may be limited.")
            end

            local function fn29()
                if not localPlayer.Character or not localPlayer.Character:FindFirstChild("Knife") then
                    if not localPlayer.Backpack:FindFirstChild("Knife") or not localPlayer.Character then
                        return
                    end
                    local humanoid = localPlayer.Character:FindFirstChild("Humanoid")

                    if humanoid then
                        humanoid:EquipTool(localPlayer.Backpack:FindFirstChild("Knife"))
                    end
                end

                for i, player in ipairs(Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        local humanoidRootPart2 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                        humanoidRootPart.Anchored = true
                        humanoidRootPart.CFrame = humanoidRootPart2.CFrame + humanoidRootPart2.CFrame.LookVector * 1
                    end
                end

                pcall(function()
                    localPlayer.Character.Knife.Stab:FireServer("Slash")
                end)
            end

            local function fn30()
                for i, child in ipairs(Workspace:GetChildren()) do
                    if child:FindFirstChild("CoinContainer") and child:FindFirstChild("Spawns") then
                        return child
                    end
                end
            end

            pickupgun = function()
                local v5 = fn30()
                if not v5 then
                    return
                end
                local gunDrop = v5:FindFirstChild("GunDrop")
                if not gunDrop then
                    return
                end

                if fn25() == localPlayer then
                    return
                end

                if not localPlayer.Character then
                    return
                end
                local pivot = localPlayer.Character:GetPivot()
                localPlayer.Character:MoveTo(gunDrop.Position)
                local gun = localPlayer.Backpack:FindFirstChild("Gun")
                local now2 = tick()

                while not gun and tick() - now2 < 2 do
                    gun = localPlayer.Backpack:FindFirstChild("Gun")
                    task.wait()
                end

                localPlayer.Character:PivotTo(pivot)
            end

            Teleport_to_lobby = function()
                if Workspace:FindFirstChild("Lobby") and localPlayer.Character then
                    localPlayer.Character:MoveTo(Workspace.Lobby.WorldPivot.Position)
                end
            end

            Teleport_to_map = function()
                if not fn30() then
                    return
                end
                local spawns = fn30():FindFirstChild("Spawns")
                if not spawns then
                    return
                end
                local children = spawns:GetChildren()

                if #children > 0 and localPlayer.Character then
                    localPlayer.Character:MoveTo(children[math.random(1, #children)].Position)
                end
            end

            fn3 = function()
                local getSyncData = ReplicatedStorage:FindFirstChild("GetSyncData")

                if getSyncData then
                    StarterGui:SetCore("SendNotification", {
                        Title = "Server IS COOKED",
                        Text = "look how ppl freezing mid air lmao",
                        Duration = 5,
                    })

                    while true do
                        for i = 1, 1 do
                            task.spawn(getSyncData.InvokeServer, getSyncData)
                        end

                        for i = 1, 1 do
                            task.spawn(getSyncData.InvokeServer, getSyncData)
                        end

                        for i = 1, 1 do
                            task.spawn(getSyncData.InvokeServer, getSyncData)
                        end

                        task.wait()
                    end
                end
            end

            fn4 = function(arg)
                local flag4 = false

                local function fn31(arg2)
                    local str = arg2:lower()

                    if str ~= "all" and str ~= "others" then
                        if str == "random" then
                            local players = Players:GetPlayers()
                            local v5 = table.find(players, localPlayer)

                            if v5 then
                                table.remove(players, v5)
                            end

                            if #players == 0 then
                                return
                            end
                            return players[math.random(#players)]
                        end

                        local v5 = next
                        local players, v6 = Players:GetPlayers()

                        for k, v7 in v5, players, v6 do
                            if v7 ~= localPlayer and (v7.Name:lower():match("^" .. str) or v7.DisplayName:lower():match("^" .. str)) then
                                return v7
                            end
                        end

                        return
                    end

                    flag4 = true
                end

                local function fn32(arg2)
                    local character = localPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local rootPart = humanoid and humanoid.RootPart
                    if not character or not humanoid or not rootPart then
                        return
                    end
                    local character2 = arg2.Character
                    if not character2 then
                        return
                    end
                    local humanoid2 = character2:FindFirstChildOfClass("Humanoid")
                    local rootPart2 = humanoid2 and humanoid2.RootPart
                    local head = character2:FindFirstChild("Head")

                    if rootPart.Velocity.Magnitude < 50 then
                        genv.OldPos = rootPart.CFrame
                    end

                    if humanoid2 and humanoid2.Sit and not flag4 then
                        return
                    end

                    if head then
                        Workspace.CurrentCamera.CameraSubject = head
                    elseif humanoid2 and rootPart2 then
                        Workspace.CurrentCamera.CameraSubject = humanoid2
                    end

                    if not character2:FindFirstChildWhichIsA("BasePart") then
                        return
                    end

                    local function fn33(arg3, arg4, arg5)
                        rootPart.CFrame = CFrame.new(arg3.Position) * arg4 * arg5

                        pcall(function()
                            character:SetPrimaryPartCFrame(CFrame.new(arg3.Position) * arg4 * arg5)
                        end)

                        rootPart.Velocity = Vector3.new(90000000, 900000000, 90000000)
                        rootPart.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
                    end

                    local function fn34(arg3)
                        local now2 = tick()
                        local n4 = 0

                        while rootPart and humanoid2 do
                            if arg3.Velocity.Magnitude < 50 then
                                local n5 = n4 + 100
                                n4 = n5
                                fn33(arg3, CFrame.new(0, 1.5, 0) + humanoid2.MoveDirection * arg3.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n5), 0, 0))
                                task.wait()
                                fn33(arg3, CFrame.new(0, -1.5, 0) + humanoid2.MoveDirection * arg3.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n5), 0, 0))
                                task.wait()
                                fn33(arg3, CFrame.new(2.25, 1.5, -2.25) + humanoid2.MoveDirection * arg3.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n5), 0, 0))
                                task.wait()
                                fn33(arg3, CFrame.new(-2.25, -1.5, 2.25) + humanoid2.MoveDirection * arg3.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n5), 0, 0))
                                task.wait()
                                fn33(arg3, CFrame.new(0, 1.5, 0) + humanoid2.MoveDirection, CFrame.Angles(math.rad(n5), 0, 0))
                                task.wait()
                                fn33(arg3, CFrame.new(0, -1.5, 0) + humanoid2.MoveDirection, CFrame.Angles(math.rad(n5), 0, 0))
                                task.wait()
                            else
                                fn33(arg3, CFrame.new(0, 1.5, humanoid2.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                                task.wait()
                                fn33(arg3, CFrame.new(0, -1.5, -humanoid2.WalkSpeed), CFrame.Angles(0, 0, 0))
                                task.wait()
                                fn33(arg3, CFrame.new(0, 1.5, humanoid2.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                                task.wait()

                                if rootPart2 then
                                    fn33(arg3, CFrame.new(0, 1.5, rootPart2.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                    fn33(arg3, CFrame.new(0, -1.5, -rootPart2.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                                    task.wait()
                                    fn33(arg3, CFrame.new(0, 1.5, rootPart2.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                end

                                fn33(arg3, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                                task.wait()
                                fn33(arg3, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                                task.wait()
                                fn33(arg3, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                                task.wait()
                                fn33(arg3, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                                task.wait()
                            end

                            if arg3.Velocity.Magnitude > 500 or arg3.Parent ~= arg2.Character or arg2.Parent ~= Players or humanoid2.Sit or humanoid.Health <= 0 or now2 + 2 < tick() then
                                break
                            end
                        end
                    end

                    Workspace.FallenPartsDestroyHeight = (0 / 0)
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Name = "EpixVel"
                    bodyVelocity.Parent = rootPart
                    bodyVelocity.Velocity = Vector3.new(900000000, 900000000, 900000000)
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

                    if rootPart2 then
                        fn34(rootPart2)
                    end

                    if bodyVelocity and bodyVelocity.Parent then
                        bodyVelocity:Destroy()
                    end

                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

                    if genv.OldPos and humanoid and humanoid.Health > 0 then
                        rootPart.CFrame = genv.OldPos
                    end
                end

                for i, v5 in ipairs(arg) do
                    local v6 = fn31(v5)

                    if v6 then
                        fn32(v6)
                    end
                end

                if flag4 then
                    for i, player in ipairs(Players:GetPlayers()) do
                        if player ~= localPlayer then
                            fn32(player)
                        end
                    end
                end
            end

            task.spawn(function()
                local v5, v6, v7, v8, v9, v10, n4
                n4 = 1

                while true do
                    if n4 == 1 then
                        task.wait(2)

                        if v.AnnoyingStuff.Fling.LoopFlingAllPlayers then
                            n4 = 2
                        else
                            n4 = 1
                        end
                    elseif n4 == 2 then
                        v5, v6, v7 = ipairs(Players:GetPlayers())
                        v8 = v7
                        n4 = 3
                    elseif n4 == 3 then
                        v9, v10 = v5(v6, v8)

                        if v9 == nil then
                            n4 = 1
                        else
                            n4 = 4
                        end
                    elseif n4 == 4 then
                        v8 = v9

                        if v10 == localPlayer then
                            n4 = 3
                        else
                            n4 = 5
                        end
                    elseif n4 == 5 then
                        pcall(function()
                            fn4({v10.Name})
                        end)

                        task.wait(0.1)
                        n4 = 3
                    end
                end
            end)

            RunService.RenderStepped:Connect(function()
                if fn26() ~= localPlayer or not v.Gameplay.AutoShooting then
                    return
                end
                local v5 = fn25()
                if not v5 or not v5.Character then
                    return
                end
                local humanoidRootPart = v5.Character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then
                    return
                end

                if not localPlayer.Character then
                    return
                end
                local humanoidRootPart2 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart2 then
                    return
                end
                local n4 = humanoidRootPart.Position - humanoidRootPart2.Position
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                raycastParams.FilterDescendantsInstances = {localPlayer.Character}
                local hit = Workspace:Raycast(humanoidRootPart2.Position, n4, raycastParams)

                if not hit or hit.Instance.Parent == v5.Character then
                    local gun = localPlayer.Character:FindFirstChild("Gun")
                    local gun2 = gun or localPlayer.Backpack:FindFirstChild("Gun")

                    if gun2 then
                        local v6 = fn()

                        if v6 and gun2.Parent == localPlayer.Backpack then
                            v6:EquipTool(gun2)
                        end

                        local v7 = fn25()
                        if not v7 or not v7.Character then
                            return
                        end
                        local upperTorso = v7.Character:FindFirstChild("UpperTorso")
                        local humanoid = v7.Character:FindFirstChild("Humanoid")
                        if not upperTorso or not humanoid then
                            return
                        end
                        local moveDirection = humanoid.MoveDirection
                        local n5 = (upperTorso.Position + upperTorso.AssemblyLinearVelocity * Vector3.new(0, 0.5, 0) * 0.14 + moveDirection * 2.8) * (localPlayer:GetNetworkPing() * 1000 * 0 + 1)

                        pcall(function()
                            local character = localPlayer.Character
                            local gun3 = character and localPlayer.Character:FindFirstChild("Gun")

                            if gun3 then
                                gun3.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1, n5, "AH2")
                            end
                        end)
                    end
                end
            end)

            local onClientEvent = roundStart.OnClientEvent
            local connect = onClientEvent.Connect

            connect(onClientEvent, function()
                if v.AutoRevealRoles then
                    fn28()
                end

                if v.AutoFarm.KillEveryoneAsAMurderer then
                    task.wait(1)

                    repeat
                        fn29()
                        task.wait(1)
                    until fn25() ~= localPlayer
                end

                if v.AutoFarm.AutoFlingMurderer then
                    local v5 = fn25()

                    if v5 and v5 ~= localPlayer then
                        fn4({v5.Name})
                    end
                end

                if v.AutoFarm.AutoFlingSheriff then
                    local v5 = fn26()

                    if v5 and v5 ~= localPlayer then
                        fn4({v5.Name})
                    end
                end

                if v.AutoFarm.TeleportSpawn then
                    Teleport_to_lobby()
                end

                task.spawn(fn20)
            end)

            fn5 = function()
                pcall(function()
                    ReplicatedStorage.Remotes.Extras.GetPlayerData:InvokeServer("GetData")
                end)

                local emoteModule = ReplicatedStorage.Modules:FindFirstChild("EmoteModule")
                local emotes = localPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Emotes")
                if not emoteModule or not emotes then
                    return
                end

                local tbl5 = {
                    "headless",
                    "zombie",
                    "zen",
                    "ninja",
                    "floss",
                    "dab",
                    "sit",
                }

                pcall(function()
                    require(emoteModule).GeneratePage(tbl5, emotes, "Free Emotes")
                end)

                genv.FreeEmotesOperator = true

                while genv.FreeEmotesOperator do
                    if emotes and not emotes.EmotePages:FindFirstChild("Free Emotes") then
                        genv.FreeEmotesOperator = false
                        connect()
                    end

                    RunService.RenderStepped:Wait()
                end
            end

            fn6 = function()
                local tbl5 = {}

                pcall(function()
                    local response = game:HttpGet(string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", game.PlaceId))
                    local data = HttpService:JSONDecode(response)
                    local v5 = ipairs
                    local data2 = data.data
                    local tbl6 = data2 or {}

                    for k, v6 in v5(tbl6) do
                        if v6.id ~= game.JobId and v6.playing < v6.maxPlayers then
                            table.insert(tbl5, v6.id)
                        end
                    end
                end)

                if #tbl5 == 0 then
                    lib:Notify({
                        Title = "ServerHop",
                        Content = "No available servers found.",
                        Type = "Warning",
                        Duration = 3,
                    })

                    return
                end

                TeleportService:TeleportToPlaceInstance(game.PlaceId, tbl5[math.random(1, #tbl5)])
            end

            Players.PlayerRemoving:Connect(function()
                task.defer(function()
                    if v.AutoFarm.AutoTeleportToRandomServerIfServerIsEmpty and #Players:GetPlayers() < v.AutoFarm.PlayersToAutoServerHop then
                        fn6()
                    end
                end)
            end)

            task.spawn(function()
                while true do
                    task.wait(30)

                    if v.AutoFarm.AutoPrestige then
                        pcall(function()
                            ReplicatedStorage.Remotes.Inventory.Prestige:FireServer()
                        end)
                    end
                end
            end)

            local flag4 = false

            coinCollected.OnClientEvent:Connect(function(arg, arg2, arg3)
                if arg2 ~= arg3 or flag4 then
                    return
                end
                flag4 = true

                task.spawn(function()
                    if v.AutoFarm.KillEveryoneAsAMurdererAtFullBag and fn25() == localPlayer then
                        for i = 1, 10 do
                            if fn25() ~= localPlayer then
                                break
                            end
                            fn29()
                            task.wait(1)
                        end
                    elseif v.AutoFarm.AutoFlingMurdererAtFullBag and fn25() ~= localPlayer then
                        for i = 1, 5 do
                            local v5 = fn25()
                            if not v5 or v5 == localPlayer then
                                break
                            end
                            fn4({v5.Name})
                            task.wait(1)
                        end
                    elseif v.AutoFarm.TeleportUnderMap then
                        task.wait(0.1)
                        fn12()
                    elseif v.CoinFarm.Settings.DieAtFullBag then
                        local v5 = fn()

                        if v5 then
                            v5:ChangeState(Enum.HumanoidStateType.Dead)
                        end
                    end

                    task.wait(2)
                    flag4 = false
                end)
            end)

            local v5 = nil
            local v6 = nil
            local v7 = nil
            local str = "Supreme"
            local flag5 = false
            local n4 = 6
            local flag6 = false

            local function fn31()
                pcall(function()
                    if not isfolder("ValueData") then
                        makefolder("ValueData")
                    end
                end)

                if isfile and isfile("ValueData/mm2_values.json") then
                    local ok, result = pcall(readfile, "ValueData/mm2_values.json")

                    if ok and result ~= "" then
                        local ok2, result2 = pcall(HttpService.JSONDecode, HttpService, result)

                        if ok2 and result2 then
                            local now2 = tick()
                            local time = result2._time
                            local n5 = time or 0
                            if now2 - n5 < 3600 then
                                return result2.data
                            end
                        end
                    end
                end

                local reqFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
                local ok, result = false, nil

                if reqFunc then
                    local resOk, resp = pcall(function()
                        return reqFunc({
                            Url = "https://api.project-reverse.org/valuables/get-game-valuables?game=mm2",
                            Method = "GET",
                            Headers = {["User-Agent"] = "Roblox/WinInet"}
                        })
                    end)
                    if resOk and resp and (resp.StatusCode == 200 or resp.Status == 200) and resp.Body then
                        ok = true
                        result = resp.Body
                    end
                end

                if not ok then
                    ok, result = pcall(game.HttpGet, game, "https://api.project-reverse.org/valuables/get-game-valuables?game=mm2")
                end

                if not ok or not result or result == "" then
                    local ok2, result2 = pcall(function()
                        return HttpService:JSONDecode(readfile("ValueData/mm2_values.json"))
                    end)
                    local data = ok2 and result2 and result2.data or {}
                    return data
                end

                local decOk, data = pcall(function()
                    return HttpService:JSONDecode(result)
                end)

                if not decOk or not data or not data.data then
                    local ok2, result2 = pcall(function()
                        return HttpService:JSONDecode(readfile("ValueData/mm2_values.json"))
                    end)
                    return (ok2 and result2 and result2.data) or {}
                end

                pcall(function()
                    writefile("ValueData/mm2_values.json", HttpService:JSONEncode({data = data.data, _time = tick()}))
                end)

                return data.data
            end

            local function fn32()
                local tbl5 = {}
                local v8 = pairs
                local v9 = fn31()
                local tbl6 = v9 or {}

                for k, v10 in v8(tbl6) do
                    tbl5[v10.name] = v10.price
                end

                return tbl5
            end

            local function fn33()
                local n5 = 0

                local function fn34(arg, arg2, arg3)
                    n5 = n5 + 1

                    task.spawn(function()
                        if not genv[arg] then
                            local ok, result = false, nil
                            local reqFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
                            if reqFunc then
                                local rOk, resp = pcall(function()
                                    return reqFunc({
                                        Url = arg2,
                                        Method = "GET",
                                        Headers = {["User-Agent"] = "Roblox/WinInet"}
                                    })
                                end)
                                if rOk and resp and resp.Body then
                                    ok = true
                                    result = resp.Body
                                end
                            end
                            if not ok then
                                ok, result = pcall(game.HttpGet, game, arg2)
                            end

                            local str2 = (ok and result) or ""

                            if arg3 and str2 ~= "" then
                                str2 = str2:split(arg3)[1] or str2
                            end

                            genv[arg] = str2
                        end

                        n5 = n5 - 1
                    end)
                end

                n5 = 1

                task.spawn(function()
                    if not genv.htmlparser then
                        local ok, htmlparser = pcall(function()
                            return loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/RBXL-HTML-Parser/refs/heads/master/html/init.lua"))()
                        end)

                        if ok then
                            genv.htmlparser = htmlparser
                        end
                    end

                    n5 = n5 - 1
                end)

                fn34("SupremeAncients", "https://supremevaluelist.com/mm2/ancients.html")
                fn34("SupremeChromas", "https://supremevaluelist.com/mm2/chromas.html", "<div class=\"tierheading\" id=\"pets\">Pets</div>")
                fn34("SupremeGodlies", "https://supremevaluelist.com/mm2/godlies.html")
                fn34("SupremeUniques", "https://supremevaluelist.com/mm2/uniques.html", "<div class=\"tierheading\" id=\"special\">Special Tier</div>")
                fn34("SupremeVintages", "https://supremevaluelist.com/mm2/vintages.html")
                fn34("SupremeLegendarys", "https://supremevaluelist.com/mm2/legendaries.html", "<div class=\"tierheading\" id=\"tier2\">Tier 2</div>")
                local now2 = tick()

                while n5 > 0 do
                    task.wait()
                    if tick() - now2 > 30 then
                        break
                    end
                end

                if not genv.htmlparser then
                    return {}
                end
                local supremeAncients = genv.SupremeAncients
                local str2 = supremeAncients or ""
                local supremeChromas = genv.SupremeChromas
                local str3 = supremeChromas or ""
                local supremeGodlies = genv.SupremeGodlies
                local str4 = supremeGodlies or ""
                local supremeUniques = genv.SupremeUniques
                local str5 = supremeUniques or ""
                local supremeLegendarys = genv.SupremeLegendarys
                local str6 = supremeLegendarys or ""
                local supremeVintages = genv.SupremeVintages
                local str7 = supremeVintages or ""
                local str8 = str2 .. str3 .. str4 .. str5 .. str6 .. str7

                local ok, result = pcall(function()
                    return genv.htmlparser.parse(str8)
                end)

                if not ok or not result then
                    return {}
                end
                local tbl5 = {}
                local itemhead = result:select(".itemhead")
                local itembody = result:select(".itembody")

                for i = 1, math.min(#itemhead, #itembody) do
                    local tbl6 = {}
                    local str9 = itemhead[i]:content():gsub("%s<img.+$", "")
                    local name = str9

                    if string.find(str9, "https://www.youtube.com/jdrbx") then
                        name = "JD"
                    end

                    tbl6.name = name
                    local itemvalue = itembody[i]:select(".itemvalue")

                    if #itemvalue > 0 then
                        tbl6.value = itemvalue[1]:content():gsub(",", "")
                    end

                    if not string.find(tbl6.name, "Nik's Scythe") then
                        table.insert(tbl5, tbl6)
                    end
                end

                local tbl6 = {}

                for k, v8 in pairs(tbl5) do
                    tbl6[v8.name] = {value = tonumber(v8.value)}
                end

                local tbl7 = {}
                local tbl8 = {}
                local Item = {}
                pcall(function()
                    Item = require(ReplicatedStorage.Database.Sync.Item) or {}
                end)

                for k, v8 in pairs(Item) do
                    if v8.Rarity == "Unique" or v8.Rarity == "Godly" or v8.Rarity == "Ancient" or v8.Rarity == "Classic" or v8.Rarity == "Legendary" then
                        local insert = table.insert
                        local tbl9 = {name = k, rarity = v8.Rarity}
                        local chroma = v8.Chroma
                        local chroma2 = chroma or false
                        tbl9.chroma = chroma2
                        insert(tbl7, tbl9)
                    end
                end

                for k, v8 in pairs(tbl7) do
                    if not v8.name then
                        v8.name = "???"
                    end

                    tbl8[v8.name] = {rarity = v8.rarity, chroma = v8.chroma}
                end

                local tbl9 = {
                    ["Red Luger"] = "RedLuger",
                    ["Hallow's Blade"] = "HallowsBlade",
                    ["Flowerwood Gun"] = "FlowerwoodGun",
                    ["Battleaxe II"] = "BattleAxe2",
                    ["Rainbow Gun"] = "Rainbow_G",
                    Waves = "Waves_K",
                    ["Orange Seer"] = "OrangeSeer",
                    Icecracker = "Icecracker_K_2020",
                    Soul = "WraithGun",
                    ["Arctic (Gun)"] = "Arctic_G_2022",
                    ["C. Elderwood Blade"] = "ElderwoodKnifeChroma",
                    ["Chroma Heat"] = "HeatChroma",
                    ["Santa's Spirit"] = "SantasSpirit",
                    Spirit = "WraithKnife",
                    ["Vampire's Edge"] = "VampiresEdge",
                    ["Vampire's Axe"] = "VampireAxe",
                    Evergun = "TreeGun2023",
                    ["Eternal III"] = "Eternal3",
                    ["Cotton Candy"] = "CottonCandy",
                    ["Chroma Gingerblade"] = "GingerbladeChroma",
                    ["Elderwood Revolver"] = "ElderwoodGun",
                    ["Chroma Tides"] = "TidesChroma",
                    ["Spectral (Knife)"] = "Spectral_K_2021",
                    ["Latte (Gun)"] = "Latte_G_2023",
                    ["Ginger (Gun)"] = "Ginger_G_2018",
                    ["Elderwood Blade"] = "ElderwoodKnife",
                    ["Chroma Seer"] = "SeerChroma",
                    ["Red Seer"] = "RedSeer",
                    Ocean = "Ocean_G",
                    ["Chroma Evergreen"] = "TreeKnife2023Chroma",
                    ["Chroma Evergun"] = "TreeGun2023Chroma",
                    ["Chroma Bauble"] = "BaubleChroma",
                    ["Green Luger"] = "GreenLuger",
                    Gingermint = "Gingermint_G",
                    Phantom = "Phantom2022",
                    ["Chroma Boneblade"] = "BonebladeChroma",
                    ["Blue Seer"] = "BlueSeer",
                    ["Winter's Edge"] = "WintersEdge",
                    ["Chroma Lightbringer"] = "ChromaLightbringer",
                    ["Cavern (Gun)"] = "Cavern_G_2019",
                    ["Tree (Knife)"] = "Tree",
                    ["Tree (Gun)"] = "TreeGun",
                    Rupture = "Bleed",
                    Evergreen = "TreeKnife2023",
                    ["Ghost (Gun)"] = "GhostG2018",
                    ["Red Fire"] = "RedFire",
                    ["Blue Scratch"] = "ScratchBlue",
                    Broken = "Broken_K_2023",
                    ["Chroma Deathshard"] = "DeathshardChroma",
                    ["Red Scratch"] = "Scratch",
                    ["Blue Elite"] = "EliteBlue",
                    ["Vampire (Knife)"] = "Vampire_K_2022",
                    ["Traveler (Gun)"] = "Traveler_G_2023",
                    ["Eternal II"] = "Eternal2",
                    ["C. Vampire's Gun"] = "VampireGunChroma",
                    ["Vampire (Gun)"] = "VampireGun",
                    ["Ice Dragon"] = "IceDragon",
                    Icedriller = "Icedriller_G_2020",
                    ["Green Elite"] = "EliteGreen",
                    ["Swirly Gun"] = "SwirlyGun",
                    ["Cavern (Knife)"] = "Cavern_K_2019",
                    Turkey = "Turkey2023",
                    ["C. Traveler's Gun"] = "TravelerGunChroma",
                    ["Santa's Magic"] = "SantasMagic",
                    Sakura = "Sakura_K",
                    ["Chroma Saw"] = "SawChroma",
                    ["Traveler's Gun"] = "TravelerGun",
                    ["Latte (Knife)"] = "Latte_K_2023",
                    Australis = "AuroraKnife",
                    ["Chroma Swirly Gun"] = "SwirlyGunChroma",
                    ["Chroma Gemstone"] = "GemstoneChroma",
                    Corrupt = "Sorry",
                    ["Old Glory"] = "AmericaSword",
                    ["Chroma Fang"] = "FangChroma",
                    Pearl = "Pearl_K",
                    ["Ginger Luger"] = "GingerLuger",
                    ["Eternal IV"] = "Eternal4",
                    ["Ghost (Knife)"] = "GhostK2018",
                    ["Chroma Darkbringer"] = "ChromaDarkbringer",
                    ["Traveler's Axe"] = "TravelerAxe",
                    ["Chroma Luger"] = "LugerChroma",
                    ["Ice Shard"] = "IceShard",
                    Battleaxe = "BattleAxe",
                    Borealis = "AuroraGun",
                    Flowerwood = "FlowerwoodKnife",
                    Cookiecane = "Gingermint_K",
                    ["Hallow's Edge"] = "Hallow",
                    ["Aurora (Gun)"] = "Aurora_G_2021",
                    ["Frostfade (Knife)"] = "Frostfade_K_2023",
                    Batwing = "Scythe",
                    Blossom = "Blossom_G",
                    ["Chroma Shark"] = "SharkChroma",
                    ["Chroma Candleflame"] = "CandleflameChroma",
                    ["Yellow Seer"] = "YellowSeer",
                    Bat = "ZombieBat",
                    ["C. Constellation"] = "ConstellationChroma",
                    ["Purple Seer"] = "PurpleSeer",
                    ["Chroma Slasher"] = "SlasherChroma",
                    Beach = "Beach_K_2023",
                    ["Elderwood Scythe"] = "ElderwoodScythe",
                    Eternalcane = "EternalCane",
                    ["Chroma Laser"] = "LaserChroma",
                    Pearlshine = "Pearl_G",
                    ["Chroma Cookiecane"] = "Gingermint_KChroma",
                    ["Swirly Blade"] = "SwirlyBlade",
                    Spectre = "Spectre2022",
                    ["Vampire's Gun"] = "VampireGun",
                    Rainbow = "Rainbow_K",
                    ["Chroma Watergun"] = "WatergunChroma",
                    ["Swirly Axe"] = "SwirlyAxe",
                    Splitter = "Knife1",
                    Ghost = "GhostKnife",
                    Blood = "BloodKnife",
                    Shadow = "ShadowKnife",
                }

                local tbl10 = {}

                for k, v8 in pairs(tbl6) do
                    if tbl8[k] then
                        tbl10[k] = v8
                    else
                        local v9 = tbl9[k]
                        local str9 = v9 or ""

                        if tbl8[str9] then
                            tbl10[tbl9[k]] = v8
                        end
                    end
                end

                local tbl11 = {}

                for k, v8 in pairs(tbl10) do
                    tbl11[k] = v8.value
                end

                return tbl11
            end

            task.spawn(function()
                local v8 = fn33()
                local tbl5 = v8 or {}
                v7 = fn32()
                v5 = tbl5
            end)

            local function fn34()
                local flag7 = str == "USD"

                if flag7 then
                    local v8 = v7
                    flag7 = v8 or {}
                end

                if not flag7 then
                    local v8 = v6
                    flag7 = v8 or {}
                end

                v5 = flag7
            end

            local mainGUI = localPlayer.PlayerGui:WaitForChild("MainGUI", 9000000000)
            local lobby = mainGUI:FindFirstChild("Lobby")
            local flag7 = false

            if lobby and mainGUI.Lobby:FindFirstChild("LeaderBar") then
                flag7 = true
            end

            local function createTextLabel(parent)
                local textLabel2 = Instance.new("TextLabel")
                textLabel2.Position = UDim2.new(0, 0, 0, 0)
                textLabel2.Size = UDim2.new(1, 0, 0.3, 0)
                textLabel2.TextScaled = true
                textLabel2.TextWrapped = true
                textLabel2.TextSize = 14
                textLabel2.TextStrokeTransparency = 0.7
                textLabel2.ZIndex = 10
                textLabel2.BackgroundTransparency = 1
                textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel2.Name = "Value"
                textLabel2.Parent = parent
                return textLabel2
            end

            local function fn35(arg)
                pcall(function()
                    local trade = ReplicatedStorage:FindFirstChild("Trade")
                    local offerItem = trade and trade:FindFirstChild("OfferItem")

                    if offerItem then
                        offerItem:FireServer(arg, "Weapons")
                    end
                end)
            end

            local function fn36(arg)
                pcall(function()
                    local trade = ReplicatedStorage:FindFirstChild("Trade")
                    local removeOffer = trade and trade:FindFirstChild("RemoveOffer")

                    if removeOffer then
                        removeOffer:FireServer(arg, "Weapons")
                    end
                end)
            end

            local function fn37(arg)
                local v8, v9, v10 = pairs(arg)
                local v11 = v10
                local v12 = v8
                local v13 = v9

                while true do
                    local v14, v15 = v12(v13, v11)
                    if v14 == nil then
                        break
                    end
                    local v16 = v15[2]
                    local n5 = v16 or 1

                    for i = 1, n5 do
                        fn36(v15[1])
                    end

                    v11 = v14
                end
            end

            local function fn38(arg)
                fn34()
                local tbl5 = {}

                local ok, result = pcall(function()
                    return ReplicatedStorage.Remotes.Extras.GetFullInventory:InvokeServer(arg).Weapons.Owned
                end)

                if not ok or not result then
                    return tbl5
                end

                for k, v8 in pairs(result) do
                    if v5[k] and v5[k] > 0 then
                        tbl5[k] = {value = v5[k], quantity = v8}
                    end
                end

                return tbl5
            end

            local function fn39(arg, arg2, arg3)
                if not arg or arg <= 0 then
                    return {}, 0
                end
                local n5 = arg * (1 - arg3 / 100)
                local tbl5 = {}
                local v8, v9, v10 = pairs(arg2)
                local v11 = v10
                local v12 = v8
                local v13 = v9

                while true do
                    local v14, v15 = v12(v13, v11)
                    if v14 == nil then
                        break
                    end

                    for i = 1, v15.quantity do
                        table.insert(tbl5, {name = v14, value = v15.value})
                    end

                    v11 = v14
                end

                table.sort(tbl5, function(arg4, arg5)
                    local flag8 = arg5.value < arg4.value
                    return flag8
                end)

                return (function(arg4, arg5, arg6)
                    local tbl6 = {}

                    for i = 0, #arg4 do
                        tbl6[i] = {}

                        for i2 = 0, arg5 do
                            tbl6[i][i2] = 0
                        end
                    end

                    for i = 1, #arg4 do
                        for i2 = 0, arg5 do
                            tbl6[i][i2] = tbl6[i - 1][i2]

                            if i2 > 0 and tbl6[i - 1][i2 - 1] + arg4[i].value <= arg6 then
                                tbl6[i][i2] = math.max(tbl6[i][i2], tbl6[i - 1][i2 - 1] + arg4[i].value)
                            end
                        end
                    end

                    local tbl7 = {}
                    local n6 = arg5

                    for i = #arg4, 1, -1 do
                        if tbl6[i][n6] ~= tbl6[i - 1][n6] then
                            table.insert(tbl7, arg4[i].name)
                            n6 = n6 - 1
                        end
                    end

                    return tbl7, tbl6[#arg4][arg5]
                end)(tbl5, 4, n5)
            end

            local v8 = nil
            local title = nil
            local title2 = nil
            local offer = nil
            local v9 = nil
            local n5 = nil
            local n6 = nil
            local player2 = nil
            local v10 = nil
            local connection2 = nil
            local v11 = nil

            local function fn40()
                local v12 = flag7
                local str2 = v12 and "TradeGUI_Phone" or "TradeGUI"
                local v13 = localPlayer.PlayerGui:FindFirstChild(str2)
                local v14 = v13 or localPlayer.PlayerGui:WaitForChild(str2, 5)
                local container = v14 and v14:FindFirstChild("Container")
                local trade = container and container:FindFirstChild("Trade")
                return trade
            end

            local function fn41(arg, arg2)
                fn34()
                if not arg2 or not arg then
                    return
                end
                n5 = 0
                n6 = 0

                for k, v12 in pairs(arg) do
                    local v13 = v12[1]
                    local v14 = v12[2]
                    local container = v8.TheirOffer.Container["NewItem" .. k].Container

                    if container:FindFirstChild("Value") then
                        container.Value:Destroy()
                    end

                    local v15 = createTextLabel(container)
                    local v16 = v5[v13]
                    local n7 = v16 or 0
                    v15.Text = "Value: " .. n7 * v14

                    if v5[v13] then
                        local v17 = n5
                        local v18 = v5[v13]
                        local n8 = v18 or 0
                        n5 = v17 + n8 * v14
                    end
                end

                for k, v12 in pairs(arg2) do
                    local v13 = v12[1]
                    local v14 = v12[2]
                    local container = v8.YourOffer.Container["NewItem" .. k].Container

                    if container:FindFirstChild("Value") then
                        container.Value:Destroy()
                    end

                    local v15 = createTextLabel(container)
                    local v16 = v5[v13]
                    local n7 = v16 or 0
                    v15.Text = "Value: " .. n7 * v14

                    if container:FindFirstChild("Amount") then
                        container.Amount.Position = UDim2.new(0.23, -4, 0.76, 0)
                    end

                    if v5[v13] then
                        local v17 = n6
                        local v18 = v5[v13]
                        local n8 = v18 or 0
                        n6 = v17 + n8 * v14
                    end
                end

                title.Text = "YOUR OFFER | TOTAL:" .. n6
                title2.Text = "THEIR OFFER | TOTAL:" .. n5
            end

            local function fn42()
                n5 = 0
                n6 = 0

                pcall(function()
                    v8 = fn40()
                end)

                if not v8 then
                    return
                end
                local v12, v13, v14 = ipairs({v8.TheirOffer.Container, v8.YourOffer.Container})
                local v15 = v14
                local v16 = v12
                local v17 = v13

                while true do
                    local v18, v19 = v16(v17, v15)
                    if v18 == nil then
                        break
                    end

                    for k, child in pairs(v19:GetChildren()) do
                        if child.ClassName == "Frame" and child:FindFirstChild("Container") and child.Container:FindFirstChild("Value") then
                            child.Container.Value:Destroy()
                        end
                    end

                    v15 = v18
                end

                if title then
                    title.Text = "YOUR OFFER"
                end

                if title2 then
                    title2.Text = "THEIR OFFER"
                end
            end

            local onClientEvent2 = ReplicatedStorage.Trade.UpdateTrade.OnClientEvent
            local connect2 = onClientEvent2.Connect

            connect2(onClientEvent2, function(arg)
                if arg.Player2.Player == localPlayer then
                    local player1 = arg.Player1
                    player2 = arg.Player2
                    v10 = player1
                end

                if arg.Player1.Player == localPlayer then
                    local player22 = arg.Player2
                    player2 = arg.Player1
                    v10 = player22
                end

                if not player2 or not v10 then
                    return
                end
                local offer2 = player2.Offer
                offer = v10.Offer
                v9 = offer2

                pcall(function()
                    v8 = fn40()
                end)

                if not v8 then
                    return
                end
                title = v8.YourOffer.Title
                title2 = v8.TheirOffer.Title
                n5 = 0
                n6 = 0

                if flag5 then
                    pcall(fn41, offer, v9)
                end
            end)

            local function fn43()
                v11 = fn38(localPlayer.Name)
                if connection2 then
                    return connection2
                end

                connection2 = ReplicatedStorage.Trade.UpdateTrade.OnClientEvent:Connect(function(arg)
                    if arg.Player2.Player == localPlayer then
                        local player1 = arg.Player1
                        player2 = arg.Player2
                        v10 = player1
                    end

                    if arg.Player1.Player == localPlayer then
                        local player22 = arg.Player2
                        player2 = arg.Player1
                        v10 = player22
                    end

                    if not player2 or not v10 then
                        return
                    end
                    local offer2 = player2.Offer
                    offer = v10.Offer
                    v9 = offer2

                    pcall(function()
                        v8 = fn40()
                    end)

                    if not v8 then
                        return
                    end
                    local title3 = v8.TheirOffer.Title
                    title = v8.YourOffer.Title
                    title2 = title3
                    n5 = 0
                    n6 = 0

                    for k, v12 in pairs(offer) do
                        if v5[v12[1]] then
                            local v13 = n5
                            local v14 = v5[v12[1]]
                            local n7 = v14 or 0
                            n5 = v13 + n7 * v12[2]
                        end
                    end

                    for k, v12 in pairs(v9) do
                        if v5[v12[1]] then
                            local v13 = n6
                            local v14 = v5[v12[1]]
                            local n7 = v14 or 0
                            n6 = v13 + n7 * v12[2]
                        end
                    end

                    if flag6 then
                        if #offer == 0 then
                            fn37(v9)
                            return
                        end
                        local v12, v13 = fn39(n5, v11, n4)

                        if v13 ~= n6 then
                            connection2:Disconnect()
                            connection2 = nil
                            fn37(v9)

                            for k, v14 in pairs(v12) do
                                fn35(v14)
                            end

                            connection2 = connect2()
                        end
                    end
                end)

                return connection2
            end

            ReplicatedStorage.Trade.StartTrade.OnClientEvent:Connect(function()
                pcall(function()
                    v8 = fn40()
                end)

                if not v8 then
                    return
                end
                local title3 = v8.TheirOffer.Title
                title = v8.YourOffer.Title
                title2 = title3

                if flag5 then
                    title.Text = "YOUR OFFER | TOTAL: 0"
                    title2.Text = "THEIR OFFER | TOTAL: 0"
                end

                connection2 = fn43()
            end)

            ReplicatedStorage.Trade.EndTrade.OnClientEvent:Connect(function()
                if connection2 then
                    connection2:Disconnect()
                    connection2 = nil
                end
            end)

            ReplicatedStorage.Trade.AcceptTrade.OnClientEvent:Connect(function()
                if connection2 then
                    connection2:Disconnect()
                    connection2 = nil
                end

                if flag6 and n5 then
                    local v12 = n5
                    local v13 = v11
                    local tbl5 = v13 or {}
                    local v14, v15 = fn39(v12, tbl5, n4)

                    if v15 ~= n6 and v9 then
                        local v16, v17, v18 = pairs(v9)
                        local v19 = v18
                        local v20 = v16
                        local v21 = v17

                        while true do
                            local v22, v23 = v20(v21, v19)
                            if v22 == nil then
                                break
                            end

                            for i = 1, v23[2] do
                                fn36(v23[1])
                            end

                            v19 = v22
                        end

                        for k, v22 in pairs(v14) do
                            fn35(v22)
                        end

                        connection2 = fn43()
                    end
                end
            end)

            local function fn44()
                local v12 = n5
                local n7 = v12 or 0
                local v13 = v11
                local tbl5 = v13 or {}
                local v14, v15 = fn39(n7, tbl5, n4)

                if v15 ~= n6 and v9 then
                    local v16, v17, v18 = pairs(v9)
                    local v19 = v18
                    local v20 = v16
                    local v21 = v17

                    while true do
                        local v22, v23 = v20(v21, v19)
                        if v22 == nil then
                            break
                        end

                        for i = 1, v23[2] do
                            fn36(v23[1])
                        end

                        v19 = v22
                    end

                    for k, v22 in pairs(v14) do
                        fn35(v22)
                    end
                end
            end

            local function fn45()
                if not v9 then
                    return
                end
                local v12, v13, v14 = pairs(v9)
                local v15 = v14
                local v16 = v12
                local v17 = v13

                while true do
                    local v18, v19 = v16(v17, v15)
                    if v18 == nil then
                        break
                    end

                    for i = 1, v19[2] do
                        fn36(v19[1])
                    end

                    v15 = v18
                end
            end

            local function fn46(arg)
                local response = ReplicatedStorage.Remotes.Extras.GetFullInventory:InvokeServer(arg)
                local tbl5 = {}
                local v12 = pairs
                local weapons = response.Weapons
                local tbl6 = weapons or {}
                local owned = tbl6.Owned
                local tbl7 = owned or {}

                for k, v13 in v12(tbl7) do
                    local v14 = tbl5[k]
                    local n7 = v14 or 0
                    tbl5[k] = n7 + v13
                end

                local v13 = pairs
                local pets = response.Pets
                local tbl8 = pets or {}
                local owned2 = tbl8.Owned
                local tbl9 = owned2 or {}

                for k, v14 in v13(tbl9) do
                    local v15 = tbl5[k]
                    local n7 = v15 or 0
                    tbl5[k] = n7 + v14
                end

                return tbl5
            end

            local function fn47(arg)
                local v12 = fn46(arg)
                local v13 = fn32()
                local tbl5 = {}
                local n7 = 0
                local n8 = 0

                for k, v14 in pairs(v12) do
                    local v15 = v13[k]
                    local n9 = v15 or 0

                    if n9 > 0 then
                        local n10 = n9 * v14
                        table.insert(tbl5, {name = k, count = v14, price = n9, total = n10})
                        n7 = n7 + n10
                        n8 = n8 + v14
                    end
                end

                table.sort(tbl5, function(arg2, arg3)
                    local flag8 = arg3.total < arg2.total
                    return flag8
                end)

                local tbl6 = {"Inventory Analysis:", string.rep("-", 40)}

                for i, v14 in ipairs(tbl5) do
                    table.insert(tbl6, string.format("%-20s x%-4d | $%8.2f | $%10.2f", v14.name, v14.count, v14.price, v14.total))
                end

                table.insert(tbl6, string.rep("-", 40))
                table.insert(tbl6, string.format("Total Items: %d", n8))
                table.insert(tbl6, string.format("Total Value: $%d", math.floor(n7)))
                return table.concat(tbl6, "\n")
            end

            local changeInventoryItem = ReplicatedStorage.Remotes.Inventory.ChangeInventoryItem
            local itemGift = ReplicatedStorage:FindFirstChild("ItemGift")

            local function fn48(arg, arg2)
                local ok, result = pcall(require, arg)
                if ok and result ~= nil then
                    return result
                end
                return arg2
            end

            local v12 = fn48(ReplicatedStorage.Modules:FindFirstChild("BoxModule"), {})
            local v13 = fn48(ReplicatedStorage.Database.Sync:FindFirstChild("Item"), {})
            local v14 = fn48(ReplicatedStorage.Modules:FindFirstChild("ProfileData"), {Weapons = {Owned = {}}})
            local v15 = _G
            local cache = _G.Cache
            local cache2 = cache or {}
            v15.Cache = cache2
            local v16 = _G
            local smallCache = _G.SmallCache
            local smallCache2 = smallCache or {}
            v16.SmallCache = smallCache2
            local ItemModule = nil

            pcall(function()
                ItemModule = require(ReplicatedStorage.Modules.ItemModule)
            end)

            local tbl5 = {}
            local v17 = pairs
            local weapons = v14.Weapons
            local tbl6 = weapons or {}
            local owned = tbl6.Owned
            local tbl7 = owned or {}

            for k, v18 in v17(tbl7) do
                tbl5[k] = v18
            end

            local function fn49(arg)
                local v18 = tbl5[arg]
                local n7 = v18 or 0
                return n7
            end

            fn7 = function(arg, arg2)
                if not arg or arg == "" then
                    return
                end
                local n7 = fn49(arg) + arg2
                tbl5[arg] = n7

                pcall(function()
                    firesignal(changeInventoryItem.OnClientEvent, "Weapons", arg, n7)
                end)

                if itemGift then
                    pcall(function()
                        firesignal(itemGift.OnClientEvent, arg, "Weapons", arg2)
                    end)
                end
            end

            local tbl8 = {
                Common = Color3.fromRGB(134, 142, 150),
                Uncommon = Color3.fromRGB(64, 192, 87),
                Rare = Color3.fromRGB(51, 154, 240),
                Legendary = Color3.fromRGB(250, 176, 5),
                Godly = Color3.fromRGB(190, 75, 219),
                Ancient = Color3.fromRGB(255, 107, 107),
                Unique = Color3.fromRGB(255, 212, 59),
                Classic = Color3.fromRGB(255, 146, 43),
                Vintage = Color3.fromRGB(173, 181, 189),
                Christmas = Color3.fromRGB(32, 201, 151),
                Halloween = Color3.fromRGB(252, 126, 20),
            }

            local tbl9 = {
                Unique = 1,
                Ancient = 2,
                Godly = 3,
                Classic = 4,
                Vintage = 5,
                Legendary = 6,
                Rare = 7,
                Uncommon = 8,
                Common = 9,
            }

            local function fn50(arg, arg2)
                local str2 = arg

                if (str2 == nil or str2 == "") and arg2 then
                    str2 = tostring(arg2)
                end

                if str2 == nil or str2 == "" then
                    return nil
                end

                if type(str2) == "string" and (string.find(str2, "rbxassetid://", 1, true) == 1 or string.find(str2, "rbxthumb://", 1, true) == 1) then
                    return str2
                end

                if ItemModule and type(ItemModule.GetImage) == "function" then
                    local ok, result = pcall(function()
                        return ItemModule.GetImage(str2)
                    end)

                    if ok and type(result) == "string" and result ~= "" then
                        return result
                    end
                end

                if tonumber(str2) then
                    return "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. tostring(str2) .. "&bust=" .. tostring(math.random(1, 10000))
                end

                if type(str2) ~= "string" then
                    return nil
                end

                if string.find(str2, "roblox.com/Thumbs/Asset.ashx", 1, true) and not string.find(str2, "&bust=", 1, true) then
                    return str2 .. "&bust=" .. tostring(math.random(1, 10000))
                end
                return str2
            end

            local function fn51(arg)
                local itemType = arg and arg.ItemType
                local flag8 = itemType == nil or itemType == "Knife" or itemType == "Gun"
                return flag8
            end

            v2 = (function()
                local tbl10 = {}

                for k, v18 in pairs(v13) do
                    if type(v18) == "table" and fn51(v18) then
                        local itemName = v18.ItemName
                        local v19 = itemName or k
                        local rarity = v18.Rarity
                        local str2 = rarity or "Unknown"
                        local itemType = v18.ItemType
                        local str3 = itemType or "Weapon"
                        local insert = table.insert

                        local tbl11 = {
                            Id = k,
                            Name = v19,
                            Subtitle = str3 .. " / " .. k,
                            Badge = str2,
                            BadgeColor = tbl8[str2],
                            Image = fn50(v18.Image, v18.ItemID),
                            _SortName = string.lower(v19),
                        }

                        local v20 = tbl9[str2]
                        local sortRarity = v20 or 99
                        tbl11._SortRarity = sortRarity
                        insert(tbl10, tbl11)
                    end
                end

                table.sort(tbl10, function(arg, arg2)
                    if arg._SortRarity == arg2._SortRarity then
                        local flag8 = arg._SortName < arg2._SortName
                        return flag8
                    end
                    local flag8 = arg._SortRarity < arg2._SortRarity
                    return flag8
                end)

                return tbl10
            end)()

            local function fn52()
                local v18 = fn48(ReplicatedStorage.Database.Sync:FindFirstChild("MysteryBox"), {})
                if not v18 or next(v18) == nil then
                    return nil
                end
                local tbl10 = {}

                for k in pairs(v18) do
                    table.insert(tbl10, k)
                end

                return tbl10[math.random(1, #tbl10)]
            end

            fn8 = function(arg)
                if not arg or arg == "" then
                    return
                end

                pcall(function()
                    v12.OpenBox(fn52(), arg)
                end)

                fn7(arg, 1)
            end

            task.spawn(function()
                while true do
                    task.wait(0.5)
                    if not v.AutoOpenCrates.State or not v.AutoOpenCrates.Crate then
                        continue
                    end

                    pcall(function()
                        ReplicatedStorage.Remotes.MysteryBox.OpenBox:FireServer(unpack({
                            "OpenBox",
                            v.AutoOpenCrates.Crate,
                            v.AutoOpenCrates.CrateType,
                        }))
                    end)
                end
            end)

            game:GetService("Lighting").ChildAdded:Connect(function(child)
                if child.Name == "DepthOfField" then
                    child.InFocusRadius = 500
                    child:Destroy()
                end
            end)

            local touchEnabled = UserInputService.TouchEnabled
            flag = touchEnabled

            if touchEnabled then
                if UserInputService.MouseEnabled then
                    flag = false
                else
                    flag = true
                end
            end

            fn9 = function(arg, arg2, arg3)
                return math.max(arg2, math.min(arg3, arg))
            end

            local v18 = (function()
                if not flag then
                    return 1
                end
                local currentCamera = Workspace.CurrentCamera
                local viewportSize = currentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(390, 800)
                local n7 = math.min(viewportSize.X, viewportSize.Y)
                local n8 = math.max(viewportSize.X, viewportSize.Y)
                return fn9(fn9(math.min(n7 / 820, n8 / 1450), 0.78, 0.96) * 0.4347826086956522, 0.32, 0.46)
            end)()

            local udim2 = flag and UDim2.fromOffset(math.floor(820 * v18), math.floor(540 * v18)) or UDim2.fromOffset(820, 540)
            local vector22 = flag and Vector2.new(160, 120) or Vector2.new(760, 420)
            vector2 = flag and Vector2.new(math.max(40, math.floor(118 * v18)), math.max(48, math.floor(148 * v18))) or Vector2.new(118, 148)

            v3 = lib:CreateWindow({
                Title = "Project Reverse [MM2]",
                Size = udim2,
                MinSize = vector22,
                MaxSize = Vector2.new(1400, 900),
                MobileScaled = flag,
                Resizable = true,
                Theme = "Dark",
                ToggleKeybind = Enum.KeyCode.RightControl,
                OnClose = function()
                    pcall(function()
                        RunService:Set3dRenderingEnabled(true)
                    end)

                    pcall(fn19)
                    genv.ValAutoFarmCoins = false
                    genv.mm2VisualLibraryLoaded = false
                    genv.MM2LibraryWindow = nil
                    print("[MM2] window closed")
                end,
            })

            local v19 = v3:CreateTab({Name = "Gameplay"})
            local v20 = v19:CreateSection({Name = "Tools", Side = "Left"})

            v20:AddButton({
                Text = "Pick Up Gun",
                Tooltip = "Instant Gun Pick Up",
                Callback = function()
                    pickupgun()
                end,
            })

            v20:AddToggle({
                Text = "Auto Pick Up Gun",
                Default = false,
                Flag = "AutoPickUpGun",
                Tooltip = "Automatic Instant Gun Pick Up",
                Callback = function(autoPickUpGun)
                    v.Gameplay.AutoPickUpGun = autoPickUpGun
                end,
            })

            local v21 = v19:CreateSection({Name = "Basic Stuff", Side = "Left"})

            v21:AddToggle({
                Text = "Noclip",
                Default = false,
                Flag = "Noclip",
                Tooltip = "Walk through walls and objects",
                Callback = function(noclip)
                    v.Noclip = noclip
                end,
            })

            v21:AddButton({
                Text = "Fly GUI",
                Tooltip = "Open the Fly GUI script",
                Callback = function()
                    local ok, result = pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
                    end)

                    if not ok then
                        lib:Notify({
                            Title = "Fly GUI failed",
                            Content = tostring(result),
                            Type = "Danger",
                            Duration = 4,
                        })
                    end
                end,
            })

            local v22 = v19:CreateSection({Name = "More Tools", Side = "Left"})

            v22:AddButton({
                Text = "Kill Everyone as Murderer",
                Variant = "Danger",
                Tooltip = "Eliminate all players if you are the murderer",
                Callback = function()
                    if fn25() ~= localPlayer then
                        lib:Notify({
                            Title = "You are not the murderer",
                            Content = "You do not have the knife.",
                            Type = "Warning",
                            Duration = 4,
                        })
                    end

                    fn29()
                end,
            })

            v22:AddButton({
                Text = "Bring All Players",
                Tooltip = "Teleport every player to your location (only useful as murderer)",
                Callback = function()
                    if fn25() == localPlayer then
                        for i, player in ipairs(Players:GetPlayers()) do
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localPlayer then
                                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                                local humanoidRootPart2 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                                humanoidRootPart.Anchored = true
                                humanoidRootPart.CFrame = humanoidRootPart2.CFrame + humanoidRootPart2.CFrame.LookVector * 5
                            end
                        end

                        lib:Notify({
                            Title = "Teleported Everyone",
                            Content = "All players moved to your position.",
                            Type = "Success",
                            Duration = 3,
                        })

                        return
                    end

                    lib:Notify({
                        Title = "You are not the murderer",
                        Content = "This is only useful when you are the murderer.",
                        Type = "Warning",
                        Duration = 4,
                    })
                end,
            })

            v22:AddToggle({
                Text = "Auto Shoot Murderer",
                Default = false,
                Flag = "AutoShootMurderer",
                Tooltip = "Automatically shoot the murderer when detected",
                Callback = function(autoShooting)
                    v.Gameplay.AutoShooting = autoShooting
                end,
            })

            v22:AddButton({
                Text = "Shoot Murderer (manual)",
                Callback = function()
                    if not localPlayer.Character then
                        return
                    end
                    local gun = localPlayer.Character:FindFirstChild("Gun")
                    local gun2 = gun or localPlayer.Backpack:FindFirstChild("Gun")

                    if gun2 then
                        local v23 = fn()

                        if v23 and gun2.Parent == localPlayer.Backpack then
                            v23:EquipTool(gun2)
                        end

                        local v24 = fn25()
                        if not v24 or not v24.Character then
                            return
                        end
                        local upperTorso = v24.Character:FindFirstChild("UpperTorso")
                        local humanoid = v24.Character:FindFirstChild("Humanoid")
                        if not upperTorso or not humanoid then
                            return
                        end
                        local moveDirection = humanoid.MoveDirection
                        local n7 = (upperTorso.Position + upperTorso.AssemblyLinearVelocity * Vector3.new(0, 0.5, 0) * 0.14 + moveDirection * 2.8) * (localPlayer:GetNetworkPing() * 1000 * 0 + 1)

                        pcall(function()
                            local character = localPlayer.Character
                            local gun3 = character and localPlayer.Character:FindFirstChild("Gun")

                            if gun3 then
                                gun3.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1, n7, "AH2")
                            end
                        end)
                    end
                end,
            })

            local v23 = v19:CreateSection({Name = "Annoying Stuff", Side = "Right"})

            local function fn53(arg)
                if not arg or arg == "" then
                    return
                end
                local str2 = arg:lower()

                for k, player in pairs(Players:GetPlayers()) do
                    if string.find(player.Name:lower(), str2, 1, true) or string.find(player.DisplayName:lower(), str2, 1, true) then
                        return player.Name
                    end
                end
            end

            v23:AddInput({
                Text = "Pick A Player",
                Placeholder = "Enter player name...",
                Default = "",
                Flag = "FlingPick",
                Callback = function(arg)
                    v.AnnoyingStuff.Fling.PickedPlayer = fn53(arg)
                end,
            })

            v23:AddButton({
                Text = "Fling Chosen Player",
                Callback = function()
                    if not v.AnnoyingStuff.Fling.PickedPlayer then
                        return
                    end
                    fn4({v.AnnoyingStuff.Fling.PickedPlayer})
                end,
            })

            v23:AddButton({
                Text = "Fling Murderer",
                Callback = function()
                    local v24 = fn25()

                    if v24 then
                        fn4({v24.Name})
                    end
                end,
            })

            v23:AddButton({
                Text = "Fling Sheriff",
                Callback = function()
                    local v24 = fn26()

                    if v24 then
                        fn4({v24.Name})
                    end
                end,
            })

            v23:AddButton({
                Text = "Fling All Players",
                Variant = "Danger",
                Callback = function()
                    fn4({"All"})
                end,
            })

            v23:AddButton({
                Text = "Fling Random Player",
                Callback = function()
                    local players = Players:GetPlayers()
                    local v24 = table.find(players, localPlayer)

                    if v24 then
                        table.remove(players, v24)
                    end

                    if #players == 0 then
                        lib:Notify({
                            Title = "No target",
                            Content = "There are no other players in the server.",
                            Type = "Warning",
                            Duration = 3,
                        })

                        return
                    end

                    fn4({players[math.random(#players)].Name})
                end,
            })

            v23:AddToggle({
                Text = "Loop Fling All Players",
                Default = false,
                Flag = "LoopFlingAll",
                Tooltip = "Repeatedly fling all players",
                Callback = function(loopFlingAllPlayers)
                    v.AnnoyingStuff.Fling.LoopFlingAllPlayers = loopFlingAllPlayers
                end,
            })

            local v24 = v19:CreateSection({Name = "Other Tools", Side = "Right"})

            v24:AddButton({
                Text = "Teleport to Map",
                Callback = function()
                    Teleport_to_map()
                end,
            })

            v24:AddButton({
                Text = "Teleport to Lobby",
                Callback = function()
                    Teleport_to_lobby()
                end,
            })

            v24:AddButton({
                Text = "Notify Murderer Username",
                Callback = function()
                    local v25 = fn25()

                    if not v25 then
                        lib:Notify({
                            Title = "Murderer",
                            Content = "Not found.",
                            Type = "Warning",
                            Duration = 3,
                        })

                        return
                    end

                    lib:Notify({
                        Title = "Murderer Username",
                        Content = v25.Name,
                        Type = "Info",
                        Duration = 5,
                    })
                end,
            })

            v24:AddButton({
                Text = "Notify Sheriff Username",
                Callback = function()
                    local v25 = fn26()

                    if not v25 then
                        lib:Notify({
                            Title = "Sheriff",
                            Content = "Not found.",
                            Type = "Warning",
                            Duration = 3,
                        })

                        return
                    end

                    lib:Notify({
                        Title = "Sheriff Username",
                        Content = v25.Name,
                        Type = "Info",
                        Duration = 5,
                    })
                end,
            })

            v24:AddButton({
                Text = "Reveal Roles",
                Callback = function()
                    fn28()
                end,
            })

            v24:AddToggle({
                Text = "Auto Reveal Roles",
                Default = false,
                Flag = "AutoRevealRoles",
                Tooltip = "Automatically show player roles each round",
                Callback = function(autoRevealRoles)
                    v.AutoRevealRoles = autoRevealRoles
                end,
            })

            local v25 = v19:CreateSection({Name = "Speed and Jump", Side = "Right"})

            v25:AddSlider({
                Text = "WalkSpeed",
                Min = 1,
                Max = 100,
                Default = 16,
                Increment = 1,
                Suffix = "studs/s",
                Flag = "WS",
                Callback = function(speed)
                    v.Sliders.Speed = speed
                end,
            })

            v25:AddSlider({
                Text = "JumpPower",
                Min = 1,
                Max = 100,
                Default = 50,
                Increment = 1,
                Flag = "JP",
                Callback = function(jump)
                    v.Sliders.Jump = jump
                end,
            })

            local v26 = v3:CreateTab({Name = "ESP"}):CreateSection("ESP Settings")

            v26:AddToggle({
                Text = "Players ESP",
                Default = false,
                Flag = "ESPPlayers",
                Tooltip = "Highlight all players on the map",
                Callback = function(players)
                    v.ESP.Players = players

                    if players then
                        fn27()
                    else
                        for i, child in ipairs(Workspace:GetChildren()) do
                            if child.Name == "PlayerESP" then
                                child:Destroy()
                            end
                        end
                    end
                end,
            })

            v26:AddToggle({
                Text = "Dropped Gun ESP",
                Default = false,
                Flag = "ESPGun",
                Tooltip = "Highlight dropped guns",
                Callback = function(droppedGun)
                    v.ESP.DroppedGun = droppedGun
                end,
            })

            v26:AddToggle({
                Text = "Trap ESP",
                Default = false,
                Flag = "ESPTrap",
                Tooltip = "Highlight traps placed by murderer",
                Callback = function(traps)
                    v.ESP.Traps = traps
                end,
            })

            local v27 = v3:CreateTab({Name = "Auto Farm"})
            local v28 = v27:CreateSection({Name = "Autofarm Features", Side = "Left"})

            v28:AddToggle({
                Text = "Auto Teleport At Spawn",
                Default = false,
                Flag = "AutoTPSpawn",
                Tooltip = "Teleport to spawn when round starts",
                Callback = function(teleportSpawn)
                    v.AutoFarm.TeleportSpawn = teleportSpawn
                end,
            })

            v28:AddToggle({
                Text = "Auto Kill Everyone As Murderer",
                Default = false,
                Flag = "AutoKillAll",
                Callback = function(killEveryoneAsAMurderer)
                    v.AutoFarm.KillEveryoneAsAMurderer = killEveryoneAsAMurderer
                end,
            })

            v28:AddToggle({
                Text = "Auto Prestige",
                Default = false,
                Flag = "AutoPrestige",
                Callback = function(autoPrestige)
                    v.AutoFarm.AutoPrestige = autoPrestige
                end,
            })

            local v29 = v27:CreateSection({Name = "More Features", Side = "Right"})

            v29:AddToggle({
                Text = "Auto Fling Murderer",
                Default = false,
                Flag = "AutoFlingM",
                Callback = function(autoFlingMurderer)
                    v.AutoFarm.AutoFlingMurderer = autoFlingMurderer
                end,
            })

            v29:AddToggle({
                Text = "Auto Fling Sheriff",
                Default = false,
                Flag = "AutoFlingS",
                Callback = function(autoFlingSheriff)
                    v.AutoFarm.AutoFlingSheriff = autoFlingSheriff
                end,
            })

            v29:AddToggle({
                Text = "Server Hop If Server Is Empty",
                Default = false,
                Flag = "AutoSH",
                Callback = function(autoTeleportToRandomServerIfServ)
                    v.AutoFarm.AutoTeleportToRandomServerIfServerIsEmpty = autoTeleportToRandomServerIfServ
                end,
            })

            v29:AddSlider({
                Text = "Players Threshold For Server Hop",
                Min = 1,
                Max = 12,
                Default = 2,
                Increment = 1,
                Flag = "SHThresh",
                Callback = function(playersToAutoServerHop)
                    v.AutoFarm.PlayersToAutoServerHop = playersToAutoServerHop
                end,
            })

            local v30 = v3:CreateTab({Name = "Coin Farm"})
            local v31 = v30:CreateSection({Name = "Coin Farm 1 [Fly]", Side = "Left"})

            v31:AddToggle({
                Text = "Enable Coin Farm 1",
                Default = false,
                Flag = "CF1",
                Tooltip = "Automatically collect coins (fly method)",
                Callback = function(state)
                    v.CoinFarm.State = state

                    if not state then
                        local character = localPlayer.Character
                        local humanoidRootPart = character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

                        if humanoidRootPart then
                            humanoidRootPart.Anchored = false
                            local mm2CoinFarmVelocity = humanoidRootPart:FindFirstChild("MM2_CoinFarmVelocity")

                            if mm2CoinFarmVelocity then
                                mm2CoinFarmVelocity:Destroy()
                            end
                        end
                    end
                end,
            })

            v31:AddSlider({
                Text = "Farm Speed",
                Min = 15,
                Max = 25,
                Default = 22.5,
                Increment = 0.5,
                Flag = "CF1Speed",
                Callback = function(speed)
                    v.CoinFarm.Settings.Speed = speed
                end,
            })

            v30:CreateSection({Name = "Coin Farm 2 [Safe TP]", Side = "Left"}):AddToggle({
                Text = "Enable Coin Farm 2",
                Default = false,
                Flag = "CF2",
                Tooltip = "Teleport-based safe coin farm",
                Callback = function(state)
                    v.CoinFarm2.State = state

                    if state then
                        task.spawn(fn24)
                    end
                end,
            })

            local v32 = v30:CreateSection({Name = "Coin Settings", Side = "Right"})

            v32:AddToggle({
                Text = "Destroy Player Models",
                Default = false,
                Flag = "DestroyP",
                Callback = function(destroyPlayers)
                    v.CoinFarm.Settings.DestroyPlayers = destroyPlayers
                end,
            })

            v32:AddToggle({
                Text = "Destroy Map",
                Default = false,
                Flag = "DestroyM",
                Callback = function(destroyMap)
                    v.CoinFarm.Settings.DestroyMap = destroyMap
                end,
            })

            v32:AddToggle({
                Text = "Die At Full Bag",
                Default = false,
                Flag = "DieFull",
                Callback = function(dieAtFullBag)
                    v.CoinFarm.Settings.DieAtFullBag = dieAtFullBag
                end,
            })

            v32:AddToggle({
                Text = "Teleport Under Map At Full Bag",
                Default = false,
                Flag = "TPUnderFull",
                Callback = function(teleportUnderMap)
                    v.AutoFarm.TeleportUnderMap = teleportUnderMap
                end,
            })

            v32:AddToggle({
                Text = "Auto Fling Murderer At Full Bag",
                Default = false,
                Flag = "AFMFull",
                Callback = function(autoFlingMurdererAtFullBag)
                    v.AutoFarm.AutoFlingMurdererAtFullBag = autoFlingMurdererAtFullBag
                end,
            })

            v32:AddToggle({
                Text = "Disable 3D Rendering",
                Default = false,
                Flag = "Disable3D",
                Callback = function(disable3DRendering)
                    v.CoinFarm2.Disable3DRendering = disable3DRendering

                    pcall(function()
                        local set3dRenderingEnabled = RunService.Set3dRenderingEnabled
                        local flag8

                        if disable3DRendering then
                            flag8 = false
                        else
                            flag8 = true
                        end

                        set3dRenderingEnabled(RunService, flag8)
                    end)
                end,
            })

            v32:AddToggle({
                Text = "Stats Overlay",
                Default = false,
                Flag = "StatsOverlay",
                Callback = function(statsOverlay)
                    v.CoinFarm.StatsOverlay = statsOverlay
                end,
            })

            local v33 = v30:CreateSection({Name = "Auto Open Crates", Side = "Right"})
            local tbl10 = {}

            local ok, result = pcall(function()
                return require(ReplicatedStorage.Database.Sync.Shop).Weapons
            end)

            if ok and result then
                for k in pairs(result) do
                    table.insert(tbl10, tostring(k))
                end

                table.sort(tbl10)
            end

            v33:AddToggle({
                Text = "Auto Open Crates",
                Default = false,
                Flag = "AOCrates",
                Callback = function(state)
                    v.AutoOpenCrates.State = state
                end,
            })

            if #tbl10 > 0 then
                v33:AddDropdown({
                    Text = "Choose Box",
                    Options = tbl10,
                    Default = tbl10[1],
                    Searchable = true,
                    Flag = "AOCrate_Pick",
                    Callback = function(crate)
                        v.AutoOpenCrates.Crate = crate

                        local ok2, crateType = pcall(function()
                            return require(ReplicatedStorage.Database.Sync.Shop).Weapons[crate].DataType
                        end)

                        if ok2 and crateType then
                            v.AutoOpenCrates.CrateType = crateType
                        end
                    end,
                })
            end

            local v34 = v3:CreateTab({Name = "Trade Helper"})
            local v35 = v34:CreateSection({Name = "Trade Info", Side = "Left"})

            v35:AddParagraph({
                Title = "Trade Helper",
                Content = "This tab shows item values in trades (USD or Supreme), calculates total value, and helps you choose profitable offers.",
            })

            v35:AddDropdown({
                Text = "Item Price Display",
                Options = {"USD", "Supreme"},
                Default = "Supreme",
                Flag = "PriceType",
                Callback = function(arg)
                    str = arg
                    fn34()
                end,
            })

            v35:AddToggle({
                Text = "Show Values In Trade",
                Default = false,
                Flag = "ShowValues",
                Callback = function(arg)
                    flag5 = arg

                    if arg then
                        pcall(fn41, offer, v9)
                    else
                        pcall(fn42)
                    end
                end,
            })

            local v36 = v34:CreateSection({Name = "Auto Trade [Risky]", Side = "Right"})

            v36:AddBanner({
                Type = "Warning",
                Text = "Auto-trade changes your offer automatically. Test it on an alt first.",
            })

            v36:AddToggle({
                Text = "Automatically Generate Offers",
                Default = false,
                Flag = "AutoOffer",
                Callback = function(arg)
                    flag6 = arg
                end,
            })

            v36:AddButton({
                Text = "Generate Offer",
                Callback = function()
                    pcall(fn44)
                end,
            })

            v36:AddButton({
                Text = "Refresh Offer",
                Variant = "Ghost",
                Callback = function()
                    pcall(fn45)
                end,
            })

            v36:AddSlider({
                Text = "Minimum Profit Percentage",
                Min = 0,
                Max = 100,
                Default = 6,
                Increment = 1,
                Suffix = "%",
                Flag = "MinProfit",
                Callback = function(arg)
                    n4 = arg
                end,
            })

            local v37 = v3:CreateTab({Name = "Inventory"})
            local v38 = v37:CreateSection({Name = "Inventory Analyzer", Side = "Left"})

            v38:AddParagraph({
                Title = "What is this?",
                Content = "Analyzes your inventory, sorts items by value, and shows the total USD value.",
            })

            local v39 = v38:AddParagraph({
                Title = "Your Inventory:",
                Content = "Press the button below.",
            })

            local flag8 = false

            v38:AddButton({
                Text = "Start Analysis",
                Variant = "Primary",
                Callback = function()
                    if flag8 then
                        return
                    end
                    flag8 = true
                    v39:SetTitle("Please wait...")
                    v39:SetContent("Collecting data...")

                    task.spawn(function()
                        local ok2, result2 = pcall(fn47, localPlayer.Name)
                        v39:SetTitle("Your Inventory:")
                        local setContent = v39.SetContent
                        local str2 = ok2 and result2 or "Failed to fetch inventory."
                        setContent(v39, str2)
                        flag8 = false
                    end)
                end,
            })

            v38:AddButton({
                Text = "Copy To Clipboard",
                Variant = "Ghost",
                Callback = function()
                    local ok2, result2 = pcall(fn47, localPlayer.Name)

                    if ok2 and typeof(setclipboard) == "function" and pcall(setclipboard, result2) then
                        lib:Notify({
                            Title = "Copied",
                            Content = "Copied to clipboard.",
                            Type = "Success",
                            Duration = 3,
                        })
                    end
                end,
            })

            local v40 = v37:CreateSection({Name = "Other Players' Inventories", Side = "Right"})

            v40:AddParagraph({
                Title = "Players Inventories Analysis",
                Content = "Start the scanner and wait a minute: it collects all player inventories and sorts them by total value.",
            })

            local tbl11 = {}
            local v41 = v40:AddParagraph({Title = "Results:", Content = "(empty)"})

            local function fn54(arg)
                local str2 = type(arg) == "string" and arg or ""
                local v42 = string.match(str2, "Total Value:%s*%$?(%-?[%d%.]+)")
                local num = tonumber(v42)
                local n7 = num or 0
                return n7
            end

            local function fn55()
                local tbl12 = {}

                for k, v42 in pairs(tbl11) do
                    table.insert(tbl12, {name = k, data = v42, total = fn54(v42)})
                end

                table.sort(tbl12, function(arg, arg2)
                    local flag9 = arg2.total < arg.total
                    return flag9
                end)

                local tbl13 = {}

                for i, v42 in ipairs(tbl12) do
                    table.insert(tbl13, string.format("Player %s:\n%s\n", v42.name, v42.data))
                end

                local setContent = v41.SetContent
                local str2 = #tbl13 > 0 and table.concat(tbl13, "\n") or "(empty)"
                setContent(v41, str2)
            end

            local flag9 = false

            v40:AddToggle({
                Text = "Auto-Scan Players Every Minute",
                Default = false,
                Flag = "OthersScan",
                Callback = function(arg)
                    flag9 = arg

                    if arg then
                        task.spawn(function()
                            while flag9 do
                                for i, player in ipairs(Players:GetPlayers()) do
                                    if not flag9 then
                                        break
                                    end
                                    local ok2, result2 = pcall(fn47, player.Name)
                                    local name = player.Name
                                    local str2 = ok2 and result2 or "Failed to fetch."
                                    tbl11[name] = str2
                                    fn55()
                                    task.wait(1)
                                end

                                task.wait(60)
                            end
                        end)
                    end
                end,
            })

            v40:AddButton({
                Text = "Scan All Players Now",
                Callback = function()
                    task.spawn(function()
                        for i, player in ipairs(Players:GetPlayers()) do
                            local ok2, result2 = pcall(fn47, player.Name)
                            local name = player.Name
                            local str2 = ok2 and result2 or "Failed to fetch."
                            tbl11[name] = str2
                            fn55()
                            task.wait(0.5)
                        end
                    end)
                end,
            })
        end

        local n = 1

        local function fn10()
            if v3 and v3._UpdateStatus then
                pcall(v3._UpdateStatus)
            end
        end

        local function fn11(arg)
            n = fn9(n + arg, 1, 100)
            fn10()
        end

        local function fn12(arg)
            local n2 = #arg:GetSelected()
            return n2, n, n2 * n
        end

        local function fn13(arg)
            local selected = arg:GetSelected()

            if #selected == 0 then
                lib:Notify({
                    Title = "Nothing selected",
                    Content = "Select item cards first. Amount applies to each selected item.",
                    Type = "Warning",
                    Duration = 3,
                })

                return
            end

            local ok, result = pcall(function()
                for i, v4 in ipairs(selected) do
                    fn7(v4, n)
                end
            end)

            if not ok then
                lib:Notify({
                    Title = "Spawn failed",
                    Content = tostring(result),
                    Type = "Danger",
                    Duration = 4,
                })

                return
            end

            lib:Notify({
                Title = "Spawned",
                Content = string.format("%d selected item(s) x %d each = %d total spawned.", #selected, n, #selected * n),
                Type = "Success",
                Duration = 3,
            })
        end

        local function fn14(arg)
            local selected = arg:GetSelected()

            if #selected == 0 then
                lib:Notify({
                    Title = "Nothing selected",
                    Content = "Select one or more item cards first.",
                    Type = "Warning",
                    Duration = 3,
                })

                return
            end

            task.spawn(function()
                local n2 = 0

                for i, v4 in ipairs(selected) do
                    local ok, result = pcall(function()
                        fn8(v4)
                    end)

                    if ok then
                        n2 = n2 + 1
                    else
                        lib:Notify({
                            Title = "Crate open failed",
                            Content = tostring(result),
                            Type = "Danger",
                            Duration = 4,
                        })
                    end

                    task.wait(0.05)
                end

                if n2 > 0 then
                    lib:Notify({
                        Title = "Crates opened",
                        Content = string.format("%d item(s).", n2),
                        Type = "Success",
                        Duration = 3,
                    })
                end
            end)
        end

        local v4 = v3:CreateTab({Name = "Spawner"})

        local v5 = v4:AddItemGrid({
            Items = v2,
            MultiSelect = true,
            SearchBar = true,
            ItemSize = vector2,
            MobileScaledItemSize = flag,
            OnSelectionChanged = function(arg)
                fn10()
            end,
        })

        v4:SetActionBar({
            Left = {
                {
                    Text = "Select All",
                    Callback = function()
                        v5:SelectAll()
                    end,
                },
                {
                    Text = "Clear",
                    Callback = function()
                        v5:Clear()
                    end,
                },
                {
                    Text = "Amount -",
                    Callback = function()
                        fn11(-1)
                    end,
                },
                {
                    Text = "Amount +",
                    Callback = function()
                        fn11(1)
                    end,
                },
            },
            Primary = {
                Text = "Spawn Selected",
                Callback = function()
                    fn13(v5)
                end,
            },
            Status = function()
                local v6, v7, v8 = fn12(v5)
                return string.format("%d x %d = %d items", v6, v7, v8)
            end,
        })

        local v6 = v3:CreateTab({Name = "Crates"})

        local v7 = v6:AddItemGrid({
            Items = v2,
            MultiSelect = true,
            SearchBar = true,
            ItemSize = vector2,
            MobileScaledItemSize = flag,
            OnSelectionChanged = function(arg)
                fn10()
            end,
        })

        v6:SetActionBar({
            Left = {
                {
                    Text = "Select All",
                    Callback = function()
                        v7:SelectAll()
                    end,
                },
                {
                    Text = "Clear",
                    Callback = function()
                        v7:Clear()
                    end,
                },
            },
            Primary = {
                Text = "Open Crate",
                Callback = function()
                    fn14(v7)
                end,
            },
            Status = function()
                return string.format("%d selected", #v7:GetSelected())
            end,
        })

        local v8 = v3:CreateTab({Name = "Misc"})
        local v9 = v8:CreateSection({Name = "Server Crasher", Side = "Left"})

        v9:AddBanner({
            Type = "Danger",
            Text = "Server crash is locked for most users. Development only (getgenv().dev = true).",
        })

        v9:AddButton({
            Text = "Crash Server",
            Variant = "Danger",
            Callback = function()
                if not genv.dev then
                    lib:Notify({
                        Title = "Feature locked",
                        Content = "You do not have access to this feature.",
                        Type = "Warning",
                        Duration = 4,
                    })

                    return
                end

                task.spawn(fn3)
            end,
        })

        v8:CreateSection({Name = "Unlock Emotes", Side = "Left"}):AddButton({
            Text = "Unlock All Emotes",
            Callback = function()
                local v10 = fn()

                if localPlayer.PlayerGui:FindFirstChild("MainGUI") and localPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Emotes") and fn2() and v10 and v10.Health > 0 then
                    fn5()
                else
                    lib:Notify({
                        Title = "Not ready",
                        Content = "Wait for the game to finish loading.",
                        Type = "Warning",
                        Duration = 3,
                    })
                end
            end,
        })

        local v10 = v8:CreateSection({Name = "Server Stuff", Side = "Right"})

        v10:AddButton({
            Text = "Rejoin Server",
            Callback = function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end,
        })

        v10:AddButton({
            Text = "Server Hop",
            Callback = function()
                fn6()
            end,
        })

        local v11 = v8:CreateSection({Name = "Spam Random Emotes", Side = "Right"})

        v11:AddToggle({
            Text = "Spam Random Emotes",
            Default = false,
            Flag = "SpamRand",
            Callback = function(autoPlayEmotes)
                v.Emotes.AutoPlayEmotes = autoPlayEmotes
            end,
        })

        v11:AddSlider({
            Text = "Spam Speed",
            Min = 1,
            Max = 50,
            Default = 1,
            Increment = 1,
            Suffix = "/s",
            Flag = "SpamSpeed",
            Callback = function(emoteSpamSpeed)
                v.Emotes.EmoteSpamSpeed = emoteSpamSpeed
            end,
        })

        local v12 = v8:CreateSection({Name = "Spam Selected Emote", Side = "Right"})

        v12:AddToggle({
            Text = "Spam Selected Emote",
            Default = false,
            Flag = "SpamSel",
            Callback = function(autoPlaySelectedEmote)
                v.Emotes.AutoPlaySelectedEmote = autoPlaySelectedEmote
            end,
        })

        v12:AddDropdown({
            Text = "Pick An Emote",
            Options = tbl,
            Default = tbl[1],
            Searchable = true,
            Flag = "PickEmote",
            Callback = function(selectedEmote)
                v.Emotes.SelectedEmote = selectedEmote
            end,
        })

        v8:CreateSection({Name = "Fast Skin Swapper", Side = "Right"}):AddToggle({
            Text = "Shuffle Weapons",
            Default = false,
            Flag = "ShuffleW",
            Callback = function(shuffleWeapons)
                v.ShuffleWeapons = shuffleWeapons
            end,
        })

        local v13 = v3:CreateTab({Name = "Valentine Farm"})

        local tbl2 = {
            PlayerData = {},
            MaxCoins = 40,
            CoinBag = 0,
            TotalCollected = 0,
            SessionTime = 0,
            PauseFloatTP = false,
            IsFarming = false,
            CoinTypes = {"Any"},
            CoinFarmType = "Under",
            FarmSpeed = 22.7,
            KillAllOnFull = false,
            ResetOnFullBag = false,
            FlingMurdererFullBag = false,
            FlingedRecently = false,
            LastFlingTime = 0,
        }

        local gameplay = ReplicatedStorage.Remotes.Gameplay
        local extras = ReplicatedStorage.Remotes.Extras

        pcall(function()
            tbl2.PlayerData = gameplay.GetCurrentPlayerData:InvokeServer()

            local ok, result = pcall(function()
                return extras.AmElite:InvokeServer()
            end)

            local maxCoins = ok and result and 50 or 40
            tbl2.MaxCoins = maxCoins

            if tbl2.PlayerData[localPlayer.Name] then
                local coins = tbl2.PlayerData[localPlayer.Name].Coins
                local coinBag = coins or 0
                tbl2.CoinBag = coinBag
                local isFarming

                if tbl2.PlayerData[localPlayer.Name].Dead then
                    isFarming = false
                else
                    isFarming = true
                end

                tbl2.IsFarming = isFarming
            end
        end)

        gameplay.PlayerDataChanged.OnClientEvent:Connect(function(playerData)
            tbl2.PlayerData = playerData
        end)

        gameplay.CoinCollected.OnClientEvent:Connect(function(arg, coinBag)
            tbl2.CoinBag = coinBag
            tbl2.TotalCollected = tbl2.TotalCollected + 1
        end)

        gameplay.LoadingMap.OnClientEvent:Connect(function()
            tbl2.CoinBag = 0
        end)

        gameplay.RoundStart.OnClientEvent:Connect(function()
            local ok, result = pcall(function()
                return extras.AmElite:InvokeServer()
            end)

            local maxCoins = ok and result and 50 or 40
            tbl2.MaxCoins = maxCoins
            tbl2.IsFarming = true
        end)

        gameplay.RoundEndFade.OnClientEvent:Connect(function()
            tbl2.IsFarming = false
        end)

        local function fn15(arg)
            local character = arg.Character
            local result = character or arg.CharacterAdded:Wait()
            return result
        end

        local function fn16(arg)
            local v14 = fn15(arg)
            local humanoidRootPart = v14 and v14:FindFirstChild("HumanoidRootPart")
            return humanoidRootPart
        end

        local function fn17(arg)
            local v14 = fn15(arg)
            local humanoid = v14 and v14:FindFirstChildOfClass("Humanoid")
            return humanoid
        end

        local function fn18()
            local character = localPlayer.Character
            local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
            local flag2 = character and humanoid and humanoid.Health > 0
            return flag2
        end

        local function fn19(arg)
            local v14 = tbl2.PlayerData[arg.Name]
            local flag2 = v14

            if v14 then
                if tbl2.PlayerData[arg.Name].Dead then
                    flag2 = false
                else
                    flag2 = true
                end
            end

            return flag2
        end

        local function fn20()
            for k, child in pairs(Workspace:GetChildren()) do
                if child:GetAttribute("MapID") then
                    return child
                end
            end
        end

        local function fn21()
            local flag2 = tbl2.MaxCoins <= tbl2.CoinBag
            return flag2
        end

        local function fn22(arg)
            for k, v14 in pairs(tbl2.PlayerData) do
                if k == arg.Name then
                    return v14.Role
                end
            end

            return "None"
        end

        local function fn23()
            local flag2 = fn22(localPlayer) == "Murderer"
            return flag2
        end

        local function fn24()
            local n2 = 0
            local flag2 = false

            for k, v14 in pairs(tbl2.PlayerData) do
                if k ~= localPlayer.Name and v14 and not v14.Dead then
                    n2 = n2 + 1

                    if v14.Role == "Murderer" then
                        flag2 = true
                    end
                end
            end

            local v14 = fn19(localPlayer)
            local flag3 = v14 and n2 == 1 and flag2
            return flag3
        end

        local function fn25()
            tbl2.PauseFloatTP = true
            task.wait(0.5)

            if fn18() then
                localPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
            end

            repeat
                task.wait(0.2)
            until fn18()

            tbl2.PauseFloatTP = false
        end

        local function fn26()
            local v14 = fn17(localPlayer)

            if localPlayer.Backpack:FindFirstChild("Knife") and v14 then
                v14:EquipTool(localPlayer.Backpack:FindFirstChild("Knife"))
            end

            local v15 = fn15(localPlayer)
            local knife = v15 and v15:FindFirstChild("Knife")
            if not knife then
                return
            end

            for k, player in pairs(Players:GetPlayers()) do
                task.spawn(function()
                    local v16 = fn16(localPlayer)

                    if player.Character and v16 and player ~= localPlayer and fn19(player) then
                        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

                        if humanoidRootPart then
                            pcall(function()
                                firetouchinterest(knife.Handle, humanoidRootPart, 1)
                                knife:FindFirstChild("Events"):FindFirstChild("KnifeStabbed"):FireServer()
                                knife:Activate()
                                firetouchinterest(knife.Handle, humanoidRootPart, 0)
                            end)

                            task.wait()
                        end
                    end
                end)
            end
        end

        local function fn27()
            local v14 = fn16(localPlayer)
            if not v14 then
                return
            end
            local v15 = fn20()
            local coinContainer = v15 and v15:FindFirstChild("CoinContainer")
            if not coinContainer then
                return
            end
            local tbl3 = {}

            for k, child in pairs(coinContainer:GetChildren()) do
                if child:GetAttribute("CoinID") and not child:GetAttribute("Collected") and (table.find(tbl2.CoinTypes, child:GetAttribute("CoinID")) or table.find(tbl2.CoinTypes, "Any")) then
                    local coinVisual = child:FindFirstChild("CoinVisual")
                    local mainCoin = coinVisual and coinVisual:FindFirstChild("MainCoin")

                    if mainCoin and mainCoin.Transparency == 0 then
                        table.insert(tbl3, {
                            coin = child,
                            dist = (v14.Position - child.Position).Magnitude,
                        })
                    end
                end
            end

            table.sort(tbl3, function(arg, arg2)
                local flag2 = arg.dist < arg2.dist
                return flag2
            end)

            local v16 = tbl3[1]
            local coin = v16 and tbl3[1].coin
            return coin
        end

        local part = nil
        local connection = nil
        local connection2 = nil
        local v14 = nil
        local connection3 = nil

        local function fn28()
            tbl2.FlingedRecently = true
            tbl2.LastFlingTime = tick()

            task.delay(30, function()
                if tick() - tbl2.LastFlingTime >= 30 then
                    tbl2.FlingedRecently = false
                end
            end)
        end

        local function fn29(valAutoFarmCoins)
            genv.ValAutoFarmCoins = valAutoFarmCoins

            if valAutoFarmCoins then
                part = Instance.new("Part")
                part.Name = "ValFarmFloat"
                local vector = Vector3.new(5, 0.1, 5)
                part.Size = vector
                part.CanCollide = true
                part.Anchored = true
                part.Parent = Workspace
                part.Transparency = 1
                local v15 = fn16(localPlayer)
                local position = v15 and fn16(localPlayer).Position or Vector3.zero
                v14 = position

                connection = RunService.RenderStepped:Connect(function()
                    if fn16(localPlayer) then
                        for k, descendant in pairs(fn15(localPlayer):GetDescendants()) do
                            if descendant:IsA("BasePart") and descendant.CanCollide then
                                descendant.CanCollide = false
                            end
                        end
                    end
                end)

                connection3 = RunService.RenderStepped:Connect(function(deltaTime)
                    tbl2.SessionTime = tbl2.SessionTime + deltaTime
                end)

                connection2 = RunService.Heartbeat:Connect(function()
                    local v16 = fn16(localPlayer)

                    if v16 and part and fn18() and not tbl2.PauseFloatTP then
                        local n2 = part.CFrame * CFrame.new(0, 3, 0)
                        local cFrame = n2

                        if fn19(localPlayer) and not fn21() and tbl2.IsFarming then
                            cFrame = n2 * CFrame.Angles(math.rad(90), 0, 0)
                        end

                        v16.CFrame = cFrame
                        v16.Velocity = Vector3.zero
                        v16.RotVelocity = Vector3.zero
                    end
                end)
            else
                if connection then
                    connection:Disconnect()
                    connection = nil
                end

                if connection2 then
                    connection2:Disconnect()
                    connection2 = nil
                end

                if connection3 then
                    connection3:Disconnect()
                    connection3 = nil
                end

                if part then
                    part:Destroy()
                    part = nil
                end

                local v15 = fn16(localPlayer)

                if v15 and v14 then
                    v15.Anchored = true
                    v15.CFrame = CFrame.new(v14)
                    v15.Velocity = Vector3.zero
                    task.wait(0.7)
                    v15.Anchored = false
                end
            end

            task.spawn(function()
                while genv.ValAutoFarmCoins do
                    local v15 = fn16(localPlayer)

                    if v15 and fn18() then
                        if fn20() then
                            if fn19(localPlayer) and not fn21() and tbl2.IsFarming then
                                local v16 = fn27()

                                if v16 then
                                    local n2 = tbl2.CoinFarmType == "Under" and -6 or -2
                                    local cFrame = CFrame.new(v16.Position) * CFrame.new(0, n2 - 1, 0)
                                    local magnitude = (v15.Position - cFrame.Position).Magnitude

                                    if magnitude >= 200 then
                                        part.CFrame = cFrame
                                    else
                                        local tween = TweenService:Create(part, TweenInfo.new(magnitude / tbl2.FarmSpeed, Enum.EasingStyle.Linear), {CFrame = cFrame})
                                        tween:Play()

                                        if not fn21() then
                                            tween.Completed:Wait()
                                            tween:Cancel()
                                        end
                                    end

                                    task.spawn(function()
                                        while v16 and v15 and not v16:GetAttribute("Collected") do
                                            for i = 0, 200 do
                                                task.spawn(function()
                                                    pcall(function()
                                                        firetouchinterest(v15, v16, 1)
                                                        firetouchinterest(v15, v16, 0)
                                                    end)
                                                end)
                                            end

                                            task.wait()
                                        end
                                    end)

                                    if v16 then
                                        v16:Destroy()
                                    end
                                end
                            else
                                if tbl2.IsFarming then
                                    if tbl2.FlingMurdererFullBag and not fn23() and fn18() and fn21() then
                                        if fn24() then
                                            fn25()
                                        else
                                            for k, v16 in pairs(tbl2.PlayerData) do
                                                if k ~= localPlayer.Name and v16.Role == "Murderer" and not v16.Dead then
                                                    tbl2.PauseFloatTP = true
                                                    fn28()
                                                    fn4({k})
                                                    tbl2.PauseFloatTP = false
                                                    task.wait(0.5)
                                                    break
                                                end
                                            end
                                        end
                                    elseif fn23() and tbl2.KillAllOnFull and fn21() and fn19(localPlayer) and fn18() then
                                        fn26()
                                    end

                                    if tbl2.ResetOnFullBag and fn21() and fn18() and not fn23() and not tbl2.FlingedRecently and fn19(localPlayer) then
                                        fn25()
                                    end
                                end

                                if part and part.Parent then
                                    local cframe = CFrame.new(100, 0, 100)
                                    part.CFrame = cframe
                                end

                                task.wait(0.1)
                            end
                        elseif part then
                            local cframe = CFrame.new(100, 0, 100)
                            part.CFrame = cframe
                        end
                    else
                        task.wait(1)
                    end

                    task.wait()
                end
            end)
        end

        local function fn30(arg)
            if not arg then
                return
            end

            return RunService.Heartbeat:Connect(function()
                local v15, v16, v17 = ipairs(Players:GetPlayers())
                local v18 = v17
                local v19 = v15
                local v20 = v16

                while true do
                    local v21, v22 = v19(v20, v18)
                    if v21 == nil then
                        break
                    end
                    v18 = v21

                    if v22 ~= localPlayer and v22.Character then
                        for i, descendant in ipairs(v22.Character:GetDescendants()) do
                            if descendant:IsA("BasePart") and not descendant.Anchored and descendant.Velocity.Magnitude > 100 then
                                descendant.Velocity = Vector3.zero
                                descendant.RotVelocity = Vector3.zero
                                descendant.Anchored = true

                                task.delay(0.5, function()
                                    if descendant and descendant.Anchored then
                                        descendant.Anchored = false
                                    end
                                end)
                            end
                        end

                        v18 = v21
                    end
                end
            end)
        end

        local v15 = v13:CreateSection({Name = "Session Statistics", Side = "Left"}):AddParagraph({
            Title = "Session Progress",
            Content = "Time: 00:00:00\nCoins: 0 | Per Hour: 0",
        })

        local function fn31(arg)
            return string.format("%02d:%02d:%02d", math.floor(arg / 3600), math.floor(arg / 60) % 60, arg % 60)
        end

        local function fn32(arg)
            return tostring(arg):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        end

        local n2 = 0

        RunService.Heartbeat:Connect(function()
            if tick() - n2 > 0.5 then
                n2 = tick()
                local setContent = v15.SetContent
                local format = string.format
                local v16 = fn31(tbl2.SessionTime)
                local v17 = fn32(tbl2.TotalCollected)
                local str = tbl2.SessionTime > 0 and fn32(math.round(tbl2.TotalCollected / tbl2.SessionTime * 3600)) or "0"
                setContent(v15, format("Time: %s\nCoins: %s | Per Hour: %s", v16, v17, str))
            end
        end)

        v13:CreateSection({Name = "Farming", Side = "Left"}):AddToggle({
            Text = "Enable Coin Auto Farm",
            Default = false,
            Flag = "ValFarm",
            Callback = function(arg)
                fn29(arg)
            end,
        })

        local v16 = v13:CreateSection({Name = "Farm Settings", Side = "Right"})

        v16:AddMultiDropdown({
            Text = "Coin Types",
            Options = {"Any", "Candy", "BeachBall", "Coin", "SnowToken", "Egg"},
            Default = {"Any"},
            Max = 6,
            Flag = "ValCoinTypes",
            Callback = function(arg)
                local coinTypes = #arg > 0 and arg

                if not coinTypes then
                    local tbl3 = {}
                    coinTypes = tbl3
                    tbl3[1] = "Any"
                end

                tbl2.CoinTypes = coinTypes
            end,
        })

        v16:AddDropdown({
            Text = "Teleport Mode",
            Options = {"Under", "Normal"},
            Default = "Under",
            Flag = "ValTPMode",
            Callback = function(coinFarmType)
                tbl2.CoinFarmType = coinFarmType
            end,
        })

        v16:AddSlider({
            Text = "Farm Speed",
            Min = 19,
            Max = 26,
            Default = 22.7,
            Increment = 0.1,
            Suffix = "studs/s",
            Flag = "ValSpeed",
            Tooltip = "Above 22 might kick",
            Callback = function(farmSpeed)
                tbl2.FarmSpeed = farmSpeed
            end,
        })

        local v17 = v13:CreateSection({Name = "On Full Bag", Side = "Right"})

        v17:AddToggle({
            Text = "Kill All (Knife required)",
            Default = false,
            Flag = "ValKillAll",
            Callback = function(killAllOnFull)
                tbl2.KillAllOnFull = killAllOnFull
            end,
        })

        v17:AddToggle({
            Text = "Reset On Full Bag",
            Default = false,
            Flag = "ValReset",
            Callback = function(resetOnFullBag)
                tbl2.ResetOnFullBag = resetOnFullBag
            end,
        })

        v17:AddToggle({
            Text = "Fling Murderer On Full Bag",
            Default = false,
            Flag = "ValFlingM",
            Callback = function(flingMurdererFullBag)
                tbl2.FlingMurdererFullBag = flingMurdererFullBag
            end,
        })

        local v18 = v13:CreateSection({Name = "Utilities", Side = "Right"})
        local v19 = nil

        v18:AddToggle({
            Text = "Anti Fling",
            Default = false,
            Flag = "ValAntiFling",
            Callback = function(arg)
                if v19 then
                    v19:Disconnect()
                    v19 = nil
                end

                if arg then
                    v19 = fn30(true)
                end
            end,
        })

        v18:AddToggle({
            Text = "Disable Rendering",
            Default = false,
            Flag = "ValNoRender",
            Tooltip = "Lowers CPU usage (Black Screen)",
            Callback = function(arg)
                pcall(function()
                    local set3dRenderingEnabled = RunService.Set3dRenderingEnabled
                    local flag2

                    if arg then
                        flag2 = false
                    else
                        flag2 = true
                    end

                    set3dRenderingEnabled(RunService, flag2)
                end)
            end,
        })

        local v20 = v3:CreateTab({Name = "Settings"})
        local v21 = v20:CreateSection({Name = "Theme", Side = "Left"})

        v21:AddDropdown({
            Text = "Preset",
            Options = {"Dark", "Light", "Midnight", "Catppuccin", "AMOLED"},
            Default = "Dark",
            Searchable = false,
            Flag = "ThemePreset",
            Callback = function(arg)
                lib:SetTheme(arg)

                lib:Notify({
                    Title = "Theme",
                    Content = arg,
                    Type = "Info",
                    Duration = 2,
                })
            end,
        })

        v21:AddDropdown({
            Text = "Density",
            Options = {"compact", "normal", "comfortable"},
            Default = "normal",
            Flag = "ThemeDensity",
            Callback = function(arg)
                lib:SetDensity(arg)

                lib:Notify({
                    Title = "Density",
                    Content = arg,
                    Type = "Info",
                    Duration = 2,
                })
            end,
        })

        v21:AddColorPicker({
            Text = "Custom Accent",
            Default = Color3.fromRGB(232, 71, 176),
            Flag = "ThemeAccent",
            Callback = function(arg)
                lib:SetTheme({
                    AccentSolid = arg,
                    AccentGradientFrom = Color3.new(arg.R * 0.85, arg.G * 0.85, arg.B * 0.85),
                    AccentGradientTo = arg,
                })
            end,
        })

        local v22 = v20:CreateSection({Name = "About", Side = "Right"})
        local addParagraph = v22.AddParagraph
        local tbl3 = {Title = "Project Reverse [MM2]"}
        local version = lib.Version
        local str = version or "?"
        tbl3.Content = "Murder Mystery 2 executor package ported to the new UI Library v" .. str .. ". Drag the header to move the window, resize from the bottom-right corner. Toggle: RightControl."
        addParagraph(v22, tbl3)
        v22:AddParagraph({Title = "Credits", Content = "discord.gg/project-reverse"})

        v22:AddBanner({
            Type = "Info",
            Text = "Universal Mode Active - Works in all games.",
        })

        if genv.MM2LibraryWindow then
            pcall(function()
                genv.MM2LibraryWindow:Destroy()
            end)
        end

        genv.MM2LibraryWindow = v3

        task.delay(0.4, function()
            local notify = lib.Notify
            local tbl4 = {Title = "Project Reverse [MM2] Loaded"}
            local version2 = lib.Version
            local str2 = version2 or "?"
            tbl4.Content = "Version " .. str2 .. ". Toggle UI: RightControl."
            tbl4.Type = "Success"
            tbl4.Duration = 5
            notify(lib, tbl4)
        end)

        print("[Universal] UI ready. Toggle with RightControl.")
        return
    end