-- PIG HUB | Auto Farm | Blox Fruit
-- ระบบจาก Domadic Hub + WindUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "PIG HUB",
    Icon = "rbxassetid://81857105973850",
    Author = "PIG TEAM",
    Folder = "PIG HUB",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Name = LocalPlayer.Name,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId
    }
})

Window:EditOpenButton({ Enabled = false })

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "WindUI_Toggle"
ScreenGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Image = "rbxassetid://81857105973850"
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local function ToggleUI()
    if Window.Toggle then Window:Toggle()
    else Window.UI.Enabled = not Window.UI.Enabled end
end

ToggleBtn.MouseButton1Click:Connect(ToggleUI)
UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.T then ToggleUI() end
end)

-- ========== TABS ==========
local FarmTab  = Window:Tab({ Title = "Level Farm", Icon = "zap" })
local MobTab   = Window:Tab({ Title = "Farm Mob",   Icon = "swords" })
local BossTab  = Window:Tab({ Title = "Boss",       Icon = "skull" })
local ChestTab = Window:Tab({ Title = "Chest",      Icon = "package" })
local SettingTab = Window:Tab({ Title = "Setting",  Icon = "settings" })

-- ========== WAIT FOR CHAR ==========
repeat task.wait() until LocalPlayer.Character
    and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    and LocalPlayer.Data

-- ========== VARIABLES ==========
local CommF = ReplicatedStorage.Remotes.CommF_
local tween
local Mon, NameMon, NameQuest, LevelQuest
local CFrameMon, CFrameQuest
local MyLevel
local FarmMode = "Normal"
local StartMagnet = false
local PosMon
local Pos = CFrame.new(0, 2, 3)
local BypassTP = false

_G.AutoFarm      = false
_G.Farmfast      = false
_G.AutoFarmMob   = false
_G.AutoFarmNearest = false
_G.AutoFarmBoss  = false
_G.AutoQuestBoss = false
_G.AutoAllBoss   = false
_G.AutoAllBossHop = false
_G.SelectWeapon  = "Melee"
_G.SelectMob     = ""
_G.SelectBoss    = ""
_G.BringMonster  = true
_G.BringMode     = 300
_G.AUTOHAKI      = true
_G.Set           = true
_G.StopTween     = false
_G.Clip          = false
_G.NotAutoEquip  = false

-- World detection
local World1, World2, World3
if game.PlaceId == 2753915549 then World1 = true
elseif game.PlaceId == 4442272183 then World2 = true
elseif game.PlaceId == 7449423635 then World3 = true
else World1 = true end

-- ========== HELPER FUNCTIONS ==========
local function AutoHaki()
    if _G.AUTOHAKI then
        if not LocalPlayer.Character:FindFirstChild("HasBuso") then
            pcall(function() CommF:InvokeServer("Buso") end)
        end
    end
end

local function UnEquipWeapon(Weapon)
    if LocalPlayer.Character:FindFirstChild(Weapon) then
        _G.NotAutoEquip = true
        task.wait(.5)
        pcall(function() LocalPlayer.Character:FindFirstChild(Weapon).Parent = LocalPlayer.Backpack end)
        task.wait(.1)
        _G.NotAutoEquip = false
    end
end

local function EquipWeapon(ToolSe)
    if not _G.NotAutoEquip then
        if LocalPlayer.Backpack:FindFirstChild(ToolSe) then
            task.wait(.1)
            pcall(function() LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(ToolSe)) end)
        end
    end
end

local function TP(Pos)
    LocalPlayer.Character.HumanoidRootPart.CFrame = Pos
end

local function topos(CF)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local Distance = (CF.Position - char.HumanoidRootPart.Position).Magnitude
    if char.Humanoid.Sit then char.Humanoid.Sit = false end
    pcall(function()
        tween = TweenService:Create(char.HumanoidRootPart,
            TweenInfo.new(Distance/325, Enum.EasingStyle.Linear), {CFrame = CF})
        tween:Play()
    end)
    if Distance <= 250 then
        if tween then tween:Cancel() end
        char.HumanoidRootPart.CFrame = CF
    end
    if _G.StopTween then
        if tween then tween:Cancel() end
        _G.Clip = false
    end
end

local function BTP(p)
    pcall(function()
        local char = LocalPlayer.Character
        if (p.Position - char.HumanoidRootPart.Position).Magnitude >= 1500 and char.Humanoid.Health > 0 then
            repeat task.wait()
                char.HumanoidRootPart.CFrame = p
                task.wait(.05)
                pcall(function() char.Head:Destroy() end)
                char.HumanoidRootPart.CFrame = p
            until (p.Position - char.HumanoidRootPart.Position).Magnitude < 1500
        end
    end)
end

local function StopTween(target)
    if not target then
        _G.StopTween = true
        task.wait()
        topos(LocalPlayer.Character.HumanoidRootPart.CFrame)
        task.wait()
        pcall(function()
            local bc = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip")
            if bc then bc:Destroy() end
        end)
        _G.StopTween = false
        _G.Clip = false
    end
end

local function Hop()
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet(
            ("https://games.roblox.com/v1/games/%s/servers/Public?limit=100"):format(game.PlaceId)
        )).data
        for _, s in ipairs(servers) do
            if s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
    end)
end

-- ========== CHECK QUEST ==========
local function CheckQuest()
    MyLevel = LocalPlayer.Data.Level.Value
    if World1 then
        if MyLevel <= 9 then Mon="Bandit" NameQuest="BanditQuest1" NameMon="Bandit" LevelQuest=1 CFrameQuest=CFrame.new(1059.37,15.44,1550.42) CFrameMon=CFrame.new(1045.96,27.0,1560.82)
        elseif MyLevel <= 14 then Mon="Monkey" NameQuest="JungleQuest" NameMon="Monkey" LevelQuest=1 CFrameQuest=CFrame.new(-1598.08,35.55,153.37) CFrameMon=CFrame.new(-1448.51,67.85,11.46)
        elseif MyLevel <= 29 then Mon="Gorilla" NameQuest="JungleQuest" NameMon="Gorilla" LevelQuest=2 CFrameQuest=CFrame.new(-1598.08,35.55,153.37) CFrameMon=CFrame.new(-1129.88,40.46,-525.42)
        elseif MyLevel <= 39 then Mon="Pirate" NameQuest="BuggyQuest1" NameMon="Pirate" LevelQuest=1 CFrameQuest=CFrame.new(-1141.07,4.1,3831.54) CFrameMon=CFrame.new(-1103.51,13.75,3896.09)
        elseif MyLevel <= 59 then Mon="Brute" NameQuest="BuggyQuest1" NameMon="Brute" LevelQuest=2 CFrameQuest=CFrame.new(-1141.07,4.1,3831.54) CFrameMon=CFrame.new(-1140.08,14.80,4322.92)
        elseif MyLevel <= 74 then Mon="Desert Bandit" NameQuest="DesertQuest" NameMon="Desert Bandit" LevelQuest=1 CFrameQuest=CFrame.new(894.48,5.14,4392.43) CFrameMon=CFrame.new(924.79,6.44,4481.58)
        elseif MyLevel <= 89 then Mon="Desert Officer" NameQuest="DesertQuest" NameMon="Desert Officer" LevelQuest=2 CFrameQuest=CFrame.new(894.48,5.14,4392.43) CFrameMon=CFrame.new(1608.28,8.61,4371.00)
        elseif MyLevel <= 99 then Mon="Snow Bandit" NameQuest="SnowQuest" NameMon="Snow Bandit" LevelQuest=1 CFrameQuest=CFrame.new(1389.74,88.15,-1298.90) CFrameMon=CFrame.new(1354.34,87.27,-1393.94)
        elseif MyLevel <= 119 then Mon="Snowman" NameQuest="SnowQuest" NameMon="Snowman" LevelQuest=2 CFrameQuest=CFrame.new(1389.74,88.15,-1298.90) CFrameMon=CFrame.new(1201.64,144.57,-1550.06)
        elseif MyLevel <= 149 then Mon="Chief Petty Officer" NameQuest="MarineQuest2" NameMon="Chief Petty Officer" LevelQuest=1 CFrameQuest=CFrame.new(-5039.58,27.35,4324.68) CFrameMon=CFrame.new(-4881.23,22.65,4273.75)
        elseif MyLevel <= 174 then Mon="Sky Bandit" NameQuest="SkyQuest" NameMon="Sky Bandit" LevelQuest=1 CFrameQuest=CFrame.new(-4839.53,716.36,-2619.44) CFrameMon=CFrame.new(-4953.20,295.74,-2899.22)
        elseif MyLevel <= 189 then Mon="Dark Master" NameQuest="SkyQuest" NameMon="Dark Master" LevelQuest=2 CFrameQuest=CFrame.new(-4839.53,716.36,-2619.44) CFrameMon=CFrame.new(-5259.84,391.39,-2229.03)
        elseif MyLevel <= 209 then Mon="Prisoner" NameQuest="PrisonerQuest" NameMon="Prisoner" LevelQuest=1 CFrameQuest=CFrame.new(5308.93,1.65,475.12) CFrameMon=CFrame.new(5098.97,-0.32,474.23)
        elseif MyLevel <= 249 then Mon="Dangerous Prisoner" NameQuest="PrisonerQuest" NameMon="Dangerous Prisoner" LevelQuest=2 CFrameQuest=CFrame.new(5308.93,1.65,475.12) CFrameMon=CFrame.new(5654.56,15.63,866.29)
        elseif MyLevel <= 274 then Mon="Toga Warrior" NameQuest="ColosseumQuest" NameMon="Toga Warrior" LevelQuest=1 CFrameQuest=CFrame.new(-1580.04,6.35,-2986.47) CFrameMon=CFrame.new(-1820.21,51.68,-2740.66)
        elseif MyLevel <= 299 then Mon="Gladiator" NameQuest="ColosseumQuest" NameMon="Gladiator" LevelQuest=2 CFrameQuest=CFrame.new(-1580.04,6.35,-2986.47) CFrameMon=CFrame.new(-1292.83,56.38,-3339.03)
        elseif MyLevel <= 374 then Mon="Military Soldier" NameQuest="FrigateQuest1" NameMon="Military Soldier" LevelQuest=1 CFrameQuest=CFrame.new(-5313.37,10.95,8515.29) CFrameMon=CFrame.new(-5411.16,11.08,8454.29)
        elseif MyLevel <= 474 then Mon="Military Man" NameQuest="FrigateQuest1" NameMon="Military Man" LevelQuest=2 CFrameQuest=CFrame.new(-5313.37,10.95,8515.29) CFrameMon=CFrame.new(-5802.86,86.26,8828.85)
        else Mon="Bandit" NameQuest="BanditQuest1" NameMon="Bandit" LevelQuest=1 CFrameQuest=CFrame.new(1059.37,15.44,1550.42) CFrameMon=CFrame.new(1045.96,27.0,1560.82) end
    elseif World2 then
        if MyLevel <= 724 then Mon="Raider" NameQuest="Area1Quest" NameMon="Raider" LevelQuest=1 CFrameQuest=CFrame.new(-429.54,71.76,1836.18) CFrameMon=CFrame.new(-728.32,52.77,2345.77)
        elseif MyLevel <= 774 then Mon="Mercenary" NameQuest="Area1Quest" NameMon="Mercenary" LevelQuest=2 CFrameQuest=CFrame.new(-429.54,71.76,1836.18) CFrameMon=CFrame.new(-1004.32,80.15,1424.61)
        elseif MyLevel <= 874 then Mon="Factory Staff" NameQuest="Area2Quest" NameMon="Factory Staff" LevelQuest=2 CFrameQuest=CFrame.new(632.69,73.10,918.66) CFrameMon=CFrame.new(73.07,81.86,-27.47)
        elseif MyLevel <= 999 then Mon="Vampire" NameQuest="ZombieQuest" NameMon="Vampire" LevelQuest=2 CFrameQuest=CFrame.new(-5497.06,47.59,-795.23) CFrameMon=CFrame.new(-6037.66,32.18,-1340.65)
        elseif MyLevel <= 1099 then Mon="Winter Warrior" NameQuest="SnowMountainQuest" NameMon="Winter Warrior" LevelQuest=2 CFrameQuest=CFrame.new(609.85,400.11,-5372.25) CFrameMon=CFrame.new(1142.74,475.63,-5199.41)
        else Mon="Lava Pirate" NameQuest="FireSideQuest" NameMon="Lava Pirate" LevelQuest=2 CFrameQuest=CFrame.new(-5428.03,15.06,-5299.43) CFrameMon=CFrame.new(-5213.33,49.73,-4701.45) end
    elseif World3 then
        if MyLevel <= 1624 then Mon="Dragon Crew Archer" NameQuest="AmazonQuest" NameMon="Dragon Crew Archer" LevelQuest=2 CFrameQuest=CFrame.new(5833.11,51.60,-1103.06) CFrameMon=CFrame.new(6616.41,441.76,446.04)
        elseif MyLevel <= 1699 then Mon="Giant Islander" NameQuest="AmazonQuest2" NameMon="Giant Islander" LevelQuest=2 CFrameQuest=CFrame.new(5446.87,601.62,749.45) CFrameMon=CFrame.new(4729.09,590.43,-36.97)
        else Mon="Marine Rear Admiral" NameQuest="MarineTreeIsland" NameMon="Marine Rear Admiral" LevelQuest=2 CFrameQuest=CFrame.new(2179.98,28.73,-6740.05) CFrameMon=CFrame.new(3656.77,160.52,-7001.59) end
    end
end

-- ========== AUTO WEAPON SELECT ==========
task.spawn(function()
    while task.wait() do
        pcall(function()
            for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                if v:IsA("Tool") then
                    if _G.SelectWeapon == "Melee" and v.ToolTip == "Melee" then _G.SelectWeapon = v.Name
                    elseif _G.SelectWeapon == "Sword" and v.ToolTip == "Sword" then _G.SelectWeapon = v.Name
                    elseif _G.SelectWeapon == "Gun" and v.ToolTip == "Gun" then _G.SelectWeapon = v.Name
                    elseif _G.SelectWeapon == "Fruit" and v.ToolTip == "Blox Fruit" then _G.SelectWeapon = v.Name end
                end
            end
        end)
    end
end)

-- Auto SetSpawn
task.spawn(function()
    while task.wait() do
        if _G.Set then
            pcall(function() CommF:InvokeServer("SetSpawnPoint") end)
        end
    end
end)

-- Auto Haki
task.spawn(function()
    while task.wait(.1) do
        if _G.AUTOHAKI then
            if not LocalPlayer.Character:FindFirstChild("HasBuso") then
                pcall(function() CommF:InvokeServer("Buso") end)
            end
        end
    end
end)

-- Bring Mob
task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.BringMonster then
                CheckQuest()
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if _G.AutoFarm and StartMagnet and v.Name == Mon
                        and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                        and v.Humanoid.Health > 0
                        and (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= _G.BringMode then
                        v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                        v.HumanoidRootPart.CFrame = PosMon
                        v.Humanoid:ChangeState(14)
                        v.HumanoidRootPart.CanCollide = false
                        v.Head.CanCollide = false
                        pcall(function()
                            if v.Humanoid:FindFirstChild("Animator") then
                                v.Humanoid.Animator:Destroy()
                            end
                            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                        end)
                    end
                end
            end
        end)
    end
end)

-- Bring Mode convert
task.spawn(function()
    while task.wait(.1) do
        if _G.BringMode then
            pcall(function()
                if _G.BringMode == "Low" then _G.BringMode = 250
                elseif _G.BringMode == "Normal" then _G.BringMode = 300
                elseif _G.BringMode == "Super Bring" then _G.BringMode = 350 end
            end)
        end
    end
end)

-- ========== FARM HELPER ==========
local function FarmLoop(v, QuestUI)
    repeat task.wait()
        EquipWeapon(_G.SelectWeapon) AutoHaki()
        PosMon = v.HumanoidRootPart.CFrame
        topos(v.HumanoidRootPart.CFrame * Pos)
        pcall(function()
            v.HumanoidRootPart.CanCollide = false
            v.Humanoid.WalkSpeed = 0
            v.Head.CanCollide = false
            v.HumanoidRootPart.Size = Vector3.new(70,70,70)
        end)
        StartMagnet = true
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280,672))
    until not _G.AutoFarm or v.Humanoid.Health <= 0 or not v.Parent or not QuestUI.Visible
end

-- ========== AUTO FARM LEVEL ==========
-- Normal
task.spawn(function()
    while task.wait() do
        if FarmMode ~= "Normal" or not _G.AutoFarm then continue end
        pcall(function()
            local QuestUI = LocalPlayer.PlayerGui.Main.Quest
            local QT = QuestUI.Container.QuestTitle.Title.Text
            if not string.find(QT, NameMon or "") then StartMagnet = false CommF:InvokeServer("AbandonQuest") end
            if not QuestUI.Visible then
                UnEquipWeapon(_G.SelectWeapon) StartMagnet = false CheckQuest()
                if BypassTP and (LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude > 1500 then
                    BTP(CFrameQuest * CFrame.new(0,20,5))
                else topos(CFrameQuest) end
                if (LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude <= 5 then
                    CommF:InvokeServer("StartQuest", NameQuest, LevelQuest)
                end
            else
                CheckQuest()
                if workspace.Enemies:FindFirstChild(Mon) then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid")
                            and v.Humanoid.Health > 0 and v.Name == Mon then
                            if string.find(QT, NameMon) then FarmLoop(v, QuestUI)
                            else StartMagnet = false CommF:InvokeServer("AbandonQuest") end
                        end
                    end
                else topos(CFrameMon) UnEquipWeapon(_G.SelectWeapon) StartMagnet = false end
            end
        end)
    end
end)

-- Not Tween To Npc Quest
task.spawn(function()
    while task.wait() do
        if FarmMode ~= "Not Tween To Npc Quest" or not _G.AutoFarm then continue end
        pcall(function()
            local QuestUI = LocalPlayer.PlayerGui.Main.Quest
            local QT = QuestUI.Container.QuestTitle.Title.Text
            if not string.find(QT, NameMon or "") then StartMagnet = false CommF:InvokeServer("AbandonQuest") end
            if not QuestUI.Visible then
                StartMagnet = false CheckQuest() UnEquipWeapon(_G.SelectWeapon)
                CommF:InvokeServer("StartQuest", NameQuest, LevelQuest)
                if BypassTP and (LocalPlayer.Character.HumanoidRootPart.Position - CFrameMon.Position).Magnitude > 1500 then
                    BTP(CFrameMon)
                else topos(CFrameMon) end
            else
                CheckQuest()
                if workspace.Enemies:FindFirstChild(Mon) then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid")
                            and v.Humanoid.Health > 0 and v.Name == Mon then
                            if string.find(QT, NameMon) then FarmLoop(v, LocalPlayer.PlayerGui.Main.Quest)
                            else StartMagnet = false CommF:InvokeServer("AbandonQuest") end
                        end
                    end
                else topos(CFrameMon) UnEquipWeapon(_G.SelectWeapon) StartMagnet = false end
            end
        end)
    end
end)

-- No Quest
task.spawn(function()
    while task.wait() do
        if FarmMode ~= "No Quest" or not _G.AutoFarm then continue end
        pcall(function()
            CheckQuest()
            if workspace.Enemies:FindFirstChild(Mon) then
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == Mon and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        repeat task.wait()
                            AutoHaki() EquipWeapon(_G.SelectWeapon)
                            pcall(function() v.HumanoidRootPart.CanCollide = false v.Humanoid.WalkSpeed = 0 v.HumanoidRootPart.Size = Vector3.new(50,50,50) end)
                            topos(v.HumanoidRootPart.CFrame * Pos)
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(1280,672))
                        until not _G.AutoFarm or v.Humanoid.Health <= 0 or not v.Parent
                    end
                end
            else topos(CFrameMon) end
        end)
    end
end)

-- ========== AUTO FARM MOB ==========
task.spawn(function()
    while task.wait() do
        if not _G.AutoFarmMob then continue end
        pcall(function()
            if workspace.Enemies:FindFirstChild(_G.SelectMob) then
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == _G.SelectMob and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        repeat task.wait()
                            AutoHaki() EquipWeapon(_G.SelectWeapon)
                            v.HumanoidRootPart.CanCollide = false v.Humanoid.WalkSpeed = 0
                            v.HumanoidRootPart.Size = Vector3.new(80,80,80)
                            PosMon = v.HumanoidRootPart.CFrame
                            topos(v.HumanoidRootPart.CFrame * Pos)
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(1280,672))
                        until not _G.AutoFarmMob or not v.Parent or v.Humanoid.Health <= 0
                    end
                end
            else
                pcall(function()
                    for _, v in pairs(workspace["_WorldOrigin"].EnemySpawns:GetChildren()) do
                        if string.find(v.Name, _G.SelectMob) then
                            if (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude >= 10 then
                                topos(v.CFrame * CFrame.new(5,10,2))
                            end
                        end
                    end
                end)
            end
        end)
    end
end)

-- ========== AUTO FARM NEAREST ==========
task.spawn(function()
    while task.wait() do
        if not _G.AutoFarmNearest then continue end
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v.Name and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                repeat task.wait()
                    EquipWeapon(_G.SelectWeapon)
                    AutoHaki()
                    topos(v.HumanoidRootPart.CFrame * Pos)
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.Size = Vector3.new(60,60,60)
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(1280,672), workspace.CurrentCamera.CFrame)
                    PosMon = v.HumanoidRootPart.CFrame
                until not _G.AutoFarmNearest or not v.Parent or v.Humanoid.Health <= 0
            end
        end
    end
end)

-- ========== AUTO FARM BOSS ==========
task.spawn(function()
    while task.wait() do
        if not _G.AutoFarmBoss or _G.AutoQuestBoss then continue end
        pcall(function()
            if workspace.Enemies:FindFirstChild(_G.SelectBoss) then
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == _G.SelectBoss and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        repeat task.wait()
                            AutoHaki() EquipWeapon(_G.SelectWeapon)
                            v.HumanoidRootPart.CanCollide = false v.Humanoid.WalkSpeed = 0
                            v.HumanoidRootPart.Size = Vector3.new(80,80,80)
                            topos(v.HumanoidRootPart.CFrame * Pos)
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(1280,672))
                            pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                        until not _G.AutoFarmBoss or not v.Parent or v.Humanoid.Health <= 0
                    end
                end
            else
                if ReplicatedStorage:FindFirstChild(_G.SelectBoss) then
                    local bossHRP = ReplicatedStorage:FindFirstChild(_G.SelectBoss).HumanoidRootPart
                    if BypassTP then BTP(bossHRP.CFrame)
                    else topos(bossHRP.CFrame * CFrame.new(5,10,7)) end
                end
            end
        end)
    end
end)

-- Auto Farm All Boss
task.spawn(function()
    while task.wait() do
        if not _G.AutoAllBoss then continue end
        pcall(function()
            local bossList = {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Warden","Chief Warden","Swan","Saber Expert","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Greybeard","Diamond","Jeremy","Fajita","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Order","Darkbeard","Cursed Captain","Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate","Longma","Cake Queen","Soul Reaper","Rip_Indra","Cake Prince","Dough King"}
            for _, bossName in pairs(bossList) do
                local boss = ReplicatedStorage:FindFirstChild(bossName)
                if boss and boss:FindFirstChild("HumanoidRootPart") then
                    if (boss.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 17000 then
                        repeat task.wait()
                            AutoHaki() EquipWeapon(_G.SelectWeapon)
                            boss.Humanoid.WalkSpeed = 0
                            boss.HumanoidRootPart.CanCollide = false
                            boss.HumanoidRootPart.Size = Vector3.new(80,80,80)
                            topos(boss.HumanoidRootPart.CFrame * Pos)
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(1280,672))
                            pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                        until boss.Humanoid.Health <= 0 or not _G.AutoAllBoss or not boss.Parent
                    else
                        if _G.AutoAllBossHop then Hop() end
                    end
                end
            end
        end)
    end
end)

-- Auto Farm Chest
task.spawn(function()
    while task.wait() do
        if not _G.AutoFarmChest then continue end
        for _, v in pairs(workspace:GetChildren()) do
            if v.Name:find("Chest") then
                if (v.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 5000 then
                    repeat task.wait()
                        if workspace:FindFirstChild(v.Name) then TP(v.CFrame) end
                    until not _G.AutoFarmChest or not v.Parent
                    TP(LocalPlayer.Character.HumanoidRootPart.CFrame)
                    break
                end
            end
        end
    end
end)

-- ========== UI: LEVEL FARM TAB ==========
FarmTab:Section({ Title = "Status" })

local MonsterLabel = FarmTab:Paragraph({ Title = "Monster", Desc = "..." })
local QuestLabel   = FarmTab:Paragraph({ Title = "Quest",   Desc = "..." })

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local QuestUI = LocalPlayer.PlayerGui.Main.Quest
            if not QuestUI.Visible then
                MonsterLabel:SetDesc("...") QuestLabel:SetDesc("...")
            else
                CheckQuest()
                MonsterLabel:SetDesc(tostring(Mon))
                QuestLabel:SetDesc(tostring(NameQuest).." | Lv: "..tostring(LevelQuest))
            end
        end)
    end
end)

FarmTab:Section({ Title = "Settings" })

FarmTab:Toggle({
    Title = "Auto Set Spawn Point",
    Desc = "เปิดถ้าใช้ Bypass TP",
    Default = true,
    Callback = function(v) _G.Set = v end
})

FarmTab:Dropdown({
    Title = "Select Weapon",
    Desc = "เลือกอาวุธ",
    Options = {"Melee", "Sword", "Fruit", "Gun"},
    Value = "Melee",
    Callback = function(v) _G.SelectWeapon = v end
})

FarmTab:Dropdown({
    Title = "Farm Mode",
    Desc = "เลือกโหมดฟาร์ม",
    Options = {"Normal", "Not Tween To Npc Quest", "No Quest"},
    Value = "Normal",
    Callback = function(v) FarmMode = v end
})

FarmTab:Section({ Title = "Farm" })

FarmTab:Toggle({
    Title = "Auto Farm Level",
    Desc = "ฟาร์มอัตโนมัติตาม level",
    Default = false,
    Callback = function(v)
        _G.AutoFarm = v
        StopTween(_G.AutoFarm)
    end
})

-- ========== UI: FARM MOB TAB ==========
MobTab:Section({ Title = "Farm Mob" })

local tableMon
if World1 then
    tableMon = {"Bandit","Monkey","Gorilla","Pirate","Brute","Desert Bandit","Desert Officer","Snow Bandit","Snowman","Chief Petty Officer","Sky Bandit","Dark Master","Toga Warrior","Gladiator","Military Soldier","Military Spy","Fishman Warrior","Fishman Commando","God's Guard","Shanda","Royal Squad","Royal Soldier","Galley Pirate","Galley Captain"}
elseif World2 then
    tableMon = {"Raider","Mercenary","Swan Pirate","Factory Staff","Marine Lieutenant","Marine Captain","Zombie","Vampire","Snow Trooper","Winter Warrior","Lab Subordinate","Horned Warrior","Magma Ninja","Lava Pirate","Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior","Snow Lurker","Sea Soldier","Water Fighter"}
elseif World3 then
    tableMon = {"Pirate Millionaire","Dragon Crew Warrior","Dragon Crew Archer","Female Islander","Giant Islander","Marine Commodore","Marine Rear Admiral","Fishman Raider","Fishman Captain","Forest Pirate","Mythological Pirate","Jungle Pirate","Musketeer Pirate","Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy","Peanut Scout","Peanut President","Ice Cream Chef","Ice Cream Commander","Cookie Crafter","Cake Guard","Baking Staff","Head Baker","Cocoa Warrior","Chocolate Bar Battler","Sweet Thief","Candy Rebel","Candy Pirate","Snow Demon","Isle Outlaw","Island Boy","Sun-kissed Warrior","Isle Champion"}
else tableMon = {"Bandit"} end

MobTab:Dropdown({
    Title = "Select Mob",
    Desc = "เลือก mob",
    Options = tableMon,
    Value = tableMon[1],
    Callback = function(v) _G.SelectMob = v end
})

MobTab:Toggle({
    Title = "Auto Farm Mob",
    Desc = "ฟาร์ม mob ที่เลือก",
    Default = false,
    Callback = function(v)
        _G.AutoFarmMob = v
        StopTween(_G.AutoFarmMob)
    end
})

MobTab:Toggle({
    Title = "Auto Farm Nearest",
    Desc = "ฟาร์ม mob ที่ใกล้ที่สุด",
    Default = false,
    Callback = function(v)
        _G.AutoFarmNearest = v
        StopTween(_G.AutoFarmNearest)
    end
})

-- ========== UI: BOSS TAB ==========
BossTab:Section({ Title = "Boss Farm" })

local bossNames = {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Warden","Chief Warden","Swan","Saber Expert","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Greybeard","Diamond","Jeremy","Fajita","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Order","Darkbeard","Cursed Captain","Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate","Longma","Cake Queen","Soul Reaper","Rip_Indra","Cake Prince","Dough King"}

BossTab:Dropdown({
    Title = "Select Boss",
    Desc = "เลือก boss",
    Options = bossNames,
    Value = bossNames[1],
    Callback = function(v) _G.SelectBoss = v end
})

BossTab:Toggle({
    Title = "Auto Farm Boss",
    Desc = "ฟาร์ม boss ที่เลือก",
    Default = false,
    Callback = function(v)
        _G.AutoFarmBoss = v
        if v then CommF:InvokeServer("AbandonQuest") end
        StopTween(_G.AutoFarmBoss)
    end
})

BossTab:Toggle({
    Title = "Auto Quest Boss",
    Desc = "รับ quest boss อัตโนมัติ",
    Default = false,
    Callback = function(v) _G.AutoQuestBoss = v end
})

BossTab:Toggle({
    Title = "Auto Farm All Boss",
    Desc = "ฟาร์มทุก boss ในแมพ",
    Default = false,
    Callback = function(v)
        _G.AutoAllBoss = v
        StopTween(_G.AutoAllBoss)
    end
})

BossTab:Toggle({
    Title = "Auto Farm All Boss Hop",
    Desc = "hop เมื่อไม่มี boss",
    Default = false,
    Callback = function(v) _G.AutoAllBossHop = v end
})

-- ========== UI: CHEST TAB ==========
ChestTab:Section({ Title = "Chest Farm" })

ChestTab:Toggle({
    Title = "Auto Farm Chest",
    Desc = "ฟาร์ม chest ในแมพ",
    Default = false,
    Callback = function(v)
        _G.AutoFarmChest = v
        StopTween(_G.AutoFarmChest)
    end
})

-- ========== UI: SETTING TAB ==========
SettingTab:Section({ Title = "Teleport" })

SettingTab:Toggle({
    Title = "Bypass TP",
    Desc = "ใช้เมื่อ tween ไปไกลไม่ได้",
    Default = false,
    Callback = function(v) BypassTP = v end
})

SettingTab:Section({ Title = "Mob Setting" })

SettingTab:Toggle({
    Title = "Bring Mob",
    Desc = "ดึง mob เข้าหาตัวเอง",
    Default = true,
    Callback = function(v) _G.BringMonster = v end
})

SettingTab:Dropdown({
    Title = "Bring Mob Mode",
    Desc = "ระยะดึง mob",
    Options = {"Low", "Normal", "Super Bring"},
    Value = "Normal",
    Callback = function(v) _G.BringMode = v end
})

SettingTab:Toggle({
    Title = "Auto Haki",
    Desc = "เปิด Buso Haki อัตโนมัติ",
    Default = true,
    Callback = function(v) _G.AUTOHAKI = v end
})

Window:Notify({
    Title = "PIG HUB",
    Description = "Auto Farm โหลดสำเร็จ!",
    Duration = 4,
})
