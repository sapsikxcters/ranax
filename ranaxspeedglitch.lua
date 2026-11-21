-- SPEED GLITCH - ONLY [F] TOGGLE + TOOL EQUIPPED (BLOCKED ON GUN / KNIFE)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

-- AYARLAR
local DEFAULT_WALKSPEED = 16
local GLITCH_SPEED = 200
local TOGGLE_KEY = Enum.KeyCode.F
local BLOCKED_KEYWORDS = { "gun", "knife" }

local enabled = true
local canUseWithTool = false
local lastToggleTick = 0
local conn
local toolConnAdded
local toolConnRemoved

-- TOOL ADININ YASAKLI OLUP OLMADIGINI KONTROL ET
local function isBlockedTool(tool)
	if not tool or not tool:IsA("Tool") then
		return false
	end

	local lowerName = string.lower(tool.Name)
	for _, keyword in ipairs(BLOCKED_KEYWORDS) do
		if string.find(lowerName, keyword, 1, true) then
			return true
		end
	end

	return false
end

-- ELDEKI TOOL DURUMUNU GUNCELLE
local function updateToolState(char)
	if not char then
		canUseWithTool = false
		return
	end

	local equippedTool = char:FindFirstChildOfClass("Tool")
	if not equippedTool then
		canUseWithTool = false
		return
	end

	canUseWithTool = not isBlockedTool(equippedTool)
end

-- TOGGLE FONKSIYONU (CIFT TETIKLENME ONLEMELI)
local function toggleSpeed()
	local now = os.clock()
	if now - lastToggleTick < 0.15 then return end
	lastToggleTick = now

	enabled = not enabled
	print("[Speed Glitch] Durum:", enabled and "ACIK" or "KAPALI")
end

-- YOL 1: ContextActionService (F TUSU)
pcall(function()
	ContextActionService:UnbindAction("ToggleSpeedGlitchF")
end)

ContextActionService:BindAction("ToggleSpeedGlitchF", function(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		toggleSpeed()
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end, false, TOGGLE_KEY)

-- YOL 2: UserInputService YEDEK (Sohbet/textbox acik degilse)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if UserInputService:GetFocusedTextBox() ~= nil then return end
	if input.KeyCode == TOGGLE_KEY then
		toggleSpeed()
	end
end)

-- KARAKTER KURULUMU
local function setup(char)
	local hum = char:WaitForChild("Humanoid")

	if conn then
		conn:Disconnect()
		conn = nil
	end
	if toolConnAdded then
		toolConnAdded:Disconnect()
		toolConnAdded = nil
	end
	if toolConnRemoved then
		toolConnRemoved:Disconnect()
		toolConnRemoved = nil
	end

	updateToolState(char)

	toolConnAdded = char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			updateToolState(char)
		end
	end)

	toolConnRemoved = char.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			updateToolState(char)
		end
	end)

	conn = RunService.RenderStepped:Connect(function()
		if not hum or hum.Parent == nil then return end

		if not enabled or not canUseWithTool then
			hum.WalkSpeed = DEFAULT_WALKSPEED
			return
		end

		local state = hum:GetState()
		local inAir = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall

		if inAir and hum.MoveDirection.Magnitude > 0 then
			hum.WalkSpeed = GLITCH_SPEED
		else
			hum.WalkSpeed = DEFAULT_WALKSPEED
		end
	end)
end

player.CharacterAdded:Connect(setup)
if player.Character then
	setup(player.Character)
end

print("[Speed Glitch] Yuklendi! [F] ile ac/kapat.")
