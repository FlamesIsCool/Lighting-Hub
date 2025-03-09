local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local TweenService = game:GetService("TweenService")

local Window = Fluent:CreateWindow({
    Title = "Lighting Hub ⚡ - Murder Mystery 2",
    SubTitle = "by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    LocalPlayer = Window:AddTab({ Title = "LocalPlayer", Icon = "user" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "compass" }),
    Autofarm = Window:AddTab({ Title = "Autofarm", Icon = "leaf" }),
    Roles = Window:AddTab({ Title = "Roles", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

------------------------------------------------------------
-- LocalPlayer Tab
------------------------------------------------------------
local WalkspeedSlider = Tabs.LocalPlayer:AddSlider("Walkspeed", {
    Title = "Walkspeed",
    Description = "Adjust your player's walkspeed.",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end
})

local JumpPowerSlider = Tabs.LocalPlayer:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Adjust your player's jump power.",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = Value
        end
    end
})

local GravitySlider = Tabs.LocalPlayer:AddSlider("Gravity", {
    Title = "Gravity",
    Description = "Adjust the game gravity.",
    Default = workspace.Gravity,
    Min = 0,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

local FOVSlider = Tabs.LocalPlayer:AddSlider("FOV", {
    Title = "Field of View",
    Description = "Adjust the camera's field of view.",
    Default = Camera.FieldOfView,
    Min = 20,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        Camera.FieldOfView = Value
    end
})

local InfJumpToggle = Tabs.LocalPlayer:AddToggle("InfJump", {
    Title = "Infinite Jump",
    Default = false,
    Description = "Enable infinite jump."
})
local InfJumpEnabled = false
local InfJumpConnection
InfJumpToggle:OnChanged(function()
    InfJumpEnabled = InfJumpToggle.Value
    if InfJumpEnabled then
        InfJumpConnection = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if InfJumpConnection then
            InfJumpConnection:Disconnect()
        end
    end
end)

local NoclipToggle = Tabs.LocalPlayer:AddToggle("Noclip", {
    Title = "Noclip",
    Default = false,
    Description = "Enable noclip (walk through walls)."
})
local NoclipEnabled = false
NoclipToggle:OnChanged(function()
    NoclipEnabled = NoclipToggle.Value
end)
RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local FlyToggle = Tabs.LocalPlayer:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Description = "Enable flying mode."
})
local FlySpeedSlider = Tabs.LocalPlayer:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Adjust your fly speed.",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 1,
    Callback = function(Value) end
})
local FlyEnabled = false
local FlyBodyVelocity, FlyBodyGyro
local FlyConnection
FlyToggle:OnChanged(function()
    FlyEnabled = FlyToggle.Value
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if FlyEnabled then
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.Parent = hrp

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        FlyBodyGyro.CFrame = hrp.CFrame
        FlyBodyGyro.Parent = hrp

        FlyConnection = RunService.RenderStepped:Connect(function()
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (Camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - (Camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - (Camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (Camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            FlyBodyVelocity.Velocity = direction * FlySpeedSlider.Value
            if direction.Magnitude > 0 then
                FlyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
            else
                FlyBodyGyro.CFrame = hrp.CFrame
            end
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
        end
        if FlyBodyVelocity then
            FlyBodyVelocity:Destroy()
        end
        if FlyBodyGyro then
            FlyBodyGyro:Destroy()
        end
    end
end)


local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local TeleportDropdown = Tabs.Teleport:AddDropdown("TeleportToPlayer", {
    Title = "Teleport to Player",
    Description = "Select a player to teleport to their position.",
    Values = getPlayerNames(),
    Multi = false,
    Default = nil,
    Callback = function(selected)
        local target = Players:FindFirstChild(selected)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
           and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame =
                target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Refresh Player List",
    Description = "Update the teleport dropdown with current players.",
    Callback = function()
        TeleportDropdown:SetValues(getPlayerNames())
    end
})

Tabs.Teleport:AddButton({
    Title = "Reset Player",
    Description = "Reset WalkSpeed and JumpPower to default values.",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
            WalkspeedSlider:SetValue(16)
            JumpPowerSlider:SetValue(50)
        end
    end
})

local locationCoordinates = {
    Lobby = Vector3.new(-121.12338256836, 138.27394104004, 38.946128845215)
}
local LocationSection = Tabs.Teleport:AddSection("Locations")
LocationSection:AddDropdown("TeleportToLocation", {
    Title = "Teleport to Location",
    Description = "Select a location to teleport to.",
    Values = {"Lobby", "Map"},
    Multi = false,
    Default = nil,
    Callback = function(selected)
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local RootPart = character:FindFirstChild("HumanoidRootPart")
            if selected == "Map" then
                local coins = {}
                for _, child in pairs(workspace:GetDescendants()) do
                    if child:IsA("BasePart") and child.Name == "Coin_Server" then
                        table.insert(coins, child)
                    end
                end
                if #coins > 0 then
                    local randomCoin = coins[math.random(1, #coins)]
                    local targetCFrame = randomCoin.CFrame
                    local distance = (RootPart.Position - randomCoin.Position).Magnitude
                    local speed = 20 
                    local tweenTime = math.max(distance / speed, 0.5)
                    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(RootPart, tweenInfo, {CFrame = targetCFrame})
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Sit = true
                        task.wait(0.1)
                        if character:FindFirstChild("HumanoidRootPart") then
                            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
                        end
                        for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                            anim:Stop()
                        end
                    end
                    tween:Play()
                    tween.Completed:Wait()
                    wait(getgenv().AutofarmPause or 2)
                else
                    Fluent:Notify({
                        Title = "Lighting Hub",
                        Content = "No coins found in the workspace!",
                        Duration = 5
                    })
                    wait(5)
                end
            else
                pcall(function()
                    RootPart.CFrame = CFrame.new(locationCoordinates[selected])
                end)
            end
        end
    end
})

------------------------------------------------------------
-- Autofarm Tab
------------------------------------------------------------
local autofarmToggle = Tabs.Autofarm:AddToggle("AutofarmCoins", {
    Title = "Autofarm Coins",
    Description = "Automatically move between coins on the map using selected method.",
    Default = false
})

local AutofarmSettingsSection = Tabs.Autofarm:AddSection("Autofarm Settings")
local autofarmSpeedSlider = AutofarmSettingsSection:AddSlider("AutofarmSpeed", {
    Title = "Autofarm Speed",
    Description = "Set movement speed (studs/sec) for autofarm.",
    Default = 20,
    Min = 10,
    Max = 100,
    Rounding = 1,
    Callback = function(val)
        getgenv().AutofarmSpeed = val
    end
})
getgenv().AutofarmSpeed = autofarmSpeedSlider.Value

local autofarmPauseSlider = AutofarmSettingsSection:AddSlider("AutofarmPause", {
    Title = "Autofarm Pause",
    Description = "Set the pause time (seconds) after reaching a coin.",
    Default = 2,
    Min = 0.5,
    Max = 10,
    Rounding = 0.1,
    Callback = function(val)
        getgenv().AutofarmPause = val
    end
})
getgenv().AutofarmPause = autofarmPauseSlider.Value

local autofarmMethodDropdown = AutofarmSettingsSection:AddDropdown("AutofarmMethod", {
    Title = "Autofarm Method",
    Description = "Choose movement method: Tween or Instant Teleport.",
    Values = {"Tween", "Instant"},
    Multi = false,
    Default = "Tween",
    Callback = function(val)
        getgenv().AutofarmMethod = val
    end
})
getgenv().AutofarmMethod = autofarmMethodDropdown.Value

autofarmToggle:OnChanged(function(enabled)
    if enabled then
        coroutine.wrap(function()
            while autofarmToggle.Value do
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local RootPart = character.HumanoidRootPart
                    local coins = {}
                    for _, child in ipairs(workspace:GetDescendants()) do
                        if child:IsA("BasePart") and child.Name == "Coin_Server" then
                            table.insert(coins, child)
                        end
                    end
                    if #coins > 0 then
                        local randomCoin = coins[math.random(1, #coins)]
                        local targetCFrame = randomCoin.CFrame  -- No offset now
                        if getgenv().AutofarmMethod == "Tween" then
                            local distance = (RootPart.Position - randomCoin.Position).Magnitude
                            local speed = getgenv().AutofarmSpeed or 20
                            local tweenTime = math.max(distance / speed, 0.5)
                            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                            local tween = TweenService:Create(RootPart, tweenInfo, {CFrame = targetCFrame})
                            -- Lay down before tweening:
                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                humanoid.Sit = true
                                task.wait(0.1)
                                if character:FindFirstChild("HumanoidRootPart") then
                                    character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
                                end
                                for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                                    anim:Stop()
                                end
                            end
                            tween:Play()
                            tween.Completed:Wait()
                        else -- Instant teleport method:
                            RootPart.CFrame = targetCFrame
                        end
                        wait(getgenv().AutofarmPause or 2)
                    else
                        Fluent:Notify({
                            Title = "Lighting Hub",
                            Content = "No coins found for autofarm!",
                            Duration = 5
                        })
                        wait(5)
                    end
                else
                    wait(1)
                end
                wait()
            end
        end)()
    end
end)

------------------------------------------------------------
-- ESP Tab
------------------------------------------------------------
local ESPSection = Tabs.ESP:AddSection("Player ESP")

local murdererESPToggle = ESPSection:AddToggle("MurdererESP", {
    Title = "Murderer ESP",
    Description = "Highlight the murderer in red.",
    Default = true
})

local sheriffESPToggle = ESPSection:AddToggle("Sheriff ESP", {
    Title = "Sheriff ESP",
    Description = "Highlight the sheriff in blue.",
    Default = true
})

local innocentESPToggle = ESPSection:AddToggle("InnocentESP", {
    Title = "Innocent ESP",
    Description = "Highlight innocent players in green.",
    Default = true
})

local coinESPToggle = ESPSection:AddToggle("CoinESP", {
    Title = "Coin ESP",
    Description = "Highlight all coins in yellow.",
    Default = true
})

local playerHighlights = {}  
local coinHighlights = {}    

local function updateESPForPlayer(player)
    if not player.Character then
        if playerHighlights[player] then
            playerHighlights[player]:Destroy()
            playerHighlights[player] = nil
        end
        return
    end
    local character = player.Character

    local function hasTool(toolName)
        local found = false
        if player:FindFirstChild("Backpack") then
            for _, tool in ipairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == toolName then
                    found = true
                    break
                end
            end
        end
        if not found then
            for _, item in ipairs(character:GetChildren()) do
                if item:IsA("Tool") and item.Name == toolName then
                    found = true
                    break
                end
            end
        end
        return found
    end

    local isMurderer = hasTool("Knife")
    local isSheriff  = (not isMurderer) and hasTool("Gun")
    local isInnocent = (not isMurderer and not isSheriff)

    local desiredColor
    if isMurderer and murdererESPToggle.Value then
        desiredColor = Color3.new(1, 0, 0)
    elseif isSheriff and sheriffESPToggle.Value then
        desiredColor = Color3.new(0, 0, 1)
    elseif isInnocent and innocentESPToggle.Value then
        desiredColor = Color3.new(0, 1, 0)
    end

    if desiredColor then
        if not playerHighlights[player] then
            local h = Instance.new("Highlight")
            h.Name = "ESPHighlight"
            h.FillTransparency = 0.5
            h.OutlineTransparency = 1
            h.Adornee = character
            h.FillColor = desiredColor
            h.Parent = character
            playerHighlights[player] = h
        else
            playerHighlights[player].FillColor = desiredColor
            if playerHighlights[player].Adornee ~= character then
                playerHighlights[player].Adornee = character
            end
        end
    else
        if playerHighlights[player] then
            playerHighlights[player]:Destroy()
            playerHighlights[player] = nil
        end
    end
end

spawn(function()
    while wait(1) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                updateESPForPlayer(player)
            end
        end
    end
end)

local function refreshAllPlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updateESPForPlayer(player)
        end
    end
end

murdererESPToggle:OnChanged(refreshAllPlayerESP)
sheriffESPToggle:OnChanged(refreshAllPlayerESP)
innocentESPToggle:OnChanged(refreshAllPlayerESP)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(0.5)
        updateESPForPlayer(player)
    end)
end)

spawn(function()
    while wait(0.1) do
        if coinESPToggle.Value then
            for _, container in ipairs(workspace:GetDescendants()) do
                if container:IsA("Model") and container.Name == "CoinContainer" then
                    for _, coinServer in ipairs(container:GetChildren()) do
                        if coinServer.Name == "Coin_Server" then
                            local coinVisual = coinServer:FindFirstChild("CoinVisual")
                            if coinVisual then
                                local mainCoin = coinVisual:FindFirstChild("MainCoin")
                                if mainCoin and mainCoin:IsA("MeshPart") then
                                    if not coinHighlights[mainCoin] then
                                        local h = Instance.new("Highlight")
                                        h.Name = "CoinESPHighlight"
                                        h.FillColor = Color3.fromRGB(0, 255, 255)
                                        h.FillTransparency = 0.5
                                        h.OutlineTransparency = 1
                                        h.Adornee = mainCoin
                                        h.Parent = mainCoin
                                        coinHighlights[mainCoin] = h
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            for coinObj, h in pairs(coinHighlights) do
                if h then
                    h:Destroy()
                end
            end
            coinHighlights = {}
        end
    end
end)

------------------------------------------------------------
-- Roles Tab
------------------------------------------------------------
local RolesTab = Tabs.Roles

local SheriffSection = RolesTab:AddSection("Sheriff")
local gunDropNotified = false
RunService.Stepped:Connect(function()
    local foundGunDrop = false
    for _, child in pairs(workspace:GetDescendants()) do
        if child.Name == "GunDrop" then
            foundGunDrop = true
            break
        end
    end
    if foundGunDrop and not gunDropNotified then
        gunDropNotified = true
        Fluent:Notify({
            Title = "Roles - Sheriff",
            Content = "Gun has been dropped!",
            Duration = 5
        })
    elseif not foundGunDrop then
        gunDropNotified = false
    end
end)

SheriffSection:AddButton({
    Title = "Teleport to GunDrop",
    Description = "Teleport to the first detected GunDrop.",
    Callback = function()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            Fluent:Notify({
                Title = "Lighting Hub",
                Content = "Character not found!",
                Duration = 3
            })
            return
        end
        local RootPart = character:FindFirstChild("HumanoidRootPart")
        local found = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                RootPart.CFrame = obj.CFrame
                found = true
                break
            end
        end
        if not found then
            Fluent:Notify({
                Title = "Lighting Hub",
                Content = "No GunDrop found!",
                Duration = 3
            })
        end
    end
})

local MurdererSection = RolesTab:AddSection("Murderer")
local KillAllKeybind = MurdererSection:AddKeybind("KillAll", {
    Title = "Kill All",
    Mode = "Toggle", 
    Default = "F"
})
KillAllKeybind:OnClick(function()
    pcall(function()
        local Client = LocalPlayer
        local Knife = Client.Backpack:FindFirstChild("Knife") or (Client.Character and Client.Character:FindFirstChild("Knife"))
        if Knife and Knife.Parent and Knife.Parent.Name == "Backpack" then
            local Humanoid = Client.Character and Client.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:EquipTool(Knife)
            end
        end
        if Knife and Knife:IsA("Tool") then
            local VirtualUser = game:GetService("VirtualUser")
            local Whitelisted = getgenv().Whitelisted or {}
            for i, v in ipairs(Players:GetPlayers()) do
                if v ~= Client and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and not table.find(Whitelisted, v.Name) then
                    local EnemyRoot = v.Character.HumanoidRootPart
                    VirtualUser:ClickButton1(Vector2.new())
                    firetouchinterest(EnemyRoot, Knife.Handle, 1)
                    firetouchinterest(EnemyRoot, Knife.Handle, 0)
                end
            end
        end
    end)
end)

local killAuraToggle = MurdererSection:AddToggle("KillAura", {
    Title = "Kill Aura",
    Description = "Automatically attack players within range.",
    Default = false
})
local killAuraRangeSlider = MurdererSection:AddSlider("KillAuraRange", {
    Title = "Kill Aura Range",
    Description = "Set the attack range for kill aura (max 250).",
    Default = 50,
    Min = 1,
    Max = 250,
    Rounding = 1,
    Callback = function(val)
        getgenv().KnifeRange = val
    end
})
getgenv().KnifeRange = killAuraRangeSlider.Value

local killAuraConnection
local lastAttack = tick()

killAuraToggle:OnChanged(function(enabled)
    if enabled then
        killAuraConnection = RunService.Heartbeat:Connect(function()
            if (tick() - lastAttack) < 0.1 then
                return
            end
            pcall(function()
                local Knife = LocalPlayer.Backpack:FindFirstChild("Knife") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife"))
                if Knife and Knife:IsA("Tool") then
                    local VirtualUser = game:GetService("VirtualUser")
                    local RootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not RootPart then return end
                    for i, v in ipairs(Players:GetPlayers()) do
                        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and not table.find(getgenv().Whitelisted or {}, v.Name) then
                            local EnemyRoot = v.Character.HumanoidRootPart
                            local Distance = (EnemyRoot.Position - RootPart.Position).Magnitude
                            if Distance <= getgenv().KnifeRange then
                                VirtualUser:ClickButton1(Vector2.new())
                                firetouchinterest(EnemyRoot, Knife.Handle, 1)
                                firetouchinterest(EnemyRoot, Knife.Handle, 0)
                                lastAttack = tick()
                            end
                        end
                    end
                end
            end)
        end)
    else
        if killAuraConnection then
            killAuraConnection:Disconnect()
            killAuraConnection = nil
        end
    end
end)

------------------------------------------------------------
-- Settings Tab
------------------------------------------------------------
local utilitiesSection = Tabs.Settings:AddSection("Utilities")

utilitiesSection:AddButton({
    Title = "Rejoin",
    Description = "Rejoin the current server.",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

utilitiesSection:AddButton({
    Title = "Serverhop",
    Description = "Hop to a different server instance.",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local PlaceId = game.PlaceId
        local req = syn and syn.request or http_request or request
        if not req then
            warn("HTTP request function not available.")
            return
        end
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local response = req({
            Url = url,
            Method = "GET"
        })
        if response and response.Body then
            local data = HttpService:JSONDecode(response.Body)
            local servers = {}
            for _, v in ipairs(data.data) do
                if v.playing < v.maxPlayers then
                    table.insert(servers, v.id)
                end
            end
            if #servers > 0 then
                local randomServer = servers[math.random(1, #servers)]
                TeleportService:TeleportToPlaceInstance(PlaceId, randomServer, LocalPlayer)
            else
                warn("No available servers found!")
            end
        end
    end
})

local executorName, executorVersion = "Unknown", "Unknown"
if identifyexecutor and type(identifyexecutor) == "function" then
    local result1, result2 = identifyexecutor()
    if type(result1) == "string" and type(result2) == "string" then
        executorName = result1
        executorVersion = result2
    end
end

utilitiesSection:AddParagraph({
    Title = "Executor Type",
    Content = "Executor: " .. executorName .. " (v" .. executorVersion .. ")"
})

utilitiesSection:AddButton({
    Title = "Set FPS Cap",
    Description = "Set your FPS cap to Infinite.",
    Callback = function()
        if setfpscap then
            setfpscap(999)
        else
            warn("setfpscap function not available on your executor.")
        end
    end
})

------------------------------------------------------------
-- Configuration Management
------------------------------------------------------------
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("Lighting Hub")
SaveManager:SetFolder("Lighting Hub/MM2")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Lighting Hub ⚡",
    Content = "Script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
