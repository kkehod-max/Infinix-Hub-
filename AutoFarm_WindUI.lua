-- Auto Farm | Blox Fruit + WindUI
-- ย่อจาก Domadic Hub

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer.Character
    and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    and LocalPlayer.Data

-- ========== LOAD WINDUI ==========
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ========== VARIABLES ==========
local tween
local Mon, NameMon, NameQuest, LevelQuest
local CFrameMon, CFrameQuest
local MyLevel
local FarmMode = "Normal"
local StartMagnet = false
local PosMon
local Pos = CFrame.new(0, 2, 3)
local CommF = ReplicatedStorage.Remotes.CommF_
local BypassTP = false

-- World detection
local World1, World2, World3
if game.PlaceId == 2753915549 then World1 = true
elseif game.PlaceId == 4442272183 then World2 = true
elseif game.PlaceId == 7449423635 then World3 = true
else World1 = true end

-- ========== SETTINGS ==========
_G.AutoFarm = false
_G.SelectWeapon = "Melee"
_G.StopTween = false
_G.Clip = false
_G.NotAutoEquip = false

-- ========== HELPER FUNCTIONS ==========
local function AutoHaki()
    if not LocalPlayer.Character:FindFirstChild("HasBuso") then
        pcall(function() CommF:InvokeServer("Buso") end)
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

local function EquipWeapon(ToolSe)
    if not _G.NotAutoEquip then
        if LocalPlayer.Backpack:FindFirstChild(ToolSe) then
            local Tool = LocalPlayer.Backpack:FindFirstChild(ToolSe)
            task.wait(.1)
            pcall(function() LocalPlayer.Character.Humanoid:EquipTool(Tool) end)
        end
    end
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
            if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
            end
        end)
        _G.StopTween = false
        _G.Clip = false
    end
end

-- ========== CHECK QUEST BY LEVEL ==========
local function CheckQuest()
    MyLevel = LocalPlayer.Data.Level.Value
    if World1 then
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
        elseif MyLevel <= 324 then
            Mon="Military Soldier" NameQuest="FrigateQuest1" NameMon="Military Soldier" LevelQuest=1
            CFrameQuest=CFrame.new(-5313.37,10.95,8515.29) CFrameMon=CFrame.new(-5411.16,11.08,8454.29)
        elseif MyLevel <= 374 then
            Mon="Military Man" NameQuest="FrigateQuest1" NameMon="Military Man" LevelQuest=2
            CFrameQuest=CFrame.new(-5313.37,10.95,8515.29) CFrameMon=CFrame.new(-5802.86,86.26,8828.85)
        elseif MyLevel <= 424 then
            Mon="Fishman Warrior" NameQuest="FishIslandQuest" NameMon="Fishman Warrior" LevelQuest=1
            CFrameQuest=CFrame.new(-5039.58,27.35,4324.68) CFrameMon=CFrame.new(-4881.23,22.65,4273.75)
        elseif MyLevel <= 474 then
            Mon="Fishman Commando" NameQuest="FishIslandQuest" NameMon="Fishman Commando" LevelQuest=2
            CFrameQuest=CFrame.new(-5039.58,27.35,4324.68) CFrameMon=CFrame.new(-5259.84,391.39,-2229.03)
        elseif MyLevel <= 524 then
            Mon="Logue Town Soldier" NameQuest="LogueTownQuest" NameMon="Logue Town Soldier" LevelQuest=1
            CFrameQuest=CFrame.new(-4839.53,716.36,-2619.44) CFrameMon=CFrame.new(-4953.20,295.74,-2899.22)
        elseif MyLevel <= 574 then
            Mon="Logue Town Citizen" NameQuest="LogueTownQuest" NameMon="Logue Town Citizen" LevelQuest=2
            CFrameQuest=CFrame.new(-4839.53,716.36,-2619.44) CFrameMon=CFrame.new(-5259.84,391.39,-2229.03)
        elseif MyLevel <= 624 then
            Mon="Marine Seaman" NameQuest="MarineQuest4" NameMon="Marine Seaman" LevelQuest=1
            CFrameQuest=CFrame.new(894.48,5.14,4392.43) CFrameMon=CFrame.new(924.79,6.44,4481.58)
        elseif MyLevel <= 699 then
            Mon="Marine Ensign" NameQuest="MarineQuest4" NameMon="Marine Ensign" LevelQuest=2
            CFrameQuest=CFrame.new(894.48,5.14,4392.43) CFrameMon=CFrame.new(1608.28,8.61,4371.00)
        else
            Mon="Bandit" NameQuest="BanditQuest1" NameMon="Bandit" LevelQuest=1
            CFrameQuest=CFrame.new(1059.37,15.44,1550.42) CFrameMon=CFrame.new(1045.96,27.0,1560.82)
        end
    elseif World2 then
        if MyLevel <= 724 then
            Mon="Raider" NameQuest="Area1Quest" NameMon="Raider" LevelQuest=1
            CFrameQuest=CFrame.new(-429.54,71.76,1836.18) CFrameMon=CFrame.new(-728.32,52.77,2345.77)
        elseif MyLevel <= 774 then
            Mon="Mercenary" NameQuest="Area1Quest" NameMon="Mercenary" LevelQuest=2
            CFrameQuest=CFrame.new(-429.54,71.76,1836.18) CFrameMon=CFrame.new(-1004.32,80.15,1424.61)
        elseif MyLevel <= 799 then
            Mon="Swan Pirate" NameQuest="Area2Quest" NameMon="Swan Pirate" LevelQuest=1
            CFrameQuest=CFrame.new(638.43,71.76,918.28) CFrameMon=CFrame.new(1068.66,137.61,1322.10)
        elseif MyLevel <= 874 then
            Mon="Factory Staff" NameQuest="Area2Quest" NameMon="Factory Staff" LevelQuest=2
            CFrameQuest=CFrame.new(632.69,73.10,918.66) CFrameMon=CFrame.new(73.07,81.86,-27.47)
        elseif MyLevel <= 899 then
            Mon="Marine Lieutenant" NameQuest="MarineQuest3" NameMon="Marine Lieutenant" LevelQuest=1
            CFrameQuest=CFrame.new(-2440.79,71.71,-3216.06) CFrameMon=CFrame.new(-2821.37,75.89,-3070.08)
        elseif MyLevel <= 949 then
            Mon="Marine Captain" NameQuest="MarineQuest3" NameMon="Marine Captain" LevelQuest=2
            CFrameQuest=CFrame.new(-2440.79,71.71,-3216.06) CFrameMon=CFrame.new(-1861.23,80.17,-3254.69)
        elseif MyLevel <= 974 then
            Mon="Zombie" NameQuest="ZombieQuest" NameMon="Zombie" LevelQuest=1
            CFrameQuest=CFrame.new(-5497.06,47.59,-795.23) CFrameMon=CFrame.new(-5657.77,78.96,-928.68)
        elseif MyLevel <= 999 then
            Mon="Vampire" NameQuest="ZombieQuest" NameMon="Vampire" LevelQuest=2
            CFrameQuest=CFrame.new(-5497.06,47.59,-795.23) CFrameMon=CFrame.new(-6037.66,32.18,-1340.65)
        elseif MyLevel <= 1049 then
            Mon="Snow Trooper" NameQuest="SnowMountainQuest" NameMon="Snow Trooper" LevelQuest=1
            CFrameQuest=CFrame.new(609.85,400.11,-5372.25) CFrameMon=CFrame.new(549.14,427.38,-5563.69)
        elseif MyLevel <= 1099 then
            Mon="Winter Warrior" NameQuest="SnowMountainQuest" NameMon="Winter Warrior" LevelQuest=2
            CFrameQuest=CFrame.new(609.85,400.11,-5372.25) CFrameMon=CFrame.new(1142.74,475.63,-5199.41)
        elseif MyLevel <= 1124 then
            Mon="Lab Subordinate" NameQuest="IceSideQuest" NameMon="Lab Subordinate" LevelQuest=1
            CFrameQuest=CFrame.new(-6064.06,15.24,-4902.97) CFrameMon=CFrame.new(-5707.47,15.95,-4513.39)
        elseif MyLevel <= 1174 then
            Mon="Horned Warrior" NameQuest="IceSideQuest" NameMon="Horned Warrior" LevelQuest=2
            CFrameQuest=CFrame.new(-6064.06,15.24,-4902.97) CFrameMon=CFrame.new(-6341.36,15.95,-5723.16)
        elseif MyLevel <= 1199 then
            Mon="Magma Ninja" NameQuest="FireSideQuest" NameMon="Magma Ninja" LevelQuest=1
            CFrameQuest=CFrame.new(-5428.03,15.06,-5299.43) CFrameMon=CFrame.new(-5449.67,76.65,-5808.20)
        elseif MyLevel <= 1249 then
            Mon="Lava Pirate" NameQuest="FireSideQuest" NameMon="Lava Pirate" LevelQuest=2
            CFrameQuest=CFrame.new(-5428.03,15.06,-5299.43) CFrameMon=CFrame.new(-5213.33,49.73,-4701.45)
        else
            Mon="Raider" NameQuest="Area1Quest" NameMon="Raider" LevelQuest=1
            CFrameQuest=CFrame.new(-429.54,71.76,1836.18) CFrameMon=CFrame.new(-728.32,52.77,2345.77)
        end
    elseif World3 then
        if MyLevel <= 1524 then
            Mon="Pirate Millionaire" NameQuest="CastleOnSeaQuest" NameMon="Pirate Millionaire" LevelQuest=1
            CFrameQuest=CFrame.new(-7859.09,5544.19,-381.47) CFrameMon=CFrame.new(-7678.48,5566.40,-497.21)
        elseif MyLevel <= 1574 then
            Mon="Dragon Crew Warrior" NameQuest="AmazonQuest" NameMon="Dragon Crew Warrior" LevelQuest=1
            CFrameQuest=CFrame.new(5832.83,51.68,-1101.51) CFrameMon=CFrame.new(6141.14,51.35,-1340.73)
        elseif MyLevel <= 1624 then
            Mon="Dragon Crew Archer" NameQuest="AmazonQuest" NameMon="Dragon Crew Archer" LevelQuest=2
            CFrameQuest=CFrame.new(5833.11,51.60,-1103.06) CFrameMon=CFrame.new(6616.41,441.76,446.04)
        elseif MyLevel <= 1649 then
            Mon="Female Islander" NameQuest="AmazonQuest2" NameMon="Female Islander" LevelQuest=1
            CFrameQuest=CFrame.new(5446.87,601.62,749.45) CFrameMon=CFrame.new(4685.25,735.80,815.34)
        elseif MyLevel <= 1699 then
            Mon="Giant Islander" NameQuest="AmazonQuest2" NameMon="Giant Islander" LevelQuest=2
            CFrameQuest=CFrame.new(5446.87,601.62,749.45) CFrameMon=CFrame.new(4729.09,590.43,-36.97)
        elseif MyLevel <= 1724 then
            Mon="Marine Commodore" NameQuest="MarineTreeIsland" NameMon="Marine Commodore" LevelQuest=1
            CFrameQuest=CFrame.new(2180.54,27.81,-6741.54) CFrameMon=CFrame.new(2286.00,73.13,-7159.80)
        elseif MyLevel <= 1774 then
            Mon="Marine Rear Admiral" NameQuest="MarineTreeIsland" NameMon="Marine Rear Admiral" LevelQuest=2
            CFrameQuest=CFrame.new(2179.98,28.73,-6740.05) CFrameMon=CFrame.new(3656.77,160.52,-7001.59)
        else
            Mon="Pirate Millionaire" NameQuest="CastleOnSeaQuest" NameMon="Pirate Millionaire" LevelQuest=1
            CFrameQuest=CFrame.new(-7859.09,5544.19,-381.47) CFrameMon=CFrame.new(-7678.48,5566.40,-497.21)
        end
    end
end

-- ========== AUTO WEAPON SELECT ==========
task.spawn(function()
    while task.wait() do
        pcall(function()
            for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                if v:IsA("Tool") then
                    if _G.SelectWeapon == "Melee" and v.ToolTip == "Melee" then
                        _G.SelectWeapon = v.Name
                    elseif _G.SelectWeapon == "Sword" and v.ToolTip == "Sword" then
                        _G.SelectWeapon = v.Name
                    elseif _G.SelectWeapon == "Gun" and v.ToolTip == "Gun" then
                        _G.SelectWeapon = v.Name
                    elseif _G.SelectWeapon == "Fruit" and v.ToolTip == "Blox Fruit" then
                        _G.SelectWeapon = v.Name
                    end
                end
            end
        end)
    end
end)

-- ========== FARM LOOPS ==========
-- Normal Mode
task.spawn(function()
    while task.wait() do
        if FarmMode ~= "Normal" or not _G.AutoFarm then continue end
        pcall(function()
            local QuestUI = LocalPlayer.PlayerGui.Main.Quest
            local QuestTitle = QuestUI.Container.QuestTitle.Title.Text
            if not string.find(QuestTitle, NameMon or "") then
                StartMagnet = false
                CommF:InvokeServer("AbandonQuest")
            end
            if not QuestUI.Visible then
                UnEquipWeapon(_G.SelectWeapon)
                StartMagnet = false
                CheckQuest()
                if BypassTP then
                    if (LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude > 1500 then
                        BTP(CFrameQuest * CFrame.new(0,20,5))
                    else topos(CFrameQuest) end
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
                            if string.find(QuestTitle, NameMon) then
                                repeat task.wait()
                                    EquipWeapon(_G.SelectWeapon)
                                    AutoHaki()
                                    PosMon = v.HumanoidRootPart.CFrame
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    pcall(function()
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        v.HumanoidRootPart.Size = Vector3.new(70,70,70)
                                    end)
                                    StartMagnet = true
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280,672))
                                until not _G.AutoFarm or v.Humanoid.Health <= 0
                                    or not v.Parent or not QuestUI.Visible
                            else
                                StartMagnet = false
                                CommF:InvokeServer("AbandonQuest")
                            end
                        end
                    end
                else
                    topos(CFrameMon)
                    UnEquipWeapon(_G.SelectWeapon)
                    StartMagnet = false
                end
            end
        end)
    end
end)

-- Not Tween To Npc Quest Mode
task.spawn(function()
    while task.wait() do
        if FarmMode ~= "Not Tween To Npc Quest" or not _G.AutoFarm then continue end
        pcall(function()
            local QuestUI = LocalPlayer.PlayerGui.Main.Quest
            local QuestTitle = QuestUI.Container.QuestTitle.Title.Text
            if not string.find(QuestTitle, NameMon or "") then
                StartMagnet = false
                CommF:InvokeServer("AbandonQuest")
            end
            if not QuestUI.Visible then
                StartMagnet = false
                CheckQuest()
                UnEquipWeapon(_G.SelectWeapon)
                CommF:InvokeServer("StartQuest", NameQuest, LevelQuest)
                if BypassTP then
                    if (LocalPlayer.Character.HumanoidRootPart.Position - CFrameMon.Position).Magnitude > 1500 then
                        BTP(CFrameMon)
                    else topos(CFrameMon) end
                else topos(CFrameMon) end
            else
                CheckQuest()
                if workspace.Enemies:FindFirstChild(Mon) then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid")
                            and v.Humanoid.Health > 0 and v.Name == Mon then
                            if string.find(QuestTitle, NameMon) then
                                repeat task.wait()
                                    EquipWeapon(_G.SelectWeapon)
                                    AutoHaki()
                                    PosMon = v.HumanoidRootPart.CFrame
                                    topos(v.HumanoidRootPart.CFrame * Pos)
                                    pcall(function()
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        v.HumanoidRootPart.Size = Vector3.new(70,70,70)
                                    end)
                                    StartMagnet = true
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280,672))
                                until not _G.AutoFarm or v.Humanoid.Health <= 0
                                    or not v.Parent or not QuestUI.Visible
                            else
                                StartMagnet = false
                                CommF:InvokeServer("AbandonQuest")
                            end
                        end
                    end
                else
                    topos(CFrameMon)
                    UnEquipWeapon(_G.SelectWeapon)
                    StartMagnet = false
                end
            end
        end)
    end
end)

-- No Quest Mode
task.spawn(function()
    while task.wait() do
        if FarmMode ~= "No Quest" or not _G.AutoFarm then continue end
        pcall(function()
            CheckQuest()
            if workspace.Enemies:FindFirstChild(Mon) then
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == Mon and v:FindFirstChild("Humanoid")
                        and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        repeat task.wait()
                            AutoHaki()
                            EquipWeapon(_G.SelectWeapon)
                            pcall(function()
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                            end)
                            topos(v.HumanoidRootPart.CFrame * Pos)
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(1280,672))
                        until not _G.AutoFarm or v.Humanoid.Health <= 0 or not v.Parent
                    end
                end
            else
                topos(CFrameMon)
            end
        end)
    end
end)

-- ========== WINDUI ==========
local Window = WindUI:CreateWindow({
    Title = "Auto Farm",
    Icon = "sword",
    Author = "Blox Fruit",
    Folder = "AutoFarm",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
})

local Tabs = Window:Tabs()
local FarmTab = Tabs:Add({
    Name = "Auto Farm",
    Icon = "zap",
})

-- Status Labels
local MonsterStatus = FarmTab:Paragraph({
    Title = "Monster",
    Description = "...",
})
local QuestStatus = FarmTab:Paragraph({
    Title = "Quest",
    Description = "...",
})

task.spawn(function()
    while task.wait() do
        pcall(function()
            local QuestUI = LocalPlayer.PlayerGui.Main.Quest
            if not QuestUI.Visible then
                MonsterStatus:SetDescription("...")
                QuestStatus:SetDescription("...")
            else
                CheckQuest()
                MonsterStatus:SetDescription(tostring(Mon))
                QuestStatus:SetDescription(tostring(NameQuest) .. " | Level: " .. tostring(LevelQuest))
            end
        end)
    end
end)

FarmTab:Divider()

-- Select Weapon
FarmTab:Dropdown({
    Title = "Select Weapon",
    Description = "เลือกอาวุธที่ใช้ตี",
    Options = {"Melee", "Sword", "Gun", "Fruit"},
    Default = "Melee",
    Callback = function(value)
        _G.SelectWeapon = value
    end,
})

-- Farm Mode
FarmTab:Dropdown({
    Title = "Farm Mode",
    Description = "เลือกโหมดการฟาร์ม",
    Options = {"Normal", "Not Tween To Npc Quest", "No Quest"},
    Default = "Normal",
    Callback = function(value)
        FarmMode = value
    end,
})

-- Bypass TP
FarmTab:Toggle({
    Title = "Bypass TP",
    Description = "ใช้เมื่อ tween ไปไกลไม่ได้",
    Default = false,
    Callback = function(value)
        BypassTP = value
    end,
})

FarmTab:Divider()

-- Auto Farm Toggle
FarmTab:Toggle({
    Title = "Auto Farm Level",
    Description = "เปิด/ปิดระบบ Auto Farm",
    Default = false,
    Callback = function(value)
        _G.AutoFarm = value
        StopTween(_G.AutoFarm)
    end,
})

Window:Notify({
    Title = "Auto Farm",
    Description = "โหลดสำเร็จ!",
    Duration = 4,
})
