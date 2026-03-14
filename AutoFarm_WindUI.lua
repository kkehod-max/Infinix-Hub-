-- Auto Farm + Fast Attack | Blox Fruit
-- WindUI by Footagesus

-- ========== LOAD WINDUI ==========
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer.Character
    and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    and LocalPlayer.Data

-- ========== FAST ATTACK ==========
local env = (getgenv or getrenv or getfenv)()
local modules = ReplicatedStorage:WaitForChild("Modules")
local net = modules:WaitForChild("Net")
local charFolder = workspace:WaitForChild("Characters")
local enemyFolder = workspace:WaitForChild("Enemies")

local AttackCooldown = tick()
local CachedChars = {}

local Settings = {
    ClickDelay = 0,
    AutoClick = true
}

_G['Fast Attack'] = false

local function IsAlive(Char)
    if not Char then return nil end
    local Hum = CachedChars[Char] or Char:FindFirstChildOfClass("Humanoid")
    if Hum then CachedChars[Char] = Hum return Hum.Health > 0 end
    return false
end

local function StartFastAttack()
    if env._trash_attack then return env._trash_attack end

    local RegisterAttack = net:WaitForChild("RE/RegisterAttack")
    local RegisterHit = net:WaitForChild("RE/RegisterHit")

    local AttackModule = {
        NextAttack = 0,
        Distance = 150,
        FirstAttack = false,
    }

    function AttackModule:AttackEnemy(EnemyHead, Table)
        if EnemyHead and LocalPlayer:DistanceFromCharacter(EnemyHead.Position) < self.Distance then
            if not self.FirstAttack then
                RegisterAttack:FireServer(Settings.ClickDelay or 0)
                self.FirstAttack = true
            end
            RegisterHit:FireServer(EnemyHead, Table or {})
        end
    end

    function AttackModule:AttackNearest()
        local args = {nil, {}}
        for _, Enemy in ipairs(enemyFolder:GetChildren()) do
            local humanoidPart = Enemy:FindFirstChild("HumanoidRootPart")
            if humanoidPart and LocalPlayer:DistanceFromCharacter(humanoidPart.Position) < self.Distance then
                local upperTorso = Enemy:FindFirstChild("UpperTorso")
                if not args[1] then args[1] = upperTorso
                else table.insert(args[2], {Enemy, upperTorso}) end
            end
        end
        self:AttackEnemy(unpack(args))
        for _, Char in ipairs(charFolder:GetChildren()) do
            if Char ~= LocalPlayer.Character then
                self:AttackEnemy(Char:FindFirstChild("UpperTorso"))
            end
        end
        if not self.FirstAttack then task.wait(0) end
    end

    function AttackModule:BladeHits()
        self:AttackNearest()
        self.FirstAttack = false
    end

    task.spawn(function()
        while task.wait(Settings.ClickDelay or 0) do
            if not _G['Fast Attack'] then task.wait(0.1) continue end
            if (tick() - AttackCooldown) < 0 then continue end
            if not Settings.AutoClick then continue end
            if not IsAlive(LocalPlayer.Character) then continue end
            if not LocalPlayer.Character:FindFirstChildOfClass("Tool") then continue end
            AttackModule:BladeHits()
        end
    end)

    env._trash_attack = AttackModule
    return AttackModule
end

StartFastAttack()

-- ========== AUTO FARM ==========
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

_G.AutoFarm = false
_G.SelectWeapon = "Melee"
_G.StopTween = false
_G.Clip = false
_G.NotAutoEquip = false

local World1, World2, World3
if game.PlaceId == 2753915549 then World1 = true
elseif game.PlaceId == 4442272183 then World2 = true
elseif game.PlaceId == 7449423635 then World3 = true
else World1 = true end

local function AutoHaki()
    if not LocalPlayer.Character:FindFirstChild("HasBuso") then
        pcall(function() CommF:InvokeServer("Buso") end)
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

-- Auto Weapon Select
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

local function FarmLoop(v, QuestUI)
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
    until not _G.AutoFarm or v.Humanoid.Health <= 0 or not v.Parent or not QuestUI.Visible
end

-- Normal
task.spawn(function()
    while task.wait() do
        if FarmMode ~= "Normal" or not _G.AutoFarm then continue end
        pcall(function()
            local QuestUI = LocalPlayer.PlayerGui.Main.Quest
            local QuestTitle = QuestUI.Container.QuestTitle.Title.Text
            if not string.find(QuestTitle, NameMon or "") then StartMagnet = false CommF:InvokeServer("AbandonQuest") end
            if not QuestUI.Visible then
                UnEquipWeapon(_G.SelectWeapon) StartMagnet = false CheckQuest()
                if BypassTP and (LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude > 1500 then BTP(CFrameQuest * CFrame.new(0,20,5)) else topos(CFrameQuest) end
                if (LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude <= 5 then CommF:InvokeServer("StartQuest", NameQuest, LevelQuest) end
            else
                CheckQuest()
                if workspace.Enemies:FindFirstChild(Mon) then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Name == Mon then
                            if string.find(QuestTitle, NameMon) then FarmLoop(v, QuestUI)
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
            local QuestTitle = QuestUI.Container.QuestTitle.Title.Text
            if not string.find(QuestTitle, NameMon or "") then StartMagnet = false CommF:InvokeServer("AbandonQuest") end
            if not QuestUI.Visible then
                StartMagnet = false CheckQuest() UnEquipWeapon(_G.SelectWeapon)
                CommF:InvokeServer("StartQuest", NameQuest, LevelQuest)
                if BypassTP and (LocalPlayer.Character.HumanoidRootPart.Position - CFrameMon.Position).Magnitude > 1500 then BTP(CFrameMon) else topos(CFrameMon) end
            else
                CheckQuest()
                if workspace.Enemies:FindFirstChild(Mon) then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Name == Mon then
                            if string.find(QuestTitle, NameMon) then FarmLoop(v, QuestUI)
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
                            VirtualUser:CaptureController() VirtualUser:Button1Down(Vector2.new(1280,672))
                        until not _G.AutoFarm or v.Humanoid.Health <= 0 or not v.Parent
                    end
                end
            else topos(CFrameMon) end
        end)
    end
end)

-- ========== WINDUI ==========
local Window = WindUI:CreateWindow({
    Title = "PIG HUB",
    Icon = "sword",
    Author = "Blox Fruit",
    Folder = "PigHub",
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",
})

-- ===== TAB: AUTO FARM =====
local FarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "zap",
})

local MonsterStatus = FarmTab:Paragraph({
    Title = "Monster",
    Desc = "...",
})
local QuestStatus = FarmTab:Paragraph({
    Title = "Quest",
    Desc = "...",
})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local QuestUI = LocalPlayer.PlayerGui.Main.Quest
            if not QuestUI.Visible then
                MonsterStatus:SetDesc("...") QuestStatus:SetDesc("...")
            else
                CheckQuest()
                MonsterStatus:SetDesc(tostring(Mon))
                QuestStatus:SetDesc(tostring(NameQuest).." | Lv: "..tostring(LevelQuest))
            end
        end)
    end
end)

FarmTab:Divider({ Title = "Settings" })

FarmTab:Dropdown({
    Title = "Select Weapon",
    Desc = "เลือกอาวุธที่ใช้ตี",
    Options = {"Melee", "Sword", "Gun", "Fruit"},
    Value = "Melee",
    Callback = function(value) _G.SelectWeapon = value end,
})

FarmTab:Dropdown({
    Title = "Farm Mode",
    Desc = "เลือกโหมดการฟาร์ม",
    Options = {"Normal", "Not Tween To Npc Quest", "No Quest"},
    Value = "Normal",
    Callback = function(value) FarmMode = value end,
})

FarmTab:Toggle({
    Title = "Bypass TP",
    Desc = "ใช้เมื่อ tween ไปไกลไม่ได้",
    Value = false,
    Callback = function(value) BypassTP = value end,
})

FarmTab:Divider({ Title = "Farm" })

FarmTab:Toggle({
    Title = "Auto Farm Level",
    Desc = "ฟาร์มอัตโนมัติตาม level",
    Value = false,
    Callback = function(value)
        _G.AutoFarm = value
        StopTween(_G.AutoFarm)
    end,
})

-- ===== TAB: FAST ATTACK =====
local AttackTab = Window:Tab({
    Title = "Fast Attack",
    Icon = "swords",
})

AttackTab:Divider({ Title = "Fast Attack" })

AttackTab:Toggle({
    Title = "Fast Attack",
    Desc = "ตีอัตโนมัติไวๆ",
    Value = false,
    Callback = function(value) _G['Fast Attack'] = value end,
})

AttackTab:Slider({
    Title = "Attack Distance",
    Desc = "ระยะโจมตี (default 150)",
    Min = 10,
    Max = 500,
    Value = 150,
    Callback = function(value)
        if env._trash_attack then env._trash_attack.Distance = value end
    end,
})

AttackTab:Toggle({
    Title = "Auto Click",
    Desc = "จำลองการคลิกอัตโนมัติ",
    Value = true,
    Callback = function(value) Settings.AutoClick = value end,
})

-- ===== NOTIFY =====
Window:Notify({
    Title = "PIG HUB",
    Description = "โหลดสำเร็จ!",
    Duration = 4,
})
