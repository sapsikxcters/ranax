--[[
    ================================================================
      Zick Hub V2 — Edited Build (Ranax MMV Menu Edition)
    ================================================================
      - Shoot V2: FOV icindeki en yakin oyuncuya otomatik ates (Auto-Equip YOK, sadece eldeki silahla ates eder)
      - Flick Shoot: KARAKTER hedefe doner, ates eder ve geri doner (gorunmezlik YOK, tam donus animasyonu) (R ile ac/kapa)
      - Kill Aura: MMV KillEvent ile etrafindakileri oldurur
      - ESP: Chams / Isim / Kutu / Tracer / Health Bar / Mesafe
      - Ranax MMV tarzi menu: sekmeler, toggle, slider, buton
      - Phantom Scope Destegi + Otomatik Silah Alma (GunDrop Pickup)
      - Q = Shoot ac/kapa | R = Flick ac/kapa | LeftControl = Menu ac/kapa
    ================================================================
]]

local genv = (type(getgenv) == "function") and getgenv() or _G
if genv.ZickHubV2Loaded then
	warn("[Zick Hub V2] zaten yuklu!")
	return
end
genv.ZickHubV2Loaded = true

-- // Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = Workspace.CurrentCamera or Camera
end)

-- ============================ AYARLAR ============================
local SETTINGS = {
	TARGET_MODE     = "FOV",          -- "FOV" veya "Range (Mesafe)"
	MAX_RANGE       = 250,            -- Studs (0 = sinirsiz)
	FOV_RADIUS      = 180,
	FOV_SHOW        = false,          -- FOV Cemberi cizimi
	FOV_COLOR       = Color3.fromRGB(160, 32, 240),
	AUTO_FIRE       = true,
	AUTO_EQUIP      = true,           -- True: cantadan/yerden silahi otomatik kusanir | False: sadece elde tutulan silahla ates eder
	SHOOT_METHOD    = "New (Blatant)",-- "New (Blatant)" veya "Normal"
	KEYBIND         = Enum.KeyCode.Q,
	SHOOT_DELAY     = 0.1,
	PREDICT_OFFSET  = 2.8,
	WALL_CHECK      = false,
	AUTO_RELOAD     = true,
	BURST_SIZE      = 0,
	BURST_PAUSE     = 0.5,
	HIT_SOUND       = true,           -- Crisp AAA vurus sesi
	TRIGGERBOT      = false,          -- Crosshair hedefe gelince aninda otomatik ates
	TRIGGERBOT_DELAY = 0.02,
	BULLET_TRACERS  = true,           -- Neon lazer mermi izleri
	KILL_BANNER     = true,           -- Zafer & Eleme gostergesi
	GUN_MAGNET      = false,          -- Yerdeki silahlari aninda eline ceker
	DEBUG           = true,

	-- Hitbox Expander (Aim Trainer / 5v5 Tanrisi)
	HITBOX_ENABLED   = false,
	HITBOX_SIZE      = 14,             -- 5 - 30 studs
	HITBOX_TRANS     = 0.65,

	-- Spinbot / Anti-Aim (Hedef alinamaz olursun)
	SPINBOT_ENABLED  = false,
	SPINBOT_SPEED    = 45,

	-- Hareket & Godmode Hileleri
	BHOP_ENABLED     = false,          -- Otomatik Bunny Hop
	INF_JUMP         = false,          -- Sinirsiz havada ziplama
	NOCLIP           = false,          -- Duvarlardan gecme
	FLY_ENABLED      = false,          -- Ucma hilesi
	FLY_SPEED        = 45,
	FLY_KEY          = Enum.KeyCode.F, -- F = Fly ac/kapa

	-- Flick Shoot (Ranax MMV Motoru)
	FLICK_ENABLED   = false,
	FLICK_KEY       = Enum.KeyCode.R, -- R = Flick ac/kapa
	FLICK_TURN_TIME = 0.08,           -- flick donme suresi (sn)
	FLICK_RESTORE   = true,           -- atis sonrasi eski rotasyona don
	FLICK_CAMERA    = true,          -- flick sirasinda kamerayi hedefe cevir

	-- Menu Keybind
	MENU_KEY        = Enum.KeyCode.LeftControl,

	-- Tema (Ranax MMV)
	THEME        = Color3.fromRGB(150, 100, 255),
	THEME_BG     = Color3.fromRGB(20, 15, 30),
	THEME_TOP    = Color3.fromRGB(30, 20, 45),
	THEME_ROW    = Color3.fromRGB(35, 25, 50),
	THEME_TEXT   = Color3.fromRGB(220, 210, 240),
	DISCORD      = "https://discord.gg",
}

local ESP_SETTINGS = {
	Enabled           = true,
	Chams             = true,
	PartChams         = true,
	GlowChams         = true,
	ChamsTransparency = 0.35,
	RoleColors        = true,
	Names             = true,
	Weapon            = true,
	Boxes             = true,
	Tracers           = false,
	HealthBars        = true,
	Distance          = true,
	TeamCheck         = false,
	GunDrop           = true, -- Dropped Sheriff Gun ESP
	MaxDistance       = 0, -- 0 = sinirsiz
	TextSize          = 13,
	BoxColor          = Color3.fromRGB(160, 32, 240),
	NameColor         = Color3.fromRGB(255, 255, 255),
}

local PLAYER_SETTINGS = {
	SpeedEnabled  = false,
	SpeedValue    = 45,
	JumpEnabled   = false,
	JumpValue     = 50,
	AntiAFK       = false,
	FPSBoost      = false,
}

-- ============================ YARDIMCI ============================
local function create(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	inst.Parent = parent
	return inst
end

local function guiParent(gui)
	local ok = pcall(function()
		gui.Parent = (type(gethui) == "function" and gethui()) or CoreGui
	end)
	if not ok then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

-- eski Draggable property modern Roblox'ta guvenilmez; manuel surukleme bagla
local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging = false
	local dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- ==================== ANIMATED NOTIFICATION ENGINE ====================
local notifyGui = create("ScreenGui", {
	Name = "ZickHubNotifs",
	ResetOnSpawn = false,
	DisplayOrder = 10001,
})
guiParent(notifyGui)

local activeNotifs = {}

local function repositionNotifs()
	for i, n in ipairs(activeNotifs) do
		if n.frame and n.frame.Parent then
			local targetY = 16 + (i - 1) * 60
			TweenService:Create(n.frame, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.new(1, -270, 0, targetY)
			}):Play()
		end
	end
end

local function notify(title, text, dur, isState)
	local n = {}
	local accentColor = SETTINGS.THEME
	local stateTag = ""
	local stateTagColor = Color3.fromRGB(255, 255, 255)

	if isState == true then
		accentColor = Color3.fromRGB(0, 235, 120)
		stateTag = "ON"
		stateTagColor = Color3.fromRGB(0, 235, 120)
	elseif isState == false then
		accentColor = Color3.fromRGB(255, 75, 75)
		stateTag = "OFF"
		stateTagColor = Color3.fromRGB(255, 75, 75)
	end

	local targetIndex = #activeNotifs + 1
	local targetY = 16 + (targetIndex - 1) * 60

	n.frame = create("Frame", {
		Size = UDim2.new(0, 254, 0, 52),
		Position = UDim2.new(1, 40, 0, targetY),
		BackgroundColor3 = Color3.fromRGB(15, 11, 23),
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		ZIndex = 50,
	}, notifyGui)
	create("UICorner", { CornerRadius = UDim.new(0, 8) }, n.frame)
	create("UIStroke", { Color = accentColor, Thickness = 1.3, Transparency = 0.3 }, n.frame)

	-- Glowing accent bar on the left edge
	local accentBar = create("Frame", {
		Size = UDim2.new(0, 3.5, 1, -12),
		Position = UDim2.new(0, 6, 0.5, -((52 - 12) / 2)),
		BackgroundColor3 = accentColor,
		BorderSizePixel = 0,
		ZIndex = 51,
	}, n.frame)
	create("UICorner", { CornerRadius = UDim.new(0, 2) }, accentBar)

	-- Title
	create("TextLabel", {
		Size = UDim2.new(1, -65, 0, 18),
		Position = UDim2.new(0, 16, 0, 7),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Color3.fromRGB(240, 235, 255),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 51,
	}, n.frame)

	-- State Pill (ON / OFF badge)
	if stateTag ~= "" then
		local pill = create("TextLabel", {
			Size = UDim2.new(0, 36, 0, 18),
			Position = UDim2.new(1, -44, 0, 7),
			BackgroundColor3 = Color3.fromRGB(22, 16, 32),
			BackgroundTransparency = 0.2,
			Font = Enum.Font.GothamBold,
			Text = stateTag,
			TextColor3 = stateTagColor,
			TextSize = 10,
			ZIndex = 51,
		}, n.frame)
		create("UICorner", { CornerRadius = UDim.new(0, 4) }, pill)
		create("UIStroke", { Color = stateTagColor, Thickness = 1, Transparency = 0.4 }, pill)
	end

	-- Subtitle text
	create("TextLabel", {
		Size = UDim2.new(1, -26, 0, 20),
		Position = UDim2.new(0, 16, 0, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = Color3.fromRGB(185, 175, 205),
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 51,
	}, n.frame)

	table.insert(activeNotifs, n)

	-- Smooth slide-in
	TweenService:Create(n.frame, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -270, 0, targetY)
	}):Play()

	task.delay(dur or 1.8, function()
		local idx = table.find(activeNotifs, n)
		if idx then
			table.remove(activeNotifs, idx)
		end
		if n.frame and n.frame.Parent then
			local curY = n.frame.Position.Y.Offset
			local slideOut = TweenService:Create(n.frame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(1, 40, 0, curY),
				BackgroundTransparency = 1
			})
			slideOut:Play()
			slideOut.Completed:Connect(function()
				pcall(function() n.frame:Destroy() end)
				repositionNotifs()
			end)
		else
			repositionNotifs()
		end
	end)
end

local lastLogKey, lastLogTime = nil, 0

local function dlog(key, msg)
	if not SETTINGS.DEBUG then
		return
	end
	local now = os.clock()
	if key ~= lastLogKey or now - lastLogTime > 3 then
		lastLogKey = key
		lastLogTime = now
		print("[ZickHub V2] " .. msg)
	end
end

-- ============================ FRIEND SYSTEM ============================
local FRIENDS_FILE = "zickhub_friends.txt"
local Friends = {}
local FriendOrder = {}

local function saveFriends()
	if type(writefile) == "function" then
		pcall(function()
			writefile(FRIENDS_FILE, table.concat(FriendOrder, "\n"))
		end)
	end
end

local function loadFriends()
	if type(readfile) == "function" and type(isfile) == "function" and isfile(FRIENDS_FILE) then
		pcall(function()
			local data = readfile(FRIENDS_FILE)
			for name in string.gmatch(data, "[^\r\n]+") do
				name = (name:gsub("^%s+", ""):gsub("%s+$", ""))
				if name ~= "" and not Friends[name] then
					Friends[name] = true
					table.insert(FriendOrder, name)
				end
			end
		end)
	end
end

local function isFriend(name)
	return Friends[name] == true
end

local function addFriend(name)
	name = (name:gsub("^%s+", ""):gsub("%s+$", ""))
	if name == "" or Friends[name] then
		return false
	end
	Friends[name] = true
	table.insert(FriendOrder, name)
	saveFriends()
	return true
end

local function removeFriend(name)
	if not Friends[name] then
		return false
	end
	Friends[name] = nil
	local idx = table.find(FriendOrder, name)
	if idx then
		table.remove(FriendOrder, idx)
	end
	saveFriends()
	return true
end

local function clearFriends()
	table.clear(Friends)
	table.clear(FriendOrder)
end

loadFriends()

-- ============================ FOV CEMBERI + TARGET INFO ============================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Color = SETTINGS.FOV_COLOR
fovCircle.Filled = false
fovCircle.Transparency = 0.8
fovCircle.NumSides = 64
fovCircle.Radius = SETTINGS.FOV_RADIUS
fovCircle.Visible = SETTINGS.FOV_SHOW

local targetInfo = Drawing.new("Text")
targetInfo.Size = 13
targetInfo.Center = true
targetInfo.Outline = true
targetInfo.OutlineColor = Color3.new(0, 0, 0)
targetInfo.Color = Color3.fromRGB(160, 32, 240)
targetInfo.Visible = false

-- ============================ GUN / REMOTE / RELOAD ============================
local GUN_HINTS = {
	"phantom scope", "phantom", "scope", "gun", "revolver", "rifle", "ak", "deagle", "pistol", "smg", "awp", "scar",
	"m4", "usp", "glock", "mp5", "shotgun", "sniper", "famas", "aug", "p90", "uzi", "vector", "m1911", "lmg",
}

local function looksLikeGun(name)
	local l = name:lower()
	for _, h in ipairs(GUN_HINTS) do
		if l:find(h, 1, true) then
			return true
		end
	end
	return false
end

-- silah OLMAYAN esyalar (prank bomba vb.) asla silah sayilmaz
local NOT_GUN_HINTS = {
	"bomb", "prank", "flash", "smoke", "medkit", "bandage", "heal",
	"pizza", "cola", "soda", "candy", "trap", "radio", "boombox", "boom",
	-- yakin dovus silahlari asla "silah" sayilmaz (murderer iken bicak kusanilip Stab'a CFrame yollanmasin)
	"knife", "sword", "machete", "katana", "dagger", "crowbar", "shovel",
}
local function isNotGun(name)
	local l = name:lower()
	for _, h in ipairs(NOT_GUN_HINTS) do
		if l:find(h, 1, true) then
			return true
		end
	end
	return false
end

local function hasShootRemote(container)
	if not container then return false end
	local ks = container:FindFirstChild("KnifeServer")
	if ks and ks:FindFirstChild("ShootGun") then return true end
	for _, n in ipairs({ "ShootGun", "Shoot", "Fire", "ShootRemote", "FireEvent", "Shot", "Shooting", "CreateBeam" }) do
		local r = container:FindFirstChild(n, true)
		if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
			return true
		end
	end
	for _, d in ipairs(container:GetDescendants()) do
		if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and not d.Name:lower():find("reload") then
			return true
		end
	end
	return false
end

local function pickShootRemote(container)
	if not container then return nil end
	local ks = container:FindFirstChild("KnifeServer")
	if ks then
		local sg = ks:FindFirstChild("ShootGun")
		if sg then return sg end
	end
	for _, n in ipairs({ "ShootGun", "Shoot", "Fire", "ShootRemote", "FireEvent", "Shot", "Shooting", "CreateBeam" }) do
		local r = container:FindFirstChild(n, true)
		if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
			return r
		end
	end
	for _, d in ipairs(container:GetDescendants()) do
		if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and not d.Name:lower():find("reload") then
			return d
		end
	end
	return nil
end

local function findGunInContainer(container)
	if not container then return nil end
	local priorityNames = { "Phantom Scope", "phantom scope", "Phantom", "phantom", "Scope", "scope", "Gun", "gun", "Revolver", "revolver" }
	for _, name in ipairs(priorityNames) do
		local t = container:FindFirstChild(name)
		if t and t:IsA("Tool") and not isNotGun(t.Name) then
			return t
		end
	end
	for _, t in ipairs(container:GetChildren()) do
		if t:IsA("Tool") and not isNotGun(t.Name) then
			if looksLikeGun(t.Name) or hasShootRemote(t) then
				return t
			end
		end
	end
	return nil
end

local function grabDroppedGun()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local dropNames = { "GunDrop", "Gun", "PhantomScopeDrop", "PhantomDrop", "ScopeDrop" }
	local foundDrop = nil
	for _, name in ipairs(dropNames) do
		local drop = Workspace:FindFirstChild(name, true)
		if drop and (drop:IsA("BasePart") or drop:IsA("Model")) then
			foundDrop = drop
			break
		end
	end

	if not foundDrop then
		for _, desc in ipairs(Workspace:GetDescendants()) do
			if desc.Name == "GunDrop" or (desc:IsA("BasePart") and desc.Name:lower():find("gundrop")) then
				foundDrop = desc
				break
			end
		end
	end

	if foundDrop then
		pcall(function()
			local handle = foundDrop:IsA("BasePart") and foundDrop or foundDrop:FindFirstChildWhichIsA("BasePart") or foundDrop:FindFirstChild("Handle")
			if handle then
				firetouchinterest(hrp, handle, 0)
				firetouchinterest(hrp, handle, 1)
			end
			if foundDrop:IsA("Model") or foundDrop:IsA("BasePart") then
				foundDrop:PivotTo(hrp.CFrame)
			end
		end)
		task.wait(0.08)
		return true
	end
	return false
end

local function getGun()
	local char = LocalPlayer.Character
	if not char then
		return nil
	end

	-- 1. Elde tutulan silah
	local held = char:FindFirstChildOfClass("Tool")
	if held and not isNotGun(held.Name) and (looksLikeGun(held.Name) or hasShootRemote(held)) then
		return held
	end

	-- 2. Karakter icindeki silah
	local inChar = findGunInContainer(char)
	if inChar then
		return inChar
	end

	-- 3. AUTO EQUIP (Aciksa cantadan / yerden silahi kusanir)
	if SETTINGS.AUTO_EQUIP then
		local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
		if bp then
			local bpGun = findGunInContainer(bp)
			if bpGun then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum:EquipTool(bpGun)
				else
					bpGun.Parent = char
				end
				task.wait(0.04)
				return bpGun
			end
		end

		-- 4. Yerdeki silahi otomatik alma
		if grabDroppedGun() then
			local newGun = findGunInContainer(char) or (bp and findGunInContainer(bp))
			if newGun then
				if newGun.Parent ~= char then
					newGun.Parent = char
					task.wait(0.04)
				end
				return newGun
			end
		end
	end

	return nil
end

local function playHitSound()
	if not SETTINGS.HIT_SOUND then return end
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://8526543415" -- Crisp AAA kill/hitmarker ding
		s.Volume = 2.0
		s.Parent = Workspace
		s:Play()
		task.delay(2, function() pcall(function() s:Destroy() end) end)
	end)
end

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
		if UserInputService and VirtualInputManager then
			VirtualInputManager:SendMouseMoveEvent(x, y, game)
		end
	end)
	return true
end

local remoteCache = { gun = nil, remote = nil }

local function getShootRemote()
	local gun = getGun()
	if not gun then
		remoteCache.gun, remoteCache.remote = nil, nil
		return nil
	end
	if remoteCache.gun == gun and remoteCache.remote and remoteCache.remote.Parent then
		return remoteCache.remote
	end
	local r = pickShootRemote(gun)
	if r then
		remoteCache.gun = gun
		remoteCache.remote = r
		return r
	end
	remoteCache.gun, remoteCache.remote = nil, nil
	return nil
end

local function getAmmo(gun)
	if not gun then
		return nil
	end
	for _, name in ipairs({ "Ammo", "ammo", "AmmoValue", "Clip", "Magazine", "Bullets" }) do
		local v = gun:FindFirstChild(name)
		if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then
			return tonumber(v.Value)
		end
	end
	local a = gun:GetAttribute("Ammo") or gun:GetAttribute("ammo") or gun:GetAttribute("AmmoInMag")
	if a ~= nil then
		return tonumber(a)
	end
	return nil
end

local function triggerReload(gun)
	if not gun then
		return
	end
	for _, d in ipairs(gun:GetDescendants()) do
		if d:IsA("RemoteEvent") and d.Name:lower():find("reload") then
			d:FireServer()
			return
		end
	end
	-- R tusu artik flick keybindi; script R basalmiyor, reload remote'u yoksa atlanir
end

-- ============================ FLICK SHOOT MOTORU ============================
local flickActive = false

local function visibleToCamera(targetObj)
	if not SETTINGS.WALL_CHECK then
		return true
	end
	if not targetObj then return true end

	local origin = Camera and Camera.CFrame.Position
	if not origin then return true end

	local part = targetObj:IsA("BasePart") and targetObj or (targetObj:FindFirstChild("HumanoidRootPart") or targetObj:FindFirstChild("Head") or targetObj:FindFirstChild("Torso") or targetObj:FindFirstChild("UpperTorso"))
	if not part then return true end

	local dir = part.Position - origin
	if dir.Magnitude < 0.5 then
		return true
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local exclude = {}
	if LocalPlayer.Character then
		table.insert(exclude, LocalPlayer.Character)
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if isFriend(p.Name) and p.Character then
			table.insert(exclude, p.Character)
		end
	end
	params.FilterDescendantsInstances = exclude

	local result = Workspace:Raycast(origin, dir, params)
	if not result then
		return true
	end

	local targetChar = targetObj:IsA("Model") and targetObj or targetObj.Parent
	return result.Instance and targetChar and (
		result.Instance:IsDescendantOf(targetChar)
		or result.Instance.Transparency > 0.65
		or result.Instance.CanCollide == false
	)
end
local isTargetVisible = visibleToCamera

-- 5V5 / AIM TRAINER / FFA / MM2 UYUMLU CLOSEST HEDEFLEME:
-- Role (Murderer/Sheriff) bakmaz, arkadas olmayan en yakin CANLI oyuncuyu secer!
local function getClosestTarget()
	local myChar = LocalPlayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end

	local bestTarget = nil
	local bestMetric = math.huge
	local center = Camera and (Camera.ViewportSize / 2)
	local isFOVMode = (SETTINGS.TARGET_MODE ~= "Range (Mesafe)" and SETTINGS.TARGET_MODE ~= "Range")

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and not isFriend(plr.Name) then
			local char = plr.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hrp and hum and hum.Health > 0 then
					local passWall = true
					if SETTINGS.WALL_CHECK then
						passWall = visibleToCamera(hrp)
						if not passWall then
							local head = char:FindFirstChild("Head")
							if head and visibleToCamera(head) then
								passWall = true
							end
						end
					end

					if passWall then
						if isFOVMode then
							-- FOV Check: Ekranda crosshair'e en yakin hedef
							if Camera then
								local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
								if onScreen then
									local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
									if d <= SETTINGS.FOV_RADIUS and d < bestMetric then
										bestMetric = d
										bestTarget = plr
									end
								end
							end
						else
							-- Range Mode: 3D Dunya mesafesinde en yakin hedef
							local dist = (myHRP.Position - hrp.Position).Magnitude
							if (SETTINGS.MAX_RANGE <= 0 or dist <= SETTINGS.MAX_RANGE) and dist < bestMetric then
								bestMetric = dist
								bestTarget = plr
							end
						end
					end
				end
			end
		end
	end
	return bestTarget
end

-- Ranax MMV Gelişmiş Lead & Mesafe Tahmin Motoru
local function getPredictedPosition(hrp, hum, offset, origin)
	local velocity = Vector3.zero
	pcall(function() velocity = hrp.AssemblyLinearVelocity end)
	if not velocity or velocity.Magnitude == 0 then pcall(function() velocity = hrp.Velocity end) end
	velocity = Vector3.new(velocity.X, 0, velocity.Z)

	local moveDir = (hum and hum.MoveDirection) or Vector3.zero
	moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)

	local dist = 1
	if origin and hrp then
		dist = math.clamp((hrp.Position - origin).Magnitude / 50, 0.4, 2.5)
	end

	local leadMult = (offset or 2.8) * dist
	local predPos = hrp.Position + (velocity * 0.65) * (leadMult / 14) + (moveDir * leadMult)

	if SETTINGS.SHOOT_METHOD == "Normal" and origin then
		local d = (origin - hrp.Position).Magnitude
		predPos = predPos + Vector3.new(0, (d / 140), 0)
	end

	return predPos
end

local function getOriginPosition()
	local char = LocalPlayer.Character
	if not char then return nil end
	local part = char:FindFirstChild("RightHand")
		or char:FindFirstChild("Right Arm")
		or char:FindFirstChild("Head")
		or char:FindFirstChild("HumanoidRootPart")
	return part and part.Position or nil
end

local remoteCooldown = 0
local shotsInBurst = 0
local currentAimTarget = nil

-- Tum MM2, Aim Trainer ve Modded remote tiplerini destekleyen universal tetikleyici (2X DOUBLE SHOT BURST)
local function fireRemote(rem, origin, hitPos, gun)
	if not rem then return end
	local aimCF = CFrame.lookAt(origin, hitPos)
	local targetCF = CFrame.new(hitPos)
	pcall(function()
		-- 1. Standart MM2 CFrame + CFrame
		rem:FireServer(aimCF, targetCF)
		-- 2. CFrame + Vector3
		rem:FireServer(aimCF, hitPos)
		-- 3. Vector3 + Vector3
		rem:FireServer(origin, hitPos)
		-- 4. HitPos tekil
		rem:FireServer(hitPos)
		-- 5. Aim CFrame tekil
		rem:FireServer(aimCF)
		-- 6. RemoteFunction invoke
		if rem:IsA("RemoteFunction") then
			rem:InvokeServer(1, hitPos, "AH2")
		end
	end)
	if gun and gun:IsA("Tool") then
		pcall(function() gun:Activate() end)
	end
	if SETTINGS.HIT_SOUND then
		playHitSound()
	end
	pcall(function() spawnBulletTracer(origin, hitPos) end)
end

-- ==================== RANAX MMV FLICK SHOOT MOTORU ====================
local function executeFlickShoot(target, hitPos, remote, gun, origin)
	if flickActive then return end
	local myChar = LocalPlayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
	if not (myHRP and myHum) then return end

	flickActive = true
	local origCFrame   = myHRP.CFrame
	local origCameraCF = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame
	local savedAutoRotate = myHum.AutoRotate
	myHum.AutoRotate = false

	local turnTime = math.clamp(SETTINGS.FLICK_TURN_TIME or 0.08, 0.03, 0.25)
	local steps = math.max(4, math.floor(turnTime / 0.016))
	local flatTarget = Vector3.new(hitPos.X, myHRP.Position.Y, hitPos.Z)
	local aimCFrame = CFrame.lookAt(myHRP.Position, flatTarget)

	-- 1. Ease-IN: smooth rotation from current -> aim (Ranax cubic lerp)
	for i = 1, steps do
		if not (myHRP and myHRP.Parent) then break end
		local alpha = (i / steps) ^ 0.6 -- Ranax flick ivmesi
		local newRot = origCFrame:Lerp(aimCFrame, alpha)
		myHRP.CFrame = CFrame.new(myHRP.Position) * newRot.Rotation

		if SETTINGS.FLICK_CAMERA and Workspace.CurrentCamera and origCameraCF then
			pcall(function()
				local camAim = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, hitPos)
				Workspace.CurrentCamera.CFrame = origCameraCF:Lerp(camAim, alpha)
			end)
			pcall(function()
				moveMouseToWorld(hitPos)
			end)
		end
		task.wait()
	end

	-- 2. Camera & Mouse snap to target at peak
	if SETTINGS.FLICK_CAMERA then
		pcall(function()
			moveMouseToWorld(hitPos)
		end)
	end

	-- 3. Namlu konumunu al ve zirvede tek sefer ates et
	local newOrigin = getOriginPosition()
	if newOrigin then origin = newOrigin end
	fireRemote(remote, origin, hitPos, gun)

	-- 4. Kisa dogal atis beklemesi (peak hold for shot registration)
	task.wait(0.04)

	-- 5. Ease-OUT: smoothly return to original orientation
	if SETTINGS.FLICK_RESTORE then
		local peakCFrame   = myHRP.CFrame
		local peakCameraCF = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame
		local returnSteps  = math.max(3, math.floor(steps * 0.7))
		for i = 1, returnSteps do
			if not (myHRP and myHRP.Parent) then break end
			local alpha = (i / returnSteps) ^ 1.4 -- Decelerating ease-out
			local newRot = peakCFrame:Lerp(origCFrame, alpha)
			myHRP.CFrame = CFrame.new(myHRP.Position) * newRot.Rotation

			if SETTINGS.FLICK_CAMERA and Workspace.CurrentCamera and peakCameraCF and origCameraCF then
				pcall(function()
					Workspace.CurrentCamera.CFrame = peakCameraCF:Lerp(origCameraCF, alpha)
				end)
			end
			task.wait()
		end

		if SETTINGS.FLICK_CAMERA and Workspace.CurrentCamera and origCameraCF then
			Workspace.CurrentCamera.CFrame = origCameraCF
		end
	end

	pcall(function() myHum.AutoRotate = savedAutoRotate end)
	flickActive = false
end

local function shootV2()
	if os.clock() < remoteCooldown then
		return
	end
	local gun = getGun()
	if not gun then
		remoteCooldown = os.clock() + 0.5
		dlog("noremote", "Silah yok - Auto Equip veya elinde silah tutulmasi gerekiyor")
		return
	end

	local remote = getShootRemote()
	if not remote then
		remoteCooldown = os.clock() + 0.5
		dlog("noremote", "Shoot remote bulunamadi")
		return
	end

	if SETTINGS.AUTO_RELOAD then
		local ammo = getAmmo(gun)
		if ammo ~= nil and ammo <= 0 then
			remoteCooldown = os.clock() + 1.2
			dlog("reload", "sarjor bos - reload tetiklendi")
			triggerReload(gun)
			return
		end
	end

	local target = getClosestTarget()
	currentAimTarget = target
	if not target then
		dlog("notarget", "Gecerli hedef bulunamadi")
		return
	end

	local tchar = target.Character
	if not tchar then return end
	local hrp = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Torso") or tchar:FindFirstChild("UpperTorso")
	local hum = tchar:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then return end

	local origin = getOriginPosition()
	if not origin then return end
	local hitPos = getPredictedPosition(hrp, hum, SETTINGS.PREDICT_OFFSET, origin)

	if SETTINGS.FLICK_ENABLED then
		executeFlickShoot(target, hitPos, remote, gun, origin)
	else
		fireRemote(remote, origin, hitPos, gun)
	end

	-- Hook kill detection for banner
	if SETTINGS.KILL_BANNER and target and target.Character then
		local victimHum = target.Character:FindFirstChildOfClass("Humanoid")
		if victimHum and victimHum.Health > 0 then
			local tDist = math.floor((origin - hitPos).Magnitude)
			local dConn
			dConn = victimHum.Died:Connect(function()
				if dConn then dConn:Disconnect(); dConn = nil end
				showKillBanner(target.Name, tDist)
			end)
			task.delay(2.8, function() if dConn then dConn:Disconnect(); dConn = nil end end)
		end
	end

	shotsInBurst = shotsInBurst + 1
	if SETTINGS.BURST_SIZE > 0 and shotsInBurst >= SETTINGS.BURST_SIZE then
		shotsInBurst = 0
		remoteCooldown = os.clock() + SETTINGS.BURST_PAUSE
		dlog("burst", "burst tamam - kisa bekleme")
	end
end

-- Auto fire dongusu
task.spawn(function()
	while true do
		if SETTINGS.AUTO_FIRE then
			local ok, err = pcall(shootV2)
			if not ok and SETTINGS.DEBUG then
				warn("[ZickHub V2] shootV2 error: " .. tostring(err))
			end
			task.wait(SETTINGS.SHOOT_DELAY)
		else
			currentAimTarget = nil
			task.wait(0.35)
		end
	end
end)

-- Target info cizimi
RunService.RenderStepped:Connect(function()
	if not SETTINGS.FOV_SHOW then
		if fovCircle.Visible then fovCircle.Visible = false end
		if targetInfo.Visible then targetInfo.Visible = false end
		return
	end
	fovCircle.Radius = SETTINGS.FOV_RADIUS
	fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	fovCircle.Visible = not flickActive
	if currentAimTarget and currentAimTarget.Character and SETTINGS.FOV_SHOW then
		local thrp = currentAimTarget.Character:FindFirstChild("HumanoidRootPart")
		local thum = currentAimTarget.Character:FindFirstChildOfClass("Humanoid")
		if thrp then
			local pos, onScreen = Camera:WorldToViewportPoint(thrp.Position)
			if onScreen then
				targetInfo.Text = currentAimTarget.Name .. (thum and (" [" .. math.floor(thum.Health) .. "hp]") or "")
				targetInfo.Position = Vector2.new(pos.X, pos.Y - 30)
				targetInfo.Visible = true
				return
			end
		end
	end
	targetInfo.Visible = false
end)

-- Q = Shoot ac/kapa (bildirim YOK, watermark gosterir) | R = Flick ac/kapa
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- yazı kutusuna yazarken tuslari toggle etme (yoksa menu/kapatma karisir)
	if gameProcessed or UserInputService:GetFocusedTextBox() then
		return
	end
	if input.KeyCode == SETTINGS.KEYBIND then
		SETTINGS.AUTO_FIRE = not SETTINGS.AUTO_FIRE
		notify("Shoot V2", SETTINGS.AUTO_FIRE and "ENABLED [ON]" or "DISABLED [OFF]", 1.6, SETTINGS.AUTO_FIRE)
	elseif input.KeyCode == SETTINGS.FLICK_KEY then
		SETTINGS.FLICK_ENABLED = not SETTINGS.FLICK_ENABLED
		notify("Flick Shoot", SETTINGS.FLICK_ENABLED and "ENABLED [ON]" or "DISABLED [OFF]", 1.6, SETTINGS.FLICK_ENABLED)
	elseif SETTINGS.FLY_KEY and input.KeyCode == SETTINGS.FLY_KEY then
		SETTINGS.FLY_ENABLED = not SETTINGS.FLY_ENABLED
		notify("Fly Hack", SETTINGS.FLY_ENABLED and "ENABLED [ON]" or "DISABLED [OFF]", 1.6, SETTINGS.FLY_ENABLED)
	end
end)

-- ============================ 5V5 / AIM TRAINER / MM2 KILL AURA ============================
local KILL_AURA = {
	Enabled = false,
	AttackDelay = 0.25,
	Range = 25,               -- 0 = tum harita
	AutoEquipKnife = true,    -- cantadan bicak kusan
	TeleportTarget = false,   -- hedefleri onune isinla (5v5 icin opsiyonel)
}

local function getHRP()
	local char = LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function getKnifeTool()
	local char = LocalPlayer.Character
	if not char then return nil end

	-- 1. Elde tutulan bicak
	for _, t in ipairs(char:GetChildren()) do
		if t:IsA("Tool") and (t.Name:lower():find("knife") or t.Name:lower():find("blade") or t.Name:lower():find("dagger") or t.Name:lower():find("scythe") or t.Name:lower():find("sword") or t:FindFirstChild("Stab") or t:FindFirstChild("Slash") or t:FindFirstChild("KnifeServer")) then
			return t
		end
	end

	-- 2. Cantadaki bicak (AutoEquip aktifse)
	if KILL_AURA.AutoEquipKnife then
		local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
		if bp then
			for _, t in ipairs(bp:GetChildren()) do
				if t:IsA("Tool") and (t.Name:lower():find("knife") or t.Name:lower():find("blade") or t.Name:lower():find("dagger") or t.Name:lower():find("scythe") or t.Name:lower():find("sword") or t:FindFirstChild("Stab") or t:FindFirstChild("Slash") or t:FindFirstChild("KnifeServer")) then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then hum:EquipTool(t) else t.Parent = char end
					task.wait(0.04)
					return t
				end
			end
		end
	end
	return nil
end

local function getKillEvent()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local gameplay = remotes and remotes:FindFirstChild("Gameplay")
	return gameplay and gameplay:FindFirstChild("KillEvent") or nil
end

task.spawn(function()
	while true do
		if KILL_AURA.Enabled then
			local myRoot = getHRP()
			if myRoot then
				local knife = getKnifeTool()
				local killEvent = getKillEvent()
				local targets = {}

				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LocalPlayer and not isFriend(plr.Name) and plr.Character then
						local hum = plr.Character:FindFirstChildOfClass("Humanoid")
						local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")
						if hum and hum.Health > 0 and root then
							local dist = (myRoot.Position - root.Position).Magnitude
							if (KILL_AURA.Range <= 0) or (dist <= KILL_AURA.Range) then
								table.insert(targets, { plr = plr, root = root, hum = hum, dist = dist })
							end
						end
					end
				end

				-- En yakindan uzaga sirala
				table.sort(targets, function(a, b) return a.dist < b.dist end)

				if #targets > 0 then
					for _, t in ipairs(targets) do
						if not KILL_AURA.Enabled then break end
						if t.hum and t.hum.Health > 0 and t.root and t.root.Parent then
							if KILL_AURA.TeleportTarget then
								pcall(function()
									t.root.CFrame = myRoot.CFrame * CFrame.new(0, 0, -2.5)
								end)
							end

							-- 1. MM2 / Aim Trainer Knife Remote Stabs
							if knife then
								local stab = knife:FindFirstChild("Stab") or (knife:FindFirstChild("KnifeServer") and knife.KnifeServer:FindFirstChild("Stab"))
								local slash = knife:FindFirstChild("Slash")
								pcall(function()
									if stab then
										stab:FireServer("Down")
										stab:FireServer("Slash")
									end
									if slash then
										slash:FireServer()
									end
								end)

								-- 2. Knife Handle Touch Interest (Direct Instant Contact Damage)
								pcall(function()
									local handle = knife:FindFirstChild("Handle") or knife:FindFirstChildWhichIsA("BasePart")
									if handle and typeof(firetouchinterest) == "function" then
										firetouchinterest(handle, t.root, 0)
										firetouchinterest(handle, t.root, 1)
									end
								end)

								pcall(function() knife:Activate() end)
							end

							-- 3. KillEvent (MM2 Standard Server)
							if killEvent then
								pcall(function()
									killEvent:FireServer(t.plr.Name, Color3.new(1, 0, 0))
								end)
							end

							task.wait(KILL_AURA.AttackDelay)
						end
					end
				else
					task.wait(0.15)
				end
			else
				task.wait(0.4)
			end
		else
			task.wait(0.3)
		end
	end
end)

-- ============================ BOT KILL FARM (AIM TRAINER / RIGS AUTO FARM) ============================
local BOT_FARM = {
	Enabled = false,
	AutoSpawn = true,
	TeleportOffset = -1.5,
}

task.spawn(function()
	while true do
		if BOT_FARM.Enabled and BOT_FARM.AutoSpawn then
			pcall(function()
				local events = ReplicatedStorage:FindFirstChild("Events")
				local remoteEvents = events and events:FindFirstChild("RemoteEvents")
				local startTraining = remoteEvents and remoteEvents:FindFirstChild("StartTraining")
				if startTraining then
					local botConfig = {
						{
							Trainer = "StandingStill",
							SheriffSettings = { AutoShoot = false, ShotAccuracy = "Straight" },
							TrainerSettings = { SpawnWithGun = true, Mini = false },
							CustomNPCs = {
								{ Default = "Roblox", Effect = "None", Knife = "Knife", Gun = "Gun", Morph = 1 },
								{ Default = "Roblox", Effect = "None", Knife = "Knife", Gun = "Gun", Morph = 1 },
								{ Default = "Roblox", Effect = "None", Knife = "Knife", Gun = "Gun", Morph = 1 },
								{ Default = "Roblox", Effect = "None", Knife = "Knife", Gun = "Gun", Morph = 1 },
								{ Default = "Roblox", Effect = "None", Knife = "Knife", Gun = "Gun", Morph = 1 },
								{ Default = "Roblox", Effect = "None", Knife = "Knife", Gun = "Gun", Morph = 1 },
								{ Default = "Roblox", Effect = "None", Knife = "Knife", Gun = "Gun", Morph = 1 },
								{ Default = "Roblox", Effect = "None", Knife = "Knife", Gun = "Gun", Morph = 1 },
								{ Default = "Roblox", Effect = "None", Knife = "Knife", Gun = "Gun", Morph = 1 },
								{ Default = "Roblox", Effect = "None", Knife = "Knife", Gun = "Gun", Morph = 1 },
							},
							MorphType = "Custom",
							Effect = "None",
							Gun = "Gun",
							Role = "Sheriff",
							Movement = "Jump",
							NPCs = 10,
							Knife = "Knife",
							MurdererSettings = { Stabbing = true, DualWield = false, ThrowAccuracy = "OFF" },
							Perk = "None",
							Morph = 1,
						},
					}
					startTraining:FireServer(unpack(botConfig))
				end
			end)
			task.wait(4.5)
		else
			task.wait(1.0)
		end
	end
end)

-- Auto Tool Equip & Slash loop
task.spawn(function()
	while true do
		if BOT_FARM.Enabled then
			pcall(function()
				local char = LocalPlayer.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if char and hum then
					local tool = char:FindFirstChildOfClass("Tool")
						or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChildOfClass("Tool"))
					if tool then
						if tool.Parent ~= char then
							hum:EquipTool(tool)
						end
						local knifeServer = tool:FindFirstChild("KnifeServer")
						local slashStart = knifeServer and knifeServer:FindFirstChild("SlashStart")
						local stab = (knifeServer and knifeServer:FindFirstChild("Stab")) or tool:FindFirstChild("Stab")
						local slash = tool:FindFirstChild("Slash")

						if slashStart then
							slashStart:FireServer()
						end
						if stab then
							pcall(function()
								stab:FireServer("Down")
								stab:FireServer("Slash")
							end)
						end
						if slash then
							pcall(function() slash:FireServer() end)
						end
						pcall(function() tool:Activate() end)
					end
				end
			end)
			task.wait(0.2)
		else
			task.wait(1.0)
		end
	end
end)

-- Teleport Slasher loop for Rigs
task.spawn(function()
	while true do
		if BOT_FARM.Enabled then
			local rigs = workspace:FindFirstChild("Rigs")
				or workspace:FindFirstChild("TrainingRigs")
				or workspace:FindFirstChild("NPCs")
				or workspace:FindFirstChild("Bots")
			local foundTarget = false

			if rigs then
				for _, bot in ipairs(rigs:GetChildren()) do
					if not BOT_FARM.Enabled then break end
					if bot:IsA("Model") and bot:FindFirstChild("HumanoidRootPart") then
						local bHum = bot:FindFirstChildOfClass("Humanoid")
						local bHrp = bot.HumanoidRootPart
						if (not bHum or bHum.Health > 0) and bHrp then
							foundTarget = true
							local startKill = os.clock()
							while os.clock() - startKill < 2.5 do
								if not BOT_FARM.Enabled then break end
								if bHum and bHum.Health <= 0 then break end
								if not bHrp or not bHrp.Parent then break end

								local char = LocalPlayer.Character
								local myHrp = char and char:FindFirstChild("HumanoidRootPart")
								if myHrp and bHrp then
									local offset = CFrame.new(0, 0, BOT_FARM.TeleportOffset)
									myHrp.CFrame = CFrame.lookAt((bHrp.CFrame * offset).Position, bHrp.Position)

									local tool = char:FindFirstChildOfClass("Tool")
									if tool then
										local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
										if handle and typeof(firetouchinterest) == "function" then
											firetouchinterest(handle, bHrp, 0)
											firetouchinterest(handle, bHrp, 1)
										end
										pcall(function() tool:Activate() end)
									end
								end
								task.wait(0.04)
							end
							task.wait(0.06)
						end
					end
				end
			end

			if not foundTarget then
				task.wait(0.4)
			end
		else
			task.wait(1.0)
		end
	end
end)

-- ============================ ESP SISTEMI ============================
-- ==================== NEON BULLET TRACERS & KILL BANNER ====================
local function spawnBulletTracer(origin, hitPos)
	if not SETTINGS.BULLET_TRACERS then return end
	pcall(function()
		local dist = (hitPos - origin).Magnitude
		local beam = Instance.new("Part")
		beam.Name = "ZickLaserBeam"
		beam.Anchored = true
		beam.CanCollide = false
		beam.CanTouch = false
		beam.CanQuery = false
		beam.Material = Enum.Material.Neon
		beam.Color = Color3.fromRGB(180, 50, 255)
		beam.Size = Vector3.new(0.18, 0.18, dist)
		beam.CFrame = CFrame.lookAt(origin, hitPos) * CFrame.new(0, 0, -dist / 2)
		beam.Parent = Workspace:FindFirstChild("Terrain") or Workspace

		TweenService:Create(beam, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
			Size = Vector3.new(0.02, 0.02, dist)
		}):Play()
		task.delay(0.5, function() pcall(function() beam:Destroy() end) end)
	end)
end

local function showKillBanner(victimName, dist)
	if not SETTINGS.KILL_BANNER then return end
	pcall(function()
		local targetParent = (type(gethui) == "function" and gethui()) or CoreGui
		local old = targetParent:FindFirstChild("ZickKillBannerGui")
		if old then pcall(function() old:Destroy() end) end

		local sg = Instance.new("ScreenGui")
		sg.Name = "ZickKillBannerGui"
		sg.ResetOnSpawn = false
		sg.DisplayOrder = 9999
		sg.Parent = targetParent

		local banner = Instance.new("Frame")
		banner.Size = UDim2.new(0, 340, 0, 68)
		banner.Position = UDim2.new(0.5, -170, 0.08, -50)
		banner.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
		banner.BackgroundTransparency = 0.2
		banner.BorderSizePixel = 0
		banner.Parent = sg

		local uic = Instance.new("UICorner")
		uic.CornerRadius = UDim.new(0, 8)
		uic.Parent = banner

		local uis = Instance.new("UIStroke")
		uis.Color = SETTINGS.THEME
		uis.Thickness = 1.8
		uis.Parent = banner

		local t1 = Instance.new("TextLabel")
		t1.Size = UDim2.new(1, 0, 0, 32)
		t1.Position = UDim2.new(0, 0, 0, 6)
		t1.BackgroundTransparency = 1
		t1.Font = Enum.Font.GothamBold
		t1.Text = "★ TARGET ELIMINATED ★"
		t1.TextColor3 = Color3.fromRGB(255, 225, 60)
		t1.TextSize = 17
		t1.Parent = banner

		local t2 = Instance.new("TextLabel")
		t2.Size = UDim2.new(1, 0, 0, 22)
		t2.Position = UDim2.new(0, 0, 0, 36)
		t2.BackgroundTransparency = 1
		t2.Font = Enum.Font.GothamMedium
		t2.Text = string.format("Victim: %s   •   Dist: %dm", tostring(victimName or "Player"), tonumber(dist) or 0)
		t2.TextColor3 = Color3.fromRGB(220, 210, 240)
		t2.TextSize = 12
		t2.Parent = banner

		TweenService:Create(banner, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, -170, 0.12, 0)
		}):Play()

		task.delay(1.5, function()
			if banner and banner.Parent then
				TweenService:Create(banner, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Position = UDim2.new(0.5, -170, 0.08, -50),
					BackgroundTransparency = 1
				}):Play()
				task.delay(0.35, function() pcall(function() sg:Destroy() end) end)
			end
		end)
	end)
end

-- ==================== HITBOX EXPANDER (AIM TRAINER / 5V5 GODMODE) ====================
local originalHitboxes = {}
task.spawn(function()
	while true do
		if SETTINGS.HITBOX_ENABLED then
			local sz = tonumber(SETTINGS.HITBOX_SIZE) or 14
			local tr = tonumber(SETTINGS.HITBOX_TRANS) or 0.65
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and not isFriend(p.Name) and p.Character then
					local hrp = p.Character:FindFirstChild("HumanoidRootPart")
					local hum = p.Character:FindFirstChildOfClass("Humanoid")
					if hrp and hum and hum.Health > 0 then
						if not originalHitboxes[hrp] then
							originalHitboxes[hrp] = { size = hrp.Size, trans = hrp.Transparency, cc = hrp.CanCollide }
						end
						hrp.Size = Vector3.new(sz, sz, sz)
						hrp.Transparency = tr
						hrp.CanCollide = false
					end
				end
			end
		else
			if next(originalHitboxes) then
				for hrp, data in pairs(originalHitboxes) do
					if hrp and hrp.Parent then
						pcall(function()
							hrp.Size = data.size
							hrp.Transparency = data.trans
							hrp.CanCollide = data.cc
						end)
					end
				end
				originalHitboxes = {}
			end
		end
		task.wait(0.3)
	end
end)

-- ==================== SILENT TRIGGERBOT ====================
local lastTriggerShot = 0
RunService.RenderStepped:Connect(function()
	if not SETTINGS.TRIGGERBOT then return end
	if os.clock() - lastTriggerShot < (SETTINGS.TRIGGERBOT_DELAY or 0.05) then return end

	local mouse = LocalPlayer:GetMouse()
	local targetPart = mouse and mouse.Target
	if targetPart and targetPart.Parent then
		local char = targetPart.Parent:IsA("Model") and targetPart.Parent or targetPart.Parent.Parent
		if char and char:IsA("Model") then
			local p = Players:GetPlayerFromCharacter(char)
			if p and p ~= LocalPlayer and not isFriend(p.Name) then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					lastTriggerShot = os.clock()
					pcall(shootV2)
				end
			end
		end
	end
end)

-- ==================== SPINBOT / ANTI-AIM ====================
RunService.RenderStepped:Connect(function()
	if not SETTINGS.SPINBOT_ENABLED then return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hrp and hum and hum.Health > 0 then
		local spd = tonumber(SETTINGS.SPINBOT_SPEED) or 45
		hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad((os.clock() * spd * 12) % 360), 0)
	end
end)

-- ==================== BUNNY HOP & INFINITE JUMP ====================
RunService.RenderStepped:Connect(function()
	if not SETTINGS.BHOP_ENABLED then return end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		if hum.FloorMaterial ~= Enum.Material.Air and hum.MoveDirection.Magnitude > 0 then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if SETTINGS.INF_JUMP then
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- ==================== NOCLIP ENGINE ====================
RunService.Stepped:Connect(function()
	if not SETTINGS.NOCLIP then return end
	local char = LocalPlayer.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end)

-- ==================== FLY HACK ENGINE ====================
local flyBodyVel, flyBodyGyro = nil, nil
task.spawn(function()
	while true do
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if SETTINGS.FLY_ENABLED and hrp and hum and hum.Health > 0 then
			if not flyBodyVel then
				flyBodyVel = Instance.new("BodyVelocity")
				flyBodyVel.Name = "ZickFlyVelocity"
				flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
				flyBodyVel.Parent = hrp

				flyBodyGyro = Instance.new("BodyGyro")
				flyBodyGyro.Name = "ZickFlyGyro"
				flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
				flyBodyGyro.CFrame = hrp.CFrame
				flyBodyGyro.Parent = hrp
			end

			local cam = Camera or Workspace.CurrentCamera
			local moveDir = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

			local speed = tonumber(SETTINGS.FLY_SPEED) or 45
			flyBodyVel.Velocity = moveDir.Unit * speed
			if moveDir.Magnitude == 0 then flyBodyVel.Velocity = Vector3.zero end
			flyBodyGyro.CFrame = cam.CFrame
		else
			if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
			if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
		end
		task.wait(0.03)
	end
end)

-- ==================== GUN MAGNET (AUTO-PULL DROPPED GUN) ====================
task.spawn(function()
	while true do
		if SETTINGS.GUN_MAGNET then
			pcall(grabDroppedGun)
		end
		task.wait(0.4)
	end
end)

local CHAMS_BODY_PARTS = {
	["Head"] = true,
	["Torso"] = true,
	["UpperTorso"] = true,
	["LowerTorso"] = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
	["LeftUpperArm"] = true,
	["LeftLowerArm"] = true,
	["LeftHand"] = true,
	["RightUpperArm"] = true,
	["RightLowerArm"] = true,
	["RightHand"] = true,
	["LeftUpperLeg"] = true,
	["LeftLowerLeg"] = true,
	["LeftFoot"] = true,
	["RightUpperLeg"] = true,
	["RightLowerLeg"] = true,
	["RightFoot"] = true,
}

local function getPlayerRoleAndColor(plr)
	if not plr then
		return "Innocent", Color3.fromRGB(50, 255, 110), "Innocent"
	end
	local char = plr.Character
	local bp = plr:FindFirstChild("Backpack")

	local hasKnife = false
	local hasGun = false
	local weaponName = ""

	local function checkTool(t)
		if not t or not t:IsA("Tool") then return end
		local nameLower = t.Name:lower()
		if nameLower:find("knife") or nameLower:find("blade") or nameLower:find("dagger") or nameLower:find("scythe") or nameLower:find("sword") or t:FindFirstChild("KnifeServer") or t:FindFirstChild("Stab") then
			hasKnife = true
			if weaponName == "" then weaponName = t.Name end
		elseif looksLikeGun(t.Name) or hasShootRemote(t) or nameLower:find("gun") or nameLower:find("revolver") or nameLower:find("phantom") then
			hasGun = true
			if weaponName == "" then weaponName = t.Name end
		end
	end

	if char then
		for _, item in ipairs(char:GetChildren()) do
			checkTool(item)
		end
	end
	if bp and not (hasKnife and hasGun) then
		for _, item in ipairs(bp:GetChildren()) do
			checkTool(item)
		end
	end

	if hasKnife then
		return "Murderer", Color3.fromRGB(255, 45, 65), weaponName ~= "" and weaponName or "Knife"
	elseif hasGun then
		return "Sheriff", Color3.fromRGB(45, 150, 255), weaponName ~= "" and weaponName or "Gun"
	else
		return "Innocent", Color3.fromRGB(50, 255, 110), weaponName ~= "" and weaponName or "Innocent"
	end
end

local espObjects = {}

local function newEspDrawing(kind, props)
	local d = Drawing.new(kind)
	for k, v in pairs(props) do
		d[k] = v
	end
	d.Visible = false
	return d
end

local function ensureEsp(plr)
	if espObjects[plr] then
		return
	end
	espObjects[plr] = {
		name = newEspDrawing("Text", {
			Size = ESP_SETTINGS.TextSize,
			Center = true,
			Outline = true,
			OutlineColor = Color3.new(0, 0, 0),
			Color = ESP_SETTINGS.NameColor,
		}),
		extra = newEspDrawing("Text", {
			Size = ESP_SETTINGS.TextSize - 1,
			Center = true,
			Outline = true,
			OutlineColor = Color3.new(0, 0, 0),
			Color = Color3.fromRGB(220, 220, 220),
		}),
		boxOutline = newEspDrawing("Square", {
			Thickness = 3,
			Color = Color3.new(0, 0, 0),
			Filled = false,
		}),
		box = newEspDrawing("Square", {
			Thickness = 1,
			Color = ESP_SETTINGS.BoxColor,
			Filled = false,
		}),
		tracer = newEspDrawing("Line", {
			Thickness = 1.2,
			Color = ESP_SETTINGS.BoxColor,
		}),
		healthBg = newEspDrawing("Square", {
			Thickness = 1,
			Color = Color3.fromRGB(20, 20, 20),
			Filled = true,
		}),
		health = newEspDrawing("Square", {
			Thickness = 1,
			Color = Color3.fromRGB(80, 220, 80),
			Filled = true,
		}),
		highlight = nil,
		partAdornments = {},
	}
end

local function clearPartAdornments(obj)
	if obj and obj.partAdornments then
		for _, adorn in pairs(obj.partAdornments) do
			pcall(function() adorn:Destroy() end)
		end
		obj.partAdornments = {}
	end
end

local function removeEsp(plr)
	local obj = espObjects[plr]
	if obj then
		for _, key in ipairs({ "name", "extra", "boxOutline", "box", "tracer", "healthBg", "health" }) do
			pcall(function()
				obj[key]:Remove()
			end)
		end
		if obj.highlight then
			pcall(function()
				obj.highlight:Destroy()
			end)
		end
		clearPartAdornments(obj)
		espObjects[plr] = nil
	end
end

local function clearAllEsp()
	for plr in pairs(espObjects) do
		removeEsp(plr)
	end
end

local function hideEsp(obj)
	obj.name.Visible = false
	if obj.extra then obj.extra.Visible = false end
	if obj.boxOutline then obj.boxOutline.Visible = false end
	obj.box.Visible = false
	obj.tracer.Visible = false
	obj.healthBg.Visible = false
	obj.health.Visible = false
	if obj.highlight then
		obj.highlight.Enabled = false
	end
	if obj.partAdornments then
		for _, adorn in pairs(obj.partAdornments) do
			adorn.Visible = false
		end
	end
end

local function teamColorOf(plr)
	if plr.Team then
		return plr.Team.TeamColor.Color
	end
	return nil
end

Players.PlayerAdded:Connect(ensureEsp)
Players.PlayerRemoving:Connect(removeEsp)
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		ensureEsp(plr)
	end
end

local wasEspEnabled = true
local lastEspTick = 0

RunService.RenderStepped:Connect(function()
	if not ESP_SETTINGS.Enabled then
		if wasEspEnabled then
			wasEspEnabled = false
			for _, obj in pairs(espObjects) do
				hideEsp(obj)
			end
		end
		return
	end
	wasEspEnabled = true

	local now = os.clock()
	if now - lastEspTick < 0.025 then
		return
	end
	lastEspTick = now

	local myRoot = getHRP()
	local viewport = Camera.ViewportSize
	for plr, obj in pairs(espObjects) do
		local char = plr.Character
		local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local show = plr ~= LocalPlayer
			and not isFriend(plr.Name)
			and hrp and hum and hum.Health > 0
		if show and ESP_SETTINGS.TeamCheck and teamColorOf(plr) and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
			show = false
		end
		if show and ESP_SETTINGS.MaxDistance > 0 and myRoot then
			if (myRoot.Position - hrp.Position).Magnitude > ESP_SETTINGS.MaxDistance then
				show = false
			end
		end
		if not show then
			hideEsp(obj)
		else
			local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if not onScreen then
				hideEsp(obj)
			else
				local screenPos = Vector2.new(pos.X, pos.Y)

				-- 1. Determine Dynamic Role & Color
				local roleName, roleColor, weaponName = getPlayerRoleAndColor(plr)
				local finalColor = ESP_SETTINGS.BoxColor
				if ESP_SETTINGS.RoleColors then
					finalColor = roleColor
				elseif ESP_SETTINGS.TeamCheck and teamColorOf(plr) then
					finalColor = teamColorOf(plr)
				end

				-- 2. Chams Engine (Part Chams for limbs + Glow Highlight)
				if ESP_SETTINGS.Chams then
					-- Part Chams (3D BoxHandleAdornment on each limb: arms, legs, torso, head)
					if ESP_SETTINGS.PartChams then
						for _, child in ipairs(char:GetChildren()) do
							if child:IsA("BasePart") and CHAMS_BODY_PARTS[child.Name] then
								local adorn = obj.partAdornments[child]
								if not adorn or adorn.Parent ~= child then
									if adorn then pcall(function() adorn:Destroy() end) end
									adorn = Instance.new("BoxHandleAdornment")
									adorn.Name = "ZickPartCham"
									adorn.Adornee = child
									adorn.AlwaysOnTop = true
									adorn.ZIndex = 5
									adorn.Parent = child
									obj.partAdornments[child] = adorn
								end
								adorn.Size = child.Size + Vector3.new(0.04, 0.04, 0.04)
								adorn.Color3 = finalColor
								adorn.Transparency = ESP_SETTINGS.ChamsTransparency or 0.35
								adorn.Visible = true
							end
						end
					else
						for _, adorn in pairs(obj.partAdornments) do
							adorn.Visible = false
						end
					end

					-- Full Glow Highlight
					if ESP_SETTINGS.GlowChams then
						if not obj.highlight or obj.highlight.Parent ~= char then
							if obj.highlight then pcall(function() obj.highlight:Destroy() end) end
							obj.highlight = create("Highlight", {
								Name = "ZickChams",
								DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
								FillColor = finalColor,
								OutlineColor = Color3.new(1, 1, 1),
								FillTransparency = 0.70,
								OutlineTransparency = 0.2,
							})
							obj.highlight.Parent = char
						else
							obj.highlight.FillColor = finalColor
							obj.highlight.Enabled = true
						end
					elseif obj.highlight then
						obj.highlight.Enabled = false
					end
				else
					if obj.highlight then obj.highlight.Enabled = false end
					for _, adorn in pairs(obj.partAdornments) do
						adorn.Visible = false
					end
				end

				-- 3. Box Size & Position Calculation
				local dist = myRoot and (myRoot.Position - hrp.Position).Magnitude or 50
				local scale = math.clamp(2000 / math.max(dist, 1), 8, 200)
				local boxW = scale * 1.15
				local boxH = scale * 2.25
				local boxPos = Vector2.new(screenPos.X - boxW / 2, screenPos.Y - boxH / 2)

				-- 4. Razor Sharp Box (with clean black outline)
				if ESP_SETTINGS.Boxes then
					obj.boxOutline.Size = Vector2.new(boxW, boxH)
					obj.boxOutline.Position = boxPos
					obj.boxOutline.Visible = true

					obj.box.Size = Vector2.new(boxW, boxH)
					obj.box.Position = boxPos
					obj.box.Color = finalColor
					obj.box.Visible = true
				else
					obj.boxOutline.Visible = false
					obj.box.Visible = false
				end

				-- 5. Name + Role + Distance (Top of box)
				local labelText = ESP_SETTINGS.Names and plr.Name or ""
				if ESP_SETTINGS.RoleColors and roleName ~= "Innocent" then
					labelText = labelText .. " [" .. roleName .. "]"
				end
				if ESP_SETTINGS.Distance then
					labelText = labelText .. (labelText ~= "" and " " or "") .. "[" .. math.floor(dist) .. "m]"
				end
				if labelText ~= "" then
					obj.name.Text = labelText
					obj.name.Size = ESP_SETTINGS.TextSize
					obj.name.Position = Vector2.new(screenPos.X, boxPos.Y - 15)
					obj.name.Color = (ESP_SETTINGS.RoleColors and finalColor) or ESP_SETTINGS.NameColor
					obj.name.Visible = true
				else
					obj.name.Visible = false
				end

				-- 6. Weapon Label (Bottom of box)
				local bottomText = ""
				if ESP_SETTINGS.Weapon and weaponName and weaponName ~= "None" and weaponName ~= "Innocent" then
					bottomText = "[" .. weaponName .. "]"
				end
				if bottomText ~= "" then
					obj.extra.Text = bottomText
					obj.extra.Size = ESP_SETTINGS.TextSize - 1
					obj.extra.Position = Vector2.new(screenPos.X, boxPos.Y + boxH + 2)
					obj.extra.Color = finalColor
					obj.extra.Visible = true
				else
					obj.extra.Visible = false
				end

				-- 7. Smooth Gradient Health Bar
				if ESP_SETTINGS.HealthBars then
					local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
					local barH = boxH * pct
					obj.healthBg.Size = Vector2.new(3, boxH)
					obj.healthBg.Position = Vector2.new(boxPos.X - 6, boxPos.Y)
					obj.healthBg.Visible = true
					obj.health.Size = Vector2.new(3, barH)
					obj.health.Position = Vector2.new(boxPos.X - 6, boxPos.Y + (boxH - barH))
					obj.health.Color = Color3.fromRGB(math.floor(255 * (1 - pct)), math.floor(255 * pct), 50)
					obj.health.Visible = true
				else
					obj.healthBg.Visible = false
					obj.health.Visible = false
				end

				-- 8. Tracer (Colorized)
				if ESP_SETTINGS.Tracers then
					obj.tracer.From = Vector2.new(viewport.X / 2, viewport.Y)
					obj.tracer.To = screenPos
					obj.tracer.Color = finalColor
					obj.tracer.Visible = true
				else
					obj.tracer.Visible = false
				end
			end
		end
	end
end)

-- ==================== DROPPED SHERIFF GUN ESP ====================
local _zickGunHighlight = nil
local _zickGunBillboard = nil
local _zickGunTarget = nil

local function cleanupZickGunESP()
	if _zickGunHighlight then
		pcall(function() _zickGunHighlight:Destroy() end)
		_zickGunHighlight = nil
	end
	if _zickGunBillboard then
		pcall(function() _zickGunBillboard:Destroy() end)
		_zickGunBillboard = nil
	end
	_zickGunTarget = nil
end

local function applyZickGunESP(targetPart)
	if not targetPart or not targetPart.Parent then return end
	if _zickGunTarget == targetPart and _zickGunBillboard and _zickGunBillboard.Parent then return end
	cleanupZickGunESP()

	_zickGunTarget = targetPart

	-- Radiant Gold Highlight
	local hl = Instance.new("Highlight")
	hl.Name = "ZickSheriffGunHighlight"
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillTransparency = 0.25
	hl.OutlineTransparency = 0
	hl.FillColor = Color3.fromRGB(255, 215, 0)
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.Adornee = targetPart
	hl.Parent = targetPart
	_zickGunHighlight = hl

	-- Prominent "Sheriff Gun" Billboard
	local bb = Instance.new("BillboardGui")
	bb.Name = "ZickSheriffGunBillboard"
	bb.AlwaysOnTop = true
	bb.Size = UDim2.new(0, 220, 0, 54)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.LightInfluence = 0
	bb.MaxDistance = 3500
	bb.Adornee = targetPart
	bb.Parent = targetPart
	_zickGunBillboard = bb

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 28)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "★ Sheriff Gun ★"
	title.TextColor3 = Color3.fromRGB(255, 225, 50)
	title.TextSize = 22
	title.TextStrokeTransparency = 0
	title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
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

	targetPart.Destroying:Connect(function()
		cleanupZickGunESP()
	end)
end

RunService.RenderStepped:Connect(function()
	if not (ESP_SETTINGS.Enabled and ESP_SETTINGS.GunDrop) then
		if _zickGunTarget then cleanupZickGunESP() end
		return
	end

	local dropNames = { "GunDrop", "Gun", "PhantomScopeDrop", "PhantomDrop", "ScopeDrop" }
	local foundDrop = nil
	for _, name in ipairs(dropNames) do
		local drop = Workspace:FindFirstChild(name, true)
		if drop and (drop:IsA("BasePart") or drop:IsA("Model")) then
			foundDrop = drop
			break
		end
	end

	if not foundDrop then
		for _, desc in ipairs(Workspace:GetDescendants()) do
			if desc.Name == "GunDrop" or (desc:IsA("BasePart") and desc.Name:lower():find("gundrop")) then
				foundDrop = desc
				break
			end
		end
	end

	if foundDrop and foundDrop.Parent then
		local handle = foundDrop:IsA("BasePart") and foundDrop or foundDrop:FindFirstChildWhichIsA("BasePart") or foundDrop:FindFirstChild("Handle")
		if handle then
			applyZickGunESP(handle)
			if _zickGunBillboard and _zickGunBillboard:FindFirstChild("Distance") then
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local d = math.floor((hrp.Position - handle.Position).Magnitude)
					_zickGunBillboard.Distance.Text = string.format("[%d studs]", d)
				end
			end
		end
	else
		if _zickGunTarget then cleanupZickGunESP() end
	end
end)

-- ============================ RANAX MMV TARZI MENU ============================
local menuGui = create("ScreenGui", {
	Name = "ZickHubMenu",
	ResetOnSpawn = false,
	DisplayOrder = 1000,
})
guiParent(menuGui)

local mainFrame = create("Frame", {
	Name = "MainFrame",
	Size = UDim2.new(0, 520, 0, 360),
	Position = UDim2.new(0.5, -260, 0.5, -180),
	BackgroundColor3 = SETTINGS.THEME_BG,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 1,
}, menuGui)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, mainFrame)
create("UIStroke", { Color = SETTINGS.THEME, Thickness = 1.4, Transparency = 0.25 }, mainFrame)

local topBar = create("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 36),
	BackgroundColor3 = SETTINGS.THEME_TOP,
	BorderSizePixel = 0,
	ZIndex = 2,
}, mainFrame)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, topBar)

create("TextLabel", {
	Size = UDim2.new(1, -80, 1, 0),
	Position = UDim2.new(0, 12, 0, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Zick Hub V2",
	TextColor3 = SETTINGS.THEME,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 3,
}, topBar)

local closeBtn = create("TextButton", {
	Size = UDim2.new(0, 24, 0, 24),
	Position = UDim2.new(1, -30, 0, 6),
	BackgroundColor3 = Color3.fromRGB(160, 40, 40),
	Font = Enum.Font.GothamBold,
	Text = "X",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 12,
	ZIndex = 3,
}, topBar)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, closeBtn)

local minBtn = create("TextButton", {
	Size = UDim2.new(0, 24, 0, 24),
	Position = UDim2.new(1, -58, 0, 6),
	BackgroundColor3 = SETTINGS.THEME,
	Font = Enum.Font.GothamBold,
	Text = "-",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 14,
	ZIndex = 3,
}, topBar)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, minBtn)

-- Surukleme
do
	local dragging, dragStart, startPos = false, nil, nil
	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Sol sekme bar
local tabBar = create("Frame", {
	Name = "TabBar",
	Size = UDim2.new(0, 120, 1, -36),
	Position = UDim2.new(0, 0, 0, 36),
	BackgroundColor3 = SETTINGS.THEME_TOP,
	BorderSizePixel = 0,
	ZIndex = 2,
}, mainFrame)
create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, tabBar)

local tabContents = {}
local tabButtons = {}
local currentTab = nil

local function switchTab(name)
	currentTab = name
	for tabName, content in pairs(tabContents) do
		content.Visible = (tabName == name)
	end
	for tabName, btn in pairs(tabButtons) do
		btn.BackgroundColor3 = (tabName == name) and SETTINGS.THEME or SETTINGS.THEME_ROW
	end
end

local function createTab(name)
	local btn = create("TextButton", {
		Size = UDim2.new(1, -8, 0, 32),
		BackgroundColor3 = SETTINGS.THEME_ROW,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = name,
		TextColor3 = SETTINGS.THEME_TEXT,
		TextSize = 13,
		ZIndex = 3,
		LayoutOrder = #tabButtons + 1,
	}, tabBar)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

	local content = create("ScrollingFrame", {
		Size = UDim2.new(1, -128, 1, -44),
		Position = UDim2.new(0, 124, 0, 40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = SETTINGS.THEME,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Visible = false,
		ZIndex = 2,
	}, mainFrame)
	local layout = create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, content)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	btn.MouseButton1Click:Connect(function()
		switchTab(name)
	end)

	tabContents[name] = content
	tabButtons[name] = btn
	return content
end

local rowOrder = {}
local toggleRefreshers = {}
local function nextOrder(content)
	rowOrder[content] = (rowOrder[content] or 0) + 1
	return rowOrder[content]
end

local function createDropdownRow(content, text, options, get, set)
	local order = nextOrder(content)
	local row = create("TextButton", {
		Size = UDim2.new(1, -6, 0, 32),
		BackgroundColor3 = SETTINGS.THEME_ROW,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 2,
		LayoutOrder = order,
	}, content)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, row)

	create("TextLabel", {
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = SETTINGS.THEME_TEXT,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	}, row)

	local optPill = create("TextLabel", {
		Size = UDim2.new(0, 105, 0, 22),
		Position = UDim2.new(1, -112, 0.5, -11),
		BackgroundColor3 = SETTINGS.THEME,
		Font = Enum.Font.GothamBold,
		Text = tostring(get()),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 11,
		ZIndex = 3,
	}, row)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, optPill)

	local function refresh()
		optPill.Text = tostring(get())
	end

	row.MouseButton1Click:Connect(function()
		local cur = get()
		local idx = 1
		for i, o in ipairs(options) do
			if o == cur then idx = i break end
		end
		idx = (idx % #options) + 1
		set(options[idx])
		refresh()
	end)

	refresh()
	table.insert(toggleRefreshers, refresh)
	return row
end

-- ==================== INTERAKTIF TUS ATAMA (KEYBIND BUILDER) ====================
local function createKeybindRow(content, text, getKey, setKey)
	local order = nextOrder(content)
	local row = create("TextButton", {
		Size = UDim2.new(1, -6, 0, 32),
		BackgroundColor3 = SETTINGS.THEME_ROW,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 2,
		LayoutOrder = order,
	}, content)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, row)

	create("TextLabel", {
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = SETTINGS.THEME_TEXT,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	}, row)

	local keyPill = create("TextLabel", {
		Size = UDim2.new(0, 96, 0, 22),
		Position = UDim2.new(1, -104, 0.5, -11),
		BackgroundColor3 = Color3.fromRGB(40, 30, 60),
		Font = Enum.Font.GothamBold,
		Text = "[--]",
		TextColor3 = Color3.fromRGB(240, 230, 255),
		TextSize = 11,
		ZIndex = 3,
	}, row)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, keyPill)
	create("UIStroke", { Color = SETTINGS.THEME, Thickness = 1, Transparency = 0.4 }, keyPill)

	local listening = false
	local function refresh()
		if listening then
			keyPill.Text = "[Tusa Bas...]"
			keyPill.BackgroundColor3 = SETTINGS.THEME
			keyPill.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			local k = getKey()
			local kname = (typeof(k) == "EnumItem" and k.Name) or tostring(k):gsub("Enum.KeyCode.", "")
			keyPill.Text = "[" .. kname .. "]"
			keyPill.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
			keyPill.TextColor3 = Color3.fromRGB(240, 230, 255)
		end
	end

	row.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		refresh()

		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gpe)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				conn:Disconnect()
				conn = nil
				listening = false
				setKey(input.KeyCode)
				notify("Keybind", text .. " bound to: [" .. input.KeyCode.Name .. "]", 2)
				refresh()
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
				conn:Disconnect()
				conn = nil
				listening = false
				refresh()
			end
		end)
	end)

	refresh()
	table.insert(toggleRefreshers, refresh)
	return row
end

local function createToggleRow(content, text, get, set)
	local order = nextOrder(content)
	local row = create("TextButton", {
		Size = UDim2.new(1, -6, 0, 30),
		BackgroundColor3 = SETTINGS.THEME_ROW,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 2,
		LayoutOrder = order,
	}, content)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, row)

	create("TextLabel", {
		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = SETTINGS.THEME_TEXT,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	}, row)

	local pill = create("TextLabel", {
		Size = UDim2.new(0, 44, 0, 20),
		Position = UDim2.new(1, -52, 0.5, -10),
		BackgroundColor3 = Color3.fromRGB(60, 60, 60),
		Font = Enum.Font.GothamBold,
		Text = "OFF",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 11,
		ZIndex = 3,
	}, row)
	create("UICorner", { CornerRadius = UDim.new(0, 10) }, pill)

	local function refresh()
		local v = get()
		pill.Text = v and "ON" or "OFF"
		pill.BackgroundColor3 = v and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(60, 60, 60)
	end
	row.MouseButton1Click:Connect(function()
		local cur = get()
		local newVal = not cur
		set(newVal)
		refresh()
		notify(text, newVal and "ENABLED [ON]" or "DISABLED [OFF]", 1.6, newVal)
	end)
	refresh()
	table.insert(toggleRefreshers, refresh)
	return row, refresh
end


local function createSliderRow(content, text, min, max, default, onChange, fmt)
	local order = nextOrder(content)
	local row = create("Frame", {
		Size = UDim2.new(1, -6, 0, 40),
		BackgroundColor3 = SETTINGS.THEME_ROW,
		BorderSizePixel = 0,
		ZIndex = 2,
		LayoutOrder = order,
	}, content)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, row)

	create("TextLabel", {
		Size = UDim2.new(1, -70, 0, 16),
		Position = UDim2.new(0, 10, 0, 4),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = SETTINGS.THEME_TEXT,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	}, row)

	local valueLabel = create("TextLabel", {
		Size = UDim2.new(0, 60, 0, 16),
		Position = UDim2.new(1, -66, 0, 4),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = fmt and fmt(default) or tostring(default),
		TextColor3 = SETTINGS.THEME,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
	}, row)

	local bar = create("Frame", {
		Size = UDim2.new(1, -20, 0, 6),
		Position = UDim2.new(0, 10, 1, -12),
		BackgroundColor3 = Color3.fromRGB(25, 18, 38),
		BorderSizePixel = 0,
		ZIndex = 3,
	}, row)
	create("UICorner", { CornerRadius = UDim.new(0, 3) }, bar)

	local fill = create("Frame", {
		Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = SETTINGS.THEME,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, bar)
	create("UICorner", { CornerRadius = UDim.new(0, 3) }, fill)

	local value = default
	local draggingSlider = false
	local function setValueFromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		value = math.floor(min + rel * (max - min) * 100 + 0.5) / 100
		fill.Size = UDim2.new(rel, 0, 1, 0)
		valueLabel.Text = fmt and fmt(value) or tostring(value)
		onChange(value)
	end
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			setValueFromX(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setValueFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = false
		end
	end)
	return row
end

local function createButtonRow(content, text, action)
	local order = nextOrder(content)
	local row = create("TextButton", {
		Size = UDim2.new(1, -6, 0, 30),
		BackgroundColor3 = SETTINGS.THEME,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = text,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12,
		ZIndex = 2,
		LayoutOrder = order,
	}, content)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, row)
	row.MouseButton1Click:Connect(action)
	return row
end

-- Sekmeler
local combatTab = createTab("Combat")
local visualsTab = createTab("Visuals")
local playerTab = createTab("Player")
local miscTab = createTab("Misc")
local friendsTab = createTab("Friends")

-- COMBAT (5v5 / AIM TRAINER / FFA / MM2 CLOSEST MOTORU)
createToggleRow(combatTab, "Shoot V2 (Auto-Fire)", function() return SETTINGS.AUTO_FIRE end, function(v) SETTINGS.AUTO_FIRE = v end)
createKeybindRow(combatTab, "Shoot Keybind", function() return SETTINGS.KEYBIND end, function(k) SETTINGS.KEYBIND = k end)
createToggleRow(combatTab, "Flick Shoot", function() return SETTINGS.FLICK_ENABLED end, function(v) SETTINGS.FLICK_ENABLED = v end)
createKeybindRow(combatTab, "Flick Keybind", function() return SETTINGS.FLICK_KEY end, function(k) SETTINGS.FLICK_KEY = k end)
createToggleRow(combatTab, "Silent Triggerbot", function() return SETTINGS.TRIGGERBOT end, function(v) SETTINGS.TRIGGERBOT = v end)
createDropdownRow(combatTab, "Targeting Mode", {"FOV", "Range (Mesafe)"}, function() return SETTINGS.TARGET_MODE end, function(v) SETTINGS.TARGET_MODE = v end)
createToggleRow(combatTab, "Auto Equip Gun", function() return SETTINGS.AUTO_EQUIP end, function(v) SETTINGS.AUTO_EQUIP = v end)
createDropdownRow(combatTab, "Shooting Method", {"New (Blatant)", "Normal"}, function() return SETTINGS.SHOOT_METHOD end, function(v) SETTINGS.SHOOT_METHOD = v end)
createToggleRow(combatTab, "Hitbox Expander", function() return SETTINGS.HITBOX_ENABLED end, function(v) SETTINGS.HITBOX_ENABLED = v end)
createSliderRow(combatTab, "Hitbox Size (studs)", 5, 30, SETTINGS.HITBOX_SIZE, function(v) SETTINGS.HITBOX_SIZE = v end, function(v) return tostring(math.floor(v)) end)
createToggleRow(combatTab, "Flick Camera Snap", function() return SETTINGS.FLICK_CAMERA end, function(v) SETTINGS.FLICK_CAMERA = v end)
createToggleRow(combatTab, "Flick Return Ease", function() return SETTINGS.FLICK_RESTORE end, function(v) SETTINGS.FLICK_RESTORE = v end)
createSliderRow(combatTab, "Flick Duration (s)", 0.02, 0.3, SETTINGS.FLICK_TURN_TIME, function(v) SETTINGS.FLICK_TURN_TIME = v end, function(v) return string.format("%.2f", v) end)
createToggleRow(combatTab, "Wall Check", function() return SETTINGS.WALL_CHECK end, function(v) SETTINGS.WALL_CHECK = v end)
createToggleRow(combatTab, "Bullet Tracers", function() return SETTINGS.BULLET_TRACERS end, function(v) SETTINGS.BULLET_TRACERS = v end)
createToggleRow(combatTab, "Kill Banner", function() return SETTINGS.KILL_BANNER end, function(v) SETTINGS.KILL_BANNER = v end)
createToggleRow(combatTab, "Gun Magnet", function() return SETTINGS.GUN_MAGNET end, function(v) SETTINGS.GUN_MAGNET = v end)
createToggleRow(combatTab, "Hit Sound", function() return SETTINGS.HIT_SOUND end, function(v) SETTINGS.HIT_SOUND = v end)
createToggleRow(combatTab, "Auto Reload", function() return SETTINGS.AUTO_RELOAD end, function(v) SETTINGS.AUTO_RELOAD = v end)
createSliderRow(combatTab, "Shoot Delay (s)", 0.05, 1, SETTINGS.SHOOT_DELAY, function(v) SETTINGS.SHOOT_DELAY = v end, function(v) return string.format("%.2f", v) end)
createSliderRow(combatTab, "Prediction Lead", 0, 10, SETTINGS.PREDICT_OFFSET, function(v) SETTINGS.PREDICT_OFFSET = v end, function(v) return string.format("%.1f", v) end)
createSliderRow(combatTab, "FOV Radius (px)", 20, 500, SETTINGS.FOV_RADIUS, function(v) SETTINGS.FOV_RADIUS = v end, function(v) return tostring(math.floor(v)) end)
createSliderRow(combatTab, "Max Range (studs)", 0, 1000, SETTINGS.MAX_RANGE, function(v) SETTINGS.MAX_RANGE = v end, function(v) return v == 0 and "Infinite" or tostring(math.floor(v)) end)
createToggleRow(combatTab, "Kill Aura (5v5/FFA/MM2)", function() return KILL_AURA.Enabled end, function(v) KILL_AURA.Enabled = v end)
createToggleRow(combatTab, "Kill Aura: Auto Equip Knife", function() return KILL_AURA.AutoEquipKnife end, function(v) KILL_AURA.AutoEquipKnife = v end)
createToggleRow(combatTab, "Kill Aura: Teleport Targets", function() return KILL_AURA.TeleportTarget end, function(v) KILL_AURA.TeleportTarget = v end)
createSliderRow(combatTab, "Kill Aura Delay (s)", 0.05, 1, KILL_AURA.AttackDelay, function(v) KILL_AURA.AttackDelay = v end, function(v) return string.format("%.2f", v) end)
createSliderRow(combatTab, "Kill Aura Range (studs)", 0, 100, KILL_AURA.Range, function(v) KILL_AURA.Range = v end, function(v) return v == 0 and "ALL" or tostring(math.floor(v)) end)
createToggleRow(combatTab, "Bot Kill Farm (Aim Trainer)", function() return BOT_FARM.Enabled end, function(v)
	BOT_FARM.Enabled = v
	notify("Bot Farm", v and "Auto Bot Farm ACTIVE" or "Auto Bot Farm OFF", 2.5, v and "sword" or "x")
end)
createToggleRow(combatTab, "Bot Farm: Auto-Spawn Bots", function() return BOT_FARM.AutoSpawn end, function(v) BOT_FARM.AutoSpawn = v end)

-- VISUALS
createToggleRow(visualsTab, "ESP", function() return ESP_SETTINGS.Enabled end, function(v) ESP_SETTINGS.Enabled = v end)
createToggleRow(visualsTab, "ESP Chams", function() return ESP_SETTINGS.Chams end, function(v) ESP_SETTINGS.Chams = v end)
createToggleRow(visualsTab, "ESP Part Chams (Limbs)", function() return ESP_SETTINGS.PartChams end, function(v) ESP_SETTINGS.PartChams = v end)
createToggleRow(visualsTab, "ESP Glow Chams", function() return ESP_SETTINGS.GlowChams end, function(v) ESP_SETTINGS.GlowChams = v end)
createToggleRow(visualsTab, "ESP Role Colors (MM2)", function() return ESP_SETTINGS.RoleColors end, function(v) ESP_SETTINGS.RoleColors = v end)
createToggleRow(visualsTab, "ESP Weapon Tags", function() return ESP_SETTINGS.Weapon end, function(v) ESP_SETTINGS.Weapon = v end)
createToggleRow(visualsTab, "ESP Gun Drop (Sheriff Gun)", function() return ESP_SETTINGS.GunDrop end, function(v) ESP_SETTINGS.GunDrop = v end)
createToggleRow(visualsTab, "ESP Names", function() return ESP_SETTINGS.Names end, function(v) ESP_SETTINGS.Names = v end)
createToggleRow(visualsTab, "ESP Boxes", function() return ESP_SETTINGS.Boxes end, function(v) ESP_SETTINGS.Boxes = v end)
createToggleRow(visualsTab, "ESP Tracers", function() return ESP_SETTINGS.Tracers end, function(v) ESP_SETTINGS.Tracers = v end)
createToggleRow(visualsTab, "ESP Health Bars", function() return ESP_SETTINGS.HealthBars end, function(v) ESP_SETTINGS.HealthBars = v end)
createToggleRow(visualsTab, "ESP Distance", function() return ESP_SETTINGS.Distance end, function(v) ESP_SETTINGS.Distance = v end)
createToggleRow(visualsTab, "ESP Team Check", function() return ESP_SETTINGS.TeamCheck end, function(v) ESP_SETTINGS.TeamCheck = v end)
createSliderRow(visualsTab, "Chams Transparency (%)", 0, 90, math.floor(ESP_SETTINGS.ChamsTransparency * 100), function(v) ESP_SETTINGS.ChamsTransparency = v / 100 end, function(v) return tostring(math.floor(v)) .. "%" end)
createSliderRow(visualsTab, "ESP Max Distance (studs)", 0, 2000, ESP_SETTINGS.MaxDistance, function(v) ESP_SETTINGS.MaxDistance = math.floor(v) end, function(v) return v == 0 and "Infinite" or tostring(math.floor(v)) end)
createSliderRow(visualsTab, "ESP Font Size", 10, 22, ESP_SETTINGS.TextSize, function(v) ESP_SETTINGS.TextSize = math.floor(v) end)
createToggleRow(visualsTab, "FOV Circle", function() return SETTINGS.FOV_SHOW end, function(v) SETTINGS.FOV_SHOW = v end)

-- PLAYER & MOVEMENT
createToggleRow(playerTab, "Fly Hack", function() return SETTINGS.FLY_ENABLED end, function(v) SETTINGS.FLY_ENABLED = v end)
createKeybindRow(playerTab, "Fly Keybind", function() return SETTINGS.FLY_KEY end, function(k) SETTINGS.FLY_KEY = k end)
createSliderRow(playerTab, "Fly Speed", 15, 150, SETTINGS.FLY_SPEED, function(v) SETTINGS.FLY_SPEED = v end, function(v) return tostring(math.floor(v)) end)
createToggleRow(playerTab, "Noclip", function() return SETTINGS.NOCLIP end, function(v) SETTINGS.NOCLIP = v end)
createToggleRow(playerTab, "Bunny Hop", function() return SETTINGS.BHOP_ENABLED end, function(v) SETTINGS.BHOP_ENABLED = v end)
createToggleRow(playerTab, "Speed TP (CFrame)", function() return PLAYER_SETTINGS.SpeedEnabled end, function(v)
	PLAYER_SETTINGS.SpeedEnabled = v
	notify("Movement", v and "Speed TP: ACTIVE" or "Speed TP: OFF", 2, v and "zap" or "x")
end)
createSliderRow(playerTab, "Speed TP Value", 16, 200, PLAYER_SETTINGS.SpeedValue, function(v) PLAYER_SETTINGS.SpeedValue = v end, function(v) return tostring(math.floor(v)) end)
createToggleRow(playerTab, "JumpPower", function() return PLAYER_SETTINGS.JumpEnabled end, function(v) PLAYER_SETTINGS.JumpEnabled = v end)
createSliderRow(playerTab, "JumpPower Value", 50, 250, PLAYER_SETTINGS.JumpValue, function(v) PLAYER_SETTINGS.JumpValue = v end, function(v) return tostring(math.floor(v)) end)
createButtonRow(playerTab, "Reset Movement", function()
	PLAYER_SETTINGS.SpeedEnabled = false
	PLAYER_SETTINGS.JumpEnabled = false
	SETTINGS.FLY_ENABLED = false
	SETTINGS.NOCLIP = false
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 16
		hum.JumpPower = 50
		hum.UseJumpPower = true
	end
end)

-- MISC & RAGE TECH
createKeybindRow(miscTab, "Menu Keybind", function() return SETTINGS.MENU_KEY end, function(k) SETTINGS.MENU_KEY = k end)
createToggleRow(miscTab, "Spinbot / Anti-Aim", function() return SETTINGS.SPINBOT_ENABLED end, function(v) SETTINGS.SPINBOT_ENABLED = v end)
createSliderRow(miscTab, "Spinbot Speed", 10, 100, SETTINGS.SPINBOT_SPEED, function(v) SETTINGS.SPINBOT_SPEED = v end, function(v) return tostring(math.floor(v)) end)
createToggleRow(miscTab, "Anti AFK", function() return PLAYER_SETTINGS.AntiAFK end, function(v) PLAYER_SETTINGS.AntiAFK = v end)
createToggleRow(miscTab, "FPS Boost", function() return PLAYER_SETTINGS.FPSBoost end, function(v)
	PLAYER_SETTINGS.FPSBoost = v
	pcall(function()
		Lighting.GlobalShadows = not v
		Lighting.FogEnd = v and 9e9 or 1000
		Lighting.Brightness = v and 1 or 2
		settings().Rendering.QualityLevel = v and 1 or 10
		for _, desc in ipairs(workspace:GetDescendants()) do
			if desc:IsA("PostEffect") then
				desc.Enabled = not v
			elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") or desc:IsA("Smoke") or desc:IsA("Fire") then
				desc.Enabled = not v
			end
		end
	end)
end)
createToggleRow(miscTab, "Debug Log", function() return SETTINGS.DEBUG end, function(v) SETTINGS.DEBUG = v end)
createButtonRow(miscTab, "Copy Discord Invite", function()
	if type(setclipboard) == "function" then
		pcall(setclipboard, SETTINGS.DISCORD)
	end
	notify("Zick Hub V2", "Discord invite copied to clipboard!", 3)
end)
createButtonRow(miscTab, "Rejoin Server", function()
	pcall(function()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end)
end)

-- ============================ FRIENDS TAB (INTEGRATED INTO CLICK GUI) ============================
local friendInputRow = create("Frame", {
	Size = UDim2.new(1, -6, 0, 36),
	BackgroundColor3 = SETTINGS.THEME_ROW,
	BorderSizePixel = 0,
	LayoutOrder = nextOrder(friendsTab),
	ZIndex = 2,
}, friendsTab)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, friendInputRow)

local friendNameBox = create("TextBox", {
	Size = UDim2.new(1, -130, 0, 26),
	Position = UDim2.new(0, 8, 0.5, -13),
	BackgroundColor3 = SETTINGS.THEME_BG,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	PlaceholderText = "Enter Username to Friend...",
	Text = "",
	TextColor3 = SETTINGS.THEME_TEXT,
	TextSize = 12,
	ClearTextOnFocus = false,
	ZIndex = 3,
}, friendInputRow)
create("UICorner", { CornerRadius = UDim.new(0, 5) }, friendNameBox)

local friendAddBtn = create("TextButton", {
	Size = UDim2.new(0, 52, 0, 26),
	Position = UDim2.new(1, -116, 0.5, -13),
	BackgroundColor3 = Color3.fromRGB(45, 140, 65),
	Font = Enum.Font.GothamBold,
	Text = "Add",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 12,
	ZIndex = 3,
}, friendInputRow)
create("UICorner", { CornerRadius = UDim.new(0, 5) }, friendAddBtn)

local friendClearBtn = create("TextButton", {
	Size = UDim2.new(0, 54, 0, 26),
	Position = UDim2.new(1, -60, 0.5, -13),
	BackgroundColor3 = Color3.fromRGB(150, 40, 40),
	Font = Enum.Font.GothamBold,
	Text = "Clear",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 11,
	ZIndex = 3,
}, friendInputRow)
create("UICorner", { CornerRadius = UDim.new(0, 5) }, friendClearBtn)

local friendHeaderRow = create("Frame", {
	Size = UDim2.new(1, -6, 0, 22),
	BackgroundTransparency = 1,
	LayoutOrder = nextOrder(friendsTab),
	ZIndex = 2,
}, friendsTab)

local friendCountLabel = create("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	Position = UDim2.new(0, 4, 0, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Saved Friends (0)",
	TextColor3 = SETTINGS.THEME,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 3,
}, friendHeaderRow)

local friendListContainer = create("Frame", {
	Size = UDim2.new(1, -6, 0, 0),
	BackgroundTransparency = 1,
	LayoutOrder = nextOrder(friendsTab),
	AutomaticSize = Enum.AutomaticSize.Y,
	ZIndex = 2,
}, friendsTab)
local friendListLayout = create("UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 5),
}, friendListContainer)

local function renderMenuFriendList()
	for _, child in ipairs(friendListContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	friendCountLabel.Text = "Saved Friends (" .. tostring(#FriendOrder) .. ")"

	if #FriendOrder == 0 then
		local emptyRow = create("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = SETTINGS.THEME_ROW,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			ZIndex = 2,
		}, friendListContainer)
		create("UICorner", { CornerRadius = UDim.new(0, 6) }, emptyRow)
		create("TextLabel", {
			Size = UDim2.new(1, -12, 1, 0),
			Position = UDim2.new(0, 6, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = "No friends added. Friends are ignored by Aimbot, Flick Shoot & Kill Aura.",
			TextColor3 = Color3.fromRGB(150, 140, 170),
			TextSize = 11,
			ZIndex = 3,
		}, emptyRow)
		return
	end

	for i, name in ipairs(FriendOrder) do
		local inServer = Players:FindFirstChild(name) ~= nil
		local row = create("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = SETTINGS.THEME_ROW,
			BorderSizePixel = 0,
			LayoutOrder = i,
			ZIndex = 2,
		}, friendListContainer)
		create("UICorner", { CornerRadius = UDim.new(0, 6) }, row)

		local dot = create("Frame", {
			Size = UDim2.new(0, 8, 0, 8),
			Position = UDim2.new(0, 10, 0.5, -4),
			BackgroundColor3 = inServer and Color3.fromRGB(50, 220, 80) or Color3.fromRGB(100, 100, 110),
			BorderSizePixel = 0,
			ZIndex = 3,
		}, row)
		create("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)

		create("TextLabel", {
			Size = UDim2.new(1, -120, 1, 0),
			Position = UDim2.new(0, 26, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = name .. (inServer and " [In Server]" or ""),
			TextColor3 = inServer and Color3.fromRGB(255, 255, 255) or SETTINGS.THEME_TEXT,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
		}, row)

		local delBtn = create("TextButton", {
			Size = UDim2.new(0, 56, 0, 22),
			Position = UDim2.new(1, -62, 0.5, -11),
			BackgroundColor3 = Color3.fromRGB(130, 35, 35),
			Font = Enum.Font.GothamBold,
			Text = "Remove",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 11,
			ZIndex = 3,
		}, row)
		create("UICorner", { CornerRadius = UDim.new(0, 5) }, delBtn)
		delBtn.MouseButton1Click:Connect(function()
			if removeFriend(name) then
				renderMenuFriendList()
			end
		end)
	end
end

friendAddBtn.MouseButton1Click:Connect(function()
	local n = friendNameBox.Text:gsub("^%s*(.-)%s*$", "%1")
	if n ~= "" and addFriend(n) then
		friendNameBox.Text = ""
		renderMenuFriendList()
	end
end)

friendNameBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local n = friendNameBox.Text:gsub("^%s*(.-)%s*$", "%1")
		if n ~= "" and addFriend(n) then
			friendNameBox.Text = ""
			renderMenuFriendList()
		end
	end
end)

friendClearBtn.MouseButton1Click:Connect(function()
	clearFriends()
	saveFriends()
	renderMenuFriendList()
end)

renderMenuFriendList()

-- Menyu ac/kapa (LeftControl) + Alt/Ust Kapatma Butonlari
local menuVisible = true
local function setMenuVisible(v)
	menuVisible = v
	mainFrame.Visible = v
end

minBtn.MouseButton1Click:Connect(function()
	setMenuVisible(false)
	notify("Zick Hub V2", "Menu hidden (Press " .. (SETTINGS.MENU_KEY and SETTINGS.MENU_KEY.Name or "LeftControl") .. " to open)", 2)
end)

closeBtn.MouseButton1Click:Connect(function()
	setMenuVisible(false)
	notify("Zick Hub V2", "Menu hidden (Press " .. (SETTINGS.MENU_KEY and SETTINGS.MENU_KEY.Name or "LeftControl") .. " to open)", 2)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	local targetKey = SETTINGS.MENU_KEY or Enum.KeyCode.LeftControl
	if input.KeyCode == targetKey then
		-- Yazi kutusuna (Friend box vs.) yaziyorsa menuyu kapatip acma!
		if UserInputService:GetFocusedTextBox() then
			return
		end
		setMenuVisible(not menuVisible)
	end
end)

switchTab("Combat")

-- Q/R kisayollari menu pill'lerini guncellesin: tum toggle pill'leri 0.25 sn'de bir yenilenir
task.spawn(function()
	while true do
		if menuVisible then
			for _, refresh in ipairs(toggleRefreshers) do
				pcall(refresh)
			end
			task.wait(0.35)
		else
			task.wait(1.0)
		end
	end
end)

-- ============================ SPEED TP ENGINE (CFRAME MOVEDIRECTION) ============================
local speedRayParams = RaycastParams.new()
speedRayParams.FilterType = Enum.RaycastFilterType.Exclude

RunService.Heartbeat:Connect(function(dt)
	if PLAYER_SETTINGS.SpeedEnabled then
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hrp and hum and hum.Health > 0 and hum.MoveDirection.Magnitude > 0.05 then
			local targetSpeed = tonumber(PLAYER_SETTINGS.SpeedValue) or 45
			local extraSpeed = math.max(0, targetSpeed - 16)
			if extraSpeed > 0 then
				local step = hum.MoveDirection * (extraSpeed * dt)
				if SETTINGS.NOCLIP then
					hrp.CFrame = hrp.CFrame + step
				else
					speedRayParams.FilterDescendantsInstances = { char }
					local hit = workspace:Raycast(hrp.Position, step.Unit * (step.Magnitude + 1.0), speedRayParams)
					if not hit then
						hrp.CFrame = hrp.CFrame + step
					end
				end
			end
		end
	end
end)

-- JumpPower uygulayici
task.spawn(function()
	while true do
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and PLAYER_SETTINGS.JumpEnabled then
			hum.UseJumpPower = true
			hum.JumpPower = PLAYER_SETTINGS.JumpValue
		end
		task.wait(0.5)
	end
end)

-- Anti AFK
task.spawn(function()
	while true do
		if PLAYER_SETTINGS.AntiAFK then
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		end
		task.wait(55)
	end
end)

-- ==================== CLAUDE-TIER AAA COMPETITIVE HUD SYSTEM ====================
local hudGui = create("ScreenGui", {
	Name = "ZickHubMasterHUD",
	ResetOnSpawn = false,
	DisplayOrder = 1000,
})
guiParent(hudGui)

-- 1. TOP-BAR SLEEK GLASSMORPHIC WATERMARK
local topBarFrame = create("Frame", {
	Name = "TopWatermark",
	Size = UDim2.new(0, 460, 0, 34),
	Position = UDim2.new(0, 20, 0, 14),
	BackgroundColor3 = Color3.fromRGB(16, 11, 24),
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
	Active = true,
}, hudGui)
create("UICorner", { CornerRadius = UDim.new(0, 9) }, topBarFrame)
create("UIStroke", { Color = SETTINGS.THEME, Thickness = 1.4, Transparency = 0.25 }, topBarFrame)
makeDraggable(topBarFrame)

-- Neon glow accent line at bottom of HUD
local hudAccentLine = create("Frame", {
	Size = UDim2.new(1, -16, 0, 1.5),
	Position = UDim2.new(0, 8, 1, -2),
	BackgroundColor3 = SETTINGS.THEME,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
}, topBarFrame)
create("UICorner", { CornerRadius = UDim.new(0, 1) }, hudAccentLine)

-- User Headshot Avatar (Kullanicinin KENDİ karakteri!)
local userAvatar = create("ImageLabel", {
	Size = UDim2.new(0, 26, 0, 26),
	Position = UDim2.new(0, 6, 0.5, -13),
	BackgroundTransparency = 1,
	Image = "",
}, topBarFrame)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, userAvatar)
create("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.7 }, userAvatar)

task.spawn(function()
	pcall(function()
		local url = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		userAvatar.Image = url
	end)
end)

-- Glowing Logo & Title
local logoText = create("TextLabel", {
	Size = UDim2.new(0, 90, 1, 0),
	Position = UDim2.new(0, 38, 0, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "ZICK V2",
	TextColor3 = SETTINGS.THEME,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
}, topBarFrame)

create("Frame", {
	Size = UDim2.new(0, 1, 0, 16),
	Position = UDim2.new(0, 98, 0.5, -8),
	BackgroundColor3 = Color3.fromRGB(60, 50, 80),
	BorderSizePixel = 0,
}, topBarFrame)

-- Live Status Metrics (FPS, Ping, Time, Game Mode)
local metricsLabel = create("TextLabel", {
	Size = UDim2.new(1, -110, 1, 0),
	Position = UDim2.new(0, 108, 0, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Color3.fromRGB(220, 215, 235),
	TextSize = 11,
	Text = "FPS: -- | PING: --ms | 5v5 TRAINER",
	TextXAlignment = Enum.TextXAlignment.Left,
}, topBarFrame)

-- FPS & Ping Loop
local fpsCount = 0
local lastFpsTick = os.clock()
local liveFPS = 60

RunService.RenderStepped:Connect(function()
	fpsCount = fpsCount + 1
	local now = os.clock()
	if now - lastFpsTick >= 1 then
		liveFPS = fpsCount
		fpsCount = 0
		lastFpsTick = now
	end
end)

task.spawn(function()
	while topBarFrame.Parent do
		local ping = 0
		pcall(function()
			ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
		end)
		local timeStr = os.date("%H:%M:%S")
		local modeTag = (SETTINGS.TARGET_MODE == "Range (Mesafe)" and "RANGE" or "FOV")
		metricsLabel.Text = string.format("FPS: %d  •  %dms  •  %s  •  [%s]", liveFPS, ping, timeStr, modeTag)
		task.wait(0.5)
	end
end)

-- ============================ BITIS ============================
print("[Zick Hub V2] Loaded | Phantom Scope + Shoot V2 + Flick Shoot (R) + Kill Aura + ESP + Friends (Menu) (LeftControl)")
