local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local DownloadGui = Instance.new("ScreenGui")
DownloadGui.Name = "PigHubLoad"
DownloadGui.Parent = CoreGui
DownloadGui.ResetOnSpawn = false
DownloadGui.IgnoreGuiInset = true

-- Background overlay (dark)
local BG = Instance.new("Frame")
BG.Size = UDim2.new(1, 0, 1, 0)
BG.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
BG.BackgroundTransparency = 0
BG.BorderSizePixel = 0
BG.Parent = DownloadGui

-- Animated background gradient
local BGGrad = Instance.new("UIGradient")
BGGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 20))
})
BGGrad.Rotation = 135
BGGrad.Parent = BG

-- Glow circle behind image
local GlowCircle = Instance.new("ImageLabel")
GlowCircle.Size = UDim2.new(0, 420, 0, 420)
GlowCircle.Position = UDim2.new(0.5, -210, 0.5, -280)
GlowCircle.BackgroundTransparency = 1
GlowCircle.Image = "rbxassetid://5028857084"
GlowCircle.ImageColor3 = Color3.fromRGB(0, 150, 255)
GlowCircle.ImageTransparency = 1
GlowCircle.Parent = DownloadGui

-- Character image
local CharImage = Instance.new("ImageLabel")
CharImage.Size = UDim2.new(0, 300, 0, 300)
CharImage.Position = UDim2.new(0.5, -150, 0.5, -230)
CharImage.BackgroundTransparency = 1
CharImage.Image = "rbxassetid://117924028123190"
CharImage.ImageTransparency = 1
CharImage.Parent = DownloadGui

-- Main title "PIG HUB"
local CampName = Instance.new("TextLabel")
CampName.Size = UDim2.new(0, 500, 0, 80)
CampName.Position = UDim2.new(0.5, -250, 0.5, 90)
CampName.BackgroundTransparency = 1
CampName.Text = "PIG HUB"
CampName.TextColor3 = Color3.fromRGB(255, 255, 255)
CampName.TextScaled = true
CampName.Font = Enum.Font.GothamBold
CampName.TextTransparency = 1
CampName.Parent = DownloadGui

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 230, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 255))
})
TitleGradient.Rotation = 45
TitleGradient.Parent = CampName

-- Subtitle "Loading..."
local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 400, 0, 30)
SubTitle.Position = UDim2.new(0.5, -200, 0.5, 178)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Loading..."
SubTitle.TextColor3 = Color3.fromRGB(100, 180, 255)
SubTitle.TextScaled = true
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextTransparency = 1
SubTitle.Parent = DownloadGui

-- Progress bar background
local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0, 320, 0, 6)
BarBG.Position = UDim2.new(0.5, -160, 0.5, 220)
BarBG.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
BarBG.BorderSizePixel = 0
BarBG.BackgroundTransparency = 1
BarBG.Parent = DownloadGui

local BarBGCorner = Instance.new("UICorner")
BarBGCorner.CornerRadius = UDim.new(1, 0)
BarBGCorner.Parent = BarBG

-- Progress bar fill
local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBG

local BarFillCorner = Instance.new("UICorner")
BarFillCorner.CornerRadius = UDim.new(1, 0)
BarFillCorner.Parent = BarFill

local BarFillGrad = Instance.new("UIGradient")
BarFillGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 220, 255))
})
BarFillGrad.Parent = BarFill

-- Version label
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 200, 0, 24)
VersionLabel.Position = UDim2.new(0.5, -100, 0.5, 235)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v0.10 • PIG TEAM"
VersionLabel.TextColor3 = Color3.fromRGB(60, 100, 160)
VersionLabel.TextScaled = true
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextTransparency = 1
VersionLabel.Parent = DownloadGui

-- Decorative line left
local LineLeft = Instance.new("Frame")
LineLeft.Size = UDim2.new(0, 80, 0, 1)
LineLeft.Position = UDim2.new(0.5, -180, 0.5, 170)
LineLeft.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
LineLeft.BorderSizePixel = 0
LineLeft.BackgroundTransparency = 1
LineLeft.Parent = DownloadGui

-- Decorative line right
local LineRight = Instance.new("Frame")
LineRight.Size = UDim2.new(0, 80, 0, 1)
LineRight.Position = UDim2.new(0.5, 100, 0.5, 170)
LineRight.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
LineRight.BorderSizePixel = 0
LineRight.BackgroundTransparency = 1
LineRight.Parent = DownloadGui

task.spawn(function()
    -- Phase 1: Fade in background glow
    TweenService:Create(GlowCircle, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {ImageTransparency = 0.5}):Play()
    TweenService:Create(BarBG, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
    task.wait(0.3)

    -- Phase 2: Fade in character image with scale feel
    local fadeInImage = TweenService:Create(CharImage, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {ImageTransparency = 0})
    fadeInImage:Play()
    fadeInImage.Completed:Wait()
    task.wait(0.2)

    -- Phase 3: Fade in title + decorative lines
    TweenService:Create(CampName, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {TextTransparency = 0}):Play()
    TweenService:Create(LineLeft, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(LineRight, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.4}):Play()
    task.wait(0.3)

    TweenService:Create(SubTitle, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
    TweenService:Create(VersionLabel, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
    task.wait(0.5)

    -- Phase 4: Animate gradient on title + progress bar filling
    local angle = 45
    local barTween = TweenService:Create(BarFill, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
    barTween:Play()

    local loadingDots = {"Loading.", "Loading..", "Loading..."}
    local dotIndex = 1

    while BarFill.Size.X.Scale < 0.98 do
        angle = (angle + 1.5) % 360
        TitleGradient.Rotation = angle
        -- Pulse glow
        GlowCircle.ImageColor3 = Color3.fromHSV((tick() * 0.2) % 1, 0.8, 1)
        -- Update dots
        dotIndex = (dotIndex % 3) + 1
        SubTitle.Text = loadingDots[dotIndex]
        task.wait(0.04)
    end

    SubTitle.Text = "Ready!"
    task.wait(0.6)

    -- Phase 5: Fade everything out
    local fadeOuts = {CharImage, CampName, SubTitle, VersionLabel, LineLeft, LineRight, GlowCircle}
    for _, obj in ipairs(fadeOuts) do
        local prop = obj:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
        if obj:IsA("Frame") then prop = "BackgroundTransparency" end
        TweenService:Create(obj, TweenInfo.new(0.8), {[prop] = 1}):Play()
    end
    TweenService:Create(BarBG, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BG, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
    task.wait(1)

    DownloadGui:Destroy()
end)
repeat task.wait() until not CoreGui:FindFirstChild("PigHubLoad")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

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
ToggleBtn.Size = UDim2.new(0,50,0,50)
ToggleBtn.Position = UDim2.new(0,20,0.5,-25)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Image = "rbxassetid://81857105973850"
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local function ToggleUI()
    if Window.Toggle then
        Window:Toggle()
    else
        Window.UI.Enabled = not Window.UI.Enabled
    end
end

ToggleBtn.MouseButton1Click:Connect(ToggleUI)
UserInputService.InputBegan:Connect(function(i,gp)
    if not gp and i.KeyCode == Enum.KeyCode.T then
        ToggleUI()
    end
end)

local PlayerTab = Window:Tab({Title="Player",Icon="user"})
local ESPTab = Window:Tab({Title="ESP",Icon="crosshair"})
local PVPTab = Window:Tab({Title="PVP",Icon="target"})
local QuestTab = Window:Tab({Title="Quest",Icon="flag"})
local ServerTab = Window:Tab({Title="Server",Icon="globe"})

PlayerTab:Section({Title="Player Stats"})
local BankBalance = PlayerTab:Button({Title="Bank Balance",Desc="<b><font color='#1E90FF'>$0</font></b>"})
local HandBalance = PlayerTab:Button({Title="Hand Balance",Desc="<b><font color='#00BFFF'>$0</font></b>"})

local function formatMoney(amount)
    amount = tonumber(amount) or 0
    if amount >= 1000000 then return string.format("$%.1fM", amount/1000000)
    elseif amount >= 1000 then return string.format("$%.1fK", amount/1000)
    else return string.format("$%d", amount) end
end

local function HandMoney()
    local success, value = pcall(function()
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not PlayerGui then return 0 end
        local topRight = PlayerGui:FindFirstChild("TopRightHud")
        if topRight then
            local holder = topRight:FindFirstChild("Holder")
            if holder and holder:FindFirstChild("Frame") and holder.Frame:FindFirstChild("MoneyTextLabel") then
                return tonumber(holder.Frame.MoneyTextLabel.Text:gsub("[$,]", "")) or 0
            end
        end
        return 0
    end)
    return success and value or 0
end

local function ATMMoney()
    local success, value = pcall(function()
        for _, v in ipairs(PlayerGui:GetDescendants()) do
            if v:IsA("TextLabel") and (v.Text:find("Bank") or v.Text:find("Balance")) then
                return tonumber(v.Text:gsub("[$,]", ""):gsub("Bank", ""):gsub("Balance", ""):gsub(":", ""):match("%d+")) or 0
            end
        end
        return 0
    end)
    return success and value or 0
end

task.spawn(function()
    while task.wait(0.5) do
        BankBalance:SetDesc('<b><font color="#1E90FF">' .. formatMoney(ATMMoney()) .. "</font></b>")
        HandBalance:SetDesc('<b><font color="#00BFFF">' .. formatMoney(HandMoney()) .. "</font></b>")
    end
end)

PlayerTab:Section({Title="ซ่อนชื่อและเลเวล"})
PlayerTab:Button({Title="เปิดใช้ระบบ", Desc="คลิกเพื่อเปิดระบบซ่อนชื่อและเลเวล", Callback = function()
    loadstring(game:HttpGet("https://pastefy.app/3BxE2aGP/raw",true))()
end})
PlayerTab:Section({Title="ANTI-LOOK SYSTEM"})

local AntiLookEnabled = false
local AntiLookHeight = 1500
local AntiLookConnection = nil

local function ToggleAntiLook(state)
    AntiLookEnabled = state
    
    if state then
        if AntiLookConnection then
            AntiLookConnection:Disconnect()
        end
        
        AntiLookConnection = RunService.Heartbeat:Connect(function()
            if AntiLookEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local currentVelocity = hrp.Velocity
                local angle = math.rad(tick() * 1500 % 360)
                
                local xVelocity = math.cos(angle) * AntiLookHeight
                local zVelocity = math.sin(angle) * AntiLookHeight
                local yVelocity = math.random(280, 480)
                
                hrp.Velocity = Vector3.new(xVelocity, yVelocity, zVelocity)
                
                task.wait()
                
                if hrp and hrp.Parent then
                    hrp.Velocity = currentVelocity
                end
            end
        end)
    else
        if AntiLookConnection then
            AntiLookConnection:Disconnect()
            AntiLookConnection = nil
        end
    end
end

PlayerTab:Toggle({
    Title = "Anti-Look",
    Desc = "ป้องกันการล็อคเป้า",
    Default = false,
    Callback = function(v)
        ToggleAntiLook(v)
    end
})

PlayerTab:Slider({
    Title = "Anti-Look Height",
    Desc = "ปรับความสูง 500-3000",
    Step = 10,
    Value = {Min = 500, Max = 3000, Default = 1500},
    Callback = function(v)
        AntiLookHeight = v
    end
})

PlayerTab:Section({Title="Sit System"})
local sit=false
local sitHeight=0
local sitConn

PlayerTab:Toggle({
    Title="เก็บของใต้ดิน",
    Callback=function(v)
        sit=v
        if sitConn then sitConn:Disconnect() end
        local c=LocalPlayer.Character
        if c and c:FindFirstChild("Humanoid") then
            c.Humanoid.Sit=v
            if v then
                sitConn=RunService.Heartbeat:Connect(function()
                    if c:FindFirstChild("HumanoidRootPart") then
                        c.HumanoidRootPart.CFrame=c.HumanoidRootPart.CFrame+Vector3.new(0,sitHeight,0)
                    end
                end)
            end
        end
    end
})

PlayerTab:Slider({
    Title="ปรับ Height",
    Step=0.1,
    Value={Min=-5,Max=4,Default=0},
    Callback=function(v) sitHeight=v end
})

PlayerTab:Section({Title="Jump power"})
local infJump=false
local jumpPower=70
local jumpConn

PlayerTab:Toggle({
    Title="Jump power",
    Callback=function(v)
        infJump=v
        if jumpConn then jumpConn:Disconnect() end
        if v then
            jumpConn=UserInputService.JumpRequest:Connect(function()
                local c=LocalPlayer.Character
                if c and c:FindFirstChild("HumanoidRootPart") then
                    c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    c.HumanoidRootPart.Velocity=Vector3.new(
                        c.HumanoidRootPart.Velocity.X,
                        jumpPower,
                        c.HumanoidRootPart.Velocity.Z
                    )
                end
            end)
        end
    end
})

PlayerTab:Slider({
    Title="Jump Power",
    Step=5,
    Value={Min=20,Max=100,Default=70},
    Callback=function(v) jumpPower=v end
})

PlayerTab:Section({Title="Warp Walk"})
local warpEnabled, warpDistance, warpSpeed, lastWarp, warpConnection = false, 0.5, 0.1, 0

PlayerTab:Toggle({
    Title="Enable Warp",
    Callback=function(v)
        warpEnabled = v
        if warpConnection then warpConnection:Disconnect() warpConnection = nil end
        if v then
            warpConnection = RunService.Heartbeat:Connect(function()
                if warpEnabled and tick() - lastWarp >= warpSpeed then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                        local moveDir = char.Humanoid.MoveDirection
                        if moveDir.Magnitude > 0 then
                            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (moveDir * warpDistance)
                            lastWarp = tick()
                        end
                    end
                end
            end)
        end
    end
})

PlayerTab:Slider({
    Title="Warp Distance",
    Step=0.1,
    Value={Min=0.1,Max=0.9,Default=0.9},
    Callback=function(v) warpDistance = tonumber(v) or 0.5 end
})

PlayerTab:Slider({
    Title="Warp Speed",
    Step=0.01,
    Value={Min=0.01,Max=0.09,Default=0.09},
    Callback=function(v) warpSpeed = tonumber(v) or 0.1 end
})

PlayerTab:Section({Title="Infinite Stamina"})

local Net = require(ReplicatedStorage.Modules.Core.Net)
local SprintModule = require(ReplicatedStorage.Modules.Game.Sprint)

PlayerTab:Toggle({
    Title = "Infinite Stamina",
    Default = false,
    Callback = function(v)
        if v then
            if not getgenv().Bypassed then
                local func = debug.getupvalue(Net.get,2)
                debug.setconstant(func,3,'__Bypass')
                debug.setconstant(func,4,'__Bypass')
                getgenv().Bypassed = true
            end
            
            repeat task.wait() until getgenv().Bypassed

            RunService.Heartbeat:Connect(function()
                Net.send("set_sprinting_1",true)
            end)

            local consume_stamina = SprintModule.consume_stamina
            local SprintBar = debug.getupvalue(consume_stamina, 2).sprint_bar
            local __InfiniteStamina = SprintBar.update

            SprintBar.update = function(...)
                if getgenv().InfiniteStamina then
                    return __InfiniteStamina(function()
                        return 0.5
                    end)
                end
                return __InfiniteStamina(...)
            end
            
            getgenv().InfiniteStamina = true
        else
            getgenv().InfiniteStamina = false
        end
    end
})
-- SILENT AIMกากๆเวอร์ชั่น0.10
getgenv().SilentAimEnabled = false
getgenv().FOV_Radius = 200
getgenv().AimPart = "Head"
getgenv().Prediction = 0.165
getgenv().RGB_Speed = 1

local i = ReplicatedStorage:WaitForChild("Remotes")
local send = i:WaitForChild("Send")

local Lines = {}
for i = 1, 8 do
    Lines[i] = Drawing.new("Line")
    Lines[i].Visible = true
    Lines[i].Thickness = 2
end

local ScreenTracer = Drawing.new("Line")
ScreenTracer.Thickness = 1.5
ScreenTracer.Transparency = 0.8
ScreenTracer.Visible = false

-- ตัวแปรตรวจจับการยิงกากๆ
local isFiring = false
local lastBeamTime = 0
local beamCooldown = 0.15

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.UserInputType == Enum.UserInputType.MouseButton1 then
        isFiring = true

        task.spawn(function()
            task.wait(0.1)
            isFiring = false
        end)
    end
end)

-- ตรวจจับการกนด
UserInputService.TouchStarted:Connect(function(input, gp)
    if not gp then
        isFiring = true
        task.spawn(function()
            task.wait(0.1)
            isFiring = false
        end)
    end
end)

local function CreateBulletBeam(startPos, endPos)
    -- ดสดสส
    if not isFiring then return end

    if tick() - lastBeamTime < beamCooldown then
        return
    end
    lastBeamTime = tick()
    
    local p = Instance.new("Part")
    p.Name = "PIG_Beam"
    p.Parent = workspace
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Size = Vector3.new(0.1, 0.1, (startPos - endPos).Magnitude)
    p.CFrame = CFrame.new(startPos:Lerp(endPos, 0.5), endPos)
    
    local hue = (tick() * 2) % 1
    p.Color = Color3.fromHSV(hue, 1, 1)
    
    local t = TweenService:Create(p, TweenInfo.new(0.5), {
        Transparency = 1,
        Size = Vector3.new(0, 0, p.Size.Z)
    })
    t:Play()
    game:GetService("Debris"):AddItem(p, 0.5)
end

local function GetClosestTarget()
    local target = nil
    local shortestDist = getgenv().FOV_Radius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health > 0 then
                local part = v.Character:FindFirstChild(getgenv().AimPart)
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist <= getgenv().FOV_Radius and dist < shortestDist then
                            shortestDist = dist
                            target = v
                        end
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local Time = tick() * getgenv().RGB_Speed
    
    for i = 1, 8 do
        local angle = math.rad((i - 1) * 45)
        local nextAngle = math.rad(i * 45)
        Lines[i].From = Center + Vector2.new(math.cos(angle) * getgenv().FOV_Radius, math.sin(angle) * getgenv().FOV_Radius)
        Lines[i].To = Center + Vector2.new(math.cos(nextAngle) * getgenv().FOV_Radius, math.sin(nextAngle) * getgenv().FOV_Radius)
        Lines[i].Color = Color3.fromHSV((Time + (i / 8)) % 1, 1, 1)
        Lines[i].Visible = getgenv().SilentAimEnabled
    end

    if getgenv().SilentAimEnabled then
        local targetPlayer = GetClosestTarget()
        if targetPlayer then
            local headPart = targetPlayer.Character:FindFirstChild(getgenv().AimPart)
            if headPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(headPart.Position)
                if onScreen then
                    ScreenTracer.From = Center
                    ScreenTracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    ScreenTracer.Color = Color3.fromHSV(Time % 1, 1, 1)
                    ScreenTracer.Visible = true
                    
                    getgenv().CurrentTargetHead = headPart
                    getgenv().FinalAimPos = headPart.Position + (headPart.Velocity * getgenv().Prediction)
                end
            end
        else
            ScreenTracer.Visible = false
            getgenv().CurrentTargetHead = nil
            getgenv().FinalAimPos = nil
        end
    else
        ScreenTracer.Visible = false
        getgenv().CurrentTargetHead = nil
        getgenv().FinalAimPos = nil
    end
end)

local oldFire
oldFire = hookfunction(send.FireServer, function(self, ...)
    local args = {...}
    
    if getgenv().SilentAimEnabled and getgenv().CurrentTargetHead and getgenv().FinalAimPos then
        local origin = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")) and LocalPlayer.Character.Head.Position or Vector3.new(0,0,0)
        
        -- สร้างลำแสงเฉพาะตอนยิงจริง
        CreateBulletBeam(origin, getgenv().FinalAimPos)

        args[4] = CFrame.new(1/0, 1/0, 1/0, 0/0, 0/0, 0/0, 0/0, 0/0, 0/0, 0/0, 0/0, 0/0)
        args[5] = {
            [1] = {
                [1] = {
                    ["Instance"] = getgenv().CurrentTargetHead,
                    ["Position"] = getgenv().FinalAimPos
                }
            }
        }
    end
    
    return oldFire(self, unpack(args))
end)

PVPTab:Toggle({
    Title = "Silent Aim",
    Default = false,
    Callback = function(v)
        getgenv().SilentAimEnabled = v
        if not v then
            getgenv().CurrentTargetHead = nil
            getgenv().FinalAimPos = nil
            ScreenTracer.Visible = false
        end
    end
})

PVPTab:Slider({
    Title = "FOV Radius",
    Desc = "ปรับขนาดวงเล็ง",
    Step = 10,
    Value = {Min = 50, Max = 500, Default = 200},
    Callback = function(v)
        getgenv().FOV_Radius = v
    end
})

PVPTab:Dropdown({
    Title = "Aim Part",
    Desc = "เลือกส่วนที่ต้องการเล็ง",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Default = 1,
    Callback = function(v)
        getgenv().AimPart = v
    end
})

PVPTab:Slider({
    Title = "Prediction",
    Desc = "ความแม่นยำ 0.1-0.2",
    Step = 0.005,
    Value = {Min = 0.1, Max = 0.2, Default = 0.165},
    Callback = function(v)
        getgenv().Prediction = v
    end
})

-- สกสกส
PVPTab:Slider({
    Title = "Beam Cooldown",
    Desc = "ระยะห่างลำแสง (ms)",
    Step = 10,
    Value = {Min = 50, Max = 300, Default = 150},
    Callback = function(v)
        beamCooldown = v / 1000
    end
})

local function findCounterTable()
    if not getgc then return nil end
    
    for _, obj in ipairs(getgc(true)) do
        if typeof(obj) == "table" then
            if rawget(obj, "event") and rawget(obj, "func") then
                return obj
            end
        end
    end
    return nil
end

local function createNetwork()
    local CounterTable = findCounterTable()
    if not CounterTable then return nil end
    
    local Net = {}
    
    function Net.get(...)
        CounterTable.func = (CounterTable.func or 0) + 1
        local GetRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Get")
        return GetRemote:InvokeServer(CounterTable.func, ...)
    end
    
    function Net.send(action)
        CounterTable.event = (CounterTable.event or 0) + 1
        local SendRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send")
        SendRemote:FireServer(CounterTable.event, action)
    end
    
    return Net
end

QuestTab:Button({
    Title = "Clear All Quests",
    Desc = "เคลียร์เควสทั้งหมด",
    Callback = function()
        task.spawn(function()
            local player = Players.LocalPlayer
            
            local Net = createNetwork()
            if not Net then
                return false
            end
            
            local success, questUI = pcall(function()
                return player:WaitForChild("PlayerGui"):WaitForChild("Quests"):WaitForChild("QuestsHolder"):WaitForChild("QuestsScrollingFrame")
            end)
            
            if not success or not questUI then
                return false
            end
            
            local cleared = 0
            local total = 0
            
            for _, child in pairs(questUI:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
                    total = total + 1
                    
                    local success, result = pcall(function()
                        return Net.get("claim_quest", child.Name)
                    end)
                    
                    if success then
                        cleared = cleared + 1
                    end
                    
                    task.wait(0.15)
                end
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Quest Clear",
                Text = "Cleared " .. cleared .. "/" .. total .. " quests",
                Duration = 5
            })
        end)
    end
})

ESPTab:Toggle({Title="ESP Box",Callback=function(v) if v then loadstring(game:HttpGet("https://pastefy.app/IAJ3EjEo/raw"))() end end})
ESPTab:Toggle({Title="ESP Name",Callback=function(v) if v then loadstring(game:HttpGet("https://pastefy.app/uEpm8OT7/raw"))() end end})
ESPTab:Toggle({Title="ESP Item",Callback=function(v) if v then loadstring(game:HttpGet("https://pastefy.app/uAhJQuzj/raw"))() end end})

ServerTab:Button({
    Title="Server Hop",
    Callback=function()
        local servers=HttpService:JSONDecode(game:HttpGet(
            ("https://games.roblox.com/v1/games/%s/servers/Public?limit=100"):format(game.PlaceId)
        )).data
        for _,s in ipairs(servers) do
            if s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
    end
})

ServerTab:Button({
    Title="Rejoin",
    Callback=function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})
