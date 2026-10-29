--[[
    ═══════════════════════════════════════════════════════════════
    SKYWARS [CLASSIC] - SUPREME EDITION
    Powered by Ranax / TRFTAP UI Architecture
    
    Features:
      • Combat:
          • Killaura with Real Studs Reach (Touch Interest + Multi-Remote Hit Detection)
          • Team Check, Auto-Equip Sword, Hitbox Expander
      • Advanced Godbridge Engine (3-Forward Place -> Pickaxe Swap -> 2-Behind Break):
          • Places 3 blocks forward in running direction
          • Instantly swaps to Pickaxe/Axe
          • Rapid auto-clicker mines 2 blocks behind in 0.5s
          • Swaps back to Block and loops seamlessly while holding W
      • Ore Suite (Advanced Mining Engine):
          • OreAura (Instant multi-target ore mining around player)
          • OreESP (Color-coded Highlighting + Distance Tags for Diamond, Gold, Iron, Coal)
          • Fast Auto Ore Farm (Auto-teleport/glide to high priority ores & instant break)
          • Ore Priority Filter (Diamonds -> Gold -> Iron -> Coal)
      • Movement & Bypasses:
          • Fly Bypass (Glide/Climb state spoof + CFrame flight)
          • Speed Bypass (CFrame Heartbeat interpolation - bypasses WalkSpeed resets)
          • Anti-Void (Auto bounce / recovery to last safe ground CFrame)
          • NoFall Damage Bypass
          • Infinite Jump & Noclip
      • Automation:
          • Auto Kill All Players (Auto Win cycle)
      • Visuals:
          • Player ESP (Boxes, Chams, Team Colors)
          • Ore ESP (Distinct Billboard text & 3D Box Highlights)
      • UI & Controls:
          • LeftControl Toggle Keybind
          • Watermark Click Controller (Clicking watermark smoothly toggles GUI)
          • Full TRFTAP Category Icons & AdaptUILibrary Wrapper
    ═══════════════════════════════════════════════════════════════
]]

-- Executor Compatibility Layer
local getgenv = getgenv or function() return _G end
local genv = getgenv()

local firetouchinterest = firetouchinterest or (syn and syn.firetouchinterest) or (fluxus and fluxus.firetouchinterest)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local Camera = Workspace.CurrentCamera

-- Global Clean Auto-Reload
_G.Ranax_SelectedLayout = "pc"
if genv.SkywarsLoaded then
    pcall(function()
        if genv.SkywarsCleanup then genv.SkywarsCleanup() end
    end)
end
local currentSessionId = tostring(tick()) .. "_" .. tostring(math.random(100000, 999999))
genv.SkywarsLoaded = true
genv.SkywarsSessionId = currentSessionId

local ScriptConnections = {}
local function trackConn(conn)
    if conn then
        table.insert(ScriptConnections, conn)
    end
    return conn
end

local function isSessionActive()
    return genv.SkywarsLoaded and genv.SkywarsSessionId == currentSessionId
end

-- Mouse Spoof State (Prevents Block / Axe tools from EVER targeting the real mouse cursor during Bridge / Ore actions!)
local spoofedMouseHit = nil
local spoofedMouseTarget = nil
local spoofedMouseSurface = nil
local State -- Forward declaration so metatable hooks capture local State upvalue

pcall(function()
    local mouse = LocalPlayer:GetMouse()
    local getrawmt = getrawmetatable or debug.getmetatable
    local setro = setreadonly or (make_writeable and function(t, b) if not b then make_writeable(t) end end)
    local newcc = newcclosure or function(f) return f end
    if mouse and getrawmt and setro then
        local mt = getrawmt(mouse)
        if mt and mt.__index then
            local oldIndex = mt.__index
            setro(mt, false)
            mt.__index = newcc(function(self, k)
                if self == mouse and isSessionActive() then
                    local kl = type(k) == "string" and k:lower() or ""
                    if (kl == "hit") and spoofedMouseHit ~= nil then
                        return spoofedMouseHit
                    elseif (kl == "target") and spoofedMouseTarget ~= nil then
                        return spoofedMouseTarget
                    elseif (kl == "targetsurface") and spoofedMouseSurface ~= nil then
                        return spoofedMouseSurface
                    elseif (kl == "unitray") and spoofedMouseHit ~= nil then
                        local cam = Workspace.CurrentCamera
                        local orig = cam and cam.CFrame.Position or Vector3.new(0, 200, 0)
                        local dir = (spoofedMouseHit.Position - orig)
                        if dir.Magnitude > 0.001 then
                            return Ray.new(orig, dir.Unit)
                        end
                    end
                end
                return oldIndex(self, k)
            end)
            setro(mt, true)
        end
    end
    -- Also hook Workspace raycasts during active spoof so 2017 tool scripts using FindPartOnRay hit our spoofed target!
    local gmt = getrawmt and getrawmt(game)
    if gmt and gmt.__namecall and setro then
        local oldNamecall = gmt.__namecall
        setro(gmt, false)
        gmt.__namecall = newcc(function(self, ...)
            if isSessionActive() and State and not (checkcaller and checkcaller()) then
                if self == Workspace and spoofedMouseTarget ~= nil and spoofedMouseHit ~= nil then
                    if State.Bridge.Godbridge or State.Bridge.Scaffold or State.Ores.OreAura or State.Ores.AutoOreFarm then
                        local method = getnamecallmethod and getnamecallmethod() or ""
                        if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
                            return spoofedMouseTarget, spoofedMouseHit.Position, Vector3.new(0, 1, 0), Enum.Material.Plastic
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        setro(gmt, true)
    end
end)

-- Configuration State (ALL DISABLED BY DEFAULT FOR COMPLETE SAFETY)
State = {
    Combat = {
        Killaura = false,
        KillauraRange = 25,
        RotateToTarget = true,
        TargetStrafe = false,
        StrafeRadius = 8,
        StrafeSpeed = 4,
        AntiKnockback = false,
        TeamCheck = false,
        AutoEquipSword = true,
        HitboxExtender = false,
        HitboxSize = 6,
        AutoClicker = false,
        AutoClickerCPS = 25,
        AutoBow = false,
        AutoBowPrediction = true
    },
    Bridge = {
        Godbridge = false,
        Scaffold = false,     -- Instant walk scaffold under feet + ahead
        AirBridge = true,     -- True Air Place (locks Y plane + air support platform)
        PlaceBlocksCount = 3, -- 3 blocks forward per cycle
        BreakBlocksCount = 2, -- 2 placed blocks behind broken per cycle
        BreakDelay = 0.08,    -- Ultra-fast pickaxe break burst (0.08s)
        PlaceDelay = 0.01,    -- Instant 3-block forward placement (0.01s)
        PlacementOffset = 3.0,
        SnapGrid = true
    },
    Ores = {
        OreAura = false,
        OreAuraRange = 25,
        OreESP = false,
        XRay = false,
        XRayTransparency = 0.65,
        AutoOreFarm = false,
        AIKillAfterOres = true, -- After all ores are mined, glide under enemies & Killaura them, then return home
        UnderTargetOffset = 6.2, -- Studs underneath the enemy player during AI Kill phase
        IgnoreLobbyOres = true, -- Never target or travel to Lobby / VIP / Mega VIP ores
        FarmPriority = "Emerald / Diamond First", -- "Emerald / Diamond First", "Gold & Up", "All Ores"
        FarmSpeed = 25, -- Adjustable from 1 (ultra slow) to 150+ (ultra fast)
        FarmMode = "Glide", -- "Glide" or "Instant TP"
        MineDelay = 0.02
    },
    World = {
        MineAura = false,
        MineAuraRange = 25,
        BypassAntiCheat = true,
        MagnetItems = false,
        AutoCoinFarm = false,
        AutoFreeArmor = false
    },
    Movement = {
        FlyBypass = false,
        FlySpeed = 50,
        SpeedBypass = false,
        SpeedMultiplier = 2.5,
        WalkSpeed = 16,
        JumpPower = 50,
        InfiniteJump = false,
        Noclip = false,
        AntiVoid = false,
        AntiVoidMode = "Solid Barrier + Bounce", -- "Solid Barrier + Bounce", "Teleport to Safe Ground", "Velocity Bounce"
        AntiVoidOffset = 12, -- Studs below lowest match island
        AntiVoidHeight = 138,
        NoFallDamage = false
    },
    Farm = {
        AutoKillAll = false,
        AutoWinPad = false
    },
    Visuals = {
        PlayerESP = false,
        OreESP = false
    }
}

-- Safe Character Helpers
local function getChar(plr)
    plr = plr or LocalPlayer
    return plr.Character
end

local function getRoot(char)
    char = char or getChar()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function getHumanoid(char)
    char = char or getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isAlive(plr)
    local c = getChar(plr)
    if not c then return false end
    local hum = getHumanoid(c)
    return hum and hum.Health > 0
end

local function isTeammate(plr)
    if not State.Combat.TeamCheck then return false end
    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
        return true
    end
    local myT = LocalPlayer:GetAttribute("TeamId")
    local theirT = plr:GetAttribute("TeamId")
    if myT ~= nil and theirT ~= nil and myT == theirT then
        return true
    end
    return false
end

-- ============================================================
-- TOOL MANAGEMENT (SWORD, AXE, BLOCK)
-- ============================================================
local function getTool(keyword, autoEquip)
    local char = getChar()
    if not char then return nil end

    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find(keyword) then
            return t
        end
    end

    if autoEquip and LocalPlayer:FindFirstChild("Backpack") then
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find(keyword) then
                t.Parent = char
                return t
            end
        end
    end
    return nil
end

local function getMiningTool(autoEquip)
    return getTool("axe", autoEquip) or getTool("pickaxe", autoEquip) or getTool("pick", autoEquip) or getTool("mine", autoEquip)
end

local function unequipTools()
    local char = getChar()
    if not char or not LocalPlayer:FindFirstChild("Backpack") then return end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            t.Parent = LocalPlayer.Backpack
        end
    end
end

-- ============================================================
-- ORE RECOGNITION & CLASSIFICATION ENGINE
-- ============================================================
local OreColors = {
    Diamond = Color3.fromRGB(0, 240, 255),
    Emerald = Color3.fromRGB(40, 255, 100),
    Gold    = Color3.fromRGB(255, 215, 0),
    Iron    = Color3.fromRGB(220, 220, 230),
    Coal    = Color3.fromRGB(70, 70, 80),
    Unknown = Color3.fromRGB(255, 140, 0)
}

local function classifyOre(part)
    if not part or not part:IsA("BasePart") then return nil end
    local name = part.Name:lower()
    local parentName = (part.Parent and part.Parent.Name:lower()) or ""

    if name:find("diamond") or parentName:find("diamond") then
        return "Diamond", 5, OreColors.Diamond
    elseif name:find("emerald") or parentName:find("emerald") or name:find("ruby") then
        return "Emerald", 4, OreColors.Emerald
    elseif name:find("gold") or parentName:find("gold") then
        return "Gold", 3, OreColors.Gold
    elseif name:find("iron") or parentName:find("iron") then
        return "Iron", 2, OreColors.Iron
    elseif name:find("coal") or parentName:find("coal") then
        return "Coal", 1, OreColors.Coal
    elseif name:find("ore") or parentName:find("ore") then
        return "Ore", 1, OreColors.Unknown
    end
    return nil
end

-- ============================================================
-- 0. SKYWARS CLASSIC FULL BYPASS ENGINE & LOBBY DETECTOR
--   • Permanently purges AntiSploitClient & AntiSploitClient2 from
--     PlayerGui.Extra AND StarterGui.Extra so they never respawn!
--   • Strips character anti-tp / speed / state watcher scripts
--   • Provides 1-Click Full Character Reset Bypass (saves position,
--     resets character cleanly without AntiSploit, & restores position)
-- ============================================================
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local isRunningBypassReset = false

local function isAntiCheatScript(inst)
    if not inst or not inst:IsA("LocalScript") then return false end
    local n = inst.Name:lower()
    if n == "animate" or n == "health" or n == "sound" or n == "freecam" then
        return false
    end
    if n:find("antisploit") or n:find("anticheat") or n:find("anti") or n:find("exploit")
        or n:find("check") or n:find("detect") or n:find("security") or n:find("kick") then
        return true
    end
    return false
end

local function disableClientAntiCheat()
    pcall(function()
        -- 1. Purge StarterGui.Extra so AntiSploitClient & AntiSploitClient2 are NEVER cloned on respawn
        local sExtra = StarterGui:FindFirstChild("Extra")
        if sExtra then
            local sac1 = sExtra:FindFirstChild("AntiSploitClient")
            local sac2 = sExtra:FindFirstChild("AntiSploitClient2")
            if sac1 then pcall(function() sac1.Disabled = true; sac1:Destroy() end) end
            if sac2 then pcall(function() sac2.Disabled = true; sac2:Destroy() end) end
        end
        for _, d in ipairs(StarterGui:GetDescendants()) do
            if isAntiCheatScript(d) then
                pcall(function() d.Disabled = true; d:Destroy() end)
            end
        end

        -- 2. Purge StarterCharacterScripts & StarterPlayerScripts anti-cheat
        local scs = StarterPlayer:FindFirstChild("StarterCharacterScripts")
        if scs then
            for _, d in ipairs(scs:GetDescendants()) do
                if isAntiCheatScript(d) then
                    pcall(function() d.Disabled = true; d:Destroy() end)
                end
            end
        end

        -- 3. Purge LocalPlayer.PlayerGui.Extra (AntiSploitClient & AntiSploitClient2)
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        if pgui then
            local extra = pgui:FindFirstChild("Extra")
            if extra then
                local ac1 = extra:FindFirstChild("AntiSploitClient")
                local ac2 = extra:FindFirstChild("AntiSploitClient2")
                if ac1 then pcall(function() ac1.Disabled = true; ac1:Destroy() end) end
                if ac2 then pcall(function() ac2.Disabled = true; ac2:Destroy() end) end
            end
            for _, d in ipairs(pgui:GetDescendants()) do
                if isAntiCheatScript(d) then
                    pcall(function() d.Disabled = true; d:Destroy() end)
                end
            end
        end

        -- 4. Purge Character anti-cheat scripts & stabilize Humanoid state
        local char = getChar()
        if char then
            for _, d in ipairs(char:GetDescendants()) do
                if isAntiCheatScript(d) then
                    pcall(function() d.Disabled = true; d:Destroy() end)
                end
            end
            local hum = getHumanoid(char)
            if hum then
                pcall(function()
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                end)
            end
        end
    end)
end

-- Instant 0ms hook when PlayerGui receives new children on respawn
pcall(function()
    local pgui = LocalPlayer:WaitForChild("PlayerGui", 3)
    if pgui then
        pgui.DescendantAdded:Connect(function(desc)
            if State.World.BypassAntiCheat then
                if desc.Name == "AntiSploitClient" or desc.Name == "AntiSploitClient2" or isAntiCheatScript(desc) then
                    pcall(function()
                        if desc:IsA("LocalScript") then desc.Disabled = true end
                        desc:Destroy()
                    end)
                end
            end
        end)
    end
end)

-- Full Skywars Classic Bypass Button Routine (Purges AntiSploit + Resets Character + Restores Position)
local function activateSkywarsFullBypass(withReset)
    if isRunningBypassReset then return end
    State.World.BypassAntiCheat = true
    disableClientAntiCheat()

    if not withReset then
        return
    end

    isRunningBypassReset = true
    task.spawn(function()
        local oldRoot = getRoot()
        local savedCF = oldRoot and oldRoot.CFrame or nil

        -- Temporarily pause active farm loops while character resets
        local prevOreFarm = State.Ores.AutoOreFarm
        local prevCoinFarm = State.World.AutoCoinFarm
        isFarmingOres = false

        -- Kill current character so server spawns a fresh character with AntiSploit already purged from StarterGui
        pcall(function()
            local char = getChar()
            local hum = getHumanoid(char)
            if hum then
                hum.Health = 0
            elseif char then
                char:BreakJoints()
            end
        end)

        local newChar = LocalPlayer.CharacterAdded:Wait()
        local newRoot = newChar:WaitForChild("HumanoidRootPart", 8) or newChar:WaitForChild("Torso", 5)
        local newHum  = newChar:WaitForChild("Humanoid", 8)
        task.wait(0.35)

        disableClientAntiCheat()

        if newRoot and newHum and savedCF then
            -- Restore previous position if valid and above void
            if savedCF.Position.Y > 130 then
                pcall(function()
                    newRoot.AssemblyLinearVelocity = Vector3.zero
                    newRoot.CFrame = savedCF
                end)
            end
        end

        if State.Movement.FlyBypass then
            task.wait(0.15)
            startFlyInternal()
        end

        State.Ores.AutoOreFarm = prevOreFarm
        State.World.AutoCoinFarm = prevCoinFarm
        isRunningBypassReset = false
    end)
end

task.spawn(function()
    disableClientAntiCheat()
    while isSessionActive() do
        if State.World.BypassAntiCheat then
            disableClientAntiCheat()
        end
        task.wait(1.0)
    end
end)

-- Lobby & VIP Room Detector (Prevents Auto Ore Farm / Aura from ever going to Lobby Ores!)
-- In Skywars Classic:
--   Spawn Lobby is at (0, 268, 0), VIP Room is at (0, 264, -72.7), Mega VIP Room is at (0, 264, 67.5)
--   Match Islands (Center Island + Spawn Islands) are around Y = 150 to 195
local LOBBY_KEYWORDS = {
    "lobby", "vip", "megavip", "mega", "shop", "store", "armor",
    "spawnarea", "waiting", "intermission", "spectate", "statue",
    "leaderboard", "safezone", "hub", "winner", "gamepass"
}

local function isLobbyPart(part)
    if not part or not part:IsA("BasePart") then return true end

    -- 1. Coordinate Altitude Check: In Skywars Classic, Lobby & VIP/Mega VIP rooms sit at Y >= 220
    local pos = part.Position
    if pos.Y >= 218 then
        return true
    end

    -- 2. Full Ancestor Hierarchy Check
    local cur = part
    while cur and cur ~= Workspace do
        local cname = cur.Name:lower()
        for _, kw in ipairs(LOBBY_KEYWORDS) do
            if cname:find(kw, 1, true) then
                return true
            end
        end
        cur = cur.Parent
    end

    return false
end

local function isPlayerInLobby()
    local root = getRoot()
    if not root then return true end
    -- In Skywars Classic, if player Y >= 222, they are in the Lobby / VIP / Mega VIP room
    if root.Position.Y >= 222 then
        return true
    end
    return false
end

-- ============================================================
-- 1. COMBAT: KILLAURA WITH REAL STUDS REACH + TARGET STRAFE
-- ============================================================
local strafeAngle = 0

local function fireSwordAttack(targetPlr)
    local char = getChar()
    if not char then return end
    local targetChar = getChar(targetPlr)
    if not targetChar then return end
    local targetRoot = getRoot(targetChar)
    if not targetRoot then return end

    local sword = getTool("sword", State.Combat.AutoEquipSword)
    if not sword then return end

    -- 1. Universal Remote Triggers
    local remote = sword:FindFirstChild("RemoteEvent") or sword:FindFirstChildOfClass("RemoteEvent")
    if not remote then
        remote = ReplicatedStorage:FindFirstChild("93b2718b-2b2a-4859-b36e-fd4614c7f0c9", true)
    end

    if remote then
        pcall(function() remote:FireServer(targetPlr) end)
        pcall(function() remote:FireServer(targetChar) end)
        pcall(function() remote:FireServer(targetRoot) end)
        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() remote:FireServer(hum) end) end
    end

    -- 2. Real Reach: Touch Interest simulation at any stud range
    local handle = sword:FindFirstChild("Handle") or sword:FindFirstChildOfClass("BasePart")
    if handle then
        pcall(function()
            if firetouchinterest then
                for _, limb in ipairs(targetChar:GetChildren()) do
                    if limb:IsA("BasePart") then
                        firetouchinterest(limb, handle, 0)
                        firetouchinterest(limb, handle, 1)
                    end
                end
            else
                -- Safe Reach when firetouchinterest is unavailable (Fluxus 5.2):
                -- NEVER move our own welded Sword.Handle (moving Handle teleports/destroys our character!).
                -- Instead, bring the enemy's HumanoidRootPart into our Sword.Handle hitbox on the client!
                targetRoot.CanCollide = false
                targetRoot.AssemblyLinearVelocity = Vector3.zero
                targetRoot.CFrame = handle.CFrame * CFrame.new(0, 0, -1.2)
            end
        end)
    end

    -- 3. Tool activation swing
    pcall(function() sword:Activate() end)
end

task.spawn(function()
    while isSessionActive() do
        task.wait(0.04)
        if State.Combat.Killaura and isAlive(LocalPlayer) then
            local myRoot = getRoot()
            if myRoot then
                local closestPlr, closestDist = nil, State.Combat.KillauraRange
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and isAlive(plr) and not isTeammate(plr) then
                        local tRoot = getRoot(getChar(plr))
                        if tRoot and (not State.Ores.IgnoreLobbyOres or tRoot.Position.Y < 220) then
                            local d = (myRoot.Position - tRoot.Position).Magnitude
                            if d <= closestDist then
                                closestDist = d
                                closestPlr = plr
                            end
                        end
                    end
                end
                if closestPlr then
                    local tRoot = getRoot(getChar(closestPlr))
                    if tRoot then
                        if State.Combat.TargetStrafe then
                            strafeAngle = strafeAngle + (State.Combat.StrafeSpeed * 0.08)
                            local r = State.Combat.StrafeRadius
                            local offset = Vector3.new(math.cos(strafeAngle) * r, 0.5, math.sin(strafeAngle) * r)
                            local goalPos = tRoot.Position + offset
                            myRoot.CFrame = CFrame.lookAt(goalPos, Vector3.new(tRoot.Position.X, goalPos.Y, tRoot.Position.Z))
                            myRoot.AssemblyLinearVelocity = Vector3.zero
                        elseif State.Combat.RotateToTarget then
                            local lookPos = Vector3.new(tRoot.Position.X, myRoot.Position.Y, tRoot.Position.Z)
                            myRoot.CFrame = CFrame.lookAt(myRoot.Position, lookPos)
                        end
                    end
                    fireSwordAttack(closestPlr)
                end
            end
        end
    end
end)

-- Anti-Knockback & Hitbox Expander
RunService.RenderStepped:Connect(function()
    if not isSessionActive() then return end
    if not isAlive(LocalPlayer) then return end

    if State.Combat.AntiKnockback then
        local myRoot = getRoot()
        local hum = getHumanoid()
        if myRoot and hum then
            local vel = myRoot.AssemblyLinearVelocity
            if hum.MoveDirection.Magnitude < 0.05 and (Vector3.new(vel.X, 0, vel.Z).Magnitude > 22) then
                myRoot.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
            end
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end
    end

    if State.Combat.HitboxExtender then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) and not isTeammate(plr) then
                local root = getRoot(getChar(plr))
                if root then
                    root.Size = Vector3.new(State.Combat.HitboxSize, State.Combat.HitboxSize, State.Combat.HitboxSize)
                    root.Transparency = 0.7
                    root.CanCollide = false
                end
            end
        end
    end
end)

-- ============================================================
-- 1.5 COMBAT ADDONS: AUTO CLICKER (0.5ms) & PREDICTIVE AUTO BOW / SLINGSHOT
-- ============================================================
task.spawn(function()
    while isSessionActive() do
        if State.Combat.AutoClicker and isAlive(LocalPlayer) then
            pcall(function()
                local char = getChar()
                local tool = char and char:FindFirstChildOfClass("Tool")
                local tName = tool and tool.Name:lower() or ""
                local isMiningTool = tName:find("axe") or tName:find("pick") or tName:find("mine")
                -- Never auto-click/activate mining tool while OreAura or AutoOreFarm is on (prevents breaking block at mouse cursor!)
                local isBlockTool = tName:find("block")
                -- Never auto-click/activate tools while Godbridge, Scaffold, OreAura, or AutoOreFarm is active!
                if State.Bridge.Godbridge or State.Bridge.Scaffold or State.Ores.OreAura or State.Ores.AutoOreFarm then
                    return
                end
                if (isMiningTool or isBlockTool) and (State.Bridge.Godbridge or State.Bridge.Scaffold or State.Ores.OreAura or State.Ores.AutoOreFarm) then
                    return
                end
                if tool then
                    tool:Activate()
                end
                if mouse1click then
                    mouse1click()
                elseif mouse1press and mouse1release then
                    mouse1press()
                    task.wait()
                    mouse1release()
                end
            end)
            task.wait(0.005)
        else
            task.wait(0.05)
        end
    end
end)

local lastBowFireTick = 0
local function getBestBowTarget()
    local myRoot = getRoot()
    if not myRoot then return nil end
    local bestPlr = nil
    local bestDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and not isTeammate(plr) then
            local tChar = getChar(plr)
            local tRoot = getRoot(tChar)
            local tHum = getHumanoid(tChar)
            if tRoot and tHum and tHum.Health > 0 and tRoot.Position.Y < 220 then
                local dist = (myRoot.Position - tRoot.Position).Magnitude
                if dist < bestDist and dist < 260 then
                    bestDist = dist
                    bestPlr = plr
                end
            end
        end
    end
    return bestPlr
end

task.spawn(function()
    while isSessionActive() do
        task.wait(0.06)
        if State.Combat.AutoBow and isAlive(LocalPlayer) then
            local char = getChar()
            local tool = char and char:FindFirstChildOfClass("Tool")
            local tName = tool and tool.Name:lower() or ""
            local isRanged = tool and (tName:find("bow") or tName:find("slingshot") or tName:find("egg") or tName:find("snowball"))

            if isRanged then
                local target = getBestBowTarget()
                if target then
                    local tChar = getChar(target)
                    local tRoot = getRoot(tChar)
                    local myRoot = getRoot(char)

                    if tRoot and myRoot then
                        local now = tick()
                        if now - lastBowFireTick > 0.30 then
                            lastBowFireTick = now

                            local dist = (myRoot.Position - tRoot.Position).Magnitude
                            local travelTime = dist / 185
                            local leadVelocity = State.Combat.AutoBowPrediction and (tRoot.AssemblyLinearVelocity * travelTime) or Vector3.zero
                            local gravityCompensation = Vector3.new(0, (travelTime ^ 2) * 16, 0)
                            local aimPos = tRoot.Position + Vector3.new(0, 1.2, 0) + leadVelocity + gravityCompensation

                            if State.Combat.RotateToTarget then
                                pcall(function()
                                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(aimPos.X, myRoot.Position.Y, aimPos.Z))
                                end)
                            end

                            local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChildOfClass("RemoteEvent")
                            local remoteFn = tool:FindFirstChild("RemoteFunction") or tool:FindFirstChildOfClass("RemoteFunction")

                            if remote then
                                pcall(function() remote:FireServer(aimPos) end)
                                pcall(function() remote:FireServer(CFrame.new(aimPos)) end)
                            elseif remoteFn then
                                pcall(function() remoteFn:InvokeServer(aimPos) end)
                            end

                            pcall(function() tool:Activate() end)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- 2. ULTRA-FAST GODBRIDGE (3 PLACE -> PICKAXE SWAP -> 2 BEHIND BREAK)
--    + TRUE AIR-PLACE WALK SCAFFOLD ENGINE
--   • Exact R6 3x3x3 grid math: floor block center is root.Position.Y - 4.5
--     (never places blocks inside the player's legs/torso!)
--   • True Air Place: locks horizontal bridgeY plane + maintains a client
--     air-support platform so the player never dips or falls in mid-air!
--   • Exact Placed-Block Tracker: tracks ONLY the blocks placed by our bridge,
--     protects the front/under-feet block, and mines ONLY the 2 placed blocks behind!
-- ============================================================
local lockedBridgeY = nil
local airBridgeSupportPart = nil
local airPlaceTargetPart = nil

local function getAirPlaceTargetPart(snappedPos)
    if not airPlaceTargetPart or not airPlaceTargetPart.Parent then
        airPlaceTargetPart = Instance.new("Part")
        airPlaceTargetPart.Name = "RanaxAirTarget"
        airPlaceTargetPart.Anchored = true
        airPlaceTargetPart.CanCollide = false
        airPlaceTargetPart.CanTouch = false
        airPlaceTargetPart.CanQuery = true
        airPlaceTargetPart.Transparency = 1
        airPlaceTargetPart.Size = Vector3.new(3, 3, 3)
        airPlaceTargetPart.Parent = Workspace
    end
    -- Position 3 studs below snappedPos so its Top surface (+Y) resolves to snappedPos!
    airPlaceTargetPart.CFrame = CFrame.new(snappedPos - Vector3.new(0, 3, 0))
    return airPlaceTargetPart
end
local recentPlacedCoords = {} -- { Pos = Vector3, Time = number }
local ourPlacedBlocks = {}    -- [BasePart] = number (tick when placed)
local placedBridgeQueue = {}  -- FIFO array of BaseParts placed by us

local function snapPosition(pos)
    if not State.Bridge.SnapGrid then return pos end
    local x = math.floor(pos.X / 3 + 0.5) * 3
    local y = math.floor(pos.Y / 3 + 0.5) * 3
    local z = math.floor(pos.Z / 3 + 0.5) * 3
    return Vector3.new(x, y, z)
end

-- Compute the exact 3x3x3 block center Y directly beneath the R6 character's feet
-- R6 RootPart center -> bottom of feet = -3.0 studs; top of 3x3x3 block -> center = -1.5 studs => -4.5 studs total
local function computeFloorBlockY(rootY)
    return math.floor((rootY - 4.5) / 3 + 0.5) * 3
end

-- Track ONLY blocks that spawn at coordinates we just placed (zero Workspace:GetDescendants() lag!)
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == "Block" then
        local now = tick()
        local objPos = obj.Position
        for i = #recentPlacedCoords, 1, -1 do
            local entry = recentPlacedCoords[i]
            if now - entry.Time > 2.5 then
                table.remove(recentPlacedCoords, i)
            elseif (objPos - entry.Pos).Magnitude <= 2.4 then
                if not ourPlacedBlocks[obj] then
                    ourPlacedBlocks[obj] = now
                    table.insert(placedBridgeQueue, obj)
                end
                break
            end
        end
    end
end)

local function getBlockToolAndRemotes(autoEquip)
    local bt = getTool("block", autoEquip)
    if not bt then return nil, nil, nil end

    -- Disable local Mouse-click script inside Block tool while bridging so Mouse.Target never interferes
    for _, sc in ipairs(bt:GetChildren()) do
        if sc:IsA("LocalScript") and not sc.Disabled then
            pcall(function() sc.Disabled = false end)
        end
    end

    local rf = bt:FindFirstChild("RemoteFunction") or bt:FindFirstChildWhichIsA("RemoteFunction", true)
    local re = bt:FindFirstChild("RemoteEvent")    or bt:FindFirstChildWhichIsA("RemoteEvent", true)
    return rf, re, bt
end

local function restoreBlockLocalScripts()
    if not State.Bridge.Godbridge and not State.Bridge.Scaffold and not State.Ores.OreAura and not State.Ores.AutoOreFarm then
        spoofedMouseHit = nil
        spoofedMouseTarget = nil
        spoofedMouseSurface = nil
    end
    local char = getChar()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    for _, container in ipairs({char, bp}) do
        if container then
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and t.Name:lower():find("block") then
                    for _, sc in ipairs(t:GetChildren()) do
                        if sc:IsA("LocalScript") and sc.Disabled then
                            pcall(function() sc.Disabled = false end)
                        end
                    end
                end
            end
        end
    end
end

-- Non-blocking server block placement (fires both RemoteEvent & async RemoteFunction at exact snapped pos)
local function placeSingleBlock(pos, cachedRF, cachedRE, cachedBT)
    local snapped = snapPosition(pos)
    local rf, re, bt = cachedRF, cachedRE, cachedBT
    if not bt or not bt.Parent then
        rf, re, bt = getBlockToolAndRemotes(true)
    end
    if not bt then return snapped end

    table.insert(recentPlacedCoords, { Pos = snapped, Time = tick() })
    if #recentPlacedCoords > 30 then
        table.remove(recentPlacedCoords, 1)
    end

    -- Always spoof Mouse.Hit / Mouse.Target BEFORE firing RemoteEvent, RemoteFunction, and bt:Activate()!
    spoofedMouseHit = CFrame.new(snapped)
    spoofedMouseTarget = getAirPlaceTargetPart(snapped)
    spoofedMouseSurface = Enum.NormalId.Top
    pcall(function() bt:Activate() end)
    if re then
    spoofedMouseHit = CFrame.new(snapped)
    spoofedMouseTarget = getAirPlaceTargetPart(snapped)
    spoofedMouseSurface = Enum.NormalId.Top
    pcall(function() if re then re:FireServer(snapped) end end)
    pcall(function() bt:Activate() end)
    spoofedMouseSurface = Enum.NormalId.Top
    pcall(function() if re then re:FireServer(snapped) end end)
    end
    if rf then
        task.spawn(function()
            pcall(function() rf:InvokeServer(snapped) end)
        end)
    end
    return snapped
end

-- Direct non-blocking break of a specific placed Block part using the Axe remote
local function breakSpecificBlockPart(axe, blockPart)
    if not axe or not blockPart or not blockPart.Parent then return false end
    spoofedMouseTarget = blockPart
    spoofedMouseHit = blockPart.CFrame
    spoofedMouseSurface = Enum.NormalId.Top
    pcall(function() axe:Activate() end)
    if not axe or not blockPart or not blockPart.Parent then return false end

    for _, sc in ipairs(axe:GetChildren()) do
        if sc:IsA("LocalScript") and not sc.Disabled then
            pcall(function() sc.Disabled = false end)
        end
    end

    local remote = axe:FindFirstChild("RemoteEvent")   or axe:FindFirstChildWhichIsA("RemoteEvent", true)
    local rfunc  = axe:FindFirstChild("RemoteFunction") or axe:FindFirstChildWhichIsA("RemoteFunction", true)

    if remote then
        spoofedMouseTarget = blockPart
        spoofedMouseHit = blockPart.CFrame
        spoofedMouseSurface = Enum.NormalId.Top
        pcall(function() remote:FireServer(blockPart) end)
        pcall(function() axe:Activate() end)
    end
    if rfunc then
        task.spawn(function()
            pcall(function() rfunc:InvokeServer(blockPart) end)
        end)
    end
    return true
end

-- Maintain the locked Air-Place Y plane & invisible client air-support floor while Scaffold or Godbridge is active
local function updateAirBridgeSupport(root, hum)
    local active = (State.Bridge.Scaffold or State.Bridge.Godbridge) and isAlive(LocalPlayer)
    if not active or not root or not hum then
        lockedBridgeY = nil
        if airBridgeSupportPart and airBridgeSupportPart.Parent then
            airBridgeSupportPart.CanCollide = false
            airBridgeSupportPart.CFrame = CFrame.new(0, -500, 0)
        end
        return nil
    end

    -- Check if standing on real map ground (excluding our airBridgeSupportPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = { LocalPlayer.Character }
    if airBridgeSupportPart then table.insert(ignore, airBridgeSupportPart) end
    if antiVoidFloorPart then table.insert(ignore, antiVoidFloorPart) end
    rayParams.FilterDescendantsInstances = ignore

    local groundHit = Workspace:Raycast(root.Position, Vector3.new(0, -5.2, 0), rayParams)

    if not State.Bridge.AirBridge then
        lockedBridgeY = computeFloorBlockY(root.Position.Y)
        if airBridgeSupportPart and airBridgeSupportPart.Parent then
            airBridgeSupportPart.CanCollide = false
            airBridgeSupportPart.CFrame = CFrame.new(0, -500, 0)
        end
        return lockedBridgeY
    end

    if lockedBridgeY == nil then
        if groundHit and groundHit.Instance then
            lockedBridgeY = math.floor(groundHit.Instance.Position.Y / 3 + 0.5) * 3
        else
            lockedBridgeY = computeFloorBlockY(root.Position.Y)
        end
    elseif groundHit and groundHit.Instance and not ourPlacedBlocks[groundHit.Instance] then
        -- Sync to island floor level when walking on an island
        local islandY = math.floor(groundHit.Instance.Position.Y / 3 + 0.5) * 3
        if math.abs((root.Position.Y - 4.5) - islandY) <= 2.2 then
            lockedBridgeY = islandY
        end
    end

    -- Allow ascending 1 block layer (+3 studs) if user intentionally jumps while Air Bridging
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) and (root.Position.Y - 4.5) > (lockedBridgeY + 1.8) then
        lockedBridgeY = lockedBridgeY + 3
    end

    -- Create/update client-side invisible support platform at exact 3x3x3 block height (lockedBridgeY)
    -- so the player can walk on thin air without ever dipping into the block placement box!
    if not airBridgeSupportPart or not airBridgeSupportPart.Parent then
        airBridgeSupportPart = Instance.new("Part")
        airBridgeSupportPart.Name = "RanaxAirBridgeSupport"
        airBridgeSupportPart.Anchored = true
        airBridgeSupportPart.Size = Vector3.new(12, 3, 12)
        airBridgeSupportPart.Transparency = 1
        airBridgeSupportPart.CanCollide = true
        airBridgeSupportPart.CastShadow = false
        airBridgeSupportPart.Parent = Workspace
    end

    -- If player dropped from Lobby to Match or changed altitude by > 4.2 studs, immediately re-sync lockedBridgeY!
    if lockedBridgeY and math.abs((root.Position.Y - 4.5) - lockedBridgeY) > 4.2 then
        lockedBridgeY = computeFloorBlockY(root.Position.Y)
    end

    local snapXZ = snapPosition(Vector3.new(root.Position.X, lockedBridgeY, root.Position.Z))
    airBridgeSupportPart.CFrame = CFrame.new(snapXZ.X, lockedBridgeY, snapXZ.Z)
    airBridgeSupportPart.CanCollide = true

    -- Prevent downward fall into the block box while walking in mid-air
    local targetRootMinY = lockedBridgeY + 4.45
    if root.Position.Y < targetRootMinY and root.Position.Y > (lockedBridgeY - 2.0) then
        local vel = root.AssemblyLinearVelocity
        -- Never overwrite root.CFrame here (prevents character disappearance / anti-cheat trigger!)
        -- The physical airBridgeSupportPart directly supports the character's feet.
        if vel.Y < 0 then
            root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
        end
    end

    return lockedBridgeY
end

RunService.Heartbeat:Connect(function()
    if not isSessionActive() then return end
    if (State.Bridge.Scaffold or State.Bridge.Godbridge) and isAlive(LocalPlayer) then
        local root = getRoot()
        local hum = getHumanoid()
        if root and hum then
            updateAirBridgeSupport(root, hum)
        end
    elseif lockedBridgeY ~= nil or (airBridgeSupportPart and airBridgeSupportPart.CanCollide) then
        lockedBridgeY = nil
        if airBridgeSupportPart and airBridgeSupportPart.Parent then
            airBridgeSupportPart.CanCollide = false
            airBridgeSupportPart.CFrame = CFrame.new(0, -500, 0)
        end
    end
end)

-- Instant Under-Feet & Air-Place Walk Scaffold (Places under feet + 1 & 2 blocks ahead in air!)
task.spawn(function()
    local wasScaffoldOn = false
    while isSessionActive() do
        task.wait(0.02)
        if State.Bridge.Scaffold and not State.Bridge.Godbridge and isAlive(LocalPlayer) then
            wasScaffoldOn = true
            local root = getRoot()
            local hum = getHumanoid()
            if root and hum then
                local bridgeY = updateAirBridgeSupport(root, hum) or computeFloorBlockY(root.Position.Y)
                local rf, re, bt = getBlockToolAndRemotes(true)
                if bt then
                    local basePos = snapPosition(Vector3.new(root.Position.X, bridgeY, root.Position.Z))
                    -- 1. Place directly under feet
                    placeSingleBlock(basePos, rf, re, bt)

                    -- 2. Place ahead in movement direction (supports diagonal & straight Air Place)
                    local moveDir = hum.MoveDirection
                    local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)
                    if flatDir.Magnitude > 0.05 then
                        flatDir = flatDir.Unit
                        local step1 = snapPosition(Vector3.new(root.Position.X + flatDir.X * 3.0, bridgeY, root.Position.Z + flatDir.Z * 3.0))
                        placeSingleBlock(step1, rf, re, bt)
                        if State.Bridge.AirBridge then
                            local step2 = snapPosition(Vector3.new(root.Position.X + flatDir.X * 6.0, bridgeY, root.Position.Z + flatDir.Z * 6.0))
                            placeSingleBlock(step2, rf, re, bt)
                        end
                    end
                end
            end
        elseif wasScaffoldOn and not State.Bridge.Godbridge then
            wasScaffoldOn = false
            restoreBlockLocalScripts()
        end
    end
end)

-- ULTRA-FAST GODBRIDGE ENGINE (3 Blocks Place Ahead -> Instant Pickaxe Swap -> Break ONLY 2 Placed Blocks Behind)
local isGodbridging = false
task.spawn(function()
    local wasGodbridgeOn = false
    while isSessionActive() do
        task.wait(0.01)
        if State.Bridge.Godbridge and isAlive(LocalPlayer) and not isGodbridging then
            wasGodbridgeOn = true
            local root = getRoot()
            local hum = getHumanoid()
            if root and hum and hum.MoveDirection.Magnitude > 0.05 then
                isGodbridging = true

                local flatDir = Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z)
                if flatDir.Magnitude < 0.05 then
                    local look = Workspace.CurrentCamera.CFrame.LookVector
                    flatDir = Vector3.new(look.X, 0, look.Z)
                end
                flatDir = flatDir.Unit

                local bridgeY = updateAirBridgeSupport(root, hum) or computeFloorBlockY(root.Position.Y)
                local placeCount = math.clamp(tonumber(State.Bridge.PlaceBlocksCount) or 3, 2, 5)
                local breakCount = math.clamp(tonumber(State.Bridge.BreakBlocksCount) or 2, 1, placeCount - 1)

                -- Build the 3 distinct grid-snapped positions ahead:
                -- coords[1] = under/first block (will be behind player)
                -- coords[2] = second block (will be behind front block)
                -- coords[3] = third/front block (kept intact so player stands/lands on it!)
                local cycleCoords = {}
                local usedKeys = {}
                local curOrigin = Vector3.new(root.Position.X, bridgeY, root.Position.Z)

                local preExistingMapBlocks = {}
                for step = 0, placeCount + 3 do
                    if #cycleCoords >= placeCount then break end
                    local candidate = snapPosition(Vector3.new(
                        curOrigin.X + flatDir.X * (step * 3.0),
                        bridgeY,
                        curOrigin.Z + flatDir.Z * (step * 3.0)
                    ))
                    local key = string.format("%d_%d_%d", candidate.X, candidate.Y, candidate.Z)
                    if not usedKeys[key] then
                        local hasIslandBlock = false
                        pcall(function()
                            for _, p in ipairs(Workspace:GetPartBoundsInBox(CFrame.new(candidate), Vector3.new(2.2, 2.2, 2.2))) do
                                if p ~= airBridgeSupportPart and p ~= airPlaceTargetPart and p ~= antiVoidFloorPart and not p:IsDescendantOf(LocalPlayer.Character) then
                                    if not ourPlacedBlocks[p] then
                                        preExistingMapBlocks[p] = true
                                        if step == 0 and p.CanCollide then
                                            hasIslandBlock = true
                                        end
                                    end
                                end
                            end
                        end)
                        -- If step == 0 already has an island block under feet, skip step 0 so all 3 blocks are placed forward in air!
                        if not (step == 0 and hasIslandBlock) then
                            usedKeys[key] = true
                            table.insert(cycleCoords, candidate)
                        end
                    end
                end
                for _unusedStep = 1, 0 do
                    if #cycleCoords >= placeCount then break end
                    local candidate = snapPosition(Vector3.new(
                        curOrigin.X + flatDir.X * (step * 3.0),
                        bridgeY,
                        curOrigin.Z + flatDir.Z * (step * 3.0)
                    ))
                    local key = string.format("%d_%d_%d", candidate.X, candidate.Y, candidate.Z)
                    if not usedKeys[key] then
                        usedKeys[key] = true
                        table.insert(cycleCoords, candidate)
                    end
                end

                -- ====================================================
                -- PHASE A: Equip Block & Rapidly Place 3 Blocks Forward
                -- ====================================================
                local rf, re, bt = getBlockToolAndRemotes(true)
                if bt then
                    local pDelay = math.clamp(tonumber(State.Bridge.PlaceDelay) or 0.01, 0.005, 0.08)
                    for i = 1, #cycleCoords do
                        if not State.Bridge.Godbridge or not isAlive(LocalPlayer) then break end
                        placeSingleBlock(cycleCoords[i], rf, re, bt)
                        if i < #cycleCoords then
                            task.wait(pDelay)
                        end
                    end
                end

                -- Brief sync for the 3 placed blocks to register in Workspace
                task.wait(0.03)

                -- ====================================================
                -- PHASE B: Instant Pickaxe Swap -> Break ONLY the 2 Placed Blocks Behind!
                -- Never breaks the front block (cycleCoords[#cycleCoords]) or map island blocks!
                -- ====================================================
                if State.Bridge.Godbridge and isAlive(LocalPlayer) then
                    local frontProtectedPos = cycleCoords[#cycleCoords]

                    -- Prune destroyed blocks from placedBridgeQueue
                    for i = #placedBridgeQueue, 1, -1 do
                        local b = placedBridgeQueue[i]
                        if not b or not b.Parent then
                            table.remove(placedBridgeQueue, i)
                        end
                    end

                    -- Select ONLY the placed blocks that belong to our bridge and are BEHIND the front block
                    local blocksToBreak = {}
                    local seenParts = {}

                    -- 1. First pick any older blocks sitting in placedBridgeQueue behind the front block
                    for _, bPart in ipairs(placedBridgeQueue) do
                        if #blocksToBreak >= breakCount then break end
                        if bPart and bPart.Parent and ourPlacedBlocks[bPart] and not seenParts[bPart] then
                            if not frontProtectedPos or (bPart.Position - frontProtectedPos).Magnitude > 2.2 then
                                seenParts[bPart] = true
                                table.insert(blocksToBreak, bPart)
                            end
                        end
                    end

                    -- 2. Also match the exact behind coordinates (cycleCoords[1 .. placeCount - 1]) from ourPlacedBlocks
                    -- 2. Also match the exact behind coordinates (cycleCoords[1 .. placeCount - 1]) from ourPlacedBlocks or spatial box
                    for idx = 1, (#cycleCoords - 1) do
                        local targetCoord = cycleCoords[idx]
                        pcall(function()
                            for _, p in ipairs(Workspace:GetPartBoundsInBox(CFrame.new(targetCoord), Vector3.new(2.4, 2.4, 2.4))) do
                                if p and p.Parent and p.Name == "Block" and not preExistingMapBlocks[p] then
                                    if p ~= airBridgeSupportPart and p ~= airPlaceTargetPart and p ~= antiVoidFloorPart then
                                        if not ourPlacedBlocks[p] then
                                            ourPlacedBlocks[p] = tick()
                                            table.insert(placedBridgeQueue, p)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                    if #blocksToBreak < breakCount then
                        for idx = 1, (#cycleCoords - 1) do
                            if #blocksToBreak >= breakCount then break end
                            local targetCoord = cycleCoords[idx]
                            for bPart, _ in pairs(ourPlacedBlocks) do
                                if bPart and bPart.Parent and not seenParts[bPart] then
                                    if (bPart.Position - targetCoord).Magnitude <= 2.2 then
                                        if not frontProtectedPos or (bPart.Position - frontProtectedPos).Magnitude > 2.2 then
                                            seenParts[bPart] = true
                                            table.insert(blocksToBreak, bPart)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if #blocksToBreak > 0 then
                        unequipTools()
                        local axe = getMiningTool(true)
                        if axe then
                            local breakDuration = math.clamp(tonumber(State.Bridge.BreakDelay) or 0.08, 0.02, 0.45)
                            local breakStart = tick()
                            repeat
                                for _, bPart in ipairs(blocksToBreak) do
                                    if bPart and bPart.Parent then
                                        breakSpecificBlockPart(axe, bPart)
                                    end
                                end
                                task.wait(0.02)
                                local anyLeft = false
                                for _, bPart in ipairs(blocksToBreak) do
                                    if bPart and bPart.Parent then
                                        anyLeft = true
                                        break
                                    end
                                end
                                if not anyLeft then break end
                            until (tick() - breakStart) >= breakDuration or not State.Bridge.Godbridge or not isAlive(LocalPlayer)
                        end

                        -- Immediately re-equip Block tool for the next 3-block placement burst
                        unequipTools()
                        getBlockToolAndRemotes(true)
                    end
                end

                isGodbridging = false
            end
        elseif wasGodbridgeOn and not State.Bridge.Godbridge then
            wasGodbridgeOn = false
            table.clear(recentPlacedCoords)
            table.clear(ourPlacedBlocks)
            table.clear(placedBridgeQueue)
            if not State.Bridge.Scaffold then
                restoreBlockLocalScripts()
            end
            if not State.Ores.OreAura and not State.Ores.AutoOreFarm then
                restoreAxeLocalScripts()
            end
        end
    end
end)

-- ============================================================
-- 3. ORE ENGINE: ZERO-LAG CACHED ORE REGISTRY, ORE AURA & AUTO ORE FARM
-- Strictly ignores Lobby / VIP / Mega VIP ores (Y >= 218 or Lobby ancestors)
-- Never calls axe:Activate() or mouse clicks -> NEVER breaks block at mouse cursor!
-- Uses O(1) reactive cachedOres table -> ZERO FPS drops or stuttering!
-- ============================================================
local activeOreESP = {}
local savedBlockTransparencies = {}
local cachedOres = {} -- [BasePart] = { Type = string, Priority = number, Color = Color3 }

local function classifyOre(part, allowLobby)
    if not part or not part:IsA("BasePart") then return nil end

    -- Strictly skip Lobby / VIP / Mega VIP ores when IgnoreLobbyOres is active
    if not allowLobby and State.Ores.IgnoreLobbyOres and isLobbyPart(part) then
        return nil
    end

    local name = part.Name:lower()
    local parent = part.Parent
    local parentName = parent and parent.Name:lower() or ""
    local grandParent = parent and parent.Parent
    local grandParentName = grandParent and grandParent.Name:lower() or ""

    if part:IsDescendantOf(LocalPlayer.Character or Workspace.CurrentCamera) then return nil end
    if not part.Anchored then return nil end
    if not part.CanCollide then return nil end

    if part:IsA("WedgePart") or part:IsA("CornerWedgePart") or part:IsA("TrussPart") then return nil end
    if part:IsA("Part") and (part.Shape == Enum.PartType.Cylinder or part.Shape == Enum.PartType.Ball) then
        return nil
    end

    local sz = part.Size
    local minSz = math.min(sz.X, sz.Y, sz.Z)
    local maxSz = math.max(sz.X, sz.Y, sz.Z)
    if minSz < 1.0 then return nil end
    if maxSz / minSz > 6.0 then return nil end

    if name:find("baseplate") or name:find("spawn") or name:find("hitbox") or name:find("antivoid")
        or name:find("barrier") or name:find("humanoid") or name:find("root") or name:find("handle")
        or name:find("button") or name:find("door") or name:find("chest") or name:find("prop")
        or name:find("deco") or name:find("model") or name:find("lobby") or name:find("vip")
        or name:find("island") or name:find("bridge") or name:find("wall") or name:find("floor") then
        return nil
    end
    if name:find("grass") or parentName:find("grass") or name:find("dirt") or parentName:find("dirt")
        or name:find("leaf") or name:find("tree") or name:find("wood") or name:find("log")
        or name:find("water") or name:find("lava") or name:find("cloud") or name:find("sky")
        or name:find("stone") or name:find("brick") or name:find("sand") or name:find("obsidian") then
        return nil
    end

    -- Tier 5: Emerald & Ruby
    if name:find("emerald") or parentName:find("emerald") or grandParentName:find("emerald")
        or name:find("zumrut") or parentName:find("zumrut") or grandParentName:find("zumrut") then
        return "Emerald", 5, Color3.fromRGB(0, 255, 120)
    elseif name:find("ruby") or parentName:find("ruby") or grandParentName:find("ruby")
        or name:find("yakut") or parentName:find("yakut") then
        return "Ruby", 5, Color3.fromRGB(255, 35, 75)

    -- Tier 4: Diamond
    elseif name:find("diamond") or parentName:find("diamond") or grandParentName:find("diamond")
        or name:find("elmas") or parentName:find("elmas") then
        return "Diamond", 4, Color3.fromRGB(0, 235, 255)

    -- Tier 3: Gold
    elseif name:find("gold") or parentName:find("gold") or grandParentName:find("gold")
        or name:find("altin") or parentName:find("altin") then
        return "Gold", 3, Color3.fromRGB(255, 215, 0)

    -- Tier 2: Iron
    elseif name:find("iron") or parentName:find("iron") or grandParentName:find("iron")
        or name:find("demir") or parentName:find("demir") then
        return "Iron", 2, Color3.fromRGB(215, 215, 220)

    -- Tier 1: Coal
    elseif name:find("coal") or parentName:find("coal") or grandParentName:find("coal")
        or name:find("komur") or parentName:find("komur") then
        return "Coal", 1, Color3.fromRGB(75, 75, 80)
    end

    -- Child decal / texture / mesh / value checks
    for _, ch in ipairs(part:GetChildren()) do
        local cn = ch.Name:lower()
        local tv = ""
        if ch:IsA("Decal") or ch:IsA("Texture") then
            tv = tostring(ch.Texture):lower()
        elseif ch:IsA("ValueBase") then
            tv = tostring(ch.Value):lower()
        end
        if cn:find("emerald") or tv:find("emerald") or cn:find("zumrut") or tv:find("zumrut") then
            return "Emerald", 5, Color3.fromRGB(0, 255, 120)
        elseif cn:find("ruby") or tv:find("ruby") then
            return "Ruby", 5, Color3.fromRGB(255, 35, 75)
        elseif cn:find("diamond") or tv:find("diamond") then
            return "Diamond", 4, Color3.fromRGB(0, 235, 255)
        elseif cn:find("gold") or tv:find("gold") then
            return "Gold", 3, Color3.fromRGB(255, 215, 0)
        elseif cn:find("iron") or tv:find("iron") then
            return "Iron", 2, Color3.fromRGB(215, 215, 220)
        elseif cn:find("coal") or tv:find("coal") then
            return "Coal", 1, Color3.fromRGB(75, 75, 80)
        end
    end

    -- Strict Ore container check (ONLY parts named "Ore"/"Ores" or directly inside an "Ores"/"Ore" folder)
    -- Never match normal map blocks ("Block") unless they are inside an "Ores" container!
    local isOreCandidate = (name == "ore" or name:find("ore")
        or parentName == "ores" or parentName == "ore"
        or grandParentName == "ores" or grandParentName == "ore")

    if isOreCandidate then
        local bc = part.BrickColor.Name:lower()
        if bc:find("green") or bc:find("lime") or bc:find("emerald") or bc:find("camo") or bc:find("mint") then
            return "Emerald", 5, Color3.fromRGB(0, 255, 120)
        elseif bc:find("red") or bc:find("crimson") or bc:find("ruby") then
            return "Ruby", 5, Color3.fromRGB(255, 35, 75)
        elseif bc:find("blue") or bc:find("cyan") or bc:find("teal") then
            return "Diamond", 4, Color3.fromRGB(0, 235, 255)
        elseif bc:find("yellow") or bc:find("gold") or bc:find("orange") then
            return "Gold", 3, Color3.fromRGB(255, 215, 0)
        elseif bc:find("white") or bc:find("grey") or bc:find("gray") or bc:find("silver") then
            return "Iron", 2, Color3.fromRGB(215, 215, 220)
        elseif bc:find("black") or bc:find("charcoal") then
            return "Coal", 1, Color3.fromRGB(75, 75, 80)
        end
        return "Ore", 1, Color3.fromRGB(200, 200, 200)
    end

    return nil
end

-- Direct Server-Only Ore Hit (NEVER calls axe:Activate(), so Mouse.Target is NEVER broken!)
-- Also neutralizes the Axe's local Mouse.Target script while OreAura or AutoOreFarm is active.
local function mineOreDirect(axe, targetOre)
    if not axe or not targetOre or not targetOre.Parent then return false end
    spoofedMouseTarget = targetOre
    spoofedMouseHit = targetOre.CFrame
    spoofedMouseSurface = Enum.NormalId.Top
    pcall(function() axe:Activate() end)
    if not axe or not targetOre or not targetOre.Parent then return false end

    -- Disable the Axe's local Mouse-based script while automated ore mining is active
    -- so even if the user clicks their mouse, it won't break random blocks around the cursor!
    for _, sc in ipairs(axe:GetChildren()) do
        if sc:IsA("LocalScript") and not sc.Disabled then
            pcall(function() sc.Disabled = false end)
        end
    end

    local remote = axe:FindFirstChild("RemoteEvent")   or axe:FindFirstChildOfClass("RemoteEvent")
    local rfunc  = axe:FindFirstChild("RemoteFunction") or axe:FindFirstChildOfClass("RemoteFunction")

    if remote then
        spoofedMouseTarget = targetOre
        spoofedMouseHit = targetOre.CFrame
        spoofedMouseSurface = Enum.NormalId.Top
        pcall(function() remote:FireServer(targetOre) end)
    end
    if rfunc then
        task.spawn(function()
            pcall(function() rfunc:InvokeServer(targetOre) end)
        end)
    end
    return (remote ~= nil or rfunc ~= nil)
end

local function restoreAxeLocalScripts()
    if not State.Bridge.Godbridge and not State.Bridge.Scaffold and not State.Ores.OreAura and not State.Ores.AutoOreFarm then
        spoofedMouseHit = nil
        spoofedMouseTarget = nil
        spoofedMouseSurface = nil
    end
    local char = getChar()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    for _, container in ipairs({char, bp}) do
        if container then
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") then
                    for _, sc in ipairs(t:GetChildren()) do
                        if sc:IsA("LocalScript") and sc.Disabled then
                            pcall(function() sc.Disabled = false end)
                        end
                    end
                end
            end
        end
    end
end

-- World X-Ray Implementation
local function setWorldXRay(enable)
    if not enable then
        for part, origTrans in pairs(savedBlockTransparencies) do
            if part and part.Parent then
                pcall(function() part.LocalTransparencyModifier = 0; part.Transparency = origTrans end)
            end
        end
        table.clear(savedBlockTransparencies)
        return
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Anchored and obj.CanCollide and not isLobbyPart(obj) then
            if not obj:IsDescendantOf(LocalPlayer.Character or Workspace.CurrentCamera) and obj.Name ~= "RanaxAntiVoidFloor" then
                if cachedOres[obj] == nil and classifyOre(obj) == nil and obj.Transparency < 0.9 then
                    if savedBlockTransparencies[obj] == nil then
                        savedBlockTransparencies[obj] = obj.Transparency
                    end
                    pcall(function()
                        obj.Transparency = State.Ores.XRayTransparency
                    end)
                end
            end
        end
    end
end

local function addOreToESP(obj)
    if not State.Ores.OreESP then return end
    if not obj or not obj:IsA("BasePart") or activeOreESP[obj] then return end
    local info = cachedOres[obj]
    local oreType, priority, oreColor
    if info then
        oreType, priority, oreColor = info.Type, info.Priority, info.Color
    else
        oreType, priority, oreColor = classifyOre(obj)
    end
    if oreType then
        local highlight = Instance.new("Highlight")
        highlight.Name = "OreXRayHighlight"
        highlight.Adornee = obj
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = oreColor
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.35
        highlight.OutlineTransparency = 0
        highlight.Parent = obj

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "OreTag"
        billboard.Adornee = obj
        billboard.Size = UDim2.new(0, 90, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = obj

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextColor3 = oreColor
        label.TextStrokeTransparency = 0.2
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Text = oreType
        label.Parent = billboard

        activeOreESP[obj] = { Highlight = highlight, Tag = billboard, Label = label }

        obj.AncestryChanged:Connect(function(_, parent)
            if not parent and activeOreESP[obj] then
                pcall(function()
                    if activeOreESP[obj].Highlight then activeOreESP[obj].Highlight:Destroy() end
                    if activeOreESP[obj].Tag then activeOreESP[obj].Tag:Destroy() end
                end)
                activeOreESP[obj] = nil
            end
        end)
    end
end

-- Reactive Ore Cache Manager (Eliminates Workspace:GetDescendants() lag!)
local function registerPartInOreCache(obj)
    if not obj or not obj:IsA("BasePart") then return end
    local oreType, priority, oreColor = classifyOre(obj, false)
    if oreType then
        cachedOres[obj] = { Type = oreType, Priority = priority, Color = oreColor }
        if State.Ores.OreESP and not activeOreESP[obj] then
            addOreToESP(obj)
        end
    else
        cachedOres[obj] = nil
    end
end

local function rebuildOreCache()
    local newCache = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            local oreType, priority, oreColor = classifyOre(obj, false)
            if oreType then
                newCache[obj] = { Type = oreType, Priority = priority, Color = oreColor }
            end
        end
    end
    cachedOres = newCache
end

-- Initial cache build
task.spawn(rebuildOreCache)

local function clearOreESP()
    for part, gui in pairs(activeOreESP) do
        pcall(function()
            if gui.Tag then gui.Tag:Destroy() end
            if gui.Highlight then gui.Highlight:Destroy() end
        end)
    end
    table.clear(activeOreESP)
end

local function updateOreESP()
    clearOreESP()
    rebuildOreCache()
    if not State.Ores.OreESP then
        if State.Ores.XRay then setWorldXRay(false) end
        return
    end
    if State.Ores.XRay then
        setWorldXRay(true)
    end

    for part, _ in pairs(cachedOres) do
        if part and part.Parent and not activeOreESP[part] then
            addOreToESP(part)
        end
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") then
        task.wait(0.05)
        if obj.Parent then
            registerPartInOreCache(obj)
        end
    end
end)

Workspace.DescendantRemoving:Connect(function(obj)
    cachedOres[obj] = nil
    if activeOreESP[obj] then
        pcall(function()
            if activeOreESP[obj].Highlight then activeOreESP[obj].Highlight:Destroy() end
            if activeOreESP[obj].Tag then activeOreESP[obj].Tag:Destroy() end
        end)
        activeOreESP[obj] = nil
    end
end)

-- Lightweight periodic cache sync every 3.5s (spread across frames so it NEVER causes a frame spike)
task.spawn(function()
    while isSessionActive() do
        task.wait(3.5)
        local descendants = Workspace:GetDescendants()
        local newCache = {}
        for i, obj in ipairs(descendants) do
            if i % 400 == 0 then task.wait() end
            if obj:IsA("BasePart") and obj.Parent then
                local oreType, priority, oreColor = classifyOre(obj, false)
                if oreType then
                    newCache[obj] = { Type = oreType, Priority = priority, Color = oreColor }
                    if State.Ores.OreESP and not activeOreESP[obj] then
                        addOreToESP(obj)
                    end
                end
            end
        end
        cachedOres = newCache
    end
end)

RunService.Heartbeat:Connect(function()
    if not isSessionActive() then return end
    if State.Ores.OreESP and isAlive(LocalPlayer) then
        local myRoot = getRoot()
        if myRoot then
            for part, data in pairs(activeOreESP) do
                if part and part.Parent and data.Label then
                    local dist = math.floor((myRoot.Position - part.Position).Magnitude)
                    local info = cachedOres[part]
                    local oreType = (info and info.Type) or "Ore"
                    data.Label.Text = string.format("%s\n[%dm]", oreType, dist)
                end
            end
        end
    end
end)

-- ZERO-LAG ORE AURA (Iterates ONLY over cachedOres, never calls Workspace:GetDescendants() or axe:Activate()!)
task.spawn(function()
    local wasOreAuraOn = false
    while isSessionActive() do
        task.wait(0.07)
        if State.Ores.OreAura and isAlive(LocalPlayer) then
            wasOreAuraOn = true
            if not (State.Ores.IgnoreLobbyOres and isPlayerInLobby()) then
                local root = getRoot()
                if root then
                    -- Collect only valid ores within OreAuraRange from our fast cache
                    local targets = {}
                    local maxR = State.Ores.OreAuraRange
                    for orePart, info in pairs(cachedOres) do
                        if orePart and orePart.Parent then
                            if not State.Ores.IgnoreLobbyOres or not isLobbyPart(orePart) then
                                local d = (root.Position - orePart.Position).Magnitude
                                if d <= maxR then
                                    table.insert(targets, { Part = orePart, Dist = d, Priority = info.Priority })
                                end
                            end
                        else
                            cachedOres[orePart] = nil
                        end
                    end

                    if #targets > 0 then
                        table.sort(targets, function(a, b)
                            if a.Priority ~= b.Priority then return a.Priority > b.Priority end
                            return a.Dist < b.Dist
                        end)
                        local axe = getMiningTool(true)
                        if axe then
                            for i = 1, math.min(#targets, 3) do
                                mineOreDirect(axe, targets[i].Part)
                            end
                        end
                    end
                end
            end
        elseif wasOreAuraOn and not State.Ores.AutoOreFarm then
            wasOreAuraOn = false
            restoreAxeLocalScripts()
        end
    end
end)

local isFarmingOres = false
local oreReturnCFrame = nil

-- ZERO-LAG ORE TARGET FINDER (Uses cachedOres directly)
local function getBestOreTarget(myPos)
    if State.Ores.IgnoreLobbyOres and isPlayerInLobby() then
        return nil
    end

    local bestPart = nil
    local bestPriority = -1
    local bestDistance = math.huge

    for item, info in pairs(cachedOres) do
        if item and item.Parent then
            if not State.Ores.IgnoreLobbyOres or not isLobbyPart(item) then
                local priority = info.Priority
                local allow = false
                if State.Ores.FarmPriority == "Emerald / Diamond First" or State.Ores.FarmPriority == "Diamond First" then
                    allow = true
                elseif State.Ores.FarmPriority == "Gold & Up" then
                    allow = (priority >= 3)
                elseif State.Ores.FarmPriority == "All Ores" then
                    allow = true
                end

                if allow then
                    local dist = (myPos - item.Position).Magnitude
                    if priority > bestPriority then
                        bestPriority = priority
                        bestDistance = dist
                        bestPart = item
                    elseif priority == bestPriority and dist < bestDistance then
                        bestDistance = dist
                        bestPart = item
                    end
                end
            end
        else
            cachedOres[item] = nil
        end
    end
    return bestPart
end

-- Find closest alive enemy player inside the active match (never in Lobby Y >= 218, never in Void Y <= 122)
local function getBestMatchEnemy(myPos)
    local bestPlr = nil
    local bestDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and not isTeammate(plr) then
            local tChar = getChar(plr)
            local tRoot = getRoot(tChar)
            local tHum  = getHumanoid(tChar)
            if tRoot and tHum and tHum.Health > 0 then
                local y = tRoot.Position.Y
                -- Must be in active match (below Lobby Y=218 and above Void kill zone Y=122)
                if y < 218 and y > 122 then
                    local d = (myPos - tRoot.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestPlr = plr
                    end
                end
            end
        end
    end
    return bestPlr
end

-- Strict Coin Validator:
-- NEVER matches player character parts, Tool Handles, Accessories, Portals, or Killbricks!
-- Prevents welded Tool.Handle / Accessory CFrame corruption that caused the character to disappear!
local function isSafeCoinPart(obj)
    if not obj or not obj:IsA("BasePart") or not obj.Parent then return false end
    if obj == antiVoidFloorPart or obj == airBridgeSupportPart then return false end
    if obj:IsDescendantOf(Workspace.CurrentCamera) then return false end

    -- Never touch ANY Tool or Accessory (equipped or dropped) or any Player Character
    if obj:FindFirstAncestorOfClass("Tool") or obj:FindFirstAncestorOfClass("Accessory") or obj:FindFirstAncestorOfClass("Hat") then
        return false
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and obj:IsDescendantOf(plr.Character) then
            return false
        end
    end
    if obj:FindFirstAncestorOfClass("Model") and obj:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid") then
        return false
    end

    -- Coins are small parts/meshes (< 10 studs)
    if obj.Size.Magnitude > 10 then return false end

    local n = obj.Name:lower()
    local pn = (obj.Parent and obj.Parent.Name:lower()) or ""
    if n:find("kill") or n:find("lava") or n:find("void") or n:find("portal")
        or n:find("teleport") or n:find("pad") or n:find("door") or n:find("shop")
        or pn:find("portal") or pn:find("teleport") or pn:find("kill") then
        return false
    end

    -- Must have a TouchTransmitter (real collectible coin) so we never match decorative signs/walls!
    if not obj:FindFirstChildOfClass("TouchTransmitter") then return false end
    if n == "coin" or n == "coins" or n:find("coin") or pn == "coin" or pn == "coins" then
        return true
    end
    return false
end

local function collectCoinPartSafely(root, coinPart)
    if not root or not root.Parent or not coinPart or not coinPart.Parent then return end
    pcall(function()
        -- 1. Zero-physics TouchTransmitter trigger (never moves or flings the character!)
        if firetouchinterest then
            local tt = coinPart:FindFirstChildOfClass("TouchTransmitter")
            if tt then
                firetouchinterest(root, coinPart, 0)
                firetouchinterest(root, coinPart, 1)
                return
            end
            if coinPart.Parent and coinPart.Parent:IsA("BasePart") and coinPart.Parent:FindFirstChildOfClass("TouchTransmitter") then
                firetouchinterest(root, coinPart.Parent, 0)
                firetouchinterest(root, coinPart.Parent, 1)
                return
            end
        end

        -- 2. Only move standalone unanchored coins with zero welds/joints, after disabling collision
        -- 2. Bring the coin part to root.CFrame with CanCollide = false (NEVER moves root.CFrame!)
        if coinPart:FindFirstChildOfClass("TouchTransmitter") then
            coinPart.CanCollide = false
            coinPart.CFrame = root.CFrame
        elseif not coinPart.Anchored and #coinPart:GetJoints() == 0 then
            coinPart.CanCollide = false
            coinPart.AssemblyLinearVelocity = Vector3.zero
            coinPart.AssemblyAngularVelocity = Vector3.zero
            coinPart.CFrame = root.CFrame
        end
    end)
end

-- Collect nearby dropped coins safely during AI Farm cycle
local function sweepNearbyCoins(root)
    if not root or not root.Parent then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isSafeCoinPart(obj) then
            if obj.Position.Y < 218 and obj.Position.Y > 125 and (obj.Position - root.Position).Magnitude < 95 then
                collectCoinPartSafely(root, obj)
            end
        end
    end
end

-- Frame-accurate Heartbeat Glider (Supports ultra-low speeds down to 1 stud/s up to 150+ studs/s without falling!)
local function tpOrGlide(root, hum, targetCFrame, speed, targetPart)
    if State.Ores.FarmMode == "Instant TP" then
        root.CFrame = targetCFrame
        root.AssemblyLinearVelocity = Vector3.zero
        return
    end

    local actualSpeed = math.max(tonumber(speed) or 25, 1)
    local startPos = root.Position
    local goalPos = targetCFrame.Position
    local totalDist = (goalPos - startPos).Magnitude
    if totalDist < 1.5 then
        root.CFrame = targetCFrame
        root.AssemblyLinearVelocity = Vector3.zero
        return
    end

    local elapsed = 0
    local duration = totalDist / actualSpeed

    while elapsed < duration and State.Ores.AutoOreFarm and isAlive(LocalPlayer) do
        if targetPart and not targetPart.Parent then
            break
        end
        if State.Ores.IgnoreLobbyOres and goalPos.Y >= 218 then
            break
        end

        local dt = RunService.Heartbeat:Wait()
        elapsed = elapsed + dt
        local alpha = math.clamp(elapsed / duration, 0, 1)
        local nextPos = startPos:Lerp(goalPos, alpha)

        local r = getRoot()
        local h = getHumanoid()
        if not r or not h then break end

        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end

        r.CFrame = CFrame.new(nextPos)
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end

    if isAlive(LocalPlayer) and (not targetPart or targetPart.Parent) and State.Ores.AutoOreFarm then
        local r = getRoot()
        if r then
            r.CFrame = targetCFrame
            r.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

-- Dynamic AI Glider that smoothly tracks a moving enemy player's underside (tRoot.Position - (0, UnderTargetOffset, 0))
local function glideUnderMovingPlayer(enemyPlr, speed)
    local underOffset = Vector3.new(0, -(State.Ores.UnderTargetOffset or 6.2), 0)

    while State.Ores.AutoOreFarm and isAlive(LocalPlayer) and isAlive(enemyPlr) do
        local myRoot = getRoot()
        local tChar = getChar(enemyPlr)
        local tRoot = getRoot(tChar)
        local tHum  = getHumanoid(tChar)
        if not myRoot or not tRoot or not tHum or tHum.Health <= 0 then break end

        -- Stop chasing if enemy died/respawned in Lobby or fell deep into the void
        if tRoot.Position.Y >= 218 or tRoot.Position.Y <= 122 then
            break
        end

        local goalPos = tRoot.Position + underOffset
        -- Keep goalPos above the void death zone
        if goalPos.Y < 130 then
            goalPos = Vector3.new(goalPos.X, 130, goalPos.Z)
        end

        if State.Ores.FarmMode == "Instant TP" then
            myRoot.CFrame = CFrame.lookAt(goalPos, tRoot.Position)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            break
        end

        local diff = goalPos - myRoot.Position
        local dist = diff.Magnitude
        if dist <= 3.5 then
            myRoot.CFrame = CFrame.lookAt(goalPos, tRoot.Position)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            break
        end

        local dt = RunService.Heartbeat:Wait()
        local actualSpeed = math.max(tonumber(speed) or 25, 1)
        local stepDist = math.min(dist, actualSpeed * dt)
        local nextPos = myRoot.Position + (diff.Unit * stepDist)

        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end

        myRoot.CFrame = CFrame.lookAt(nextPos, tRoot.Position)
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end
end

-- AI Under-Player Kill Routine: Stays locked underneath enemyPlr & attacks with Killaura until they die
local function aiKillEnemyUnderneath(enemyPlr)
    local underOffset = Vector3.new(0, -(State.Ores.UnderTargetOffset or 6.2), 0)
    -- Re-enable Axe scripts if we are switching to Sword
    restoreAxeLocalScripts()

    -- 1. Glide smoothly to the underside of the enemy player
    glideUnderMovingPlayer(enemyPlr, State.Ores.FarmSpeed)

    -- 2. Lock underneath enemy & Killaura them until they die, fall into void, or return to Lobby
    local lastAttack = 0
    while State.Ores.AutoOreFarm and isAlive(LocalPlayer) and isAlive(enemyPlr) and not isTeammate(enemyPlr) do
        local myRoot = getRoot()
        local tChar = getChar(enemyPlr)
        local tRoot = getRoot(tChar)
        local tHum  = getHumanoid(tChar)
        if not myRoot or not tRoot or not tHum or tHum.Health <= 0 then
            break
        end

        -- If enemy was knocked into the void or teleported back to Lobby, move on to next target!
        if tRoot.Position.Y >= 218 or tRoot.Position.Y <= 122 then
            break
        end

        local goalPos = tRoot.Position + underOffset
        if goalPos.Y < 130 then
            goalPos = Vector3.new(goalPos.X, 130, goalPos.Z)
        end

        -- If enemy dashed/flew far away (> 30 studs), glide back under them at FarmSpeed
        if (myRoot.Position - goalPos).Magnitude > 30 and State.Ores.FarmMode ~= "Instant TP" then
            glideUnderMovingPlayer(enemyPlr, State.Ores.FarmSpeed)
        else
            local c = getChar()
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        p.CanCollide = false
                    end
                end
            end

            -- Position directly under the enemy facing up at them so Sword reach hits 100% while they can't hit us
            myRoot.CFrame = CFrame.lookAt(goalPos, tRoot.Position)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end

        local now = tick()
        if now - lastAttack >= 0.04 then
            lastAttack = now
            fireSwordAttack(enemyPlr)
        end

        RunService.Heartbeat:Wait()
    end

    -- Sweep any coins dropped by the killed player
    local r = getRoot()
    if r then
        sweepNearbyCoins(r)
    end
end

-- ============================================================
-- MASTER AI AUTO ORE & KILL FARM LOOP:
--   Step 1: Save start position (oreReturnCFrame)
--   Step 2: Glide to & mine all match Ores (ignoring Lobby ores)
--   Step 3: When Ores finish -> AI Glide underneath each match enemy & Killaura them one by one
--   Step 4: Collect dropped coins & Glide back to starting position (oreReturnCFrame)
-- ============================================================
task.spawn(function()
    local wasAutoFarming = false
    while isSessionActive() do
        task.wait(0.08)
        if State.Ores.AutoOreFarm and isAlive(LocalPlayer) and not isFarmingOres then
            wasAutoFarming = true
            if not (State.Ores.IgnoreLobbyOres and isPlayerInLobby()) then
                local root = getRoot()
                local hum  = getHumanoid()
                if root and hum then
                    -- Save starting position before the AI Farm cycle begins
                    if not oreReturnCFrame and root.Position.Y < 218 then
                        oreReturnCFrame = CFrame.new(root.Position)
                    end

                    -- PHASE 1: Check for any remaining Match Ores first
                    local targetOre = getBestOreTarget(root.Position)

                    if targetOre then
                        local axe = getMiningTool(true)
                        if axe then
                            isFarmingOres = true

                            local targetCFrame = targetOre.CFrame * CFrame.new(0, 3.2, 0)
                            tpOrGlide(root, hum, targetCFrame, State.Ores.FarmSpeed, targetOre)

                            -- Mine ONLY targetOre directly via server remote (NEVER calls axe:Activate()!)
                            local mineTries = 0
                            while targetOre and targetOre.Parent and mineTries < 14 and State.Ores.AutoOreFarm and isAlive(LocalPlayer) do
                                mineTries = mineTries + 1
                                local curRoot = getRoot()
                                if curRoot then
                                    curRoot.CFrame = targetOre.CFrame * CFrame.new(0, 3.2, 0)
                                    curRoot.AssemblyLinearVelocity = Vector3.zero
                                end
                                local curAxe = getMiningTool(true) or axe
                                mineOreDirect(curAxe, targetOre)
                                task.wait(0.04)
                            end

                            cachedOres[targetOre] = nil
                            if isAlive(LocalPlayer) then
                                sweepNearbyCoins(getRoot())
                            end
                            isFarmingOres = false
                        end
                    else
                        -- PHASE 2: All Match Ores are finished! Switch to AI Under-Player Kill Cycle
                        local nextEnemy = State.Ores.AIKillAfterOres and getBestMatchEnemy(root.Position) or nil

                        if nextEnemy then
                            isFarmingOres = true
                            unequipTools()
                            getTool("sword", true)
                            aiKillEnemyUnderneath(nextEnemy)
                            isFarmingOres = false
                        else
                            -- PHASE 3: Both Ores and Enemy Players are finished! Sweep coins & Glide back to start position
                            if oreReturnCFrame and isAlive(LocalPlayer) then
                                isFarmingOres = true
                                restoreAxeLocalScripts()
                                local retRoot = getRoot()
                                local retHum  = getHumanoid()
                                if retRoot and retHum then
                                    sweepNearbyCoins(retRoot)
                                    local distToHome = (retRoot.Position - oreReturnCFrame.Position).Magnitude
                                    if distToHome > 2.5 then
                                        tpOrGlide(retRoot, retHum, oreReturnCFrame, State.Ores.FarmSpeed, nil)
                                    end
                                    retRoot.CFrame = oreReturnCFrame
                                    retRoot.AssemblyLinearVelocity = Vector3.zero
                                end
                                oreReturnCFrame = nil
                                isFarmingOres = false
                            end
                        end
                    end
                end
            end
        end

        if not State.Ores.AutoOreFarm then
            oreReturnCFrame = nil
            if wasAutoFarming and not State.Ores.OreAura then
                wasAutoFarming = false
                restoreAxeLocalScripts()
            end
        end
    end
end)

task.spawn(function()
    while isSessionActive() do
        task.wait(0.12)
        if State.World.MineAura and isAlive(LocalPlayer) then
            local root = getRoot()
            local axe = getMiningTool(true)
            if root and axe then
                local remote  = axe:FindFirstChild("RemoteEvent")   or axe:FindFirstChildOfClass("RemoteEvent")
                local rfunc   = axe:FindFirstChild("RemoteFunction") or axe:FindFirstChildOfClass("RemoteFunction")
                local mined = 0
                for _, item in ipairs(Workspace:GetDescendants()) do
                    if not State.World.MineAura then break end
                    if item:IsA("BasePart") and item.Parent and not item:IsDescendantOf(LocalPlayer.Character or Workspace.CurrentCamera) then
                        if not isLobbyPart(item) and item.Name ~= "RanaxAntiVoidFloor" then
                            local iName = item.Name:lower()
                            local isTarget = (item.Name == "Block" or cachedOres[item] ~= nil
                                or iName:find("ore") or iName:find("emerald") or iName:find("diamond")
                                or iName:find("gold") or iName:find("iron") or iName:find("coal") or iName:find("ruby"))
                            if isTarget and not iName:find("baseplate") and not iName:find("antivoid") and not iName:find("spawn") then
                                local dist = (root.Position - item.Position).Magnitude
                                if dist <= State.World.MineAuraRange then
                                    if remote then pcall(function() remote:FireServer(item) end) end
                                    if rfunc  then task.spawn(function() pcall(function() rfunc:InvokeServer(item) end) end) end
                                    mined = mined + 1
                                    if mined >= 5 then break end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- 3.5 SKYWARS CLASSIC SPECIALS: VIP UNLOCK, FREE ARMOR/ITEMS, MAGNET & WAYPOINTS
-- ============================================================
local savedCustomPos = nil

local function unlockVIPDoors()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            local pn = (obj.Parent and obj.Parent.Name:lower()) or ""
            if n:find("vip") or n:find("door") or n:find("barrier") or n:find("gamepass")
                or pn:find("vipdoor") or pn:find("megadoor") or (pn:find("vip") and n:find("wall")) then
                if obj.Size.Magnitude < 65 then
                    pcall(function()
                        obj.CanCollide = false
                        obj.Transparency = math.max(obj.Transparency, 0.75)
                    end)
                end
            end
        end
    end
end

local function claimFreeLobbyArmorAndItems()
    local root = getRoot()
    if not root then return end
    local savedCF = root.CFrame

    -- Touch all armor stands / weapon givers / Mega VIP / Undertale pads
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
            local part = obj.Parent
            local fullPath = part:GetFullName():lower()
            if fullPath:find("armor") or fullPath:find("chestplate") or fullPath:find("helmet")
                or fullPath:find("legging") or fullPath:find("boot") or fullPath:find("mega")
                or fullPath:find("undertale") or fullPath:find("sword") or fullPath:find("giver")
                or fullPath:find("vip") or fullPath:find("kit") then
                if not fullPath:find("kill") and not fullPath:find("lava") and not fullPath:find("portal") then
                    pcall(function()
                        if firetouchinterest then
                            firetouchinterest(root, part, 0)
                            task.wait()
                            firetouchinterest(root, part, 1)
                        else
                            -- Never teleport root.CFrame across the lobby (prevents character disappearance!); bring the giver part to root briefly!
                            local oldCanCollide = part.CanCollide
                            local oldCF = part.CFrame
                            part.CanCollide = false
                            part.CFrame = root.CFrame
                            task.wait(0.03)
                            if part and part.Parent then
                                part.CFrame = oldCF
                                part.CanCollide = oldCanCollide
                            end
                            task.wait(0.05)
                        end
                    end)
                end
            end
        end
    end

    if not firetouchinterest and root and root.Parent then
        -- root.CFrame is never modified during claimFreeLobbyArmorAndItems!
    end
end

-- Safe Coin Farm & Coin Magnet (Never touches Tool.Handle / Character welds -> Character NEVER disappears!)
local isCoinFarming = false
task.spawn(function()
    while isSessionActive() do
        task.wait(0.12)
        if (State.World.MagnetItems or State.World.AutoCoinFarm) and isAlive(LocalPlayer) and not isRunningBypassReset then
            local root = getRoot()
            local hum  = getHumanoid()
            if root and hum then
                local bestCoin = nil
                local bestDist = math.huge

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if isSafeCoinPart(obj) and obj.Position.Y > 125 then
                        local d = (obj.Position - root.Position).Magnitude
                        if State.World.MagnetItems and d < 120 then
                            collectCoinPartSafely(root, obj)
                        end
                        if State.World.AutoCoinFarm then
                            -- If in match, only target match coins; if in lobby, allow lobby coins
                            local inLobby = isPlayerInLobby()
                            local coinInLobby = (obj.Position.Y >= 218)
                            if inLobby == coinInLobby and d < bestDist then
                                bestDist = d
                                bestCoin = obj
                            end
                        end
                    end
                end

                if State.World.AutoCoinFarm and bestCoin and bestCoin.Parent and not isFarmingOres and not isCoinFarming then
                    isCoinFarming = true
                    -- Always collect coin safely by bringing coinPart to root.CFrame (NEVER teleports root.CFrame -> character NEVER disappears!)
                    collectCoinPartSafely(root, bestCoin)
                    if false and firetouchinterest and bestCoin:FindFirstChildOfClass("TouchTransmitter") then
                        collectCoinPartSafely(root, bestCoin)
                    else
                        -- Never teleport root.CFrame in AutoCoinFarm!
                        local startP = root.Position
                        local goalP  = Vector3.new(bestCoin.Position.X, math.max(bestCoin.Position.Y + 2.5, 134), bestCoin.Position.Z)
                        local dist   = (goalP - startP).Magnitude
                        local spd    = math.max(tonumber(State.Ores.FarmSpeed) or 25, 5)
                        local dur    = math.clamp(dist / spd, 0.03, 4.0)
                        local el     = 0
                        while false do
                            local dt = RunService.Heartbeat:Wait()
                            el = el + dt
                            local r = getRoot()
                            if not r then break end
                            local nxt = startP:Lerp(goalP, math.clamp(el / dur, 0, 1))
                            r.CFrame = CFrame.new(nxt)
                            r.AssemblyLinearVelocity = Vector3.zero
                        end
                        local r = getRoot()
                        if r and bestCoin.Parent then
                            collectCoinPartSafely(r, bestCoin)
                        end
                    end
                    isCoinFarming = false
                end
            end
        end
        if State.World.AutoFreeArmor and isAlive(LocalPlayer) and isPlayerInLobby() and not isRunningBypassReset then
            claimFreeLobbyArmorAndItems()
            task.wait(1.2)
        end
    end
end)

local function teleportToWaypoint(mode)
    local root = getRoot()
    if not root then return end
    root.AssemblyLinearVelocity = Vector3.zero

    if mode == "CenterIsland" then
        -- Skywars Classic Center Island (Mid) is at (11.36, 165, -0.87)
        root.CFrame = CFrame.new(11.3622465, 168.5, -0.872686088)
    elseif mode == "VIPRoom" then
        unlockVIPDoors()
        root.CFrame = CFrame.new(0.129652873, 264, -72.7414246)
    elseif mode == "MegaVIPRoom" then
        unlockVIPDoors()
        root.CFrame = CFrame.new(0.644594908, 264, 67.4945374)
    elseif mode == "SpawnLobby" then
        root.CFrame = CFrame.new(-0.418475986, 268, -0.111892045)
    elseif mode == "NearestPlayer" then
        local bestPlr, bestD = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) and not isTeammate(plr) then
                local tr = getRoot(getChar(plr))
                if tr and tr.Position.Y < 220 then
                    local d = (root.Position - tr.Position).Magnitude
                    if d < bestD then bestD = d; bestPlr = tr end
                end
            end
        end
        if bestPlr then
            root.CFrame = bestPlr.CFrame * CFrame.new(0, 4, 0)
        end
    elseif mode == "SavePos" then
        savedCustomPos = root.CFrame
    elseif mode == "LoadPos" and savedCustomPos then
        root.CFrame = savedCustomPos
    end
end

-- ============================================================
-- 4. MOVEMENT: ULTIMATE SKYWARS CLASSIC ANTI-VOID ENGINE
-- Accurately detects match islands at Y ~ 150-190 (ignoring Lobby at Y ~ 264)
-- Places solid ForceField barrier + active bounce / safe-ground teleport
-- WELL ABOVE the Skywars Classic void kill plane (Y ~ 115-130)!
-- ============================================================
local lastSafeCFrame = CFrame.new(11.3622465, 168.5, -0.872686088)
local lastAntiVoidTick = 0
local antiVoidFloorPart = nil
local cachedMapFloorY = 142

local function findMapFloorY()
    local lowestY = math.huge

    -- Scan match blocks & island parts below Lobby height (Y < 215 and Y > 60)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Anchored and obj.CanCollide and obj.Name ~= "RanaxAntiVoidFloor" then
            local y = obj.Position.Y
            -- Match islands in Skywars Classic sit between Y = 135 and Y = 210 (Center Island is Y = 165)
            if y < 215 and y > 75 and not isLobbyPart(obj) and not obj:IsDescendantOf(LocalPlayer.Character or Workspace.CurrentCamera) then
                local n = obj.Name:lower()
                if not n:find("kill") and not n:find("void") and not n:find("death") and not n:find("barrier") then
                    if y < lowestY then
                        lowestY = y
                    end
                end
            end
        end
    end

    local offset = tonumber(State.Movement.AntiVoidOffset) or 12
    if lowestY < math.huge then
        -- Place barrier `offset` studs below the lowest island block, but never below Y = 132 (above void death plane!)
        return lowestY - offset
    end

    -- Fallback for Skywars Classic where Center Island is at Y = 165:
    -- 160 - 12 = 148 (safely below island undersides and 20+ studs above void kill zone!)
    return 160 - offset
end

local function syncAntiVoidBarrier()
    cachedMapFloorY = findMapFloorY()
    State.Movement.AntiVoidHeight = cachedMapFloorY

    if not antiVoidFloorPart or not antiVoidFloorPart.Parent then
        antiVoidFloorPart = Instance.new("Part")
        antiVoidFloorPart.Name = "RanaxAntiVoidFloor"
        antiVoidFloorPart.Anchored = true
        antiVoidFloorPart.Size = Vector3.new(2048, 6, 2048)
        antiVoidFloorPart.Material = Enum.Material.ForceField
        antiVoidFloorPart.Color = Color3.fromRGB(130, 95, 255)
        antiVoidFloorPart.CastShadow = false
        antiVoidFloorPart.Parent = Workspace

        antiVoidFloorPart.Touched:Connect(function(hit)
            if not State.Movement.AntiVoid then return end
            if hit and LocalPlayer.Character and hit:IsDescendantOf(LocalPlayer.Character) then
                local r = getRoot()
                if r then
                    if State.Movement.AntiVoidMode == "Teleport to Safe Ground" and lastSafeCFrame then
                        r.AssemblyLinearVelocity = Vector3.zero
                        r.CFrame = lastSafeCFrame + Vector3.new(0, 3, 0)
                    elseif State.Movement.AntiVoidMode == "Velocity Bounce" then
                        r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 75, r.AssemblyLinearVelocity.Z)
                    else
                        if r.AssemblyLinearVelocity.Y < 0 then
                            r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 28, r.AssemblyLinearVelocity.Z)
                        end
                    end
                end
            end
        end)
    end

    local solidOn = State.Movement.AntiVoid and (State.Movement.AntiVoidMode == "Solid Barrier + Bounce")
    antiVoidFloorPart.CFrame = CFrame.new(0, cachedMapFloorY - 3, 0)
    antiVoidFloorPart.CanCollide = solidOn
    antiVoidFloorPart.Transparency = State.Movement.AntiVoid and 0.55 or 1
end

task.spawn(function()
    while isSessionActive() do
        task.wait(2.5)
        cachedMapFloorY = findMapFloorY()
        if antiVoidFloorPart and antiVoidFloorPart.Parent then
            local solidOn = State.Movement.AntiVoid and (State.Movement.AntiVoidMode == "Solid Barrier + Bounce")
            antiVoidFloorPart.CFrame = CFrame.new(0, cachedMapFloorY - 3, 0)
            antiVoidFloorPart.CanCollide = solidOn
            antiVoidFloorPart.Transparency = State.Movement.AntiVoid and 0.55 or 1
        end
    end
end)

syncAntiVoidBarrier()

RunService.Heartbeat:Connect(function()
    if not isSessionActive() then return end
    if isAlive(LocalPlayer) then
        local root = getRoot()
        local hum = getHumanoid()
        if root and hum then
            local y = root.Position.Y

            -- Record last safe island CFrame whenever standing on solid match island blocks (Y between cachedMapFloorY+2 and 218)
            if hum.FloorMaterial ~= Enum.Material.Air and y < 218 and y > (cachedMapFloorY + 2) then
                lastSafeCFrame = root.CFrame
            end

            -- Active Anti-Void Trigger (Works in all 3 modes!)
            if State.Movement.AntiVoid and y < 218 then
                -- Cushion downward speed as player approaches the Anti-Void level
                if y <= (cachedMapFloorY + 10) and y >= cachedMapFloorY and root.AssemblyLinearVelocity.Y < -18 then
                    if State.Movement.AntiVoidMode == "Solid Barrier + Bounce" then
                        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -4, root.AssemblyLinearVelocity.Z)
                    end
                end

                -- Trigger recovery if player reaches or falls below cachedMapFloorY
                if y <= (cachedMapFloorY + 1.5) then
                    local now = tick()
                    if State.Movement.AntiVoidMode == "Teleport to Safe Ground" then
                        if now - lastAntiVoidTick > 0.15 then
                            lastAntiVoidTick = now
                            root.AssemblyLinearVelocity = Vector3.zero
                            if lastSafeCFrame and lastSafeCFrame.Position.Y > cachedMapFloorY and lastSafeCFrame.Position.Y < 218 then
                                root.CFrame = lastSafeCFrame + Vector3.new(0, 3.5, 0)
                            else
                                root.CFrame = CFrame.new(11.3622465, 168.5, -0.872686088)
                            end
                        end
                    elseif State.Movement.AntiVoidMode == "Velocity Bounce" then
                        if now - lastAntiVoidTick > 0.12 then
                            lastAntiVoidTick = now
                            root.CFrame = CFrame.new(root.Position.X, cachedMapFloorY + 3, root.Position.Z)
                            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 78, root.AssemblyLinearVelocity.Z)
                        end
                    else
                        -- Solid Barrier + Bounce: keep player above the solid ForceField floor even if Noclip is on!
                        if y < (cachedMapFloorY + 1.0) then
                            root.CFrame = CFrame.new(root.Position.X, cachedMapFloorY + 3.2, root.Position.Z)
                            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 22, root.AssemblyLinearVelocity.Z)
                        end
                    end
                end
            end

            if (State.Movement.NoFallDamage or State.Movement.AntiVoid) and root.AssemblyLinearVelocity.Y < -25 then
                local ray = Ray.new(root.Position, Vector3.new(0, -12, 0))
                local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                if hit then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -5, root.AssemblyLinearVelocity.Z)
                end
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    isFarmingOres = false
    task.wait(0.5)
    disableClientAntiCheat()
    syncAntiVoidBarrier()
end)

RunService.Heartbeat:Connect(function(dt)
    if not isSessionActive() then return end
    if State.Movement.SpeedBypass and isAlive(LocalPlayer) then
        local root = getRoot()
        local hum = getHumanoid()
        if root and hum and hum.MoveDirection.Magnitude > 0.05 then
            local speedDelta = (hum.MoveDirection * (State.Movement.SpeedMultiplier * 16 * dt))
            root.CFrame = root.CFrame + speedDelta
        end
    end
end)

-- ============================================================
-- FLY BYPASS (EXACT INFINITE YIELD sFLY ENGINE)
-- 1:1 IY Flight using BodyGyro & BodyVelocity
-- Full WASD + Space/Shift/E/Q control with respawn persistence
-- ============================================================
local FLYING = false
local flyKeyDown = nil
local flyKeyUp = nil
local flyBG = nil
local flyBV = nil
local flyCharConn = nil

local function stopFlyInternal()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect(); flyKeyDown = nil end
    if flyKeyUp then flyKeyUp:Disconnect(); flyKeyUp = nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    local hum = getHumanoid()
    if hum then
        pcall(function() hum.PlatformStand = false end)
    end
end

local function startFlyInternal()
    stopFlyInternal()
    local char = getChar()
    local root = getRoot(char)
    local hum = getHumanoid(char)
    if not root or not hum then return end

    FLYING = true

    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    flyBG = Instance.new("BodyGyro")
    flyBV = Instance.new("BodyVelocity")
    flyBG.Name = "IYFlyBG"
    flyBV.Name = "IYFlyBV"
    flyBG.P = 9e4
    flyBG.Parent = root
    flyBV.Parent = root
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.CFrame = root.CFrame
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    task.spawn(function()
        while FLYING and isAlive(LocalPlayer) do
            task.wait()
            local cam = Workspace.CurrentCamera
            if hum then
                hum.PlatformStand = true
            end

            local maxspeed = State.Movement.FlySpeed or 50

            if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                SPEED = maxspeed
            elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                SPEED = 0
            end

            if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                flyBV.Velocity = ((cam.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((cam.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).Position) - cam.CFrame.Position)) * SPEED
                lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
            elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                flyBV.Velocity = ((cam.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((cam.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).Position) - cam.CFrame.Position)) * SPEED
            else
                flyBV.Velocity = Vector3.new(0, 0, 0)
            end
            flyBG.CFrame = cam.CFrame
        end

        stopFlyInternal()
    end)

    flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.W then
            CONTROL.F = 1
        elseif input.KeyCode == Enum.KeyCode.S then
            CONTROL.B = -1
        elseif input.KeyCode == Enum.KeyCode.A then
            CONTROL.L = -1
        elseif input.KeyCode == Enum.KeyCode.D then
            CONTROL.R = 1
        elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then
            CONTROL.Q = 1
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.Q then
            CONTROL.E = -1
        end
    end)

    flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.W then
            CONTROL.F = 0
        elseif input.KeyCode == Enum.KeyCode.S then
            CONTROL.B = 0
        elseif input.KeyCode == Enum.KeyCode.A then
            CONTROL.L = 0
        elseif input.KeyCode == Enum.KeyCode.D then
            CONTROL.R = 0
        elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then
            CONTROL.Q = 0
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.Q then
            CONTROL.E = 0
        end
    end)
end

local function toggleFlyBypass(enable, shouldResetFirst)
    State.Movement.FlyBypass = enable

    if not enable then
        stopFlyInternal()
        if flyCharConn then flyCharConn:Disconnect(); flyCharConn = nil end
        return
    end

    if shouldResetFirst and isAlive(LocalPlayer) then
        pcall(function()
            local hum = getHumanoid()
            if hum then hum.Health = 0 end
        end)
        task.spawn(function()
            LocalPlayer.CharacterAdded:Wait()
            task.wait(0.6)
            if State.Movement.FlyBypass then
                startFlyInternal()
            end
        end)
    else
        startFlyInternal()
    end

    if flyCharConn then flyCharConn:Disconnect() end
    flyCharConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.6)
        if State.Movement.FlyBypass then
            stopFlyInternal()
            task.wait(0.1)
            startFlyInternal()
        end
    end)
end

-- ============================================================
-- REJOIN SERVER UTILITY
-- ============================================================
local function rejoinServer()
    local ts = game:GetService("TeleportService")
    if #Players:GetPlayers() <= 1 then
        pcall(function() LocalPlayer:Kick("\n[Ranax] Rejoining server...") end)
        task.wait(0.3)
        ts:Teleport(game.PlaceId, LocalPlayer)
    else
        pcall(function()
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end
end

UserInputService.JumpRequest:Connect(function()
    if State.Movement.InfiniteJump and isAlive(LocalPlayer) then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Stepped:Connect(function()
    if not isSessionActive() then return end
    if State.Movement.Noclip and isAlive(LocalPlayer) then
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end
end)

-- ============================================================
-- 5. AUTOMATION: AUTO WIN (KILL ALL IN MATCH + MEGA VIP PAD LOOP)
-- ============================================================
task.spawn(function()
    while isSessionActive() do
        task.wait(0.15)
        if State.Farm.AutoKillAll and isAlive(LocalPlayer) then
            local myRoot = getRoot()
            if myRoot then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if not State.Farm.AutoKillAll then break end
                    if plr ~= LocalPlayer and isAlive(plr) and not isTeammate(plr) then
                        local tRoot = getRoot(getChar(plr))
                        -- Only teleport to players inside the active match (Y < 218), never players waiting in Lobby!
                        if tRoot and tRoot.Position.Y < 218 and tRoot.Position.Y > 125 then
                            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 3.5, 0)
                            myRoot.AssemblyLinearVelocity = Vector3.zero
                            fireSwordAttack(plr)
                            task.wait(0.12)
                        end
                    end
                end
            end
        end
        if State.Farm.AutoWinPad and isAlive(LocalPlayer) then
            local myRoot = getRoot()
            if myRoot then
                myRoot.CFrame = CFrame.new(0.644594908, 264, 67.4945374)
                myRoot.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)

-- ============================================================
-- 6. VISUALS: PLAYER ESP
-- ============================================================
local function updatePlayerESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local highlight = plr.Character:FindFirstChild("RanaxSkyESP")
            if State.Visuals.PlayerESP then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "RanaxSkyESP"
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = isTeammate(plr) and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(255, 50, 70)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.65
                    highlight.OutlineTransparency = 0
                    highlight.Parent = plr.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

-- Cleanup Function
genv.SkywarsCleanup = function()
    spoofedMouseHit = nil
    spoofedMouseTarget = nil
    spoofedMouseSurface = nil
    for _, c in ipairs(ScriptConnections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(ScriptConnections)
    if airPlaceTargetPart then
        pcall(function() airPlaceTargetPart:Destroy() end)
        airPlaceTargetPart = nil
    end
    clearOreESP()
    stopFlyInternal()
    if flyCharConn then flyCharConn:Disconnect(); flyCharConn = nil end
    if antiVoidFloorPart then
        pcall(function() antiVoidFloorPart:Destroy() end)
        antiVoidFloorPart = nil
    end
    if airBridgeSupportPart then
        pcall(function() airBridgeSupportPart:Destroy() end)
        airBridgeSupportPart = nil
    end
    restoreBlockLocalScripts()
    restoreAxeLocalScripts()
end


-- ============================================================
-- UNIVERSAL KEYBIND MANAGER (ALL MODULES EXCEPT ESP)
-- Allows user-configurable keybinds for every gameplay feature
-- ============================================================
local KeybindRegistry = {
    Killaura        = { Key = Enum.KeyCode.R, StatePath = {"Combat", "Killaura"}, Name = "Killaura" },
    TargetStrafe    = { Key = nil,            StatePath = {"Combat", "TargetStrafe"}, Name = "Target Strafe" },
    AntiKnockback   = { Key = nil,            StatePath = {"Combat", "AntiKnockback"}, Name = "Anti-Knockback" },
    AutoClicker     = { Key = nil,            StatePath = {"Combat", "AutoClicker"}, Name = "Auto Clicker" },
    AutoBow         = { Key = nil,            StatePath = {"Combat", "AutoBow"}, Name = "Auto Bow" },
    RotateToTarget  = { Key = nil,            StatePath = {"Combat", "RotateToTarget"}, Name = "Rotate Target" },
    TeamCheck       = { Key = nil,            StatePath = {"Combat", "TeamCheck"}, Name = "Team Check" },
    AutoEquipSword  = { Key = nil,            StatePath = {"Combat", "AutoEquipSword"}, Name = "Auto Sword" },
    HitboxExtender  = { Key = Enum.KeyCode.H, StatePath = {"Combat", "HitboxExtender"}, Name = "Hitbox Expander" },
    Godbridge       = { Key = Enum.KeyCode.B, StatePath = {"Bridge", "Godbridge"}, Name = "Godbridge" },
    Scaffold        = { Key = Enum.KeyCode.G, StatePath = {"Bridge", "Scaffold"}, Name = "Scaffold" },
    SnapGrid        = { Key = nil,            StatePath = {"Bridge", "SnapGrid"}, Name = "Snap Grid" },
    OreAura         = { Key = Enum.KeyCode.V, StatePath = {"Ores", "OreAura"}, Name = "OreAura" },
    AutoOreFarm     = { Key = Enum.KeyCode.N, StatePath = {"Ores", "AutoOreFarm"}, Name = "Auto Ore Farm" },
    FlyBypass       = { Key = Enum.KeyCode.F, StatePath = {"Movement", "FlyBypass"}, Name = "Fly Bypass", OnToggle = function(v) toggleFlyBypass(v) end },
    SpeedBypass     = { Key = Enum.KeyCode.X, StatePath = {"Movement", "SpeedBypass"}, Name = "Speed Bypass" },
    AntiVoid        = { Key = Enum.KeyCode.Z, StatePath = {"Movement", "AntiVoid"}, Name = "Anti-Void", OnToggle = function(v) syncAntiVoidBarrier() end },
    NoFallDamage    = { Key = nil,            StatePath = {"Movement", "NoFallDamage"}, Name = "NoFall Damage" },
    InfiniteJump    = { Key = nil,            StatePath = {"Movement", "InfiniteJump"}, Name = "Infinite Jump" },
    Noclip          = { Key = Enum.KeyCode.C, StatePath = {"Movement", "Noclip"}, Name = "Noclip" },
    AutoKillAll     = { Key = nil,            StatePath = {"Farm", "AutoKillAll"}, Name = "Auto Win" },
}

local ModuleToggleUIs = {}

local function toggleModuleByKey(featName)
    local kb = KeybindRegistry[featName]
    if not kb then return end
    local c = kb.StatePath[1]
    local s = kb.StatePath[2]
    local newVal = not State[c][s]
    State[c][s] = newVal

    if kb.OnToggle then
        kb.OnToggle(newVal)
    end

    local ui = ModuleToggleUIs[featName]
    if ui and ui.Set then
        ui.Set(newVal)
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for featName, kb in pairs(KeybindRegistry) do
            if kb.Key and input.KeyCode == kb.Key then
                toggleModuleByKey(featName)
            end
        end
    end
end)

-- ============================================================
-- 7. TRFTAP ADAPT UI LIBRARY (EXACT 1:1 REPLICA FROM TRFTAP_V3)
-- Ensures logos, blocks, toggles, and sliders work identically!
-- ============================================================
local function AdaptUILibrary(RealLibrary)
    local Registry = {}
    local activeNotify = nil

    local WrapperLibrary = {}
    WrapperLibrary.Flags = Registry
    WrapperLibrary.Items = Registry

    local function register(cfg, api)
        if type(cfg) ~= "table" or not api then return end
        if cfg.Flag and cfg.Flag ~= "" then Registry[cfg.Flag] = api end
        if cfg.Name and cfg.Name ~= "" then
            Registry[cfg.Name] = api
            Registry[(cfg.Name:gsub("%s+", ""))] = api
        end
    end

    function WrapperLibrary:Notify(cfg)
        if activeNotify then return activeNotify(cfg) end
        warn("[Ranax Notify]", cfg and (cfg.Title or ""), cfg and (cfg.Content or cfg.Description or ""))
    end

    function WrapperLibrary:CreateWindow(cfg)
        cfg = cfg or {}
        local oldTheme = type(cfg.Theme) == "table" and cfg.Theme or {}
        local realCfg = {}
        for k, v in pairs(cfg) do realCfg[k] = v end
        realCfg.OpenKeybind = cfg.ToggleKey or cfg.OpenKeybind or Enum.KeyCode.LeftControl
        realCfg.Logo = cfg.CustomIcon or cfg.Logo or "82269833034303"
        realCfg.Watermark = true
        realCfg.ShowWatermark = true
        realCfg.WindowSize = cfg.WindowSize or Vector2.new(820, 520)
        realCfg.ConfigFolder = cfg.ConfigFolder or "TR_skywars_Config"
        realCfg.Theme = {
            Accent = oldTheme.ElementAccent or oldTheme.GradientStart or Color3.fromRGB(110, 100, 255),
            Background = oldTheme.Main or Color3.fromRGB(8, 8, 11),
            Sidebar = oldTheme.Second or Color3.fromRGB(13, 13, 17),
            Card = Color3.fromRGB(18, 18, 24),
            Element = Color3.fromRGB(22, 22, 30),
            Input = Color3.fromRGB(16, 16, 22),
            Text = oldTheme.TextColor or Color3.fromRGB(255, 255, 255),
            TextMuted = Color3.fromRGB(145, 150, 170),
            BackgroundImage = "",
            BgImageTrans = 1.0,
            TextFont = oldTheme.Font or "GothamBold",
            CornerRadius = oldTheme.CornerRadius or 12,
        }

        local RealWindow = RealLibrary:CreateWindow(realCfg)
        activeNotify = function(c) return RealWindow:Notify(c) end

        local WrapperWindow = {}
        function WrapperWindow:Notify(c) return RealWindow:Notify(c) end
        function WrapperWindow:SetThemeOption(k, v)
            if RealWindow and RealWindow.SetThemeOption then return RealWindow:SetThemeOption(k, v) end
        end
        setmetatable(WrapperWindow, {
            __index = function(_, k)
                if RealWindow and RealWindow[k] then
                    return function(self, ...) return RealWindow[k](RealWindow, ...) end
                end
            end
        })

        local function formatModuleName(str)
            if type(str) ~= "string" then return str end
            return str
        end

        function WrapperWindow:CreateTab(nameArg, secondArg, thirdArg)
            local tabName, rawIcon, tabSettings
            if type(nameArg) == "table" then
                tabName = formatModuleName(nameArg.Name or "Tab")
                rawIcon = nameArg.Icon
                tabSettings = nameArg.IsSettings
            else
                tabName = formatModuleName(tostring(nameArg or "Tab"))
                if type(secondArg) == "string" and thirdArg == nil then
                    rawIcon = secondArg
                elseif type(thirdArg) == "string" then
                    rawIcon = thirdArg
                elseif type(secondArg) == "string" then
                    rawIcon = secondArg
                end
                tabSettings = false
            end

            -- Ensure numeric Asset IDs are prefixed with rbxassetid:// so logos display properly!
            local tabIcon = rawIcon
            if tabIcon and tostring(tabIcon):match("^%d+$") then
                tabIcon = "rbxassetid://" .. tostring(tabIcon)
            end

            local RealTab = RealWindow:CreateTab({ Name = tabName, Icon = tabIcon, IsSettings = tabSettings == true })

            local WrapperTab = {}
            function WrapperTab:CreateBlock(blockCfg)
                blockCfg = type(blockCfg) == "table" and blockCfg or { Name = tostring(blockCfg or "Block") }
                local bName = formatModuleName(blockCfg.Name or "Block")
                local RealBlock = RealTab:CreateBlock({ Name = bName, Side = blockCfg.Side or "Left", Icon = blockCfg.Icon })

                local WrapperBlock = {}

                function WrapperBlock:CreateToggle(tglCfg)
                    local api
                    local value = tglCfg.Default and true or false
                    local tName = formatModuleName(tglCfg.Name)
                    local realApi = RealBlock:CreateToggle({
                        Name = tName,
                        Default = tglCfg.Default,
                        Callback = function(state)
                            value = state and true or false
                            if tglCfg.Callback then tglCfg.Callback(state) end
                        end,
                    })
                    api = {}
                    api.Value = value
                    function api:Set(v)
                        value = v and true or false
                        api.Value = value
                        if realApi and realApi.Set then realApi:Set(value) end
                    end
                    function api:SetValue(v) return api:Set(v) end
                    function api:GetValue() return value end
                    function api:Get() return value end
                    register(tglCfg, api)
                    return api
                end

                function WrapperBlock:CreateSlider(sldCfg)
                    local decimals = tonumber(sldCfg.Rounding) or 0
                    if sldCfg.Rounding == nil then
                        local function decOf(x)
                            local s = tostring(x or "")
                            local d = s:match("%.(%d+)")
                            return d and #d or 0
                        end
                        decimals = math.max(decOf(sldCfg.Default), decOf(sldCfg.Min), decOf(sldCfg.Max))
                    end
                    local step = 10 ^ (-math.clamp(decimals, 0, 4))
                    local value = sldCfg.Default
                    local sName = formatModuleName(sldCfg.Name)
                    local realApi = RealBlock:CreateSlider({
                        Name = sName,
                        Min = sldCfg.Min,
                        Max = sldCfg.Max,
                        Default = sldCfg.Default,
                        Step = step,
                        Callback = function(v)
                            value = v
                            if sldCfg.Callback then sldCfg.Callback(v) end
                        end,
                    })
                    local api = {}
                    function api:Set(v)
                        value = v
                        if realApi and realApi.Set then realApi:Set(v) end
                    end
                    function api:SetValue(v) return api:Set(v) end
                    function api:GetValue() return value end
                    function api:Get() return value end
                    register(sldCfg, api)
                    return api
                end

                function WrapperBlock:CreateDropdown(drpCfg)
                    local options = drpCfg.Items or drpCfg.List or drpCfg.Options or {}
                    local defaultValue = drpCfg.Default
                    if type(defaultValue) == "number" then
                        defaultValue = options[defaultValue]
                    end
                    local value = defaultValue
                    local dName = formatModuleName(drpCfg.Name)
                    local realApi = RealBlock:CreateDropdown({
                        Name = dName,
                        Options = options,
                        Default = defaultValue,
                        Multi = drpCfg.Multi,
                        Callback = function(v)
                            if type(v) == "table" and not drpCfg.Multi then
                                v = v[1] or v.Value or v
                            end
                            value = v
                            if drpCfg.Callback then drpCfg.Callback(v) end
                        end,
                    })
                    local api = {}
                    function api:Set(v)
                        value = v
                        if realApi and realApi.Set then realApi:Set(v) end
                    end
                    function api:SetValue(v) return api:Set(v) end
                    function api:GetValue() return value end
                    function api:Get() return value end
                    register(drpCfg, api)
                    return api
                end

                function WrapperBlock:CreateButton(btnCfg)
                    local bName = formatModuleName(btnCfg.Name)
                    return RealBlock:CreateButton({
                        Name = bName,
                        Callback = btnCfg.Callback
                    })
                end

                function WrapperBlock:CreateKeybind(kbCfg)
                    local kName = formatModuleName(kbCfg.Name)
                    local realApi = RealBlock:CreateKeybind({
                        Name = kName,
                        Default = kbCfg.Default,
                        Callback = function(k)
                            if kbCfg.Callback then kbCfg.Callback(k) end
                        end
                    })
                    local api = {}
                    register(kbCfg, api)
                    return api
                end

                return WrapperBlock
            end

            return WrapperTab
        end

        return WrapperWindow
    end

    return WrapperLibrary
end

-- ============================================================
-- 8. UI INITIALIZATION WITH REAL ADAPTED LIBRARY
-- ============================================================
local function loadTrftapLibrary()
    local sources = {
        "https://raw.githubusercontent.com/sladkoeshkaogg-svg/XOCU/refs/heads/main/XOCU%20FAKELIBRORY.lua",
        "https://raw.githubusercontent.com/katnaa-debug/AxiomUI/refs/heads/main/Library.lua",
        "https://raw.githubusercontent.com/sapsikxcters/ranax/main/Library.luau"
    }

    for _, url in ipairs(sources) do
        local ok, res = pcall(function()
            local raw = game:HttpGet(url)
            local fn = loadstring(raw)
            return fn()
        end)
        if ok and type(res) == "table" and type(res.CreateWindow) == "function" then
            return AdaptUILibrary(res)
        end
    end
    return nil
end

local RealLib = loadTrftapLibrary()

if RealLib then
    local Window = RealLib:CreateWindow({
        Title = "Ranax",
        WindowSize = Vector2.new(820, 520),
        Theme = {
            Font = "GothamBold",
            ElementAccent = Color3.fromRGB(110, 100, 255),
            Main = Color3.fromRGB(8, 8, 11),
            Second = Color3.fromRGB(13, 13, 17),
            TextColor = Color3.fromRGB(255, 255, 255),
            CornerRadius = 12
        },
        ToggleKey = Enum.KeyCode.LeftControl,
        OpenKeybind = Enum.KeyCode.LeftControl,
        ShowWatermark = {Enabled = true, Title = true, User = true, FPS = true, Duration = false, Ping = true},
        Watermark = true,
        Transparency = 0.25,
        CustomIcon = "17007876976"
    })

    -- Sync Logo in Menu & Watermark (TRFTAP Moon Logo Asset 17007876976)
    task.spawn(function()
        local core = game:GetService("CoreGui")
        local dash = nil
        for _ = 1, 60 do
            dash = core:FindFirstChild("ModernDashboardGui")
            if dash and dash:FindFirstChild("LogoContainer", true) then break end
            task.wait(0.1)
        end
        if not dash then return end

        local logoContainer = dash:FindFirstChild("LogoContainer", true)
        if logoContainer then
            local defLogo = logoContainer:FindFirstChild("LogoLabel")
            if defLogo then pcall(function() defLogo:Destroy() end) end
            local oldImg = logoContainer:FindFirstChild("LogoImage")
            if oldImg then pcall(function() oldImg:Destroy() end) end
            local oldSkel = logoContainer:FindFirstChild("SkeletonMoon")
            if oldSkel then pcall(function() oldSkel:Destroy() end) end

            local img = Instance.new("ImageLabel")
            img.Name = "SkeletonMoon"
            img.Size = UDim2.new(0, 32, 0, 32)
            img.BackgroundTransparency = 1
            img.Image = "rbxthumb://type=Asset&id=17007876976&w=420&h=420"
            img.LayoutOrder = 1
            img.Parent = logoContainer

            local titleL = Instance.new("TextLabel")
            titleL.Name = "RanaxTitleLabel"
            titleL.Text = "Ranax"
            titleL.Font = Enum.Font.GothamBold
            titleL.TextSize = 16
            titleL.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleL.BackgroundTransparency = 1
            titleL.Size = UDim2.new(0, 80, 1, 0)
            titleL.LayoutOrder = 2
            titleL.Parent = logoContainer
        end

        local function syncWm()
            pcall(function()
                local wmLogo = dash:FindFirstChild("WMLogo", true)
                if wmLogo then
                    wmLogo.Visible = true
                    wmLogo.Image = "rbxthumb://type=Asset&id=17007876976&w=420&h=420"
                end
                local wmTitle = dash:FindFirstChild("WMTitle", true)
                if wmTitle then
                    wmTitle.Text = "Ranax"
                end
            end)
        end
        syncWm()
        while dash and dash.Parent do
            syncWm()
            task.wait(1.5)
        end
    end)

    -- TRFTAP Category Icons (Exact Assets with full rbxassetid support)
    local function addKeybind(block, featName)
        local kb = KeybindRegistry[featName]
        if not kb then return end
        pcall(function()
            block:CreateKeybind({
                Name = kb.Name .. " Keybind",
                Default = kb.Key,
                Callback = function(newKey)
                    kb.Key = newKey
                end
            })
        end)
    end

    local Tabs = {
        Combat   = Window:CreateTab("Combat", true, "17313314020"),       -- Swords icon
        Bridge   = Window:CreateTab("Godbridge", true, "96097489556461"),  -- Defense / Shield icon
        Ores     = Window:CreateTab("Ore Suite", true, "10826661578"),    -- Cube / Ores icon
        Movement = Window:CreateTab("Movement", true, "6023426915"),      -- Speed / Main icon
        World    = Window:CreateTab("World & Farm", true, "2795572803"),  -- Player / World icon
        Visuals  = Window:CreateTab("Visuals", true, "112488114197106")   -- Eye icon
    }

    -- 1. COMBAT TAB
    local CombatLeft = Tabs.Combat:CreateBlock({ Name = "Killaura Reach Engine", Side = "Left" })
    CombatLeft:CreateToggle({
        Name = "Enable Killaura",
        Default = State.Combat.Killaura,
        Callback = function(v) State.Combat.Killaura = v end
    })
    CombatLeft:CreateToggle({
        Name = "Target Strafe (360° Orbit)",
        Default = State.Combat.TargetStrafe,
        Callback = function(v) State.Combat.TargetStrafe = v end
    })
    CombatLeft:CreateSlider({
        Name = "Strafe Radius",
        Min = 3,
        Max = 16,
        Default = State.Combat.StrafeRadius,
        Decimals = 1,
        Callback = function(v) State.Combat.StrafeRadius = v end
    })
    CombatLeft:CreateSlider({
        Name = "Strafe Orbit Speed",
        Min = 1,
        Max = 12,
        Default = State.Combat.StrafeSpeed,
        Decimals = 1,
        Callback = function(v) State.Combat.StrafeSpeed = v end
    })
    CombatLeft:CreateToggle({
        Name = "Anti-Knockback (No Velocity Push)",
        Default = State.Combat.AntiKnockback,
        Callback = function(v) State.Combat.AntiKnockback = v end
    })
    CombatLeft:CreateToggle({
        Name = "Auto Clicker (0.5ms Left Click)",
        Default = State.Combat.AutoClicker,
        Callback = function(v) State.Combat.AutoClicker = v end
    })
    addKeybind(CombatLeft, "AutoClicker")
    CombatLeft:CreateToggle({
        Name = "Auto Bow / Slingshot (Predictive)",
        Default = State.Combat.AutoBow,
        Callback = function(v) State.Combat.AutoBow = v end
    })
    addKeybind(CombatLeft, "AutoBow")
    CombatLeft:CreateToggle({
        Name = "Rotate to Target (Look At)",
        Default = State.Combat.RotateToTarget,
        Callback = function(v) State.Combat.RotateToTarget = v end
    })
    CombatLeft:CreateToggle({
        Name = "Team Check",
        Default = State.Combat.TeamCheck,
        Callback = function(v) State.Combat.TeamCheck = v end
    })
    CombatLeft:CreateToggle({
        Name = "Auto-Equip Sword",
        Default = State.Combat.AutoEquipSword,
        Callback = function(v) State.Combat.AutoEquipSword = v end
    })
    CombatLeft:CreateSlider({
        Name = "Killaura Studs Reach",
        Min = 5,
        Max = 55,
        Default = State.Combat.KillauraRange,
        Decimals = 1,
        Callback = function(v) State.Combat.KillauraRange = v end
    })
    addKeybind(CombatLeft, "Killaura")
    addKeybind(CombatLeft, "TargetStrafe")
    addKeybind(CombatLeft, "AntiKnockback")

    local CombatRight = Tabs.Combat:CreateBlock({ Name = "Hitbox Expander", Side = "Right" })
    CombatRight:CreateToggle({
        Name = "Hitbox Expander",
        Default = State.Combat.HitboxExtender,
        Callback = function(v) State.Combat.HitboxExtender = v end
    })
    CombatRight:CreateSlider({
        Name = "Hitbox Multiplier",
        Min = 2,
        Max = 15,
        Default = State.Combat.HitboxSize,
        Decimals = 1,
        Callback = function(v) State.Combat.HitboxSize = v end
    })
    addKeybind(CombatRight, "HitboxExtender")

    -- 2. ADVANCED GODBRIDGE TAB
    local BridgeLeft = Tabs.Bridge:CreateBlock({ Name = "Godbridge & Walk Scaffold", Side = "Left" })
    BridgeLeft:CreateToggle({
        Name = "Godbridge (3 Place Ahead -> Pickaxe 2 Break)",
        Default = State.Bridge.Godbridge,
        Callback = function(v) State.Bridge.Godbridge = v end
    })
    BridgeLeft:CreateToggle({
        Name = "Walk Scaffold (Instant Place Under Feet)",
        Default = State.Bridge.Scaffold,
        Callback = function(v) State.Bridge.Scaffold = v end
    })
    BridgeLeft:CreateToggle({
        Name = "Air Bridge (Place Without Floor Surface)",
        Default = State.Bridge.AirBridge,
        Callback = function(v) State.Bridge.AirBridge = v end
    })
    BridgeLeft:CreateSlider({
        Name = "Forward Blocks to Place",
        Min = 1,
        Max = 5,
        Default = State.Bridge.PlaceBlocksCount,
        Decimals = 0,
        Callback = function(v) State.Bridge.PlaceBlocksCount = v end
    })
    BridgeLeft:CreateSlider({
        Name = "Behind Blocks to Break",
        Min = 1,
        Max = 4,
        Default = State.Bridge.BreakBlocksCount,
        Decimals = 0,
        Callback = function(v) State.Bridge.BreakBlocksCount = v end
    })
    addKeybind(BridgeLeft, "Godbridge")
    addKeybind(BridgeLeft, "Scaffold")

    local BridgeRight = Tabs.Bridge:CreateBlock({ Name = "Timing & Snapping", Side = "Right" })
    BridgeRight:CreateSlider({
        Name = "Pickaxe Break Burst Time (s)",
        Min = 0.02,
        Max = 0.45,
        Default = State.Bridge.BreakDelay,
        Decimals = 2,
        Callback = function(v) State.Bridge.BreakDelay = v end
    })
    BridgeRight:CreateSlider({
        Name = "Placement Delay (s) -- lower = faster",
        Min = 0.005,
        Max = 0.08,
        Default = State.Bridge.PlaceDelay,
        Decimals = 3,
        Callback = function(v) State.Bridge.PlaceDelay = v end
    })
    BridgeRight:CreateToggle({
        Name = "Snap to 3x3 Grid",
        Default = State.Bridge.SnapGrid,
        Callback = function(v) State.Bridge.SnapGrid = v end
    })
    addKeybind(BridgeRight, "SnapGrid")

    -- 3. ORE SUITE TAB
    local OreLeft = Tabs.Ores:CreateBlock({ Name = "OreAura & ESP", Side = "Left" })
    OreLeft:CreateToggle({
        Name = "OreAura (Auto-Mine Nearby Ores)",
        Default = State.Ores.OreAura,
        Callback = function(v) State.Ores.OreAura = v end
    })
    OreLeft:CreateSlider({
        Name = "OreAura Radius",
        Min = 5,
        Max = 45,
        Default = State.Ores.OreAuraRange,
        Decimals = 1,
        Callback = function(v) State.Ores.OreAuraRange = v end
    })
    addKeybind(OreLeft, "OreAura")
    OreLeft:CreateToggle({
        Name = "OreESP (X-Ray & Distance Tags)",
        Default = State.Ores.OreESP,
        Callback = function(v)
            State.Ores.OreESP = v
            updateOreESP()
        end
    })
    OreLeft:CreateToggle({
        Name = "X-Ray Blocks (See-Through Terrain)",
        Default = State.Ores.XRay,
        Callback = function(v)
            State.Ores.XRay = v
            setWorldXRay(v)
        end
    })
    OreLeft:CreateSlider({
        Name = "X-Ray Transparency",
        Min = 0.2,
        Max = 0.9,
        Default = State.Ores.XRayTransparency,
        Decimals = 2,
        Callback = function(v)
            State.Ores.XRayTransparency = v
            if State.Ores.XRay then
                setWorldXRay(true)
            end
        end
    })

    local OreRight = Tabs.Ores:CreateBlock({ Name = "AI Auto Ore & Kill Farm", Side = "Right" })
    OreRight:CreateToggle({
        Name = "Auto Ore Farm (Ores -> Kill Under -> Return)",
        Default = State.Ores.AutoOreFarm,
        Callback = function(v) State.Ores.AutoOreFarm = v end
    })
    OreRight:CreateToggle({
        Name = "AI Kill Players After Ores (Underneath)",
        Default = State.Ores.AIKillAfterOres,
        Callback = function(v) State.Ores.AIKillAfterOres = v end
    })
    OreRight:CreateToggle({
        Name = "Ignore Lobby / VIP Ores (Match Only)",
        Default = State.Ores.IgnoreLobbyOres,
        Callback = function(v)
            State.Ores.IgnoreLobbyOres = v
            if State.Ores.OreESP then updateOreESP() end
        end
    })
    OreRight:CreateDropdown({
        Name = "Farm Priority",
        List = { "Emerald / Diamond First", "Gold & Up", "All Ores" },
        Default = State.Ores.FarmPriority,
        Callback = function(v) State.Ores.FarmPriority = v end
    })
    OreRight:CreateDropdown({
        Name = "Farm Movement Mode",
        List = { "Glide", "Instant TP" },
        Default = State.Ores.FarmMode,
        Callback = function(v) State.Ores.FarmMode = v end
    })
    OreRight:CreateSlider({
        Name = "Auto Farm Speed (Min 1 - Max 150)",
        Min = 1,
        Max = 150,
        Default = State.Ores.FarmSpeed,
        Decimals = 0,
        Callback = function(v) State.Ores.FarmSpeed = v end
    })
    addKeybind(OreRight, "AutoOreFarm")

    -- 4. MOVEMENT TAB
    local MovLeft = Tabs.Movement:CreateBlock({ Name = "Bypass Flight & Speed", Side = "Left" })
    MovLeft:CreateButton({
        Name = "Activate Skywars Bypass (Reset & Bypass)",
        Callback = function()
            activateSkywarsFullBypass(true)
        end
    })
    MovLeft:CreateButton({
        Name = "Instant Anti-Cheat Bypass (No Reset)",
        Callback = function()
            activateSkywarsFullBypass(false)
        end
    })
    MovLeft:CreateToggle({
        Name = "Fly Bypass (R6 Safe)",
        Default = State.Movement.FlyBypass,
        Callback = function(v) toggleFlyBypass(v, false) end
    })
    MovLeft:CreateButton({
        Name = "Reset Character & Enable Fly",
        Callback = function()
            toggleFlyBypass(true, true)
        end
    })
    MovLeft:CreateSlider({
        Name = "Fly Speed",
        Min = 1,
        Max = 150,
        Default = State.Movement.FlySpeed,
        Decimals = 0,
        Callback = function(v) State.Movement.FlySpeed = v end
    })
    MovLeft:CreateToggle({
        Name = "CFrame Speed Bypass (Undetected)",
        Default = State.Movement.SpeedBypass,
        Callback = function(v) State.Movement.SpeedBypass = v end
    })
    MovLeft:CreateSlider({
        Name = "Speed Multiplier",
        Min = 0.5,
        Max = 6.0,
        Default = State.Movement.SpeedMultiplier,
        Decimals = 1,
        Callback = function(v) State.Movement.SpeedMultiplier = v end
    })
    addKeybind(MovLeft, "FlyBypass")
    addKeybind(MovLeft, "SpeedBypass")

    local MovRight = Tabs.Movement:CreateBlock({ Name = "Anti-Void & Safety", Side = "Right" })
    MovRight:CreateToggle({
        Name = "Anti-Void Recovery (Skywars Classic)",
        Default = State.Movement.AntiVoid,
        Callback = function(v) State.Movement.AntiVoid = v; syncAntiVoidBarrier() end
    })
    MovRight:CreateDropdown({
        Name = "Anti-Void Mode",
        List = { "Solid Barrier + Bounce", "Teleport to Safe Ground", "Velocity Bounce" },
        Default = State.Movement.AntiVoidMode,
        Callback = function(v) State.Movement.AntiVoidMode = v; syncAntiVoidBarrier() end
    })
    MovRight:CreateSlider({
        Name = "Anti-Void Depth Below Islands",
        Min = 5,
        Max = 25,
        Default = State.Movement.AntiVoidOffset,
        Decimals = 0,
        Callback = function(v) State.Movement.AntiVoidOffset = v; syncAntiVoidBarrier() end
    })
    MovRight:CreateToggle({
        Name = "NoFall Damage Bypass",
        Default = State.Movement.NoFallDamage,
        Callback = function(v) State.Movement.NoFallDamage = v end
    })
    MovRight:CreateToggle({
        Name = "Infinite Jump",
        Default = State.Movement.InfiniteJump,
        Callback = function(v) State.Movement.InfiniteJump = v end
    })
    MovRight:CreateToggle({
        Name = "Noclip Walls",
        Default = State.Movement.Noclip,
        Callback = function(v) State.Movement.Noclip = v end
    })
    addKeybind(MovRight, "AntiVoid")
    addKeybind(MovRight, "NoFallDamage")
    addKeybind(MovRight, "InfiniteJump")
    addKeybind(MovRight, "Noclip")

    -- 5. WORLD, VIP BYPASSES & TELEPORTS TAB
    local FarmLeft = Tabs.World:CreateBlock({ Name = "Skywars Classic Bypasses & Perks", Side = "Left" })
    FarmLeft:CreateButton({
        Name = "Activate Full Skywars Bypass (Reset & Bypass)",
        Callback = function()
            activateSkywarsFullBypass(true)
        end
    })
    FarmLeft:CreateButton({
        Name = "Instant AntiSploit Bypass (No Reset)",
        Callback = function()
            activateSkywarsFullBypass(false)
        end
    })
    FarmLeft:CreateToggle({
        Name = "Bypass Client Anti-Cheat (AntiSploit)",
        Default = State.World.BypassAntiCheat,
        Callback = function(v)
            State.World.BypassAntiCheat = v
            if v then disableClientAntiCheat() end
        end
    })
    FarmLeft:CreateButton({
        Name = "Unlock VIP & Mega VIP Doors",
        Callback = function() unlockVIPDoors() end
    })
    FarmLeft:CreateButton({
        Name = "Claim Free Armor & VIP / Undertale Gear",
        Callback = function() claimFreeLobbyArmorAndItems() end
    })
    FarmLeft:CreateToggle({
        Name = "Auto Claim Free Armor in Lobby",
        Default = State.World.AutoFreeArmor,
        Callback = function(v) State.World.AutoFreeArmor = v end
    })
    FarmLeft:CreateToggle({
        Name = "Auto Coin Farm (Safe Map Collector)",
        Default = State.World.AutoCoinFarm,
        Callback = function(v) State.World.AutoCoinFarm = v end
    })
    FarmLeft:CreateToggle({
        Name = "Coin Magnet (Safe Touch Collect)",
        Default = State.World.MagnetItems,
        Callback = function(v) State.World.MagnetItems = v end
    })
    FarmLeft:CreateToggle({
        Name = "Mine Aura (All Match Blocks)",
        Default = State.World.MineAura,
        Callback = function(v) State.World.MineAura = v end
    })
    FarmLeft:CreateSlider({
        Name = "Mining Range",
        Min = 5,
        Max = 40,
        Default = State.World.MineAuraRange,
        Decimals = 1,
        Callback = function(v) State.World.MineAuraRange = v end
    })

    local FarmRight = Tabs.World:CreateBlock({ Name = "Auto Win & Classic Teleports", Side = "Right" })
    FarmRight:CreateToggle({
        Name = "Auto Kill All Players (Match Auto Win)",
        Default = State.Farm.AutoKillAll,
        Callback = function(v) State.Farm.AutoKillAll = v end
    })
    addKeybind(FarmRight, "AutoKillAll")
    FarmRight:CreateToggle({
        Name = "Auto Farm Wins (Mega VIP Pad Loop)",
        Default = State.Farm.AutoWinPad,
        Callback = function(v) State.Farm.AutoWinPad = v end
    })
    FarmRight:CreateButton({
        Name = "TP -> Center Island (Mid)",
        Callback = function() teleportToWaypoint("CenterIsland") end
    })
    FarmRight:CreateButton({
        Name = "TP -> Nearest Match Player",
        Callback = function() teleportToWaypoint("NearestPlayer") end
    })
    FarmRight:CreateButton({
        Name = "TP -> Mega VIP Room",
        Callback = function() teleportToWaypoint("MegaVIPRoom") end
    })
    FarmRight:CreateButton({
        Name = "TP -> VIP Room",
        Callback = function() teleportToWaypoint("VIPRoom") end
    })
    FarmRight:CreateButton({
        Name = "TP -> Spawn Lobby",
        Callback = function() teleportToWaypoint("SpawnLobby") end
    })
    FarmRight:CreateButton({
        Name = "Save Custom Position",
        Callback = function() teleportToWaypoint("SavePos") end
    })
    FarmRight:CreateButton({
        Name = "TP -> Saved Position",
        Callback = function() teleportToWaypoint("LoadPos") end
    })
    FarmRight:CreateButton({
        Name = "Rejoin Server",
        Callback = function() rejoinServer() end
    })

    -- 6. VISUALS TAB
    local VisLeft = Tabs.Visuals:CreateBlock({ Name = "ESP Enhancements", Side = "Left" })
    VisLeft:CreateToggle({
        Name = "Player Chams / ESP",
        Default = State.Visuals.PlayerESP,
        Callback = function(v)
            State.Visuals.PlayerESP = v
            updatePlayerESP()
        end
    })
    VisLeft:CreateToggle({
        Name = "Ore ESP Highlights",
        Default = State.Ores.OreESP,
        Callback = function(v)
            State.Ores.OreESP = v
            updateOreESP()
        end
    })

    -- ============================================================
    -- WATERMARK MENU CONTROLLER (1:1 TRFTAP ARCHITECTURE)
    -- ============================================================
    task.spawn(function()
        local dash, wmBar, wmHolder, wrapper
        for _ = 1, 80 do
            dash = CoreGui:FindFirstChild("ModernDashboardGui")
            wmBar = dash and dash:FindFirstChild("WatermarkBar", true)
            wmHolder = dash and dash:FindFirstChild("WatermarkHolder", true)
            if dash and wmBar and wmHolder then break end
            task.wait(0.1)
        end
        if not dash or not wmBar or not wmHolder then return end

        dash.Enabled = true
        dash:GetPropertyChangedSignal("Enabled"):Connect(function()
            if not dash.Enabled then dash.Enabled = true end
        end)

        pcall(function()
            wmBar.Size = UDim2.new(0, 0, 1, 0)
            wmBar.AutomaticSize = Enum.AutomaticSize.X
        end)

        local isAnimating = false
        local function toggleMenu()
            if isAnimating then return end
            isAnimating = true
            pcall(function()
                if not wrapper then
                    wrapper = dash:FindFirstChild("Wrapper", true)
                end
                if not wrapper then
                    isAnimating = false
                    return
                end

                local contentWrapper = wrapper:FindFirstChild("ContentWrapper", true) or wrapper

                if wrapper.Visible then
                    local tOut = TweenService:Create(contentWrapper, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                        Position = UDim2.new(0, 0, 0, 16)
                    })
                    tOut:Play()
                    tOut.Completed:Connect(function()
                        wrapper.Visible = false
                        isAnimating = false
                    end)
                else
                    wrapper.Visible = true
                    contentWrapper.Position = UDim2.new(0, 0, 0, 16)
                    local tIn = TweenService:Create(contentWrapper, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 0, 0, 0)
                    })
                    tIn:Play()
                    tIn.Completed:Connect(function()
                        isAnimating = false
                    end)
                end
            end)
            task.delay(0.35, function() isAnimating = false end)
        end

        local pressStartPos = nil
        local pressStartTime = 0

        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                pressStartPos = input.Position
                pressStartTime = tick()
            end
        end

        local function onInputEnded(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if pressStartPos then
                    local moveDist = (Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(pressStartPos.X, pressStartPos.Y)).Magnitude
                    local elapsed = tick() - pressStartTime
                    pressStartPos = nil
                    if moveDist < 6 and elapsed < 0.5 then
                        toggleMenu()
                    end
                end
            end
        end

        wmBar.InputBegan:Connect(onInputBegan)
        wmBar.InputEnded:Connect(onInputEnded)
        wmHolder.InputBegan:Connect(onInputBegan)
        wmHolder.InputEnded:Connect(onInputEnded)

        for _, child in ipairs(wmBar:GetChildren()) do
            if child:IsA("GuiObject") then
                child.InputBegan:Connect(onInputBegan)
                child.InputEnded:Connect(onInputEnded)
            end
        end
        wmBar.ChildAdded:Connect(function(child)
            if child:IsA("GuiObject") then
                child.InputBegan:Connect(onInputBegan)
                child.InputEnded:Connect(onInputEnded)
            end
        end)

        -- Force Native PC Mode Layout (Unscaled 1.0, 820x520 centered)
        pcall(function()
            local sc = wrapper:FindFirstChildOfClass("UIScale")
            if not sc then
                sc = Instance.new("UIScale")
                sc.Parent = wrapper
            end
            sc.Scale = 1.0
            wrapper.Size = UDim2.new(0, 820, 0, 520)
            wrapper.Position = UDim2.new(0.5, 0, 0.5, 0)
            wrapper.Active = true
            _G.Ranax_SelectedLayout = "pc"
        end)

        -- Persistent PC size lock (prevents mobile layout from blowing it up)
        task.spawn(function()
            while wrapper and wrapper.Parent do
                pcall(function()
                    local sc = wrapper:FindFirstChildOfClass("UIScale")
                    if sc and sc.Scale ~= 1.0 then sc.Scale = 1.0 end
                    if wrapper.Size.X.Offset > 850 or wrapper.Size.Y.Offset > 550 then
                        wrapper.Size = UDim2.new(0, 820, 0, 520)
                    end
                end)
                task.wait(1.5)
            end
        end)

        -- LeftControl Keybind to Toggle Menu
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightShift) then
                toggleMenu()
            end
        end)
    end)

else
-- =====================================================================
-- RANAX SUPREME GUI -- TAM TRFTAP PC MODU (Kutuphane yuklenemeyince)
-- Sidebar + 2-sutun icerik, toggle/slider, animasyonlu tab gecisi
-- =====================================================================
do
    local SGui = Instance.new("ScreenGui")
    SGui.Name = "RanaxSkywarsPC"
    SGui.ResetOnSpawn = false
    SGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SGui.IgnoreGuiInset = true
    pcall(function() SGui.Parent = CoreGui end)
    if not SGui.Parent then SGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local C = {
        Bg        = Color3.fromRGB(8,   8,  12),
        Sidebar   = Color3.fromRGB(12,  12, 17),
        Card      = Color3.fromRGB(17,  17, 24),
        Row       = Color3.fromRGB(22,  22, 32),
        Accent    = Color3.fromRGB(105, 95, 240),
        AccentHi  = Color3.fromRGB(130,120, 255),
        AccentOff = Color3.fromRGB(40,  40,  58),
        Text      = Color3.fromRGB(230,228, 255),
        TextMuted = Color3.fromRGB(130,128, 160),
        Border    = Color3.fromRGB(35,  34,  55),
        TitleBar  = Color3.fromRGB(10,  10,  15),
    }

    local function corner(p, r) local c = Instance.new("UICorner",p); c.CornerRadius = UDim.new(0,r or 8); return c end
    local function stroke(p, col, t) local s = Instance.new("UIStroke",p); s.Color = col; s.Thickness = t or 1; return s end
    local function pad(p, l,r2,t2,b)
        local u = Instance.new("UIPadding",p)
        u.PaddingLeft=UDim.new(0,l or 0); u.PaddingRight=UDim.new(0,r2 or 0)
        u.PaddingTop=UDim.new(0,t2 or 0); u.PaddingBottom=UDim.new(0,b or 0)
    end

    local W, H = 820, 520
    local Win = Instance.new("Frame", SGui)
    Win.Name = "Window"
    Win.Size = UDim2.new(0, W, 0, H)
    Win.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    Win.BackgroundColor3 = C.Bg
    Win.BorderSizePixel = 0
    Win.Active = true
    Win.Draggable = true
    Win.ClipsDescendants = true
    corner(Win, 14)
    stroke(Win, C.Accent, 1.5)

    -- Title bar
    local TB = Instance.new("Frame", Win)
    TB.Size = UDim2.new(1, 0, 0, 46)
    TB.BackgroundColor3 = C.TitleBar
    TB.BorderSizePixel = 0
    corner(TB, 14)

    local TBLine = Instance.new("Frame", TB)
    TBLine.Size = UDim2.new(1, 0, 0, 2)
    TBLine.Position = UDim2.new(0, 0, 1, -2)
    TBLine.BackgroundColor3 = C.Accent
    TBLine.BorderSizePixel = 0

    local LogoImg = Instance.new("ImageLabel", TB)
    LogoImg.Size = UDim2.new(0, 28, 0, 28)
    LogoImg.Position = UDim2.new(0, 12, 0.5, -14)
    LogoImg.BackgroundTransparency = 1
    LogoImg.Image = "rbxthumb://type=Asset&id=17007876976&w=420&h=420"

    local TitleL = Instance.new("TextLabel", TB)
    TitleL.Text = "Ranax"
    TitleL.Font = Enum.Font.GothamBold
    TitleL.TextSize = 16
    TitleL.TextColor3 = C.Text
    TitleL.Position = UDim2.new(0, 48, 0, 0)
    TitleL.Size = UDim2.new(1, -150, 1, 0)
    TitleL.BackgroundTransparency = 1
    TitleL.TextXAlignment = Enum.TextXAlignment.Left

    local WMLbl = Instance.new("TextLabel", TB)
    WMLbl.Text = "Ranax"
    WMLbl.Font = Enum.Font.GothamMedium
    WMLbl.TextSize = 11
    WMLbl.TextColor3 = C.TextMuted
    WMLbl.Size = UDim2.new(0, 160, 1, 0)
    WMLbl.Position = UDim2.new(1, -200, 0, 0)
    WMLbl.BackgroundTransparency = 1
    WMLbl.TextXAlignment = Enum.TextXAlignment.Right

    local XBtn = Instance.new("TextButton", TB)
    XBtn.Text = "X"
    XBtn.Size = UDim2.new(0, 36, 0, 36)
    XBtn.Position = UDim2.new(1, -42, 0, 5)
    XBtn.BackgroundTransparency = 1
    XBtn.TextColor3 = C.TextMuted
    XBtn.Font = Enum.Font.GothamBold
    XBtn.TextSize = 15
    XBtn.AutoButtonColor = false
    XBtn.MouseButton1Click:Connect(function() Win.Visible = false end)
    XBtn.MouseEnter:Connect(function() XBtn.TextColor3 = Color3.fromRGB(255,80,80) end)
    XBtn.MouseLeave:Connect(function() XBtn.TextColor3 = C.TextMuted end)

    -- Sidebar
    local SBW = 160
    local Sidebar = Instance.new("Frame", Win)
    Sidebar.Size = UDim2.new(0, SBW, 1, -46)
    Sidebar.Position = UDim2.new(0, 0, 0, 46)
    Sidebar.BackgroundColor3 = C.Sidebar
    Sidebar.BorderSizePixel = 0

    local SBBorder = Instance.new("Frame", Sidebar)
    SBBorder.Size = UDim2.new(0, 1, 1, 0)
    SBBorder.Position = UDim2.new(1, -1, 0, 0)
    SBBorder.BackgroundColor3 = C.Border
    SBBorder.BorderSizePixel = 0

    local SBList = Instance.new("UIListLayout", Sidebar)
    SBList.Padding = UDim.new(0, 1)
    pad(Sidebar, 0, 1, 6, 6)

    -- Content area
    local ContentArea = Instance.new("Frame", Win)
    ContentArea.Size = UDim2.new(1, -SBW, 1, -46)
    ContentArea.Position = UDim2.new(0, SBW, 0, 46)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0

    local allTabs = {}
    local activePage = nil

    local function switchTab(entry)
        if activePage then activePage.Visible = false end
        activePage = entry.page
        activePage.Visible = true
        for _, e in ipairs(allTabs) do
            local on = (e == entry)
            e.btn.BackgroundColor3 = on and Color3.fromRGB(20,18,36) or C.Sidebar
            e.indicator.Visible = on
            e.iconLbl.TextColor3 = on and C.AccentHi or C.TextMuted
            e.nameLbl.TextColor3 = on and C.Text or C.TextMuted
        end
    end

    local function createTab(icon, name)
        local btn = Instance.new("TextButton", Sidebar)
        btn.Size = UDim2.new(1, 0, 0, 60)
        btn.BackgroundColor3 = C.Sidebar
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false

        local ind = Instance.new("Frame", btn)
        ind.Size = UDim2.new(0, 3, 0.7, 0)
        ind.Position = UDim2.new(0, 0, 0.15, 0)
        ind.BackgroundColor3 = C.Accent
        ind.BorderSizePixel = 0
        corner(ind, 2)
        ind.Visible = false

        local iconLbl = Instance.new("TextLabel", btn)
        iconLbl.Text = icon
        iconLbl.Font = Enum.Font.GothamBold
        iconLbl.TextSize = 22
        iconLbl.Size = UDim2.new(1, 0, 0, 30)
        iconLbl.Position = UDim2.new(0, 0, 0, 8)
        iconLbl.BackgroundTransparency = 1
        iconLbl.TextColor3 = C.TextMuted

        local nameLbl = Instance.new("TextLabel", btn)
        nameLbl.Text = name
        nameLbl.Font = Enum.Font.GothamMedium
        nameLbl.TextSize = 10
        nameLbl.Size = UDim2.new(1, 0, 0, 14)
        nameLbl.Position = UDim2.new(0, 0, 0, 38)
        nameLbl.BackgroundTransparency = 1
        nameLbl.TextColor3 = C.TextMuted

        btn.MouseEnter:Connect(function()
            if ind.Visible then return end
            btn.BackgroundColor3 = Color3.fromRGB(18,16,30)
        end)
        btn.MouseLeave:Connect(function()
            if ind.Visible then return end
            btn.BackgroundColor3 = C.Sidebar
        end)

        local page = Instance.new("ScrollingFrame", ContentArea)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = C.Accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        pad(page, 14, 14, 10, 10)

        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 10)

        local entry = { btn = btn, page = page, indicator = ind, iconLbl = iconLbl, nameLbl = nameLbl }
        table.insert(allTabs, entry)
        btn.MouseButton1Click:Connect(function() switchTab(entry) end)

        local function createBlock(blockName)
            local card = Instance.new("Frame", page)
            card.BackgroundColor3 = C.Card
            card.BorderSizePixel = 0
            card.Size = UDim2.new(1, 0, 0, 0)
            card.AutomaticSize = Enum.AutomaticSize.Y
            corner(card, 10)
            stroke(card, C.Border, 1)
            pad(card, 12, 12, 10, 12)

            local cardLayout = Instance.new("UIListLayout", card)
            cardLayout.Padding = UDim.new(0, 7)

            local bHeader = Instance.new("TextLabel", card)
            bHeader.Text = blockName
            bHeader.Font = Enum.Font.GothamBold
            bHeader.TextSize = 12
            bHeader.TextColor3 = C.Accent
            bHeader.Size = UDim2.new(1, 0, 0, 18)
            bHeader.BackgroundTransparency = 1
            bHeader.TextXAlignment = Enum.TextXAlignment.Left

            local sep = Instance.new("Frame", card)
            sep.Size = UDim2.new(1, 0, 0, 1)
            sep.BackgroundColor3 = C.Border
            sep.BorderSizePixel = 0

            local Block = {}

            function Block:CreateToggle(cfg)
                local row = Instance.new("Frame", card)
                row.Size = UDim2.new(1, 0, 0, 36)
                row.BackgroundColor3 = C.Row
                row.BorderSizePixel = 0
                corner(row, 7)

                local lbl = Instance.new("TextLabel", row)
                lbl.Text = "  " .. cfg.Name
                lbl.Font = Enum.Font.GothamMedium
                lbl.TextSize = 13
                lbl.TextColor3 = C.Text
                lbl.Size = UDim2.new(1, -125, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                -- Keybind Button (For all except ESP)
                local featKey = cfg.FeatKey
                local kbBtn = nil
                if featKey and KeybindRegistry[featKey] then
                    local kbData = KeybindRegistry[featKey]
                    kbBtn = Instance.new("TextButton", row)
                    kbBtn.Size = UDim2.new(0, 48, 0, 22)
                    kbBtn.Position = UDim2.new(1, -110, 0.5, -11)
                    kbBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                    kbBtn.Text = kbData.Key and kbData.Key.Name or "[None]"
                    kbBtn.TextColor3 = C.AccentHi
                    kbBtn.Font = Enum.Font.GothamBold
                    kbBtn.TextSize = 11
                    corner(kbBtn, 5)

                    local listening = false
                    kbBtn.MouseButton1Click:Connect(function()
                        if listening then return end
                        listening = true
                        kbBtn.Text = "..."
                        kbBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
                        local conn
                        conn = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                conn:Disconnect()
                                listening = false
                                if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
                                    kbData.Key = nil
                                    kbBtn.Text = "[None]"
                                else
                                    kbData.Key = input.KeyCode
                                    kbBtn.Text = input.KeyCode.Name
                                end
                                kbBtn.TextColor3 = C.AccentHi
                            end
                        end)
                    end)
                end

                local track = Instance.new("TextButton", row)
                track.Size = UDim2.new(0, 44, 0, 22)
                track.Position = UDim2.new(1, -52, 0.5, -11)
                track.BackgroundColor3 = cfg.Default and C.Accent or C.AccentOff
                track.Text = ""
                track.AutoButtonColor = false
                corner(track, 11)

                local thumb = Instance.new("Frame", track)
                thumb.Size = UDim2.new(0, 16, 0, 16)
                thumb.Position = cfg.Default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
                thumb.BorderSizePixel = 0
                corner(thumb, 8)

                local state = cfg.Default or false
                local function setState(newVal)
                    state = newVal
                    local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
                    TweenService:Create(track, ti, {BackgroundColor3 = state and C.Accent or C.AccentOff}):Play()
                    TweenService:Create(thumb, ti, {Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
                    if cfg.Callback then cfg.Callback(state) end
                end

                track.MouseButton1Click:Connect(function()
                    setState(not state)
                end)

                if featKey then
                    ModuleToggleUIs[featKey] = { Set = setState }
                end
            end

            function Block:CreateSlider(cfg2)
                local slRow = Instance.new("Frame", card)
                slRow.Size = UDim2.new(1, 0, 0, 54)
                slRow.BackgroundColor3 = C.Row
                slRow.BorderSizePixel = 0
                corner(slRow, 7)
                pad(slRow, 10, 10, 6, 6)

                local slLayout = Instance.new("UIListLayout", slRow)
                slLayout.Padding = UDim.new(0, 5)

                local topRow = Instance.new("Frame", slRow)
                topRow.Size = UDim2.new(1, 0, 0, 16)
                topRow.BackgroundTransparency = 1
                topRow.BorderSizePixel = 0

                local topLayout = Instance.new("UIListLayout", topRow)
                topLayout.FillDirection = Enum.FillDirection.Horizontal
                topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

                local slLbl = Instance.new("TextLabel", topRow)
                slLbl.Text = cfg2.Name
                slLbl.Font = Enum.Font.GothamMedium
                slLbl.TextSize = 12
                slLbl.TextColor3 = C.Text
                slLbl.Size = UDim2.new(0.72, 0, 1, 0)
                slLbl.BackgroundTransparency = 1
                slLbl.TextXAlignment = Enum.TextXAlignment.Left

                local initVal = cfg2.Default or cfg2.Min or 0
                local slVal = Instance.new("TextLabel", topRow)
                slVal.Text = tostring(initVal)
                slVal.Font = Enum.Font.GothamBold
                slVal.TextSize = 12
                slVal.TextColor3 = C.AccentHi
                slVal.Size = UDim2.new(0.28, 0, 1, 0)
                slVal.BackgroundTransparency = 1
                slVal.TextXAlignment = Enum.TextXAlignment.Right

                local track2 = Instance.new("Frame", slRow)
                track2.Size = UDim2.new(1, 0, 0, 6)
                track2.BackgroundColor3 = C.AccentOff
                track2.BorderSizePixel = 0
                corner(track2, 3)

                local initFrac = (initVal - cfg2.Min) / math.max(cfg2.Max - cfg2.Min, 0.001)
                local fill = Instance.new("Frame", track2)
                fill.Size = UDim2.new(initFrac, 0, 1, 0)
                fill.BackgroundColor3 = C.Accent
                fill.BorderSizePixel = 0
                corner(fill, 3)

                local thumb2 = Instance.new("Frame", track2)
                thumb2.Size = UDim2.new(0, 12, 0, 12)
                thumb2.Position = UDim2.new(initFrac, -6, 0.5, -6)
                thumb2.BackgroundColor3 = Color3.fromRGB(255,255,255)
                thumb2.BorderSizePixel = 0
                corner(thumb2, 6)

                local dragging = false
                local function updateSlider(absX)
                    local rPos = track2.AbsolutePosition.X
                    local rSize = track2.AbsoluteSize.X
                    if rSize == 0 then return end
                    local t = math.clamp((absX - rPos) / rSize, 0, 1)
                    local newVal = cfg2.Min + (cfg2.Max - cfg2.Min) * t
                    local dec = cfg2.Decimals or 0
                    newVal = math.floor(newVal * (10^dec) + 0.5) / (10^dec)
                    slVal.Text = tostring(newVal)
                    fill.Size = UDim2.new(t, 0, 1, 0)
                    thumb2.Position = UDim2.new(t, -6, 0.5, -6)
                    if cfg2.Callback then cfg2.Callback(newVal) end
                end

                track2.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; updateSlider(i.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(i.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
            end

            function Block:CreateButton(cfg3)
                local bRow = Instance.new("TextButton", card)
                bRow.Size = UDim2.new(1, 0, 0, 34)
                bRow.BackgroundColor3 = C.Accent
                bRow.BorderSizePixel = 0
                bRow.Text = cfg3.Name
                bRow.Font = Enum.Font.GothamBold
                bRow.TextColor3 = Color3.fromRGB(255,255,255)
                bRow.TextSize = 12
                bRow.AutoButtonColor = false
                corner(bRow, 7)
                bRow.MouseButton1Click:Connect(function()
                    if cfg3.Callback then cfg3.Callback() end
                end)
            end

            return Block
        end

        local Tab = {}
        function Tab:CreateBlock(cfg) return createBlock(cfg.Name or "") end
        return Tab, entry
    end

    -- Tabs
    local combatTab, combatEntry = createTab("[/]", "Combat")
    local bridgeTab, bridgeEntry = createTab("[#]", "Bridge")
    local oresTab,   oresEntry   = createTab("[*]", "Ores")
    local movTab,    movEntry    = createTab("[^]", "Movement")
    local visTab,    visEntry    = createTab("[O]", "Visuals")
    local farmTab,   farmEntry   = createTab("[!]", "Farm")

    -- COMBAT
    local CL = combatTab:CreateBlock("Killaura Reach Engine")
    CL:CreateToggle({ Name = "Enable Killaura", FeatKey = "Killaura",        Default = State.Combat.Killaura,        Callback = function(v) State.Combat.Killaura = v end })
    CL:CreateToggle({ Name = "Target Strafe (Orbit)", FeatKey = "TargetStrafe", Default = State.Combat.TargetStrafe, Callback = function(v) State.Combat.TargetStrafe = v end })
    CL:CreateToggle({ Name = "Anti-Knockback", FeatKey = "AntiKnockback",    Default = State.Combat.AntiKnockback,   Callback = function(v) State.Combat.AntiKnockback = v end })
    CL:CreateToggle({ Name = "Auto Clicker (0.5ms)", FeatKey = "AutoClicker", Default = State.Combat.AutoClicker, Callback = function(v) State.Combat.AutoClicker = v end })
    CL:CreateToggle({ Name = "Auto Bow / Slingshot", FeatKey = "AutoBow",    Default = State.Combat.AutoBow,     Callback = function(v) State.Combat.AutoBow = v end })
    CL:CreateToggle({ Name = "Rotate to Target", FeatKey = "RotateToTarget", Default = State.Combat.RotateToTarget,   Callback = function(v) State.Combat.RotateToTarget = v end })
    CL:CreateToggle({ Name = "Team Check", FeatKey = "TeamCheck",            Default = State.Combat.TeamCheck,        Callback = function(v) State.Combat.TeamCheck = v end })
    CL:CreateToggle({ Name = "Auto-Equip Sword", FeatKey = "AutoEquipSword", Default = State.Combat.AutoEquipSword,   Callback = function(v) State.Combat.AutoEquipSword = v end })
    CL:CreateSlider({ Name = "Studs Reach", Min = 5, Max = 55, Default = State.Combat.KillauraRange, Decimals = 0, Callback = function(v) State.Combat.KillauraRange = v end })

    local CR = combatTab:CreateBlock("Hitbox Expander")
    CR:CreateToggle({ Name = "Hitbox Expander", FeatKey = "HitboxExtender",  Default = State.Combat.HitboxExtender,   Callback = function(v) State.Combat.HitboxExtender = v end })
    CR:CreateSlider({ Name = "Hitbox Size", Min = 2, Max = 15, Default = State.Combat.HitboxSize, Decimals = 0, Callback = function(v) State.Combat.HitboxSize = v end })

    -- BRIDGE
    local BL = bridgeTab:CreateBlock("Godbridge & Walk Scaffold")
    BL:CreateToggle({ Name = "Godbridge (3 Place -> 2 Break)", FeatKey = "Godbridge", Default = State.Bridge.Godbridge, Callback = function(v) State.Bridge.Godbridge = v end })
    BL:CreateToggle({ Name = "Walk Scaffold (Under Feet)", FeatKey = "Scaffold", Default = State.Bridge.Scaffold, Callback = function(v) State.Bridge.Scaffold = v end })
    BL:CreateToggle({ Name = "Air Bridge (Place in Air)", Default = State.Bridge.AirBridge, Callback = function(v) State.Bridge.AirBridge = v end })
    BL:CreateSlider({ Name = "Forward Blocks", Min = 1, Max = 5, Default = State.Bridge.PlaceBlocksCount, Decimals = 0, Callback = function(v) State.Bridge.PlaceBlocksCount = v end })
    BL:CreateSlider({ Name = "Behind Blocks",  Min = 1, Max = 4, Default = State.Bridge.BreakBlocksCount, Decimals = 0, Callback = function(v) State.Bridge.BreakBlocksCount = v end })

    local BR = bridgeTab:CreateBlock("Timing & Snapping")
    BR:CreateSlider({ Name = "Pickaxe Break Time (s)", Min = 0.02, Max = 0.45, Default = State.Bridge.BreakDelay, Decimals = 2, Callback = function(v) State.Bridge.BreakDelay = v end })
    BR:CreateSlider({ Name = "Place Delay (s)",        Min = 0.005, Max = 0.08, Default = State.Bridge.PlaceDelay, Decimals = 3, Callback = function(v) State.Bridge.PlaceDelay = v end })
    BR:CreateToggle({ Name = "Snap to 3x3 Grid", FeatKey = "SnapGrid",   Default = State.Bridge.SnapGrid, Callback = function(v) State.Bridge.SnapGrid = v end })

    -- ORES
    local OL = oresTab:CreateBlock("OreAura & ESP")
    OL:CreateToggle({ Name = "OreAura (Auto-Mine Nearby)", FeatKey = "OreAura", Default = State.Ores.OreAura, Callback = function(v) State.Ores.OreAura = v end })
    OL:CreateSlider({ Name = "OreAura Radius", Min = 5, Max = 45, Default = State.Ores.OreAuraRange, Decimals = 0, Callback = function(v) State.Ores.OreAuraRange = v end })
    OL:CreateToggle({ Name = "OreESP (X-Ray & Tags)", Default = State.Ores.OreESP, Callback = function(v) State.Ores.OreESP = v; updateOreESP() end })
    OL:CreateToggle({ Name = "X-Ray Blocks (See-Through)", Default = State.Ores.XRay, Callback = function(v) State.Ores.XRay = v; setWorldXRay(v) end })

    local OR2 = oresTab:CreateBlock("AI Auto Ore & Kill Farm")
    OR2:CreateToggle({ Name = "Auto Ore Farm (AI Cycle)", FeatKey = "AutoOreFarm", Default = State.Ores.AutoOreFarm, Callback = function(v) State.Ores.AutoOreFarm = v end })
    OR2:CreateToggle({ Name = "AI Kill Players After Ores (Under)", Default = State.Ores.AIKillAfterOres, Callback = function(v) State.Ores.AIKillAfterOres = v end })
    OR2:CreateToggle({ Name = "Ignore Lobby / VIP Ores", Default = State.Ores.IgnoreLobbyOres, Callback = function(v) State.Ores.IgnoreLobbyOres = v; if State.Ores.OreESP then updateOreESP() end end })
    OR2:CreateSlider({ Name = "Auto Farm Speed (1 - 150)", Min = 1, Max = 150, Default = State.Ores.FarmSpeed, Decimals = 0, Callback = function(v) State.Ores.FarmSpeed = v end })

    -- MOVEMENT
    local ML = movTab:CreateBlock("Fly & Speed Bypass")
    ML:CreateButton({ Name = "Activate Skywars Bypass (Reset)", Callback = function() activateSkywarsFullBypass(true) end })
    ML:CreateButton({ Name = "Instant AntiSploit Bypass", Callback = function() activateSkywarsFullBypass(false) end })
    ML:CreateToggle({ Name = "Fly Bypass (R6 Safe)", FeatKey = "FlyBypass", Default = State.Movement.FlyBypass, Callback = function(v) toggleFlyBypass(v, false) end })
    ML:CreateButton({ Name = "Reset & Enable Fly", Callback = function() toggleFlyBypass(true, true) end })
    ML:CreateSlider({ Name = "Fly Speed", Min = 1, Max = 150, Default = State.Movement.FlySpeed, Decimals = 0, Callback = function(v) State.Movement.FlySpeed = v end })
    ML:CreateToggle({ Name = "CFrame Speed Bypass", FeatKey = "SpeedBypass", Default = State.Movement.SpeedBypass, Callback = function(v) State.Movement.SpeedBypass = v end })
    ML:CreateSlider({ Name = "Speed Multiplier", Min = 0.5, Max = 6.0, Default = State.Movement.SpeedMultiplier, Decimals = 1, Callback = function(v) State.Movement.SpeedMultiplier = v end })

    local MR = movTab:CreateBlock("Anti-Void & Safety")
    MR:CreateToggle({ Name = "Anti-Void Recovery", FeatKey = "AntiVoid",   Default = State.Movement.AntiVoid,     Callback = function(v) State.Movement.AntiVoid = v; syncAntiVoidBarrier() end })
    MR:CreateSlider({ Name = "Anti-Void Depth Below Islands", Min = 5, Max = 25, Default = State.Movement.AntiVoidOffset, Decimals = 0, Callback = function(v) State.Movement.AntiVoidOffset = v; syncAntiVoidBarrier() end })
    MR:CreateToggle({ Name = "NoFall Damage Bypass", FeatKey = "NoFallDamage", Default = State.Movement.NoFallDamage, Callback = function(v) State.Movement.NoFallDamage = v end })
    MR:CreateToggle({ Name = "Infinite Jump", FeatKey = "InfiniteJump",         Default = State.Movement.InfiniteJump, Callback = function(v) State.Movement.InfiniteJump = v end })
    MR:CreateToggle({ Name = "Noclip Walls", FeatKey = "Noclip",          Default = State.Movement.Noclip,       Callback = function(v) State.Movement.Noclip = v end })

    -- VISUALS
    local VL = visTab:CreateBlock("ESP Enhancements")
    VL:CreateToggle({ Name = "Player Chams / ESP", Default = State.Visuals.PlayerESP, Callback = function(v) State.Visuals.PlayerESP = v; updatePlayerESP() end })

    -- FARM & CLASSIC PERKS
    local FL = farmTab:CreateBlock("Auto Win & Classic Perks")
    FL:CreateButton({ Name = "Activate Full Skywars Bypass (Reset)", Callback = function() activateSkywarsFullBypass(true) end })
    FL:CreateToggle({ Name = "Bypass Client Anti-Cheat", Default = State.World.BypassAntiCheat, Callback = function(v) State.World.BypassAntiCheat = v; if v then disableClientAntiCheat() end end })
    FL:CreateToggle({ Name = "Auto Kill All Players (Match)", FeatKey = "AutoKillAll", Default = State.Farm.AutoKillAll, Callback = function(v) State.Farm.AutoKillAll = v end })
    FL:CreateToggle({ Name = "Auto Farm Wins (Mega VIP Pad)", Default = State.Farm.AutoWinPad, Callback = function(v) State.Farm.AutoWinPad = v end })
    FL:CreateToggle({ Name = "Auto Coin Farm (Safe)", Default = State.World.AutoCoinFarm, Callback = function(v) State.World.AutoCoinFarm = v end })
    FL:CreateToggle({ Name = "Coin Magnet (Safe)", Default = State.World.MagnetItems, Callback = function(v) State.World.MagnetItems = v end })
    FL:CreateButton({ Name = "Unlock VIP & Mega VIP Doors", Callback = function() unlockVIPDoors() end })
    FL:CreateButton({ Name = "Claim Free Armor & VIP Gear", Callback = function() claimFreeLobbyArmorAndItems() end })
    FL:CreateButton({ Name = "TP -> Center Island (Mid)", Callback = function() teleportToWaypoint("CenterIsland") end })
    FL:CreateButton({ Name = "TP -> Mega VIP Room", Callback = function() teleportToWaypoint("MegaVIPRoom") end })
    FL:CreateButton({ Name = "TP -> VIP Room", Callback = function() teleportToWaypoint("VIPRoom") end })
    FL:CreateButton({ Name = "TP -> Spawn Lobby", Callback = function() teleportToWaypoint("SpawnLobby") end })
    FL:CreateButton({ Name = "Rejoin Server", Callback = function() rejoinServer() end })

    -- Select combat first
    switchTab(combatEntry)

    -- Watermark pill
    local WMPill = Instance.new("TextButton", SGui)
    WMPill.Size = UDim2.new(0, 160, 0, 30)
    WMPill.Position = UDim2.new(0, 16, 0, 16)
    WMPill.BackgroundColor3 = Color3.fromRGB(11, 11, 16)
    WMPill.Text = "       Ranax  [LeftCtrl]"
    WMPill.TextColor3 = Color3.fromRGB(180, 175, 255)
    WMPill.Font = Enum.Font.GothamBold
    WMPill.TextSize = 11
    WMPill.TextXAlignment = Enum.TextXAlignment.Left

    local WmLogo = Instance.new("ImageLabel", WMPill)
    WmLogo.Size = UDim2.new(0, 18, 0, 18)
    WmLogo.Position = UDim2.new(0, 6, 0.5, -9)
    WmLogo.BackgroundTransparency = 1
    WmLogo.Image = "rbxthumb://type=Asset&id=17007876976&w=420&h=420"
    WMPill.AutoButtonColor = false
    corner(WMPill, 9)
    stroke(WMPill, C.Accent, 1)
    WMPill.MouseButton1Click:Connect(function()
        Win.Visible = not Win.Visible
    end)

    -- LeftControl keybind
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and (inp.KeyCode == Enum.KeyCode.LeftControl or inp.KeyCode == Enum.KeyCode.RightShift) then
            Win.Visible = not Win.Visible
        end
    end)
end
end

print("[Skywars Classic] Ranax Supreme Hub — PC Mode GUI Loaded!")
