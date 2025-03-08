local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Lighting Hub ⚡ - LUCKY BLOCKS Battlegrounds",
    SubTitle = "by Flames",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    FreeLuckyBlocks = Window:AddTab({ Title = "Free Lucky Blocks", Icon = "box" }),
    LocalPlayer = Window:AddTab({ Title = "Local Player", Icon = "user" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = {
    {Name = "SpawnSuperBlock",    Event = ReplicatedStorage.SpawnSuperBlock},
    {Name = "SpawnDiamondBlock",  Event = ReplicatedStorage.SpawnDiamondBlock},
    {Name = "SpawnGalaxyBlock",   Event = ReplicatedStorage.SpawnGalaxyBlock},
    {Name = "SpawnLuckyBlock",    Event = ReplicatedStorage.SpawnLuckyBlock},
    {Name = "SpawnRainbowBlock",  Event = ReplicatedStorage.SpawnRainbowBlock}
}

local SingleOpenSection = Tabs.FreeLuckyBlocks:AddSection("Single Open")
for _, remote in ipairs(remoteEvents) do
    Tabs.FreeLuckyBlocks:AddButton({
        Title = remote.Name,
        Description = "Click to spawn a " .. remote.Name:gsub("Spawn", "") .. " block.",
        Callback = function()
            remote.Event:FireServer()
        end
    })
end

local AutoOpenSection = Tabs.FreeLuckyBlocks:AddSection("Auto Open")
for _, remote in ipairs(remoteEvents) do
    local firing = false
    Tabs.FreeLuckyBlocks:AddToggle(remote.Name, {
        Title = remote.Name,
        Default = false,
        Callback = function(value)
            firing = value
            if firing then
                task.spawn(function()
                    while firing do
                        remote.Event:FireServer()
                        task.wait(0.1)
                    end
                end)
            end
        end
    })
end

local KeybindSection = Tabs.FreeLuckyBlocks:AddSection("Keybinds")
for _, remote in ipairs(remoteEvents) do
    local keybind = Tabs.FreeLuckyBlocks:AddKeybind(remote.Name, {
        Title = remote.Name,
        Mode = "Toggle",
        Default = "Q"
    })
    keybind:OnClick(function()
        remote.Event:FireServer()
    end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

Tabs.LocalPlayer:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Description = "Adjust your WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 250,
    Rounding = 1,
    Callback = function(value)
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
})

Tabs.LocalPlayer:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Adjust your Jump Power",
    Default = 50,
    Min = 20,
    Max = 200,
    Rounding = 1,
    Callback = function(value)
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").JumpPower = value
        end
    end
})

Tabs.LocalPlayer:AddSlider("Gravity", {
    Title = "Gravity",
    Description = "Adjust the Gravity",
    Default = workspace.Gravity,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Callback = function(value)
        workspace.Gravity = value
    end
})

local infJumpEnabled = false
Tabs.LocalPlayer:AddToggle("InfJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(value)
        infJumpEnabled = value
    end
})
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local noclipEnabled = false
Tabs.LocalPlayer:AddToggle("NoClip", {
    Title = "NoClip",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
    end
})
RunService.Stepped:Connect(function()
    if noclipEnabled and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local flying = false
local flySpeed = 50
local flyConnection
local bodyVelocity

local function startFly()
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flying = true
    bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    
    flyConnection = RunService.RenderStepped:Connect(function(delta)
        local direction = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + (workspace.CurrentCamera.CFrame.LookVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - (workspace.CurrentCamera.CFrame.LookVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - (workspace.CurrentCamera.CFrame.RightVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + (workspace.CurrentCamera.CFrame.RightVector)
        end
        if direction.Magnitude > 0 then
            direction = direction.Unit * flySpeed
        end
        bodyVelocity.Velocity = direction
    end)
end

local function stopFly()
    flying = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end

Tabs.LocalPlayer:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Callback = function(value)
        if value then
            startFly()
        else
            stopFly()
        end
    end
})

Tabs.LocalPlayer:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Adjust your fly speed",
    Default = flySpeed,
    Min = 10,
    Max = 200,
    Rounding = 1,
    Callback = function(value)
        flySpeed = value
    end
})

local ESPColorPicker = Tabs.ESP:AddColorpicker("ESPColor", {
    Title = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Transparency = 0
})

ESPColorPicker:OnChanged(function()
    for _, highlight in ipairs(workspace:GetDescendants()) do
        if highlight:IsA("Highlight") and highlight.Name == "ESPHighlight" then
            highlight.FillColor = ESPColorPicker.Value
            highlight.OutlineColor = Color3.new(0, 0, 0)
            highlight.FillTransparency = ESPColorPicker.Transparency
            highlight.OutlineTransparency = ESPColorPicker.Transparency
        end
    end
end)

local function addESPToCharacter(character)
    if character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Adornee = character
        highlight.FillColor = ESPColorPicker.Value
        highlight.OutlineColor = Color3.new(0, 0, 0) 
        highlight.FillTransparency = ESPColorPicker.Transparency
        highlight.OutlineTransparency = ESPColorPicker.Transparency
        highlight.Parent = character
    end
end

local espEnabled = false

local function enableESP()
    espEnabled = true
    for _, plyr in ipairs(Players:GetPlayers()) do
        if plyr ~= player and plyr.Character then
            addESPToCharacter(plyr.Character)
            plyr.CharacterAdded:Connect(function(char)
                wait(0.1)
                if espEnabled then
                    addESPToCharacter(char)
                end
            end)
        end
    end
end

local function disableESP()
    espEnabled = false
    for _, highlight in ipairs(workspace:GetDescendants()) do
        if highlight:IsA("Highlight") and highlight.Name == "ESPHighlight" then
            highlight:Destroy()
        end
    end
end

Tabs.ESP:AddToggle("ESPEnabled", {
    Title = "Enable ESP",
    Default = false,
    Callback = function(value)
        if value then
            enableESP()
        else
            disableESP()
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("LightingHub")
SaveManager:SetFolder("LightingHub/config")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "Lighting Hub Loaded ✅",
    Content = "Enjoy!",
    Duration = 5
})
Window:SelectTab(1)
