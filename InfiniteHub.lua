-- Check if Orion Library is available
if not game:IsLoaded() then game.Loaded:Wait() end
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Create the main GUI window
local Window = OrionLib:MakeWindow({
    Name = "Infinity Hub - Enhanced Edition",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "InfinityHubConfig",
    IntroText = "Welcome to Infinity Hub!",
    Theme = {
        MainColor = Color3.fromRGB(40, 40, 40),
        AccentColor = Color3.fromRGB(85, 170, 255),
        BackgroundColor = Color3.fromRGB(30, 30, 30),
        BorderColor = Color3.fromRGB(50, 50, 50)
    }
})

-- Tabs for the GUI
local HomeTab = Window:MakeTab({
    Name = "Home",
    Icon = "rbxassetid://6031068420", -- Home icon
    PremiumOnly = false
})

local ScriptsTab = Window:MakeTab({
    Name = "Scripts",
    Icon = "rbxassetid://6031071053", -- Script icon
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://6031280882", -- Settings gear icon
    PremiumOnly = false
})

-- 🏠 Home Tab Content
HomeTab:AddLabel("Welcome to Infinity Hub")
HomeTab:AddLabel("Username: " .. game.Players.LocalPlayer.Name)
HomeTab:AddLabel("UserID: " .. game.Players.LocalPlayer.UserId)
HomeTab:AddParagraph("Welcome to Infinity Hub!", "Navigate through the tabs to explore features and options.")

-- 📜 Scripts Tab Content
local gamePlaceId = game.PlaceId
local scripts = {
    [16732694052] = { -- Fisch Game ID
        {name = "Blackhub", callback = function()
            print("Executing Blackhub script...")
            getgenv().key = "Nexsie"
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Skibidiking123/Fisch1/refs/heads/main/FischMain"))()
        end},
        {name = "Ronix Hub", callback = function()
            print("Executing Ronix Hub script...")
            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/2d99ecf0d551e181ff393dc36c46de6a.lua"))()
        end}
    },

    [537413528] = { -- Build A Boat for Treasure (BABFT) Game ID
        {name = "BABFT Script", callback = function()
            print("Attempting to load Build A Boat script...")
            local success, err = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/TheRealAsu/BABFT/refs/heads/main/Source.lua'))()
            end)
            if not success then
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Failed to load Build A Boat script: " .. err,
                    Image = "rbxassetid://6031280882", -- Warning icon
                    Time = 5
                })
            else
                OrionLib:MakeNotification({
                    Name = "Success",
                    Content = "Build A Boat script loaded successfully!",
                    Image = "rbxassetid://6031071053", -- Script icon
                    Time = 5
                })
            end
        end}
    },

    [10450270085] = { -- Jujutsu Infinite
        {name = "Blackhub", callback = function()
            print("Executing Jujutsu Infinite with key...")
            getgenv().key = "Nexsie"
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Skibidiking123/JujutsuInfinite/refs/heads/main/Main"))()
        end},
        {name = "Prime Hub", callback = function()
            print("Executing secondary Jujutsu Infinite script...")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Mixplaylikeencoder/Games/refs/heads/main/JJI"))()
        end}
    },

    [2753915549] = { -- Blox Fruits
        {name = "Kncrypt Script", callback = function()
            print("Executing Blox Fruits script...")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/Kncrypt/refs/heads/main/sources/BloxFruit.lua"))()
        end}
    }
}

if scripts[gamePlaceId] then
    ScriptsTab:AddLabel("Game Detected: " .. gamePlaceId)
    for _, scriptInfo in ipairs(scripts[gamePlaceId]) do
        ScriptsTab:AddButton({
            Name = scriptInfo.name,
            Callback = scriptInfo.callback
        })
    end
else
    ScriptsTab:AddLabel("This game is not supported yet.")
    ScriptsTab:AddParagraph("Suggestion", "Check back soon! We're always adding new supported games.")
end

-- ⚙️ Settings Tab Content
SettingsTab:AddDropdown({
    Name = "Theme Selector",
    Options = {"Dark", "Light", "Aqua", "Blood", "Custom"},
    Default = "Dark",
    Callback = function(selectedTheme)
        local themes = {
            Dark = {
                MainColor = Color3.fromRGB(40, 40, 40),
                TextColor = Color3.fromRGB(255, 255, 255),
                ButtonColor = Color3.fromRGB(50, 50, 50)
            },
            Light = {
                MainColor = Color3.fromRGB(240, 240, 240),
                TextColor = Color3.fromRGB(0, 0, 0),
                ButtonColor = Color3.fromRGB(200, 200, 200)
            },
            Aqua = {
                MainColor = Color3.fromRGB(0, 128, 255),
                TextColor = Color3.fromRGB(255, 255, 255),
                ButtonColor = Color3.fromRGB(0, 102, 204)
            },
            Blood = {
                MainColor = Color3.fromRGB(128, 0, 0),
                TextColor = Color3.fromRGB(255, 255, 255),
                ButtonColor = Color3.fromRGB(102, 0, 0)
            },
            Custom = {
                MainColor = Color3.fromRGB(50, 50, 50),
                TextColor = Color3.fromRGB(255, 200, 100),
                ButtonColor = Color3.fromRGB(70, 70, 70)
            }
        }
        OrionLib:SetTheme(themes[selectedTheme])
        OrionLib:MakeNotification({
            Name = "Theme Changed",
            Content = "The theme has been updated to " .. selectedTheme .. ".",
            Image = "rbxassetid://6031072540", -- Paintbrush icon
            Time = 5
        })
    end
})

SettingsTab:AddSlider({
    Name = "Animation Speed",
    Min = 1,
    Max = 5,
    Default = 3,
    Callback = function(value)
        OrionLib:MakeNotification({
            Name = "Animation Speed Updated",
            Content = "Speed set to: " .. value,
            Image = "rbxassetid://6031071053", -- Script icon
            Time = 5
        })
    end
})

SettingsTab:AddButton({
    Name = "Reset Settings",
    Callback = function()
        OrionLib:ResetConfig()
        OrionLib:MakeNotification({
            Name = "Reset Complete",
            Content = "Settings have been reset to default values.",
            Image = "rbxassetid://6031280882", -- Reset icon
            Time = 5
        })
    end
})

SettingsTab:AddParagraph("Tips", "Customize your experience with themes and settings!")

-- Initialize the GUI
OrionLib:Init()

