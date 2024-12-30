local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local autofarm_running = false
local max_printers = 6
local cash_collection_limit = 200
local safe_platform_position = CFrame.new(2620.70, 61.70, -4115.15) -- Position for the floating platform
local platform_created = false
local owned_printer_amount = 0
local buying_printers = false
local esp_enabled = false
local current_job = "Civilian" -- Default job
local available_jobs = {
    "Civilian",
    "Sheriff",
    "Paramedic",
    "Mayor {DON'T USE}"
}

local function stabilizePrinters()
    game:GetService("RunService").Heartbeat:Connect(function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for i, printer in pairs(workspace:GetChildren()) do
                if printer and printer:FindFirstChild("Properties") and printer.Properties:FindFirstChild("Owner") and printer.Properties.Owner.Value == player.Name then
                    printer.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 5 + (i * 2), 0)
                end
            end
        end
    end)
end

local Window = OrionLib:MakeWindow({
    Name = "Monsters Market",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MonstersMarketConfig"
})


local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local aimbot_enabled = false
local visibility_check = false
local fov_radius = 100
local silent_aim_enabled = false
local hitbox_target = "Head" -- Default hitbox target

local function enableAimbot()
    game:GetService("RunService").RenderStepped:Connect(function()
        if aimbot_enabled then
            local player = game.Players.LocalPlayer
            local camera = workspace.CurrentCamera
            local target = nil
            local closest_distance = fov_radius

            for _, other_player in pairs(game.Players:GetPlayers()) do
                if other_player ~= player and other_player.Character and other_player.Character:FindFirstChild(hitbox_target) then
                    local target_part = other_player.Character[hitbox_target]
                    local screen_position, on_screen = camera:WorldToScreenPoint(target_part.Position)
                    
                    if on_screen then
                        local distance = (Vector2.new(screen_position.X, screen_position.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                        if distance < closest_distance then
                            if visibility_check then
                                local ray = Ray.new(camera.CFrame.Position, (target_part.Position - camera.CFrame.Position).Unit * 5000)
                                local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})
                                if hit and hit:IsDescendantOf(other_player.Character) then
                                    target = target_part
                                    closest_distance = distance
                                end
                            else
                                target = target_part
                                closest_distance = distance
                            end
                        end
                    end
                end
            end

            if target then
                -- Adjust camera to look at the target
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)

                end
            end
        end
    end)
end

CombatTab:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(value)
        aimbot_enabled = value
        if value then
            enableAimbot()
        end
    end
})

CombatTab:AddToggle({
    Name = "Enable Visibility Check",
    Default = false,
    Callback = function(value)
        visibility_check = value
    end
})

CombatTab:AddSlider({
    Name = "FOV Radius",
    Min = 50,
    Max = 300,
    Default = 100,
    Increment = 10,
    Callback = function(value)
        fov_radius = value
    end
})

CombatTab:AddToggle({
    Name = "Enable Silent Aim",
    Default = false,
    Callback = function(value)
        silent_aim_enabled = value
    end
})

CombatTab:AddDropdown({
    Name = "Hitbox Target",
    Default = "Head",
    Options = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    Callback = function(selected_hitbox)
        hitbox_target = selected_hitbox
    end
})

local CustomTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local esp_enabled = false
local visuals_settings = {
    health_bar = false,
    skeleton = false,
    box = false,
    glow = false,
    name = false,
    distance = false
}

local function createESPComponents(character)
    -- Ensure there are no duplicates
    if character:FindFirstChild("PlayerESPComponents") then
        character:FindFirstChild("PlayerESPComponents"):Destroy()
    end

    -- Create folder to store ESP components
    local espFolder = Instance.new("Folder")
    espFolder.Name = "PlayerESPComponents"
    espFolder.Parent = character

    -- Create Billboard GUI for health bar, name, and distance
    local billboard = Instance.new("BillboardGui", espFolder)
    billboard.Name = "ESPBillboard"
    billboard.Size = UDim2.new(5, 0, 1.5, 0) -- Adjust size as needed
    billboard.Adornee = character:FindFirstChild("HumanoidRootPart")
    billboard.AlwaysOnTop = true

    -- Create Health Bar
    local healthBarBackground = Instance.new("Frame", billboard)
    healthBarBackground.Size = UDim2.new(1, 0, 0.2, 0)
    healthBarBackground.Position = UDim2.new(0, 0, 0, 0)
    healthBarBackground.BackgroundColor3 = Color3.new(0, 0, 0)

    local healthBar = Instance.new("Frame", healthBarBackground)
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.Position = UDim2.new(0, 0, 0, 0)
    healthBar.BackgroundColor3 = Color3.new(0, 1, 0)

    -- Create Text Labels for Name and Distance
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.2, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Text = character.Name

    local distanceLabel = Instance.new("TextLabel", billboard)
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextScaled = true
    distanceLabel.Text = ""
end

local function updateESPComponents(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        local espFolder = player.Character:FindFirstChild("PlayerESPComponents")

        if espFolder then
            local billboard = espFolder:FindFirstChild("ESPBillboard")
            if billboard then
                -- Update Health Bar
                local healthBar = billboard:FindFirstChild("HealthBar")
                if healthBar then
                    local healthRatio = humanoid.Health / humanoid.MaxHealth
                    healthBar.Size = UDim2.new(healthRatio, 0, 1, 0)
                    healthBar.BackgroundColor3 = Color3.new(1 - healthRatio, healthRatio, 0) -- Gradient from red to green
                    healthBar.Visible = visuals_settings.health_bar
                end

                -- Update Name Label
                local nameLabel = billboard:FindFirstChild("NameLabel")
                if nameLabel then
                    nameLabel.Visible = visuals_settings.name
                end

                -- Update Distance Label
                local distanceLabel = billboard:FindFirstChild("DistanceLabel")
                if distanceLabel and rootPart then
                    local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    distanceLabel.Text = string.format("Distance: %.1f", distance)
                    distanceLabel.Visible = visuals_settings.distance
                end
            end
        end
    end
end

local function enableESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            createESPComponents(player.Character)
        end
    end

    game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            createESPComponents(character)
        end)
    end)
end

local function disableESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local espFolder = player.Character:FindFirstChild("PlayerESPComponents")
            if espFolder then
                espFolder:Destroy()
            end
        end
    end
end

local function updateVisuals()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            updateESPComponents(player)
        end
    end
end

local function toggleESP(enabled)
    esp_enabled = enabled
    if enabled then
        enableESP()
        OrionLib:MakeNotification({
            Name = "ESP Enabled",
            Content = "You can now see other players highlighted.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    else
        disableESP()
        OrionLib:MakeNotification({
            Name = "ESP Disabled",
            Content = "Player highlights are now removed.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
end

CustomTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(value)
        toggleESP(value)
    end
})

CustomTab:AddToggle({
    Name = "Health Bar",
    Default = false,
    Callback = function(value)
        visuals_settings.health_bar = value
        updateVisuals()
    end
})

CustomTab:AddToggle({
    Name = "Name",
    Default = false,
    Callback = function(value)
        visuals_settings.name = value
        updateVisuals()
    end
})

CustomTab:AddToggle({
    Name = "Distance",
    Default = false,
    Callback = function(value)
        visuals_settings.distance = value
        updateVisuals()
    end
})


local AutofarmTab = Window:MakeTab({
    Name = "AutoFarm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local function createSafePlatform()
    if platform_created then return end
    local platform = Instance.new("Part")
    platform.Name = "SafePlatform"
    platform.Size = Vector3.new(50, 1, 50)
    platform.Position = safe_platform_position.Position
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.SmoothPlastic
    platform.BrickColor = BrickColor.new("Bright yellow")
    platform.Parent = workspace
    platform_created = true
end

local function teleportToSafePlatform()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart

        createSafePlatform()

        game:GetService('TweenService'):Create(
            hrp,
            TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
            {CFrame = safe_platform_position}
        ):Play()

        OrionLib:MakeNotification({
            Name = "Teleportation Successful",
            Content = "You have been teleported to a safe location.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    else
        OrionLib:MakeNotification({
            Name = "Teleportation Failed",
            Content = "HumanoidRootPart not found. Ensure your character has fully loaded.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
end

local function isPlayerOnSafePlatform()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local platform = workspace:FindFirstChild("SafePlatform")
        if platform then
            local position = hrp.Position
            local platformPosition = platform.Position
            local platformSize = platform.Size

            if math.abs(position.X - platformPosition.X) <= platformSize.X / 2 and
               math.abs(position.Y - platformPosition.Y) <= platformSize.Y / 2 + 5 and
               math.abs(position.Z - platformPosition.Z) <= platformSize.Z / 2 then
                return true
            end
        end
    end
    return false
end

local function updateOwnedPrinterCount()
    owned_printer_amount = 0
    for _, printer in pairs(workspace.Entities:GetChildren()) do
        if string.find(tostring(printer.Name):lower(), 'printer') and 
           tostring(printer.Properties.Owner.Value) == game.Players.LocalPlayer.Name then
            owned_printer_amount += 1
        end
    end
end

local function collectPrinterCash(printer)
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage")["_CS.Events"].LockPrinter:FireServer(printer)
        game:GetService("ReplicatedStorage")["_CS.Events"].UsePrinter:FireServer(printer)
        game:GetService("ReplicatedStorage")["_CS.Events"].LockPrinter:FireServer(printer)
    end)
    if not success then
        warn("Error collecting cash from printer: " .. tostring(err))
    end
end

local function startAutofarm()
    autofarm_running = true
    stabilizePrinters()

    OrionLib:MakeNotification({
        Name = "AutoFarm Started",
        Content = "Printers are stabilized above your head.",
        Image = "rbxassetid://4483345998",
        Time = 5
    })

    while autofarm_running do
        updateOwnedPrinterCount()

        if owned_printer_amount < max_printers and not buying_printers then
            buying_printers = true
            task.spawn(function()
                while owned_printer_amount < max_printers and autofarm_running do
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage")["_CS.Events"].PurchaseTeamItem:FireServer("Hotwired Printer", "Single", Color3.new(0, 0, 0))
                    end)
                    if success then
                        owned_printer_amount += 1
                    else
                        warn("Error purchasing printer: " .. tostring(err))
                    end
                    task.wait(3)
                end
                buying_printers = false
            end)
        end

        for _, printer in pairs(workspace.Entities:GetChildren()) do
            if string.find(tostring(printer.Name):lower(), 'printer') and 
               tostring(printer.Properties.Owner.Value) == game.Players.LocalPlayer.Name and 
               tonumber(printer.Properties.CurrentPrinted.Value) >= cash_collection_limit then
                collectPrinterCash(printer)
            end
        end

        task.wait(1)
    end

    OrionLib:MakeNotification({
        Name = "AutoFarm Stopped",
        Content = "The autofarm has been stopped.",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

AutofarmTab:AddToggle({
    Name = "Enable AutoFarm",
    Default = false,
    Callback = function(value)
        autofarm_running = value
        if value then
            startAutofarm()
        end
    end
})

AutofarmTab:AddButton({
    Name = "Teleport to Safe Location",
    Callback = function()
        teleportToSafePlatform()
    end
})

local ExploitsTab = Window:MakeTab({
    Name = "Exploits",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})


local function activateImmunity()
    game:GetService("RunService").RenderStepped:Connect(function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.Health = character.Humanoid.MaxHealth
        end
    end)
end

local function showFullChat()
    local chatGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
    chatGui.Name = "DraggableChatGui"
    chatGui.ResetOnSpawn = false

    local chatFrame = Instance.new("Frame", chatGui)
    chatFrame.Size = UDim2.new(0.4, 0, 0.5, 0)
    chatFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
    chatFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    chatFrame.BorderSizePixel = 2
    chatFrame.Draggable = true
    chatFrame.Active = true
    chatFrame.Selectable = true

    local titleBar = Instance.new("TextLabel", chatFrame)
    titleBar.Size = UDim2.new(1, 0, 0.1, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.Text = "Chat Viewer"
    titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleBar.Font = Enum.Font.SourceSansBold
    titleBar.TextSize = 18
    titleBar.BorderSizePixel = 0

    local closeButton = Instance.new("TextButton", chatFrame)
    closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.9, 0, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.BorderSizePixel = 0

    closeButton.MouseButton1Click:Connect(function()
        chatGui:Destroy()
    end)

    local chatBox = Instance.new("ScrollingFrame", chatFrame)
    chatBox.Size = UDim2.new(1, 0, 0.9, 0)
    chatBox.Position = UDim2.new(0, 0, 0.1, 0)
    chatBox.CanvasSize = UDim2.new(0, 0, 10, 0)
    chatBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    chatBox.BorderSizePixel = 1
    chatBox.ScrollBarThickness = 8

    local chatLayout = Instance.new("UIListLayout", chatBox)
    chatLayout.Padding = UDim.new(0, 5)
    chatLayout.SortOrder = Enum.SortOrder.LayoutOrder

    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
        local newMessage = Instance.new("TextLabel", chatBox)
        newMessage.Size = UDim2.new(1, -10, 0, 20)
        newMessage.Text = "[" .. messageData.FromSpeaker .. "]: " .. messageData.Message
        newMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
        newMessage.Font = Enum.Font.SourceSans
        newMessage.TextSize = 16
        newMessage.BackgroundTransparency = 1
        newMessage.TextXAlignment = Enum.TextXAlignment.Left

        chatBox.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y)
    end)
end

local function switchJob(job_name)
    if not table.find(available_jobs, job_name) then
        OrionLib:MakeNotification({
            Name = "Job Switch Failed",
            Content = "Invalid job name provided!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
        return
    end

    local success, error_message = pcall(function()
        game:GetService("ReplicatedStorage")["_CS.Events"].TeamChanger:FireServer(job_name)
    end)

    if success then
        current_job = job_name
        OrionLib:MakeNotification({
            Name = "Job Switch Successful",
            Content = "You are now working as a " .. job_name .. "!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    else
        OrionLib:MakeNotification({
            Name = "Job Switch Failed",
            Content = "An error occurred: " .. tostring(error_message),
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
end

ExploitsTab:AddDropdown({
    Name = "Switch Job",
    Default = "Unemployed",
    Options = available_jobs,
    Callback = function(selected_job)
        switchJob(selected_job)
    end
})

ExploitsTab:AddButton({
    Name = "Activate Immunity",
    Callback = function()
        activateImmunity()
        OrionLib:MakeNotification({
            Name = "Immunity Enabled",
            Content = "Your health will now always stay at maximum.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

ExploitsTab:AddButton({
    Name = "Show Full Chat",
    Callback = function()
        showFullChat()
        OrionLib:MakeNotification({
            Name = "Chat Viewer Enabled",
            Content = "You can now see all chat messages in a movable window.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

local TeleportTab = Window:MakeTab({
    Name = "Teleportation",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local teleportLocations = {
    ["Arway"] = CFrame.new(1729.95, -65.57, -1490.40),
    ["Pahrump"] = CFrame.new(-106.15, 9.68, 24.00),
    ["Eastdike"] = CFrame.new(2531.59, -3.83, -3601.18),
    ["Bank"] = CFrame.new(2046.01, -67.40, -1431.46),
    ["Military Base"] = CFrame.new(1867.02, -21.39, -43.00)
}

local function teleportTo(locationCFrame)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart

        game:GetService('TweenService'):Create(
            hrp,
            TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
            {CFrame = locationCFrame}
        ):Play()

        OrionLib:MakeNotification({
            Name = "Teleportation Successful",
            Content = "You have been teleported to your chosen location.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    else
        OrionLib:MakeNotification({
            Name = "Teleportation Failed",
            Content = "HumanoidRootPart not found. Ensure your character has fully loaded.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
end

for locationName, cframe in pairs(teleportLocations) do
    TeleportTab:AddButton({
        Name = locationName,
        Callback = function()
            teleportTo(cframe)
        end
    })
end


OrionLib:Init()




