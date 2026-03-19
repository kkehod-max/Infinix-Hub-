local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Util = require(ReplicatedStorage.Modules.Core.Util)
local BuyPromptUI = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI)
local EmotesUI = require(ReplicatedStorage.Modules.Game.Emotes.EmotesUI)
local EmotesList = require(ReplicatedStorage.Modules.Game.Emotes.EmotesList)
local CoreUI = require(ReplicatedStorage.Modules.Core.UI)
local CharModule = require(ReplicatedStorage.Modules.Core.Char)
local ItemsFolder = ReplicatedStorage:WaitForChild("Items")
local MeleeFolder = ItemsFolder:WaitForChild("melee")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Client = Players.LocalPlayer
local item_drawings = {}
local droppedItems = workspace:WaitForChild("DroppedItems")

local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local WindUI = nil

-- โหลด WindUI แบบมี error handling
pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua", true))()
end)

-- ถ้าโหลดไม่สำเร็จ ให้สร้าง dummy window
if not WindUI then
    WindUI = {
        CreateWindow = function() 
            return {
                Tab = function() 
                    return {
                        Section = function() end,
                        Toggle = function() end,
                        Slider = function() end,
                        Button = function() end,
                        Input = function() return {} end,
                        Divider = function() end,
                        Dropdown = function() end,
                        Label = function() end
                    }
                end,
                ConfigManager = {
                    CreateConfig = function() 
                        return {
                            Register = function() end,
                            Save = function() end,
                            Delete = function() end,
                            Load = function() end
                        }
                    end
                },
                Notify = function() end
            }
        end
    }
end

-- สร้าง Window
local Window = WindUI:CreateWindow({
    Title = "PIGHUB [BUY] | Block Spin 🔫| Paid 💸",
    Icon = "piggy-bank",
    Author = "🐷 PIG FARM OFFICIAL 🐷",
    Folder = "PIGHUB Config",
    Size = UDim2.fromOffset(650, 400),
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
    KeyCode = Enum.KeyCode.G
})

-- Config Manager
local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("PIGHUBConfig")

-- SILENT AIM VARIABLES
local SilentAimEnabled = false
local SilentAimAttachEnabled = false
local FOVRadius = 120
local CurrentTarget = nil
local FOVShape = "Octagon"
local FOVSides = 8
local RainbowFOV = false
local HueShift = 0
local FOVThickness = 2
local FOVTransparency = 1
local SelectedAimPart = "Head"
local highlightEnabled = false
local highlights = {}
local enabled = false
local flying = false
local Remote = nil

-- หา Remote
pcall(function()
    Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Send")
end)

-- FOV Drawing
local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Thickness = FOVThickness
SilentFOVCircle.NumSides = FOVSides
SilentFOVCircle.Filled = false
SilentFOVCircle.Transparency = FOVTransparency
SilentFOVCircle.Radius = FOVRadius
SilentFOVCircle.Visible = false
SilentFOVCircle.Color = Color3.fromRGB(255, 255, 255)
SilentFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Tracer
local Tracer = Drawing.new("Line")
Tracer.Thickness = 1
Tracer.Color = Color3.fromRGB(255, 50, 50)
Tracer.Transparency = 1
Tracer.Visible = false

-- TracerESP
local TracerESP = nil

local espPlayers = {}
local nameESPEnabled = false
local distanceESPEnabled = false
local healthESPEnabled = false
local excludedPlayerNames = {}

local walkSpeedEnabled = false
local speedValue = 0.05
local FlyEnabled = false
local isFlyingUp = false
local floatPower = 40
local teleportActive = false
local featureEnabled = false
local lockedY = nil
local maxHeight = 10
local startY = nil
local moveConnection = nil
local flyJumpConnection = nil
local hookEnabled = false
local clickCount = 0
local fastFinishEnabled = false
local Active = false
local BringConnection = nil
local holdTime = 1
local scanInterval = 0.4
local flickering = false
local undergroundBaseCFrame = nil
local getgenv = getgenv or function() return _G end
getgenv().Sky = false
getgenv().SkyAmount = 1500
local AutoSkipEnabled = false
local sucking = false
local lastPickupTimes = {}
local DROP_DEPTH = -55
local MOVE_RADIUS = 30
local FLICKER_RATE = 0.1
local AutoRespawnEnabled = false
local WallShootEnabled = false
local ShootEnabled = false
local ChckEnabled = false
local scanRadius = 20
local localEventCounter = 0
local localFuncCounter = 0
local AutoSprintEnabled = false

local RARITY_COLORS = {
    ["Common"] = Color3.fromRGB(255, 255, 255),
    ["Uncommon"] = Color3.fromRGB(99, 255, 52),
    ["Rare"] = Color3.fromRGB(51, 170, 255),
    ["Epic"] = Color3.fromRGB(237, 44, 255),
    ["Legendary"] = Color3.fromRGB(255, 150, 0),
    ["Omega"] = Color3.fromRGB(255, 20, 51)
}
local WeaponDB = {}
local BillboardCache = {}
local ESPEnabled = false
local ESPConnection = nil
local FistsBuffEnabled = false
local OriginalValues = {}
local BOX_SIZE_SCALE = 100
local playerHighlights = {}

local CounterTable = nil
pcall(function()
    for _, Obj in ipairs(getgc(true)) do
        if typeof(Obj) == "table" and rawget(Obj, "event") and rawget(Obj, "func") then
            CounterTable = Obj
            break
        end
    end
end)

-- ถ้าไม่เจอ CounterTable ให้สร้างใหม่
if not CounterTable then
    CounterTable = {
        event = 0,
        func = 0
    }
end

-- ANTI-LOCK VARIABLES
local AntiLockStrength = 5000
local AntiLockMode = "Extreme"

-- EXTREME ANTI-LOCK FUNCTION
local function extremeAntiLock()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not getgenv().Sky then return end
    
    local randomX = math.random(-AntiLockStrength, AntiLockStrength)
    local randomY = math.random(-AntiLockStrength, AntiLockStrength)
    local randomZ = math.random(-AntiLockStrength, AntiLockStrength)
    
    if AntiLockMode == "Normal" then
        hrp.Velocity = Vector3.new(randomX/2, randomY/2, randomZ/2)
        hrp.CFrame = hrp.CFrame * CFrame.new(randomX/20, randomY/20, randomZ/20)
        
    elseif AntiLockMode == "Extreme" then
        hrp.Velocity = Vector3.new(randomX, math.random(800, 2500), randomZ)
        hrp.CFrame = CFrame.new(
            hrp.Position.X + randomX/5,
            hrp.Position.Y + randomY,
            hrp.Position.Z + randomZ/5
        )
        
    elseif AntiLockMode == "Chaos" then
        hrp.Velocity = Vector3.new(randomX * 3, randomY * 4, randomZ * 3)
        hrp.CFrame = CFrame.new(
            hrp.Position.X + randomX,
            hrp.Position.Y + randomY * 2,
            hrp.Position.Z + randomZ
        ) * CFrame.Angles(
            math.rad(randomX/10),
            math.rad(randomY/10),
            math.rad(randomZ/10)
        )
    end
end

-- RAINBOW FOV EFFECT
RunService.RenderStepped:Connect(function()
    if RainbowFOV and SilentFOVCircle and SilentFOVCircle.Visible then
        HueShift = (HueShift + 0.01) % 1
        SilentFOVCircle.Color = Color3.fromHSV(HueShift, 1, 1)
    end
    -- อัพเดทตำแหน่ง FOV
    if SilentFOVCircle and Camera then
        SilentFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end)

local function getPing()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return 0.2 end
    local stats = gui:FindFirstChild("NetworkStats")
    if not stats then return 0.2 end
    local pingLabel = stats:FindFirstChild("PingLabel")
    if not pingLabel then return 0.2 end
    local text = pingLabel.Text
    if typeof(text) ~= "string" then return 0.2 end
    local num = tonumber(text:match("%d+"))
    if not num then return 0.2 end
    local ping = num / 1000
    if ping < 0 or ping > 2 then ping = 0.2 end
    return ping
end

local function isPlayerExcluded(playerName)
    for _, excludedName in ipairs(excludedPlayerNames) do
        if excludedName ~= "" and string.find(string.lower(playerName), string.lower(excludedName)) then
            return true
        end
    end
    return false
end

local function getClosestTarget()
    local closest = nil
    local shortestDistance = FOVRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if head and humanoid and humanoid.Health > 0 and hrp then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenVector = Vector2.new(screenPos.X, screenPos.Y)
                    local distanceFromCenter = (screenVector - center).Magnitude
                    if distanceFromCenter <= FOVRadius and not isPlayerExcluded(player.Name) then
                        if distanceFromCenter < shortestDistance then
                            shortestDistance = distanceFromCenter
                            closest = player
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function predictPosition(head, hrp)
    if not head then return Vector3.zero end
    local ping = (getPing and getPing()) or 0.2
    if ping > 1 then ping = 0.2 end
    local vel = (hrp and hrp.AssemblyLinearVelocity) or Vector3.zero
    return head.Position + (vel * ping * 1.21)
end

local function isBehindWall(startPos, endPos)
    if not startPos or not endPos then return false end
    local direction = endPos - startPos
    if direction.Magnitude < 1 then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local ignoreList = {LocalPlayer.Character}
    if CurrentTarget and CurrentTarget.Character then
        table.insert(ignoreList, CurrentTarget.Character)
    end
    params.FilterDescendantsInstances = ignoreList
    local raycastResult = workspace:Raycast(startPos, direction, params)
    return raycastResult ~= nil
end

local function setupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    if moveConnection then
        pcall(function() moveConnection:Disconnect() end)
    end
    moveConnection = RunService.RenderStepped:Connect(function()
        if walkSpeedEnabled and Humanoid and HumanoidRootPart then
            if Humanoid.MoveDirection.Magnitude > 0 then
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (Humanoid.MoveDirection.Unit * speedValue)
            end
        end
    end)
end

local function isDowned()
    local hum = CharModule and CharModule.get_hum and CharModule.get_hum()
    if not hum then return false end
    if hum.Health <= 0 then return false end
    return hum:GetAttribute("HasBeenDowned") or hum:GetAttribute("IsDead")
end

local function getHRP()
    local char = CharModule and CharModule.current_char and CharModule.current_char.get and CharModule.current_char.get()
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart")
end

local function teleportUnderground()
    local hrp = getHRP()
    if not hrp then return end
    local original = hrp.CFrame
    undergroundBaseCFrame = original + Vector3.new(0, DROP_DEPTH, 0)
    hrp.CFrame = undergroundBaseCFrame
end

local function flickerAndMove()
    if flickering then return end
    flickering = true
    task.spawn(function()
        while flickering and enabled and isDowned() do
            local hum = CharModule and CharModule.get_hum and CharModule.get_hum()
            if hum and hum.Health <= 0 then break end
            local hrp = getHRP()
            if hrp and undergroundBaseCFrame then
                local angle = math.random() * math.pi * 2
                local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * MOVE_RADIUS
                local randomPos = undergroundBaseCFrame.Position + offset
                hrp.CFrame = CFrame.new(randomPos)
                task.wait(0.05)
                hrp.CFrame = undergroundBaseCFrame
            end
            task.wait(FLICKER_RATE)
        end
        flickering = false
    end)
end

local function NetGet(...)
    if not CounterTable or not CounterTable.func then return end
    local args = {...}
    for i, v in ipairs(args) do
        if typeof(v) == "Instance" then
            if v:IsA("Model") and #v:GetChildren() == 0 then
                local fallback = Workspace:FindFirstChild("DroppedItems")
                if fallback then
                    local model = fallback:FindFirstChildWhichIsA("Model")
                    if model then args[i] = model else return end
                else return end
            end
        end
    end
    CounterTable.func = (CounterTable.func or 0) + 1
    local success, result = pcall(function()
        local GetRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Get")
        if GetRemote then
            return GetRemote:InvokeServer(CounterTable.func, unpack(args))
        end
    end)
    return result
end

local function CheckAndPickup()
    if not sucking then return end
    local dropped = Workspace:FindFirstChild("DroppedItems")
    if not dropped then return end
    local now = tick()
    local itemsToPickup = {}
    for _, item in ipairs(dropped:GetChildren()) do
        if item:IsA("Model") then
            local part = item:FindFirstChildWhichIsA("BasePart")
            if part then
                local distance = (HumanoidRootPart.Position - part.Position).Magnitude
                if distance <= 20 and (now - (lastPickupTimes[item] or 0)) >= 0 then
                    table.insert(itemsToPickup, item)
                    lastPickupTimes[item] = now
                end
            end
        end
    end
    if #itemsToPickup > 0 then
        for _, item in ipairs(itemsToPickup) do
            task.spawn(function() NetGet("pickup_dropped_item", item) end)
        end
    end
end

local function SafeCall(f, ...)
    local ok, res = pcall(f, ...)
    return ok, res
end

local tu_unpack = table.unpack or unpack

local function CallRemote(remote, ...)
    if not remote then return end
    local args = {...}
    if remote.ClassName == "RemoteEvent" then
        if CounterTable and type(CounterTable.event) == "number" then
            CounterTable.event = CounterTable.event + 1
            SafeCall(function(...) remote:FireServer(CounterTable.event, ...) end, tu_unpack(args))
        else
            localEventCounter = (localEventCounter or 0) + 1
            SafeCall(function(...) remote:FireServer(localEventCounter, ...) end, tu_unpack(args))
        end
    elseif remote.ClassName == "RemoteFunction" then
        if CounterTable and type(CounterTable.func) == "number" then
            CounterTable.func = CounterTable.func + 1
            SafeCall(function(...) remote:InvokeServer(CounterTable.func, ...) end, tu_unpack(args))
        else
            localFuncCounter = (localFuncCounter or 0) + 1
            SafeCall(function(...) remote:InvokeServer(localFuncCounter, ...) end, tu_unpack(args))
        end
    else
        SafeCall(function(...)
            if remote.FireServer then remote:FireServer(...)
            elseif remote.InvokeServer then remote:InvokeServer(...) end
        end, tu_unpack(args))
    end
end

local function getPlayersInRange(radius)
    local inRange = {}
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return inRange end
    local pos = char.PrimaryPart.Position
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.PrimaryPart then
            local ok, mag = pcall(function() return (player.Character.PrimaryPart.Position - pos).Magnitude end)
            if ok and mag and mag <= radius then table.insert(inRange, player) end
        end
    end
    return inRange
end

local function getActiveTool()
    local char = LocalPlayer and LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if pcall(function() return item:IsA("Tool") end) and item:IsA("Tool") then return item end
        end
    end
    local backpack = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if pcall(function() return item:IsA("Tool") end) and item:IsA("Tool") then return item end
        end
    end
    return nil
end

local function isMeleeTool(tool)
    if not tool then return false end
    if tool.Name == "Fists" then return true end
    local meleeItems = ReplicatedStorage:FindFirstChild("Items") and ReplicatedStorage.Items:FindFirstChild("melee")
    local throwableItems = ReplicatedStorage:FindFirstChild("Items") and ReplicatedStorage.Items:FindFirstChild("throwable")
    if meleeItems and meleeItems:FindFirstChild(tool.Name) and (not throwableItems or not throwableItems:FindFirstChild(tool.Name)) then 
        return true 
    end
    return false
end

local function AttackNearby()
    if not Remote then return end
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    local tool = getActiveTool()
    if not tool or not isMeleeTool(tool) then return end
    local okParent, parent = pcall(function() return tool.Parent end)
    if not okParent or parent ~= LocalPlayer.Character then return end
    local targets = getPlayersInRange(scanRadius)
    if #targets == 0 then return end
    local okLocalPos, localPos = pcall(function() return char.PrimaryPart.Position end)
    if not okLocalPos or not localPos then return end
    local playerTargets = {}
    local predictedPositions = {}
    for _, player in pairs(targets) do
        if player and player.Character and player.Character.PrimaryPart then
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character.PrimaryPart
            if head and hrp then
                local predictedPos = predictPosition(head, hrp)
                table.insert(playerTargets, player)
                table.insert(predictedPositions, predictedPos)
            end
        end
    end
    if #playerTargets == 0 then return end
    local primaryPredictedPos = predictedPositions[1]
    local lookAtCFrame = CFrame.lookAt(localPos, primaryPredictedPos)
    local args = { "melee_attack", tool, playerTargets, lookAtCFrame, 0.75 }
    pcall(function() CallRemote(Remote, tu_unpack(args)) end)
end

local running = false
local function StartAutoAttack()
    if running then return end
    running = true
    task.spawn(function()
        while running do
            task.wait(scanInterval)
            if hookEnabled and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                pcall(AttackNearby)
            end
        end
    end)
end

local function performTeleport()
    if not HumanoidRootPart then return end
    local currentPos = HumanoidRootPart.Position
    local bottomPos = Vector3.new(currentPos.X, currentPos.Y - maxHeight, currentPos.Z)
    HumanoidRootPart.CFrame = CFrame.new(bottomPos)
    lockedY = bottomPos.Y
end

local function toggleTeleport()
    if not featureEnabled then return end
    teleportActive = not teleportActive
    if teleportActive then performTeleport() else lockedY = nil end
end

local connection
local function lockYPosition()
    if connection then pcall(function() connection:Disconnect() end) end
    connection = RunService.Heartbeat:Connect(function()
        if teleportActive and lockedY and HumanoidRootPart then
            local currentPos = HumanoidRootPart.Position
            if math.abs(currentPos.Y - lockedY) > 0.1 then
                HumanoidRootPart.CFrame = CFrame.new(currentPos.X, lockedY, currentPos.Z)
            end
        end
    end)
end

local function registerItems(folder)
    if not folder then return end
    for _, tool in ipairs(folder:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            local key = nil
            local displayName = tool:GetAttribute("DisplayName") or tool.Name
            local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
            local rarity = tool:GetAttribute("RarityName") or "Common"
            local imageId = tool:GetAttribute("ImageId") or "rbxassetid://7072725737"
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshId ~= "" then
                    key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
                elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                    key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
                end
            end
            if not key and itemId and itemId ~= "" and itemId ~= tool.Name then
                key = "ITEMID_" .. itemId .. "_RARITY_" .. rarity
            end
            if not key then
                key = "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
            end
            WeaponDB[key] = { Name = displayName, Rarity = rarity, ImageId = imageId, ToolName = tool.Name }
        end
    end
end

local function getItemKey(tool)
    local handle = tool:FindFirstChild("Handle")
    local displayName = tool:GetAttribute("DisplayName") or tool.Name
    local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
    local rarity = tool:GetAttribute("RarityName") or "Common"
    if handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and mesh.MeshId ~= "" then
            return mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
        elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
            return handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
        end
    end
    if itemId and itemId ~= "" and itemId ~= tool.Name then
        return "ITEMID_" .. itemId .. "_RARITY_" .. rarity
    end
    return "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
end

local function getWeaponInfo(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local key = getItemKey(tool)
    return WeaponDB[key]
end

local function createBillboardForPlayer(player)
    if not ESPEnabled or player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if BillboardCache[player] then 
        pcall(function() BillboardCache[player]:Destroy() end)
        BillboardCache[player] = nil 
    end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0, 90, 0, 20)
    billboard.StudsOffset = Vector3.new(0, -5.0, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char
    billboard:ClearAllChildren()
    local layout = Instance.new("UIListLayout", billboard)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local tools = {}
    for _, container in ipairs({ "Backpack", "StarterGear", "StarterPack" }) do
        local obj = player:FindFirstChild(container)
        if obj then
            for _, tool in ipairs(obj:GetChildren()) do
                if tool:IsA("Tool") and tool.Name ~= "Fists" then table.insert(tools, tool) end
            end
        end
    end
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name ~= "Fists" then table.insert(tools, tool) end
        end
    end
    for _, tool in ipairs(tools) do
        local info = getWeaponInfo(tool)
        if info then
            local img = Instance.new("ImageLabel", billboard)
            img.Size = UDim2.new(0, 20, 0, 20)
            img.BackgroundTransparency = 0.1
            img.Image = info.ImageId
            img.BackgroundColor3 = Color3.fromRGB(240, 248, 255)
            Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)
            local border = Instance.new("UIStroke", img)
            border.Color = RARITY_COLORS[info.Rarity] or Color3.new(1, 1, 1)
            border.Thickness = 2
        end
    end
    BillboardCache[player] = billboard
end

local function setFinishPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = holdTime
        prompt.MaxActivationDistance = 20
    end
end

local function tryHoldPrompt(prompt, duration)
    if not prompt or prompt:GetAttribute("__AutoFinishBusy") then return end
    prompt:SetAttribute("__AutoFinishBusy", true)
    pcall(function() if prompt.InputHoldBegin then prompt:InputHoldBegin() end end)
    pcall(function() if prompt.HoldBegin then prompt:HoldBegin() end end)
    pcall(function() if prompt.Trigger then prompt:Trigger() end end)
    task.wait(duration)
    pcall(function() if prompt.InputHoldEnd then prompt:InputHoldEnd() end end)
    pcall(function() if prompt.HoldEnd then prompt:HoldEnd() end end)
    prompt:SetAttribute("__AutoFinishBusy", nil)
end

local function findFinishPrompts()
    local found = {}
    for _, char in pairs(workspace:GetChildren()) do
        local player = Players:GetPlayerFromCharacter(char)
        if player and not isPlayerExcluded(player.Name) then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then 
                    setFinishPrompt(prompt) 
                    table.insert(found, prompt) 
                end
            end
        end
    end
    return found
end

local function applyToAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end
    end
end

local function setupFastFinishForPlayer(p)
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function(char)
            char.DescendantAdded:Connect(function(desc)
                if fastFinishEnabled and desc.Name == "FinishPrompt" and desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Name == "HumanoidRootPart" then
                    setFinishPrompt(desc)
                end
            end)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp and fastFinishEnabled then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end)
        if p.Character then
            local char = p.Character
            char.DescendantAdded:Connect(function(desc)
                if fastFinishEnabled and desc.Name == "FinishPrompt" and desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Name == "HumanoidRootPart" then
                    setFinishPrompt(desc)
                end
            end)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and fastFinishEnabled then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end
    end
end

local function getPlayer(name)
    name = string.lower(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), name) or string.find(string.lower(p.DisplayName), name) then
            return p
        end
    end
end

local function ForcePart(v)
    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, obj in ipairs(v:GetChildren()) do
            if obj:IsA("BodyMover") or obj:IsA("RocketPropulsion") then obj:Destroy() end
        end
        for _, junk in ipairs({ "Attachment", "AlignPosition", "Torque" }) do
            local f = v:FindFirstChild(junk)
            if f then f:Destroy() end
        end
        v.CanCollide = false
        local Attachment2 = Instance.new("Attachment", v)
        Attachment2.Name = "ForcePartAttachment"
    end
end

local function ToggleBring(name)
    local player = getPlayer(name)
    if not player then return end
    Active = not Active
    if Active then
        local char = player.Character or player.CharacterAdded:Wait()
        local targetRoot = char:WaitForChild("HumanoidRootPart")
        for _, v in ipairs(Workspace:GetDescendants()) do ForcePart(v) end
        BringConnection = Workspace.DescendantAdded:Connect(ForcePart)
    else
        if BringConnection then BringConnection:Disconnect() end
    end
end

local function TrySkipCrate()
    local success, CrateController = pcall(function() 
        return require(ReplicatedStorage.Modules.Game.CrateSystem.Crate) 
    end)
    if not (success and CrateController) then return end
    task.spawn(function()
        local spinning = CrateController.spinning
        if not spinning then return end
        local waited = 0
        while not spinning.get() do
            if waited > 3 then break end
            task.wait(0.05)
            waited = waited + 0.05
        end
        if spinning.get() then 
            pcall(function() 
                if CrateController.skip_spin then
                    CrateController.skip_spin() 
                end
            end) 
        end
    end)
end

local function SetupAutoSkip()
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotesFolder then return end
    local sendRemote = remotesFolder:FindFirstChild("Send")
    if not (sendRemote and sendRemote:IsA("RemoteEvent")) then return end
    sendRemote.OnClientEvent:Connect(function(...)
        if AutoSkipEnabled then TrySkipCrate() end
    end)
end

local function createESP(player)
    if espPlayers[player] then return end
    local nameText = Drawing.new("Text")
    nameText.Size = 16
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
    nameText.Font = 4
    nameText.Visible = false
    local distanceText = Drawing.new("Text")
    distanceText.Size = 14
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.Color = Color3.fromRGB(255, 255, 255)
    distanceText.Font = 4
    distanceText.Visible = false
    local healthBg = Drawing.new("Square")
    healthBg.Filled = false
    healthBg.Thickness = 1
    healthBg.Color = Color3.fromRGB(0, 0, 0)
    healthBg.Transparency = 0.9
    healthBg.Visible = false
    local healthFg = Drawing.new("Square")
    healthFg.Filled = true
    healthFg.Transparency = 0.9
    healthFg.Visible = false
    local drawings = { nameText, distanceText, healthBg, healthFg }
    local conn = RunService.RenderStepped:Connect(function()
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(drawings) do obj.Visible = false end
            return
        end
        local hrp = player.Character.HumanoidRootPart
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local dist = 0
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen or screenPos.Z <= 0 then
            for _, obj in pairs(drawings) do obj.Visible = false end
            return
        end
        local centerX = screenPos.X
        local currentTopY = screenPos.Y - 15
        if healthESPEnabled and humanoid and humanoid.Health > 0 then
            local perc = humanoid.Health / (humanoid.MaxHealth > 0 and humanoid.MaxHealth or 1)
            local barHeight = 4
            local barWidth = 60
            local healthX = centerX - barWidth / 2
            healthBg.Position = Vector2.new(healthX, currentTopY - barHeight - 2)
            healthBg.Size = Vector2.new(barWidth, barHeight)
            healthBg.Visible = true
            healthFg.Position = Vector2.new(healthX, currentTopY - barHeight - 2)
            healthFg.Size = Vector2.new(barWidth * perc, barHeight)
            healthFg.Color = Color3.fromHSV(perc * 0.333, 0.8, 0.9)
            healthFg.Visible = true
            currentTopY = currentTopY - barHeight - 6
        else
            healthBg.Visible = false
            healthFg.Visible = false
        end
        if nameESPEnabled then
            local minSize, maxSize = 14, 42
            local scaleDist = math.clamp(dist / 50, 0, 1)
            local dynamicSize = maxSize - (maxSize - minSize) * scaleDist
            nameText.Text = player.Name
            nameText.Size = math.floor(dynamicSize)
            nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
            nameText.Outline = true
            nameText.Position = Vector2.new(centerX, currentTopY - 16)
            nameText.Visible = true
        else
            nameText.Visible = false
        end
        distanceText.Text = distanceESPEnabled and string.format("%.0f studs", dist) or ""
        distanceText.Position = Vector2.new(centerX, screenPos.Y + 20)
        distanceText.Visible = distanceESPEnabled
    end)
    espPlayers[player] = { conn = conn, drawings = drawings }
end

local function loadESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not espPlayers[player] then createESP(player) end
    end
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function()
                task.wait(0.1)
                if not espPlayers[player] then createESP(player) end
            end)
            if player.Character and not espPlayers[player] then
                task.wait(0.1)
                createESP(player)
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if espPlayers[player] then
            for _, obj in pairs(espPlayers[player].drawings) do
                if obj and obj.Remove then 
                    pcall(function() obj:Remove() end)
                end
            end
            if espPlayers[player].conn then 
                pcall(function() espPlayers[player].conn:Disconnect() end) 
            end
            espPlayers[player] = nil
        end
    end)
end

local HISTORY_SIZE = 6
local PREDICT_FACTOR = 1.2
local SKY_Y_THRESHOLD = 150
local SMOOTH_ALPHA = 0.75

local PositionHistory = {}
local TracerSmoothedPos = Vector3.new()

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            if hrp and humanoid and humanoid.Health > 0 then
                PositionHistory[player] = PositionHistory[player] or {}
                table.insert(PositionHistory[player], { time = os.clock(), pos = hrp.Position })
                if #PositionHistory[player] > HISTORY_SIZE then table.remove(PositionHistory[player], 1) end
            else 
                PositionHistory[player] = nil 
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player) PositionHistory[player] = nil end)

local function calculateVelocity(player)
    local hist = PositionHistory[player]
    if not hist or #hist < 2 then return Vector3.new() end
    local totalVel = Vector3.new()
    local count = 0
    for i = 2, #hist do
        local dt = hist[i].time - hist[i - 1].time
        if dt > 0 then
            totalVel = totalVel + (hist[i].pos - hist[i - 1].pos) / dt
            count = count + 1
        end
    end
    if count == 0 then return Vector3.new() end
    local avgVel = totalVel / count
    if avgVel.Y > SKY_Y_THRESHOLD then
        return Vector3.new(avgVel.X * 1.15, math.clamp(avgVel.Y * 0.85, 0, 400), avgVel.Z * 1.15)
    end
    return avgVel
end

local function predictPosition(targetPart, hrp)
    if not targetPart then return Vector3.zero end
    local character = targetPart.Parent
    local player = character and Players:GetPlayerFromCharacter(character)
    if not player then return targetPart.Position end
    local velocity = calculateVelocity(player) or Vector3.zero
    local ping = (getPing and getPing()) or 0.1
    if ping < 0 then ping = 0.1 end
    return targetPart.Position + (velocity * ping * PREDICT_FACTOR)
end

local function getAimPositionAndPart(character)
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return nil, nil end
    local targetPart, aimPos
    if SilentAimAttachEnabled then
        targetPart = (SelectedAimPart == "HumanoidRootPart") and hrp or head
        aimPos = predictPosition(targetPart, hrp)
    else
        targetPart = (SelectedAimPart == "Head") and head or (SelectedAimPart == "HumanoidRootPart") and hrp or head
        aimPos = targetPart.Position
        if SilentAimEnabled then aimPos = predictPosition(targetPart, hrp) end
    end
    return aimPos, targetPart
end

local function isShotgun()
    if not Character then return false end
    for _, tool in ipairs(Character:GetChildren()) do
        if tool:IsA("Tool") then
            local ammoType = tool:GetAttribute("AmmoType")
            if ammoType == "shotgun" or ammoType == "shootgun" then return true end
        end
    end
    return false
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if SilentAimAttachEnabled then CurrentTarget = getClosestTarget() end
        CurrentTarget = (SilentAimEnabled or SilentAimAttachEnabled) and getClosestTarget() or nil
        if SilentFOVCircle then
            SilentFOVCircle.Visible = SilentAimEnabled
            if SilentAimEnabled then
                SilentFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                SilentFOVCircle.Radius = FOVRadius
            end
        end
        if FlyEnabled and isFlyingUp and HumanoidRootPart then
            local v = HumanoidRootPart.Velocity
            HumanoidRootPart.Velocity = Vector3.new(v.X, floatPower, v.Z)
        end
        if teleportActive and lockedY and HumanoidRootPart then
            local currentPos = HumanoidRootPart.Position
            if math.abs(currentPos.Y - lockedY) > 0.1 then
                HumanoidRootPart.CFrame = CFrame.new(currentPos.X, lockedY, currentPos.Z)
            end
        end
        if getgenv().Sky then extremeAntiLock() end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(newChar) Character = newChar end)

RunService.Heartbeat:Connect(function()
    if not enabled then return end
    if isDowned() then
        local hrp = getHRP()
        if hrp and not undergroundBaseCFrame then teleportUnderground() end
        flickerAndMove()
    else
        if undergroundBaseCFrame then
            local hrp = getHRP()
            if hrp then hrp.CFrame = undergroundBaseCFrame + Vector3.new(0, -DROP_DEPTH, 0) end
        end
        undergroundBaseCFrame = nil
        flickering = false
    end
end)

RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    end
    pcall(CheckAndPickup)
end)

ContextActionService:BindAction("FlyUp", function(actionName, inputState, inputObject)
    if not FlyEnabled then return Enum.ContextActionResult.Pass end
    local isJumpPressed = false
    if inputObject.UserInputType == Enum.UserInputType.Keyboard and inputObject.KeyCode == Enum.KeyCode.Space then isJumpPressed = true end
    if inputObject.UserInputType == Enum.UserInputType.Touch then isJumpPressed = true end
    if isJumpPressed then
        if inputState == Enum.UserInputState.Begin then
            isFlyingUp = true
            if Humanoid then Humanoid.Jump = true end
            return Enum.ContextActionResult.Sink
        elseif inputState == Enum.UserInputState.End then
            isFlyingUp = false
            return Enum.ContextActionResult.Sink
        end
    end
    return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.Space)

RunService.RenderStepped:Connect(function(deltaTime)
    if FlyEnabled and isFlyingUp and HumanoidRootPart then
        HumanoidRootPart.Velocity = Vector3.new(HumanoidRootPart.Velocity.X, floatPower, HumanoidRootPart.Velocity.Z)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if flyJumpConnection then flyJumpConnection:Disconnect() end
    flyJumpConnection = hum:GetPropertyChangedSignal("Jumping"):Connect(function()
        if FlyEnabled and hum.Jumping then isFlyingUp = true else isFlyingUp = false end
    end)
end)

LocalPlayer.CharacterAdded:Connect(setupCharacter)
if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G and Window then
        if Window.Toggle then 
            Window:Toggle()
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z and featureEnabled then toggleTeleport() end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    lockedY = nil
    teleportActive = false
    lockYPosition()
end)

lockYPosition()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    running = false
    task.wait(0.1)
    StartAutoAttack()
end)

StartAutoAttack()

-- Register items
pcall(function()
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if itemsFolder then
        for _, category in ipairs({ "gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish" }) do
            local folder = itemsFolder:FindFirstChild(category)
            if folder then
                registerItems(folder)
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            task.wait(0.2)
            createBillboardForPlayer(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if BillboardCache[player] then 
        pcall(function() BillboardCache[player]:Destroy() end)
        BillboardCache[player] = nil 
    end
end)

for _, p in ipairs(Players:GetPlayers()) do setupFastFinishForPlayer(p) end
Players.PlayerAdded:Connect(setupFastFinishForPlayer)

task.spawn(function()
    while true do
        task.wait(scanInterval)
        if fastFinishEnabled then
            for _, prompt in ipairs(findFinishPrompts()) do
                task.spawn(function() tryHoldPrompt(prompt, holdTime) end)
            end
        end
    end
end)

SetupAutoSkip()

ReplicatedStorage.ChildAdded:Connect(function(child)
    if child.Name == "Remotes" then SetupAutoSkip() end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if highlightEnabled and highlights then
            highlights[player] = createHighlight(character)
        end
        if espPlayers[player] and espPlayers[player].drawings then
            local nameText = espPlayers[player].drawings[1]
            if nameText then
                nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
            end
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if espPlayers[player] then
        for _, obj in pairs(espPlayers[player].drawings) do
            if obj and obj.Remove then 
                pcall(function() obj:Remove() end)
            end
        end
        if espPlayers[player].conn then 
            pcall(function() espPlayers[player].conn:Disconnect() end) 
        end
        espPlayers[player] = nil
    end
end)

loadESP()

-- UI TABS
local Tab = Window:Tab({ Title = "COMBAT:", Icon = "crosshair" })
Tab:Section({ Title = "GUN:" })

local SilentToggle = Tab:Toggle({
    Title = "Silent Aim",
    Default = false,
    Callback = function(state)
        SilentAimEnabled = state
        CurrentTarget = nil
    end
})
myConfig:Register("SilentAim", SilentToggle)

local AttachToggle = Tab:Toggle({
    Title = "Red Line Lock",
    Default = false,
    Callback = function(state)
        SilentAimAttachEnabled = state
        CurrentTarget = nil
    end
})
myConfig:Register("SilentAimAttach", AttachToggle)

Tab:Section({ Title = "FOV SETTINGS:" })

local FOVShapeDropdown = Tab:Dropdown({
    Title = "FOV Shape",
    Values = { "Octagon", "Circle", "Square", "Diamond", "Star", "Hexagon", "Pentagon" },
    Default = 1,
    Callback = function(value)
        FOVShape = value
        if SilentFOVCircle then
            if value == "Circle" then
                SilentFOVCircle.NumSides = 64
            elseif value == "Octagon" then
                SilentFOVCircle.NumSides = 8
            elseif value == "Square" then
                SilentFOVCircle.NumSides = 4
            elseif value == "Diamond" then
                SilentFOVCircle.NumSides = 4
            elseif value == "Star" then
                SilentFOVCircle.NumSides = 10
            elseif value == "Hexagon" then
                SilentFOVCircle.NumSides = 6
            elseif value == "Pentagon" then
                SilentFOVCircle.NumSides = 5
            end
        end
    end
})

local RainbowFOVToggle = Tab:Toggle({
    Title = "Rainbow FOV",
    Default = false,
    Callback = function(state)
        RainbowFOV = state
        if not state and SilentFOVCircle then 
            SilentFOVCircle.Color = Color3.fromRGB(255, 255, 255) 
        end
    end
})

local FOVSlider = Tab:Slider({
    Title = "FOV Radius: ",
    Step = 1,
    Value = { Min = 20, Max = 800, Default = FOVRadius },
    Callback = function(value)
        FOVRadius = tonumber(value) or 120
        if SilentFOVCircle then
            SilentFOVCircle.Radius = FOVRadius
        end
    end
})
myConfig:Register("FOVRadius", FOVSlider)

local FOVThicknessSlider = Tab:Slider({
    Title = "FOV Thickness: ",
    Step = 0.1,
    Value = { Min = 0.5, Max = 5, Default = 2 },
    Callback = function(value)
        FOVThickness = value
        if SilentFOVCircle then
            SilentFOVCircle.Thickness = value
        end
    end
})

local FriendsInput = Tab:Input({
    Title = "Safe Friend",
    Desc = "Enter names separated by spaces",
    Value = "",
    InputIcon = "shield-check",
    Type = "Input",
    Placeholder = "friend1 friend2",
    Callback = function(input)
        excludedPlayerNames = {}
        for name in string.gmatch(input, "%S+") do 
            table.insert(excludedPlayerNames, name) 
        end
        for _, player in pairs(Players:GetPlayers()) do
            if espPlayers[player] and espPlayers[player].drawings then
                local nameText = espPlayers[player].drawings[1]
                if nameText then
                    nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
})
myConfig:Register("FriendsList", FriendsInput)

pcall(function() Tab:Divider() end)

local Tab_mods = Window:Tab({ Title = "WEAPON:", Icon = "layers" })
Tab_mods:Section({ Title = "MODS:" })

local GunsFolder = ReplicatedStorage:FindFirstChild("Items") and ReplicatedStorage.Items:FindFirstChild("gun")

getgenv().FireRateValue = 1000
getgenv().AccuracyValue = 1
getgenv().RecoilValue = 0
getgenv().Durability = 999999999
getgenv().Auto = true
getgenv().automatic = true
getgenv().AutoValue = true
getgenv().GunModsAutoApply = false

local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return GunsFolder and GunsFolder:FindFirstChild(tool.Name) ~= nil or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
end

local function applyGodGun(tool)
    if not tool or not isGunTool(tool) then return end
    pcall(function()
        tool:SetAttribute("fire_rate", getgenv().FireRateValue)
        tool:SetAttribute("accuracy", getgenv().AccuracyValue)
        tool:SetAttribute("Recoil", getgenv().RecoilValue)
        tool:SetAttribute("Durability", getgenv().Durability)
        tool:SetAttribute("automatic", getgenv().AutoValue)
    end)
end

RunService.Heartbeat:Connect(function()
    if not getgenv().GunModsAutoApply then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and isGunTool(tool) then pcall(applyGodGun, tool) end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    repeat
        task.wait(0.1)
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and isGunTool(tool) then task.spawn(applyGodGun, tool) end
        end
    until not getgenv().GunModsAutoApply
end)

LocalPlayer.Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and getgenv().GunModsAutoApply then
        task.wait(0.2)
        applyGodGun(child)
    end
end)

Tab_mods:Slider({
    Title = "Fire Rate",
    Step = 10,
    Value = { Min = 100, Max = 3000, Default = 1000 },
    Callback = function(v) getgenv().FireRateValue = v end
})

Tab_mods:Slider({
    Title = "Accuracy",
    Step = 0.01,
    Value = { Min = 0, Max = 1, Default = 1 },
    Callback = function(v) getgenv().AccuracyValue = v end
})

Tab_mods:Slider({
    Title = "Recoil",
    Step = 0.1,
    Value = { Min = 0, Max = 10, Default = 0 },
    Callback = function(v) getgenv().RecoilValue = v end
})

Tab_mods:Slider({
    Title = "Reload Time",
    Step = 0.1,
    Value = { Min = 0.1, Max = 10, Default = 0.1 },
    Callback = function(v) getgenv().ReloadValue = v end
})

local Automodifyer = Tab_mods:Toggle({
    Title = "Automatic",
    Icon = "check",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        getgenv().automatic = v
        getgenv().GunModsAutoApply = v
        if v and WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "✅ Auto Modify", Duration = 2 })
        end
    end
})

Tab_mods:Section({ Title = "COMBAT" })

local function modifyFists(tool, enable)
    if tool then
        local attributes = tool:GetAttributes()
        local keys = {}
        for name, _ in pairs(attributes) do table.insert(keys, name) end
        table.sort(keys)
        if #keys >= 7 then
            local attr6 = keys[6]
            local attr7 = keys[7]
            if enable then
                if OriginalValues[attr6] == nil then OriginalValues[attr6] = tool:GetAttribute(attr6) end
                if OriginalValues[attr7] == nil then OriginalValues[attr7] = tool:GetAttribute(attr7) end
                tool:SetAttribute(attr6, 360)
                tool:SetAttribute(attr7, 20)
            else
                if OriginalValues[attr6] then tool:SetAttribute(attr6, OriginalValues[attr6]) end
                if OriginalValues[attr7] then tool:SetAttribute(attr7, OriginalValues[attr7]) end
            end
        end
    end
end

local meleeNames = {}
if MeleeFolder then
    for _, v in ipairs(MeleeFolder:GetChildren()) do 
        table.insert(meleeNames, v.Name) 
    end
end

local function isMeleeTool(tool)
    if not tool:IsA("Tool") then return false end
    if tool.Name == "Fists" then return true end
    for _, name in ipairs(meleeNames) do 
        if tool.Name == name then return true end 
    end
    return false
end

local function checkAndModifyFists()
    local Character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Character or not backpack then return end
    local tools = {}
    for _, t in ipairs(Character:GetChildren()) do 
        if isMeleeTool(t) then table.insert(tools, t) end 
    end
    for _, t in ipairs(backpack:GetChildren()) do 
        if isMeleeTool(t) then table.insert(tools, t) end 
    end
    for _, tool in ipairs(tools) do 
        modifyFists(tool, FistsBuffEnabled) 
    end
end

RunService.Heartbeat:Connect(function() 
    if FistsBuffEnabled then 
        pcall(checkAndModifyFists) 
    end 
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if FistsBuffEnabled then 
        pcall(checkAndModifyFists) 
    end
end)

local FistsToggle = Tab_mods:Toggle({
    Title = "Melee Aura",
    Desc = "Wide Fists Range",
    Default = false,
    Callback = function(Value)
        FistsBuffEnabled = Value
        pcall(checkAndModifyFists)
    end
})
myConfig:Register("Fists Modifier", FistsToggle)

local autoAttackToggle = Tab_mods:Toggle({
    Title = "Auto Attack",
    Default = false,
    Callback = function(state)
        hookEnabled = state
    end
})
myConfig:Register("AutoAttack_Enabled", autoAttackToggle)

local Tab_ESP = Window:Tab({ Title = "ESP:", Icon = "eye" })
Tab_ESP:Section({ Title = "Visual:" })

local ItemsESPToggle = Tab_ESP:Toggle({
    Title = "Inventory Viewer",
    Default = false,
    Callback = function(state)
        ESPEnabled = state
        if state then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then 
                    pcall(function() createBillboardForPlayer(p) end)
                end
            end
            ESPConnection = RunService.Heartbeat:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then 
                        pcall(function() createBillboardForPlayer(p) end)
                    end
                end
            end)
            if WindUI and WindUI.Notify then 
                WindUI:Notify({ Title = "✅ ESP Items Enabled", Duration = 3 }) 
            end
        else
            if ESPConnection then ESPConnection:Disconnect() ESPConnection = nil end
            for _, billboard in pairs(BillboardCache) do 
                pcall(function() billboard:Destroy() end)
            end
            BillboardCache = {}
            if WindUI and WindUI.Notify then 
                WindUI:Notify({ Title = "❌ ESP Items Disabled", Duration = 3 }) 
            end
        end
    end
})
myConfig:Register("ItemsESP", ItemsESPToggle)

local NameESPToggle = Tab_ESP:Toggle({
    Title = "Name",
    Default = false,
    Callback = function(state)
        nameESPEnabled = state
    end
})
myConfig:Register("NameESP", NameESPToggle)

local HealthESPToggle = Tab_ESP:Toggle({
    Title = "Health",
    Default = false,
    Callback = function(state)
        healthESPEnabled = state
    end
})
myConfig:Register("HealthESP", HealthESPToggle)

local DistanceESPToggle = Tab_ESP:Toggle({
    Title = "Distance",
    Default = false,
    Callback = function(state)
        distanceESPEnabled = state
    end
})
myConfig:Register("DistanceESP", DistanceESPToggle)

local HighlightToggle = Tab_ESP:Toggle({
    Title = "Highlight",
    Default = false,
    Callback = function(state)
        highlightEnabled = state
        for _, player in pairs(game.Players:GetPlayers()) do 
            pcall(function() updateHighlight(player) end)
        end
    end
})
myConfig:Register("HighlightESP", HighlightToggle)

function updateHighlight(player)
    if player == game.Players.LocalPlayer then return end
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if playerHighlights[player] then 
        pcall(function() playerHighlights[player]:Destroy() end)
        playerHighlights[player] = nil 
    end
    if highlightEnabled then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(0, 170, 255)
        highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
        highlight.Parent = workspace
        playerHighlights[player] = highlight
    end
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.1)
        pcall(function() updateHighlight(player) end)
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    if playerHighlights[player] then 
        pcall(function() playerHighlights[player]:Destroy() end)
        playerHighlights[player] = nil 
    end
end)

for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.1)
            pcall(function() updateHighlight(player) end)
        end)
        pcall(function() updateHighlight(player) end)
    end
end

local Tab_Character = Window:Tab({ Title = "CHARACTER:", Icon = "user" })
Tab_Character:Section({ Title = "CHARACTER:" })

local WalkSpeedToggle = Tab_Character:Toggle({
    Title = "Walk Speed",
    Default = false,
    Callback = function(state)
        walkSpeedEnabled = state
    end
})
myConfig:Register("WalkSpeed", WalkSpeedToggle)

local SpeedSlider = Tab_Character:Slider({
    Title = "Speed Multiplier",
    Step = 0.5,
    Value = { Min = 1, Max = 5, Default = 2 },
    Callback = function(value) 
        speedValue = value * 0.05 
    end
})
myConfig:Register("SpeedMultiplier", SpeedSlider)

local JumpPowerToggle = Tab_Character:Toggle({
    Title = "Jump Power",
    Default = false,
    Callback = function(state)
        FlyEnabled = state
        if not FlyEnabled then flying = false end
    end
})
myConfig:Register("JumpPower", JumpPowerToggle)

Tab_Character:Section({ Title = "ANTI-LOCK SETTINGS:" })

local AntiLockModeDropdown = Tab_Character:Dropdown({
    Title = "Anti-Lock Mode",
    Values = { "Normal", "Extreme", "Chaos" },
    Default = 2,
    Callback = function(value)
        AntiLockMode = value
        if value == "Normal" then AntiLockStrength = 1500
        elseif value == "Extreme" then AntiLockStrength = 5000
        elseif value == "Chaos" then AntiLockStrength = 8000 end
    end
})

local AntiLockStrengthSlider = Tab_Character:Slider({
    Title = "Anti-Lock Strength",
    Step = 100,
    Value = { Min = 1000, Max = 20000, Default = 5000 },
    Callback = function(value) AntiLockStrength = value end
})

local Net = {}
function Net.send(...)
    local args = { ... }
    if CounterTable then
        CounterTable.event = (CounterTable.event or 0) + 1
        pcall(function() 
            if Remotes and Remotes.Send then
                Remotes.Send:FireServer(CounterTable.event, unpack(args)) 
            end
        end)
    end
end

local AutoSprintToggle = Tab_Character:Toggle({
    Title = "Infinite Stamina",
    Default = false,
    Callback = function(state)
        AutoSprintEnabled = state
        if AutoSprintEnabled then
            if WindUI and WindUI.Notify then 
                WindUI:Notify({ Title = "✅ INF STAMINA", Duration = 3 }) 
            end
        else
            if WindUI and WindUI.Notify then 
                WindUI:Notify({ Title = "❌ Auto Sprint Disabled", Duration = 3 }) 
            end
        end
    end
})
myConfig:Register("AutoSprint", AutoSprintToggle)

local AntiLockToggle = Tab_Character:Toggle({
    Title = "Anti Lock",
    Default = false,
    Callback = function(state)
        getgenv().Sky = state
        if state then
            getgenv().SkyAmount = 1500
        end
    end
})
myConfig:Register("AntiLock", AntiLockToggle)

local AntiKillToggle = Tab_Character:Toggle({
    Title = "Anti Kill",
    Default = false,
    Callback = function(state)
        enabled = state
        if state then
            if WindUI and WindUI.Notify then 
                WindUI:Notify({ Title = "✅ Anti Kill Enabled", Duration = 3 }) 
            end
        else
            if WindUI and WindUI.Notify then 
                WindUI:Notify({ Title = "❌ Anti Kill Disabled", Duration = 3 }) 
            end
        end
    end
})
myConfig:Register("AntiKill", AntiKillToggle)

pcall(function() 
    if Tab_Character and typeof(Tab_Character.Divider) == "function" then 
        Tab_Character:Divider() 
    end 
end)

pcall(function() 
    if Tab_Character and typeof(Tab_Character.Section) == "function" then 
        Tab_Character:Section({ Title = "Att:" }) 
    end 
end)

local PickupToggle = Tab_Character:Toggle({
    Title = "Pickup items",
    Default = false,
    Callback = function(state)
        sucking = state
    end
})
myConfig:Register("PickupItems", PickupToggle)

local AntiRagdollToggle = Tab_Character:Toggle({
    Title = "Anti Ragdoll",
    Default = false,
    Callback = function(state)
        local _AntiRagdollEnabled = state
        if not _AntiRagdollEnabled then return end
        task.spawn(function()
            while _AntiRagdollEnabled do
                pcall(function()
                    if CounterTable and Remotes and Remotes.Send then
                        CounterTable.event = (CounterTable.event or 0) + 1
                        Remotes.Send:FireServer(CounterTable.event, "end_ragdoll_early")
                        task.wait(0.3)
                        CounterTable.event = (CounterTable.event or 0) + 1
                        Remotes.Send:FireServer(CounterTable.event, "clear_ragdoll")
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
})
myConfig:Register("AntiRagdoll", AntiRagdollToggle)

local HideNameToggle = Tab_Character:Toggle({
    Title = "Hide Name",
    Default = false,
    Callback = function(state)
        pcall(function()
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local gui = hrp:FindFirstChild("CharacterBillboardGui")
            if gui then
                local nameLabel = gui:FindFirstChild("PlayerName")
                if nameLabel and nameLabel:IsA("TextLabel") then 
                    nameLabel.Visible = not state 
                end
            end
        end)
    end
})
myConfig:Register("HideName", HideNameToggle)

local AutoRespawnToggle = Tab_Character:Toggle({
    Title = "Auto Respawn",
    Default = false,
    Callback = function(state)
        local _AutoRespawnEnabled = state
        if not _AutoRespawnEnabled then return end
        task.spawn(function()
            while _AutoRespawnEnabled do
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    task.wait(6)
                    if _AutoRespawnEnabled then
                        pcall(function()
                            if CounterTable and Remotes and Remotes.Send then
                                CounterTable.event = (CounterTable.event or 0) + 1
                                Remotes.Send:FireServer(CounterTable.event, "death_screen_request_respawn")
                            end
                        end)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})
myConfig:Register("AutoRespawn", AutoRespawnToggle)

Tab_Character:Divider()
Tab_Character:Section({ Title = "PC HOLD (Z)" })

local SnapToggle = Tab_Character:Toggle({
    Title = "Snap Under Map",
    Default = false,
    Callback = function(state)
        featureEnabled = state
        if featureEnabled then
            clickCount = clickCount + 1
            if clickCount < 2 then return end
            startY = HumanoidRootPart and HumanoidRootPart.Position.Y or nil
            teleportActive = true
            performTeleport()
        else
            teleportActive = false
            lockedY = nil
            startY = nil
        end
    end
})
myConfig:Register("SnapUnderMap", SnapToggle)

local SnapSlider = Tab_Character:Slider({
    Title = "Snap Depth:",
    Step = 1,
    Value = { Min = 1, Max = 50, Default = 10 },
    Callback = function(value)
        maxHeight = value
        if teleportActive and HumanoidRootPart and startY then
            local bottomPos = Vector3.new(HumanoidRootPart.Position.X, startY - maxHeight, HumanoidRootPart.Position.Z)
            HumanoidRootPart.CFrame = CFrame.new(bottomPos)
            lockedY = bottomPos.Y
        end
    end
})
myConfig:Register("SnapHeight", SnapSlider)

local Tab_player = Window:Tab({ Title = "PLAYER:", Icon = "person-standing" })
Tab_player:Section({ Title = "PLAYER:" })

local Folder = Instance.new("Folder", Workspace)
Folder.Name = "PIGHUB_Folder"
local CorePart = Instance.new("Part", Folder)
CorePart.Name = "CorePart"
CorePart.Anchored = true
CorePart.CanCollide = false
CorePart.Transparency = 1
local Attachment1 = Instance.new("Attachment", CorePart)
Attachment1.Name = "Attachment1"

local AutoFinnishToggle = Tab_player:Toggle({
    Title = "Auto Finish",
    Default = false,
    Callback = function(state)
        fastFinishEnabled = state
        if state then
            applyToAll()
            if WindUI and WindUI.Notify then 
                WindUI:Notify({ Title = "✅ Auto Finish Enabled", Duration = 3 }) 
            end
        else
            if WindUI and WindUI.Notify then 
                WindUI:Notify({ Title = "❌ Auto Finish Disabled", Duration = 3 }) 
            end
        end
    end
})
myConfig:Register("AutoFinnish", AutoFinnishToggle)

Tab_player:Divider()

local Tab_buyer = Window:Tab({ Title = "BUY:", Icon = "landmark" })
Tab_buyer:Section({ Title = "BUY:" })

local function safeToggle(title, desc, key, callback)
    pcall(function()
        local ToggleElement = Tab_buyer:Toggle({
            Title = title,
            Desc = desc,
            Icon = "check",
            Type = "Checkbox",
            Default = false,
            Callback = function(state)
                AutoSkipEnabled = state
                if callback then callback(state) end
            end
        })
        myConfig:Register(key, ToggleElement)
    end)
end

safeToggle("Skip Crate Spin", "Auto skip crate spinning", "SkipCrate", function(state) 
    if state then TrySkipCrate() end 
end)

local Tab_misc = Window:Tab({ Title = "MISC:", Icon = "warehouse" })

local placeId = game.PlaceId

local Input = Tab_misc:Input({
    Title = "Server Hop by ID",
    Value = "",
    InputIcon = "send",
    Type = "Input",
    Placeholder = "server id here!",
    Callback = function(input)
        if not input or input == "" then return end
        local serverIds = {}
        for id in string.gmatch(input, "[%w%-]+") do 
            table.insert(serverIds, id) 
        end
        if #serverIds == 0 then return end
        for _, id in ipairs(serverIds) do
            print("Teleporting to server:", id)
            task.wait(0.5)
            pcall(function() 
                game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, id, LocalPlayer) 
            end)
        end
    end
})

Tab_misc:Button({
    Title = "Server Rejoin",
    Desc = "Return to current server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local Serverhop = Tab_misc:Button({
    Title = "Server Hop",
    Desc = "Hop to a new server",
    Locked = false,
    Callback = function()
        local PlaceId = 104715542330896
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        end)
        if not success or not servers or not servers.data then
            warn("Cannot fetch server data")
            return
        end
        local availableServers = {}
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(availableServers, server)
            end
        end
        if #availableServers == 0 then
            warn("No available servers found")
            return
        end
        table.sort(availableServers, function(a, b) return a.playing > b.playing end)
        local targetServer = availableServers[1]
        game.StarterGui:SetCore("SendNotification", { 
            Title = "Server Hop", 
            Text = "Teleporting to new server...", 
            Duration = 3 
        })
        TeleportService:TeleportToPlaceInstance(PlaceId, targetServer.id, game.Players.LocalPlayer)
    end
})

Tab_misc:Divider()

local ClaimAllQuestButton = Tab_misc:Button({
    Title = "Claim All Quest",
    Callback = function()
        task.spawn(function()
            local success, err = pcall(function()
                local player = Players.LocalPlayer
                local questFrame = player:FindFirstChild("PlayerGui") and 
                                   player.PlayerGui:FindFirstChild("Quests") and
                                   player.PlayerGui.Quests:FindFirstChild("QuestsHolder") and
                                   player.PlayerGui.Quests.QuestsHolder:FindFirstChild("QuestsScrollingFrame")
                if questFrame then
                    for _, child in ipairs(questFrame:GetChildren()) do
                        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
                            NetGet("claim_quest", child.Name)
                            task.wait(0.2)
                        end
                    end
                end
            end)
            if success then 
                print("Claim All Quests Completed") 
            else 
                warn(err) 
            end
        end)
    end
})
myConfig:Register("ClaimAllQuest", ClaimAllQuestButton)

local saveFunc = myConfig["Save"]
local deleteFunc = myConfig["Delete"]
local loadFunc = myConfig["Load"]

Tab_misc:Section({ Title = "Config Management" })

local SaveConfigButton = Tab_misc:Button({
    Title = "Save Config",
    Callback = function() 
        if saveFunc then 
            saveFunc(myConfig) 
        end 
    end
})
myConfig:Register("SaveConfig", SaveConfigButton)

local DeleteConfigButton = Tab_misc:Button({
    Title = "Delete Config",
    Callback = function() 
        if deleteFunc then 
            deleteFunc(myConfig) 
        end 
    end
})
myConfig:Register("DeleteConfig", DeleteConfigButton)

if loadFunc then 
    pcall(function() loadFunc(myConfig) end)
end

-- Bypass systems
local _old_tween = Util.tween if Util then
    Util.tween = function(instance, tweenInfo, properties)
        if instance and instance:IsA("NumberValue") and properties and properties.Value ~= nil then
            instance.Value = properties.Value
            return { Cancel = function() end }
        end
        return _old_tween(instance, tweenInfo, properties)
    end
end

local success, sellBtn = pcall(function() 
    return BuyPromptUI and BuyPromptUI.get and BuyPromptUI.get("SellPromptSellButton") 
end)

if success and sellBtn then
    local hold = sellBtn:FindFirstChild("HoldStroke", true)
    if hold then
        hold.Enabled = false
        local uiGrad = hold:FindFirstChildOfClass("UIGradient")
        if uiGrad then uiGrad.Enabled = false end
    end
    for _, v in pairs(sellBtn:GetDescendants()) do
        if v:IsA("NumberValue") then v.Value = 1 end
    end
end

task.wait(2)
print("PIGHUB [BUY] Loaded Successfully!")

if WindUI and WindUI.Notify then
    WindUI:Notify({ Title = "🐷 PIGHUB [BUY] Loaded!", Duration = 3 })
end