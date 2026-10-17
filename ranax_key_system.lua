local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local SCRIPT_RAW_URL = "https://raw.githubusercontent.com/xCters/RanaxMM2/main/ranax_mmv.lua"
local LOOTLABS_LINK  = "https://loot-link.com/s?exampleRanaxKey"
local DISCORD_LINK   = "https://discord.gg/ranax"

local VALID_KEY = "RANAX-2027"
local KEY_FILE = "Ranax_SavedKey.txt"

local function LoadMainRanaxScript()
    local loaded = false
    if SCRIPT_RAW_URL and SCRIPT_RAW_URL ~= "" then
        local ok, err = pcall(function()
            local content = game:HttpGet(SCRIPT_RAW_URL)
            loadstring(content)()
            loaded = true
        end)
        if ok and loaded then return end
    end

    pcall(function()
        if readfile and isfile and isfile("ranax_mmv.lua") then
            loadstring(readfile("ranax_mmv.lua"))()
            loaded = true
        end
    end)
end

local function getSafeGuiParent()
    if typeof(gethui) == "function" then
        local h = gethui()
        if h then return h end
    end
    local ok, core = pcall(function() return CoreGui end)
    if ok and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function safeSetClipboard(str)
    if typeof(setclipboard) == "function" then
        pcall(function() setclipboard(str) end)
        return true
    elseif typeof(toclipboard) == "function" then
        pcall(function() toclipboard(str) end)
        return true
    elseif typeof(set_clipboard) == "function" then
        pcall(function() set_clipboard(str) end)
        return true
    end
    return false
end

local function makeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        TweenService:Create(guiObject, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = targetPos
        }):Play()
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function CreateKeySystemUI()
    local parentGui = getSafeGuiParent()

    local existing = parentGui:FindFirstChild("RanaxKeySystem")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RanaxKeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 9999999
    ScreenGui.Parent = parentGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 370, 0, 290)
    MainFrame.Position = UDim2.new(0.5, -185, 0.5, -145)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.4
    MainStroke.Color = Color3.fromRGB(40, 42, 55)
    MainStroke.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 46)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 14)
    HeaderCorner.Parent = Header

    local HeaderCover = Instance.new("Frame")
    HeaderCover.Size = UDim2.new(1, 0, 0, 10)
    HeaderCover.Position = UDim2.new(0, 0, 1, -10)
    HeaderCover.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    HeaderCover.BorderSizePixel = 0
    HeaderCover.Parent = Header

    local LogoIcon = Instance.new("TextLabel")
    LogoIcon.Size = UDim2.new(0, 24, 0, 24)
    LogoIcon.Position = UDim2.new(0, 14, 0.5, -12)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Font = Enum.Font.GothamBold
    LogoIcon.Text = "⚡"
    LogoIcon.TextColor3 = Color3.fromHex("#30ff6a")
    LogoIcon.TextSize = 16
    LogoIcon.Parent = Header

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(1, -90, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 42, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.Text = "Ranax Hub  •  Key System"
    HeaderTitle.TextColor3 = Color3.fromRGB(240, 240, 250)
    HeaderTitle.TextSize = 14
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header

    local VerTag = Instance.new("TextLabel")
    VerTag.Size = UDim2.new(0, 38, 0, 20)
    VerTag.Position = UDim2.new(1, -80, 0.5, -10)
    VerTag.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    VerTag.Font = Enum.Font.GothamBold
    VerTag.Text = "v1.7"
    VerTag.TextColor3 = Color3.fromHex("#30ff6a")
    VerTag.TextSize = 11
    VerTag.Parent = Header
    local VerCorner = Instance.new("UICorner")
    VerCorner.CornerRadius = UDim.new(0, 6)
    VerCorner.Parent = VerTag

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -34, 0.5, -13)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(140, 140, 160)
    CloseBtn.TextSize = 13
    CloseBtn.Parent = Header
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = Color3.fromHex("#30ff6a")
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Header

    makeDraggable(MainFrame, Header)

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -36, 0, 18)
    StatusLabel.Position = UDim2.new(0, 18, 0, 56)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = "Please enter your key to continue"
    StatusLabel.TextColor3 = Color3.fromRGB(160, 165, 185)
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame

    local InputContainer = Instance.new("Frame")
    InputContainer.Size = UDim2.new(1, -36, 0, 42)
    InputContainer.Position = UDim2.new(0, 18, 0, 78)
    InputContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    InputContainer.BorderSizePixel = 0
    InputContainer.Parent = MainFrame

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = InputContainer

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(48, 50, 65)
    InputStroke.Thickness = 1
    InputStroke.Parent = InputContainer

    local KeyTextBox = Instance.new("TextBox")
    KeyTextBox.Size = UDim2.new(1, -20, 1, 0)
    KeyTextBox.Position = UDim2.new(0, 10, 0, 0)
    KeyTextBox.BackgroundTransparency = 1
    KeyTextBox.Font = Enum.Font.GothamMedium
    KeyTextBox.PlaceholderText = "Paste your key here..."
    KeyTextBox.PlaceholderColor3 = Color3.fromRGB(90, 95, 115)
    KeyTextBox.Text = ""
    KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyTextBox.TextSize = 13
    KeyTextBox.ClearTextOnFocus = false
    KeyTextBox.Parent = InputContainer

    local ButtonRow = Instance.new("Frame")
    ButtonRow.Size = UDim2.new(1, -36, 0, 36)
    ButtonRow.Position = UDim2.new(0, 18, 0, 132)
    ButtonRow.BackgroundTransparency = 1
    ButtonRow.Parent = MainFrame

    local LootLabsBtn = Instance.new("TextButton")
    LootLabsBtn.Name = "LootLabsBtn"
    LootLabsBtn.Size = UDim2.new(0.62, -4, 1, 0)
    LootLabsBtn.Position = UDim2.new(0, 0, 0, 0)
    LootLabsBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
    LootLabsBtn.Font = Enum.Font.GothamBold
    LootLabsBtn.Text = "🔗 Get Key (LootLabs)"
    LootLabsBtn.TextColor3 = Color3.fromRGB(210, 225, 255)
    LootLabsBtn.TextSize = 12
    LootLabsBtn.BorderSizePixel = 0
    LootLabsBtn.Parent = ButtonRow

    local LootCorner = Instance.new("UICorner")
    LootCorner.CornerRadius = UDim.new(0, 8)
    LootCorner.Parent = LootLabsBtn

    local LootStroke = Instance.new("UIStroke")
    LootStroke.Color = Color3.fromRGB(50, 55, 75)
    LootStroke.Parent = LootLabsBtn

    local DiscordBtn = Instance.new("TextButton")
    DiscordBtn.Name = "DiscordBtn"
    DiscordBtn.Size = UDim2.new(0.38, -4, 1, 0)
    DiscordBtn.Position = UDim2.new(0.62, 4, 0, 0)
    DiscordBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
    DiscordBtn.Font = Enum.Font.GothamBold
    DiscordBtn.Text = "💬 Discord"
    DiscordBtn.TextColor3 = Color3.fromRGB(180, 190, 220)
    DiscordBtn.TextSize = 12
    DiscordBtn.BorderSizePixel = 0
    DiscordBtn.Parent = ButtonRow

    local DiscCorner = Instance.new("UICorner")
    DiscCorner.CornerRadius = UDim.new(0, 8)
    DiscCorner.Parent = DiscordBtn

    local DiscStroke = Instance.new("UIStroke")
    DiscStroke.Color = Color3.fromRGB(50, 55, 75)
    DiscStroke.Parent = DiscordBtn

    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.Name = "VerifyBtn"
    VerifyBtn.Size = UDim2.new(1, -36, 0, 40)
    VerifyBtn.Position = UDim2.new(0, 18, 0, 178)
    VerifyBtn.BackgroundColor3 = Color3.fromHex("#30ff6a")
    VerifyBtn.Font = Enum.Font.GothamBold
    VerifyBtn.Text = "Verify Key"
    VerifyBtn.TextColor3 = Color3.fromRGB(12, 22, 14)
    VerifyBtn.TextSize = 14
    VerifyBtn.BorderSizePixel = 0
    VerifyBtn.Parent = MainFrame

    local VerifyCorner = Instance.new("UICorner")
    VerifyCorner.CornerRadius = UDim.new(0, 8)
    VerifyCorner.Parent = VerifyBtn

    local FooterNote = Instance.new("TextLabel")
    FooterNote.Size = UDim2.new(1, -36, 0, 20)
    FooterNote.Position = UDim2.new(0, 18, 1, -30)
    FooterNote.BackgroundTransparency = 1
    FooterNote.Font = Enum.Font.GothamMedium
    FooterNote.Text = "Keys are saved automatically after first verify"
    FooterNote.TextColor3 = Color3.fromRGB(110, 115, 135)
    FooterNote.TextSize = 11
    FooterNote.TextXAlignment = Enum.TextXAlignment.Center
    FooterNote.Parent = MainFrame

    local function handleLootClick()
        if safeSetClipboard(LOOTLABS_LINK) then
            StatusLabel.Text = "LootLabs Link Copied to Clipboard!"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        else
            StatusLabel.Text = "Clipboard not supported on your executor"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
        end
    end
    LootLabsBtn.MouseButton1Click:Connect(handleLootClick)
    LootLabsBtn.Activated:Connect(handleLootClick)

    local function handleDiscordClick()
        if safeSetClipboard(DISCORD_LINK) then
            StatusLabel.Text = "Discord Invite Copied to Clipboard!"
            StatusLabel.TextColor3 = Color3.fromRGB(130, 180, 255)
        end
    end
    DiscordBtn.MouseButton1Click:Connect(handleDiscordClick)
    DiscordBtn.Activated:Connect(handleDiscordClick)

    local isVerifying = false
    local function CheckEnteredKey(inputKey)
        if isVerifying then return end
        local cleanKey = (inputKey or KeyTextBox.Text):gsub("^%s+", ""):gsub("%s+$", "")

        if cleanKey == "" then
            StatusLabel.Text = "Please enter a key first!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end

        if cleanKey == VALID_KEY then
            isVerifying = true
            StatusLabel.Text = "Key Correct! Loading Script..."
            StatusLabel.TextColor3 = Color3.fromHex("#30ff6a")
            InputStroke.Color = Color3.fromHex("#30ff6a")
            VerifyBtn.Text = "✓ Verified!"
            VerifyBtn.BackgroundColor3 = Color3.fromRGB(35, 180, 80)

            pcall(function()
                if writefile then writefile(KEY_FILE, cleanKey) end
            end)

            task.delay(1.0, function()
                local fadeOut = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset - 25),
                    BackgroundTransparency = 1
                })
                fadeOut:Play()
                fadeOut.Completed:Connect(function()
                    ScreenGui:Destroy()
                    LoadMainRanaxScript()
                end)
            end)
        else
            StatusLabel.Text = "Invalid Key! Please check LootLabs."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
            InputStroke.Color = Color3.fromRGB(255, 75, 75)

            local origPos = MainFrame.Position
            TweenService:Create(MainFrame, TweenInfo.new(0.05), { Position = origPos + UDim2.new(0, 8, 0, 0) }):Play()
            task.wait(0.05)
            TweenService:Create(MainFrame, TweenInfo.new(0.05), { Position = origPos - UDim2.new(0, 8, 0, 0) }):Play()
            task.wait(0.05)
            TweenService:Create(MainFrame, TweenInfo.new(0.05), { Position = origPos }):Play()
        end
    end

    VerifyBtn.MouseButton1Click:Connect(function()
        CheckEnteredKey()
    end)
    VerifyBtn.Activated:Connect(function()
        CheckEnteredKey()
    end)

    KeyTextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            CheckEnteredKey()
        end
    end)

    pcall(function()
        if isfile and readfile and isfile(KEY_FILE) then
            local saved = readfile(KEY_FILE)
            if saved and saved:gsub("^%s+", ""):gsub("%s+$", "") == VALID_KEY then
                KeyTextBox.Text = saved
                CheckEnteredKey(saved)
            end
        end
    end)
end

CreateKeySystemUI()
