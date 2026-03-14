-- Auto Farm | Blox Fruit
-- ย่อจาก Domadic Hub เอาเฉพาะระบบ Auto Farm

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer.Character
    and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    and LocalPlayer.Data

-- ========== SETTINGS ==========
_G.AutoFarm = false
_G.SelectWeapon = "Melee"

-- ========== VARIABLES ==========
local Mon, NameMon, NameQuest, LevelQuest
local CFrameMon, CFrameQuest
local MyLevel
local tween
local Pos = CFrame.new(0, 2, 3)
local CommF = ReplicatedStorage.Remotes.CommF_

-- ========== HELPER FUNCTIONS ==========
local function AutoHaki()
    if not LocalPlayer.Character:FindFirstChild("HasBuso") then
        pcall(function() CommF:InvokeServer("Buso") end)
    end
end

local function EquipWeapon(ToolSe)
    if not _G.NotAutoEquip then
        if LocalPlayer.Backpack:FindFirstChild(ToolSe) then
            local Tool = LocalPlayer.Backpack:FindFirstChild(ToolSe)
            task.wait(.1)
            pcall(function() LocalPlayer.Character.Humanoid:EquipTool(Tool) end)
        end
    end
end

local function UnEquipWeapon(Weapon)
    if LocalPlayer.Character:FindFirstChild(Weapon) then
        _G.NotAutoEquip = true
        task.wait(.5)
        pcall(function()
            LocalPlayer.Character:FindFirstChild(Weapon).Parent = LocalPlayer.Backpack
        end)
        task.wait(.1)
        _G.NotAutoEquip = false
    end
end

local function topos(Pos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local Distance = (Pos.Position - char.HumanoidRootPart.Position).Magnitude
    if char.Humanoid.Sit then char.Humanoid.Sit = false end
    if Distance <= 250 then
        char.HumanoidRootPart.CFrame = Pos
        return
    end
    pcall(function()
        tween = TweenService:Create(char.HumanoidRootPart,
            TweenInfo.new(Distance/325, Enum.EasingStyle.Linear),
            {CFrame = Pos})
        tween:Play()
    end)
end

local function StopTween()
    if tween then pcall(function() tween:Cancel() end) end
end

-- ========== CHECK QUEST BY LEVEL ==========
local function CheckQuest()
    MyLevel = LocalPlayer.Data.Level.Value
    if MyLevel <= 9 then
        Mon="Bandit" NameQuest="BanditQuest1" NameMon="Bandit" LevelQuest=1
        CFrameQuest=CFrame.new(1059.37,15.44,1550.42) CFrameMon=CFrame.new(1045.96,27.0,1560.82)
    elseif MyLevel <= 14 then
        Mon="Monkey" NameQuest="JungleQuest" NameMon="Monkey" LevelQuest=1
        CFrameQuest=CFrame.new(-1598.08,35.55,153.37) CFrameMon=CFrame.new(-1448.51,67.85,11.46)
    elseif MyLevel <= 29 then
        Mon="Gorilla" NameQuest="JungleQuest" NameMon="Gorilla" LevelQuest=2
        CFrameQuest=CFrame.new(-1598.08,35.55,153.37) CFrameMon=CFrame.new(-1129.88,40.46,-525.42)
    elseif MyLevel <= 39 then
        Mon="Pirate" NameQuest="BuggyQuest1" NameMon="Pirate" LevelQuest=1
        CFrameQuest=CFrame.new(-1141.07,4.1,3831.54) CFrameMon=CFrame.new(-1103.51,13.75,3896.09)
    elseif MyLevel <= 59 then
        Mon="Brute" NameQuest="BuggyQuest1" NameMon="Brute" LevelQuest=2
        CFrameQuest=CFrame.new(-1141.07,4.1,3831.54) CFrameMon=CFrame.new(-1140.08,14.80,4322.92)
    elseif MyLevel <= 74 then
        Mon="Desert Bandit" NameQuest="DesertQuest" NameMon="Desert Bandit" LevelQuest=1
        CFrameQuest=CFrame.new(894.48,5.14,4392.43) CFrameMon=CFrame.new(924.79,6.44,4481.58)
    elseif MyLevel <= 89 then
        Mon="Desert Officer" NameQuest="DesertQuest" NameMon="Desert Officer" LevelQuest=2
        CFrameQuest=CFrame.new(894.48,5.14,4392.43) CFrameMon=CFrame.new(1608.28,8.61,4371.00)
    elseif MyLevel <= 99 then
        Mon="Snow Bandit" NameQuest="SnowQuest" NameMon="Snow Bandit" LevelQuest=1
        CFrameQuest=CFrame.new(1389.74,88.15,-1298.90) CFrameMon=CFrame.new(1354.34,87.27,-1393.94)
    elseif MyLevel <= 119 then
        Mon="Snowman" NameQuest="SnowQuest" NameMon="Snowman" LevelQuest=2
        CFrameQuest=CFrame.new(1389.74,88.15,-1298.90) CFrameMon=CFrame.new(1201.64,144.57,-1550.06)
    elseif MyLevel <= 149 then
        Mon="Chief Petty Officer" NameQuest="MarineQuest2" NameMon="Chief Petty Officer" LevelQuest=1
        CFrameQuest=CFrame.new(-5039.58,27.35,4324.68) CFrameMon=CFrame.new(-4881.23,22.65,4273.75)
    elseif MyLevel <= 174 then
        Mon="Sky Bandit" NameQuest="SkyQuest" NameMon="Sky Bandit" LevelQuest=1
        CFrameQuest=CFrame.new(-4839.53,716.36,-2619.44) CFrameMon=CFrame.new(-4953.20,295.74,-2899.22)
    elseif MyLevel <= 189 then
        Mon="Dark Master" NameQuest="SkyQuest" NameMon="Dark Master" LevelQuest=2
        CFrameQuest=CFrame.new(-4839.53,716.36,-2619.44) CFrameMon=CFrame.new(-5259.84,391.39,-2229.03)
    elseif MyLevel <= 209 then
        Mon="Prisoner" NameQuest="PrisonerQuest" NameMon="Prisoner" LevelQuest=1
        CFrameQuest=CFrame.new(5308.93,1.65,475.12) CFrameMon=CFrame.new(5098.97,-0.32,474.23)
    elseif MyLevel <= 249 then
        Mon="Dangerous Prisoner" NameQuest="PrisonerQuest" NameMon="Dangerous Prisoner" LevelQuest=2
        CFrameQuest=CFrame.new(5308.93,1.65,475.12) CFrameMon=CFrame.new(5654.56,15.63,866.29)
    elseif MyLevel <= 274 then
        Mon="Toga Warrior" NameQuest="ColosseumQuest" NameMon="Toga Warrior" LevelQuest=1
        CFrameQuest=CFrame.new(-1580.04,6.35,-2986.47) CFrameMon=CFrame.new(-1820.21,51.68,-2740.66)
    elseif MyLevel <= 299 then
        Mon="Gladiator" NameQuest="ColosseumQuest" NameMon="Gladiator" LevelQuest=2
        CFrameQuest=CFrame.new(-1580.04,6.35,-2986.47) CFrameMon=CFrame.new(-1292.83,56.38,-3339.03)
    else
        Mon="Bandit" NameQuest="BanditQuest1" NameMon="Bandit" LevelQuest=1
        CFrameQuest=CFrame.new(1059.37,15.44,1550.42) CFrameMon=CFrame.new(1045.96,27.0,1560.82)
    end
end

-- ========== AUTO FARM LOOP ==========
task.spawn(function()
    while task.wait() do
        if not _G.AutoFarm then continue end
        pcall(function()
            CheckQuest()
            local QuestUI = LocalPlayer.PlayerGui.Main.Quest
            if not QuestUI.Visible then
                StopTween()
                UnEquipWeapon(_G.SelectWeapon)
                topos(CFrameQuest)
                task.wait(1)
                if (LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude <= 10 then
                    CommF:InvokeServer("StartQuest", NameQuest, LevelQuest)
                end
            else
                local QuestTitle = QuestUI.Container.QuestTitle.Title.Text
                if not string.find(QuestTitle, NameMon) then
                    CommF:InvokeServer("AbandonQuest")
                    return
                end
                CheckQuest()
                local Enemies = workspace.Enemies
                if Enemies:FindFirstChild(Mon) then
                    for _, v in pairs(Enemies:GetChildren()) do
                        if v.Name == Mon
                            and v:FindFirstChild("HumanoidRootPart")
                            and v:FindFirstChild("Humanoid")
                            and v.Humanoid.Health > 0
                            and _G.AutoFarm then
                            repeat task.wait()
                                EquipWeapon(_G.SelectWeapon)
                                AutoHaki()
                                topos(v.HumanoidRootPart.CFrame * Pos)
                                pcall(function()
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.Head.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(70,70,70)
                                end)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280,672))
                            until not _G.AutoFarm
                                or v.Humanoid.Health <= 0
                                or not v.Parent
                                or not QuestUI.Visible
                        end
                    end
                else
                    topos(CFrameMon)
                end
            end
        end)
    end
end)

-- ========== UI ==========
local OldGui = game.CoreGui:FindFirstChild("AutoFarmUI")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, -160, 0.5, -100)
Main.Size = UDim2.new(0, 320, 0, 200)
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 32)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🌊 AUTO FARM"
Title.TextColor3 = Color3.fromRGB(0, 247, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 14
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Main
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Level Label
local LevelLabel = Instance.new("TextLabel")
LevelLabel.Parent = Main
LevelLabel.BackgroundTransparency = 1
LevelLabel.Position = UDim2.new(0, 10, 0, 62)
LevelLabel.Size = UDim2.new(1, -20, 0, 20)
LevelLabel.Font = Enum.Font.Gotham
LevelLabel.Text = "Level: -"
LevelLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
LevelLabel.TextSize = 12
LevelLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Target Label
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Parent = Main
TargetLabel.BackgroundTransparency = 1
TargetLabel.Position = UDim2.new(0, 10, 0, 84)
TargetLabel.Size = UDim2.new(1, -20, 0, 20)
TargetLabel.Font = Enum.Font.Gotham
TargetLabel.Text = "Target: -"
TargetLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
TargetLabel.TextSize = 12
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = Main
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Position = UDim2.new(0, 10, 0, 115)
ToggleBtn.Size = UDim2.new(1, -20, 0, 36)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "▶  START FARM"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 247, 255)
ToggleBtn.TextSize = 13
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    if _G.AutoFarm then
        ToggleBtn.Text = "⏹  STOP FARM"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
        StatusLabel.Text = "Status: ON ✅"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 247, 100)
    else
        StopTween()
        ToggleBtn.Text = "▶  START FARM"
        ToggleBtn.TextColor3 = Color3.fromRGB(0, 247, 255)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        StatusLabel.Text = "Status: OFF"
        StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        TargetLabel.Text = "Target: -"
    end
end)

-- Weapon Buttons
local WeaponLabel = Instance.new("TextLabel")
WeaponLabel.Parent = Main
WeaponLabel.BackgroundTransparency = 1
WeaponLabel.Position = UDim2.new(0, 10, 0, 158)
WeaponLabel.Size = UDim2.new(0, 60, 0, 20)
WeaponLabel.Font = Enum.Font.Gotham
WeaponLabel.Text = "Weapon:"
WeaponLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
WeaponLabel.TextSize = 11
WeaponLabel.TextXAlignment = Enum.TextXAlignment.Left

local weapons = {"Melee", "Sword", "Gun"}
for i, wname in pairs(weapons) do
    local btn = Instance.new("TextButton")
    btn.Parent = Main
    btn.BackgroundColor3 = wname == _G.SelectWeapon
        and Color3.fromRGB(0, 100, 120)
        or Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0, 70 + (i-1)*78, 0, 157)
    btn.Size = UDim2.new(0, 72, 0, 22)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = wname
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        _G.SelectWeapon = wname
        for _, b in pairs(Main:GetChildren()) do
            if b:IsA("TextButton") and b ~= ToggleBtn and b ~= CloseBtn then
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 120)
    end)
end

-- Draggable
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Update Labels Loop
task.spawn(function()
    while task.wait(0.5) do
        if not ScreenGui.Parent then break end
        pcall(function()
            local lv = LocalPlayer.Data.Level.Value
            LevelLabel.Text = "Level: " .. tostring(lv)
            if _G.AutoFarm and Mon then
                TargetLabel.Text = "Target: " .. tostring(Mon)
            end
        end)
    end
end)

print("✅ Auto Farm loaded")
