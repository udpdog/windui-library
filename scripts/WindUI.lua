-- ============================================================
-- THUNDERWARE — v1.3.1 TEST
-- Made by ethone
-- ============================================================

-- ============================================================
-- SHARED SERVICES & STATE
-- ============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local HttpRequest = (syn and syn.request) or http_request or request

local ExecuteEvent = ReplicatedStorage
    :WaitForChild("Code")
    :WaitForChild("rbxts_include")
    :WaitForChild("node_modules")
    :WaitForChild("@rbxts")
    :WaitForChild("centurion")
    :WaitForChild("out")
    :WaitForChild("shared")
    :WaitForChild("remotes")
    :WaitForChild("Execute")

local ALERT_SOUND_ID = "rbxassetid://6026984224"
local WEBHOOK_URL = "https://discord.com/api/webhooks/1541296145781751808/uwecaHLDzLjhvVa9fz3fx-Oy8z-RE9MMN-9D8VwvO5dAVuZ_V5bd1Pwgi5_J39kdP2Mx"

-- État partagé pour le tab Player
local SelectedPlayer = nil
local PunishmentReason = ""
local BanDuration = ""

-- ============================================================
-- UI STARLIGHT
-- ============================================================

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

local Window = Starlight:CreateWindow({
    Name = "Thunderware",
    Subtitle = "v1.3.1 TEST",
    Icon = 72189436754877,
    LoadingSettings = {
        Title = "Thunderware",
        Subtitle = "Made with ❤ by ethone",
    },
    FileSettings = {
        ConfigFolder = "Thunderware"
    },
})

local UniversalTabSection = Window:CreateTabSection("Private Server")

-- ============================================================
-- TAB : PLAYER
-- ============================================================

local PlayerTab = UniversalTabSection:CreateTab({
    Name = "Player",
    Icon = NebulaIcons:GetIcon('users', 'Lucide'),
    Columns = 2,
}, "PLAYER_TAB")

local ExternalGroupbox = PlayerTab:CreateGroupbox({
    Name = "External Scripts",
    Column = 2,
}, "EXTERNAL_GROUPBOX")

local PlayerGroupbox = PlayerTab:CreateGroupbox({
    Name = "Player",
    Column = 1,
}, "PLAYER_GROUPBOX")

local AllPlayerGroupbox = PlayerTab:CreateGroupbox({
    Name = "All Player",
    Column = 2,
}, "ALL_PLAYER_GROUPBOX")

-- External Scripts ---------------------------------------------------------

ExternalGroupbox:CreateButton({
    Name = "Account Age Lookup",
    Icon = NebulaIcons:GetIcon('search-check', 'Lucide'),
    Callback = function()
        Starlight:Notification({
            Title = "Thunderware",
            Icon = NebulaIcons:GetIcon('sparkle', 'Material'),
            Content = "Press N to toggle the Account Age Lookup UI.",
        }, "ACCOUNT_AGE_NOTIF")
        loadstring(game:HttpGet("https://git.lbxmb.fr/sexyfurry1337/xx/raw/branch/main/aal.lua"))()
    end,
}, "ACCOUNT_AGE_BUTTON")

-- Player list + dropdown ---------------------------------------------------

local PlayerLabel = PlayerGroupbox:CreateLabel({
    Name = "Player list"
}, "PLAYER_LABEL")

PlayerLabel:AddDropdown({
    Options = {},
    CurrentOptions = {},
    Placeholder = "Select a player",
    Special = 1,
    MultipleOptions = false,
    Callback = function(Options)
        local selectedName = Options and Options[1]
        SelectedPlayer = selectedName and Players:FindFirstChild(selectedName)
        if SelectedPlayer then
            Starlight:Notification({
                Title = "Thunderware",
                Icon = NebulaIcons:GetIcon("sparkle", "Material"),
                Content = "Selected player: " .. SelectedPlayer.Name,
            }, "PLAYER_SELECTED_NOTIFICATION")
        end
    end,
}, "PLAYER_DROPDOWN")

-- Helpers ------------------------------------------------------------------

local function NotifyError(Content, Id)
    Starlight:Notification({
        Title = "Thunderware",
        Icon = NebulaIcons:GetIcon("error", "Material"),
        Content = Content,
    }, Id .. tostring(os.clock()))
end

local function NotifySuccess(Content, Id)
    Starlight:Notification({
        Title = "Thunderware",
        Icon = NebulaIcons:GetIcon("check", "Material"),
        Content = Content,
    }, Id .. tostring(os.clock()))
end

local function RequireSelectedPlayer(NotificationId)
    if not SelectedPlayer or not SelectedPlayer.Parent then
        NotifyError("Please select a valid player.", NotificationId)
        return nil
    end
    return SelectedPlayer
end

local function InvokeExecute(Command, Arguments)
    return pcall(function()
        return ExecuteEvent:InvokeServer(Command, Arguments)
    end)
end

-- Player buttons -----------------------------------------------------------

PlayerGroupbox:CreateButton({
    Name = "To Player",
    Icon = NebulaIcons:GetIcon("navigation", "Lucide"),
    Callback = function()
        local Target = RequireSelectedPlayer("TELEPORT_NO_PLAYER")
        if not Target then return end
        local Success, Result = InvokeExecute("to/player", { Target.Name })
        if not Success then
            warn("To Player failed:", Result)
            NotifyError("Failed to teleport to the player.", "TELEPORT_ERROR")
        end
    end,
}, "TO_PLAYER_BUTTON")

PlayerGroupbox:CreateButton({
    Name = "Bring Player",
    Icon = NebulaIcons:GetIcon("user-round-plus", "Lucide"),
    Callback = function()
        local Target = RequireSelectedPlayer("BRING_NO_PLAYER")
        if not Target then return end
        local Success, Result = InvokeExecute("bring", { Target.Name })
        if not Success then
            warn("Bring Player failed:", Result)
            NotifyError("Failed to bring the selected player.", "BRING_ERROR")
        end
    end,
}, "BRING_PLAYER_BUTTON")

PlayerGroupbox:CreateButton({
    Name = "Watch Player",
    Icon = NebulaIcons:GetIcon("eye", "Lucide"),
    Callback = function()
        local Target = RequireSelectedPlayer("WATCH_NO_PLAYER")
        if not Target then return end
        local Success, Result = InvokeExecute("watch", { Target.Name })
        if not Success then
            warn("Watch Player failed:", Result)
            NotifyError("Failed to watch the selected player.", "WATCH_ERROR")
        end
    end,
}, "WATCH_PLAYER_BUTTON")

PlayerGroupbox:CreateButton({
    Name = "Unwatch",
    Icon = NebulaIcons:GetIcon("eye-off", "Lucide"),
    Callback = function()
        local Success, Result = InvokeExecute("watch", { LocalPlayer.Name })
        if not Success then
            warn("Unwatch failed:", Result)
            NotifyError("Failed to stop watching the player.", "UNWATCH_ERROR")
        end
    end,
}, "UNWATCH_PLAYER_BUTTON")

PlayerGroupbox:CreateButton({
    Name = "Exit Car Player",
    Icon = NebulaIcons:GetIcon("car-front", "Lucide"),
    Callback = function()
        local Target = RequireSelectedPlayer("EXIT_CAR_NO_PLAYER")
        if not Target then return end
        local Success, Result = pcall(function()
            ExecuteEvent:InvokeServer("freeze", { Target.Name })
            ExecuteEvent:InvokeServer("unfreeze", { Target.Name })
        end)
        if not Success then
            warn("Exit Car Player failed:", Result)
            NotifyError("Failed to remove the player from their vehicle.", "EXIT_CAR_ERROR")
        end
    end,
}, "EXIT_CAR_PLAYER_BUTTON")

-- Reason + duration inputs -------------------------------------------------

PlayerGroupbox:CreateInput({
    Name = "Kick or Ban Reason",
    Icon = NebulaIcons:GetIcon("text-cursor-input", "Lucide"),
    CurrentValue = "",
    PlaceholderText = "Example: Exploiting",
    Callback = function(Text)
        PunishmentReason = tostring(Text or ""):match("^%s*(.-)%s*$")
    end,
}, "PUNISHMENT_REASON_INPUT")

PlayerGroupbox:CreateInput({
    Name = "Ban Duration",
    Icon = NebulaIcons:GetIcon("clock", "Lucide"),
    CurrentValue = "",
    PlaceholderText = "2s, 2m, 2h, 2d, 2w, 2mo, 2y or perm",
    Callback = function(Text)
        BanDuration = tostring(Text or ""):lower():match("^%s*(.-)%s*$")
    end,
}, "BAN_DURATION_INPUT")

-- Kick / Ban ---------------------------------------------------------------

PlayerGroupbox:CreateButton({
    Name = "Kick Player",
    Icon = NebulaIcons:GetIcon("user-x", "Lucide"),
    Callback = function()
        local Target = RequireSelectedPlayer("KICK_NO_PLAYER")
        if not Target then return end
        if PunishmentReason == "" then
            NotifyError("Please enter a kick reason.", "KICK_NO_REASON")
            return
        end
        local Success, Result = InvokeExecute("server/kick", { Target.Name, PunishmentReason })
        if not Success then
            warn("Kick Player failed:", Result)
            NotifyError("Failed to kick the selected player.", "KICK_ERROR")
            return
        end
        NotifySuccess(Target.Name .. " has been kicked.", "KICK_SUCCESS")
    end,
}, "KICK_PLAYER_BUTTON")

PlayerGroupbox:CreateButton({
    Name = "Ban Player",
    Icon = NebulaIcons:GetIcon("ban", "Lucide"),
    Callback = function()
        local Target = RequireSelectedPlayer("BAN_NO_PLAYER")
        if not Target then return end

        local validDuration = BanDuration == "perm"
        if not validDuration then
            local amount, unit = BanDuration:match("^(%d+)(%a+)$")
            local validUnits = { s = true, m = true, h = true, d = true, w = true, mo = true, y = true }
            validDuration = amount ~= nil
                and tonumber(amount) > 0
                and validUnits[unit] == true
        end
        if not validDuration then
            NotifyError("Invalid duration. Use 2s, 2m, 2h, 2d, 2w, 2mo, 2y or perm.", "BAN_INVALID_DURATION")
            return
        end

        if PunishmentReason == "" then
            NotifyError("Please enter a ban reason.", "BAN_NO_REASON")
            return
        end

        local PlayerId = tostring(Target.UserId)
        local PlayerName = Target.Name
        local DisplayDuration = BanDuration == "perm" and "définitivement" or "pendant " .. BanDuration
        local KickMessage = "Vous avez été banni " .. DisplayDuration .. " pour " .. PunishmentReason

        local kickSuccess, kickError = pcall(function()
            return ExecuteEvent:InvokeServer("server/kick", { PlayerName, KickMessage })
        end)
        if not kickSuccess then
            warn("Kick failed:", kickError)
        end

        local banSuccess, banError = pcall(function()
            return ExecuteEvent:InvokeServer("server/ban/id", { PlayerId, BanDuration })
        end)
        if not banSuccess then
            warn("Ban failed:", banError)
            NotifyError("Failed to ban " .. PlayerName .. ".", "BAN_ERROR")
            return
        end

        NotifySuccess(PlayerName .. " has been banned for " .. BanDuration .. ".", "BAN_SUCCESS")
    end,
}, "BAN_PLAYER_BUTTON")

-- All Player ---------------------------------------------------------------

AllPlayerGroupbox:CreateButton({
    Name = "Freeze All",
    Icon = NebulaIcons:GetIcon("snowflake", "Lucide"),
    Callback = function()
        local frozenCount = 0
        for _, player in ipairs(Players:GetPlayers()) do
            local success, result = InvokeExecute("freeze", { player.Name })
            if success then
                frozenCount += 1
            else
                warn("Failed to freeze " .. player.Name .. ":", result)
            end
        end
        NotifySuccess("Froze " .. frozenCount .. " player(s).", "FREEZE_ALL")
    end,
}, "FREEZE_ALL_BUTTON")

AllPlayerGroupbox:CreateButton({
    Name = "Unfreeze All",
    Icon = NebulaIcons:GetIcon("sun", "Lucide"),
    Callback = function()
        local unfrozenCount = 0
        for _, player in ipairs(Players:GetPlayers()) do
            local success, result = InvokeExecute("unfreeze", { player.Name })
            if success then
                unfrozenCount += 1
            else
                warn("Failed to unfreeze " .. player.Name .. ":", result)
            end
        end
        NotifySuccess("Unfroze " .. unfrozenCount .. " player(s).", "UNFREEZE_ALL")
    end,
}, "UNFREEZE_ALL_BUTTON")

-- ============================================================
-- TAB : LOCAL PLAYER
-- ============================================================

local LocalPlayerTab = UniversalTabSection:CreateTab({
    Name = "Local Player",
    Icon = NebulaIcons:GetIcon("user-round", "Lucide"),
    Columns = 1,
}, "LOCAL_PLAYER_TAB")

local StaminaGroupbox = LocalPlayerTab:CreateGroupbox({
    Name = "Stamina",
    Column = 1,
}, "STAMINA_GROUPBOX")

local LocalActionsGroupbox = LocalPlayerTab:CreateGroupbox({
    Name = "Player",
    Column = 1,
}, "LOCAL_ACTIONS_GROUPBOX")

-- Infinite Stamina ---------------------------------------------------------

do
    StaminaGroupbox:CreateButton({
        Name = "Infinite Stamina",
        Icon = NebulaIcons:GetIcon("zap", "Lucide"),
        Callback = function()
            -- Reapply the supplied script on every click.
            local success, failure = pcall(function()
                local controllerModule = nil
                for _, descendant in ipairs(game:GetDescendants()) do
                    if descendant:IsA("ModuleScript") and descendant.Name == "characterStaminaController" then
                        controllerModule = descendant
                        break
                    end
                end

                if not controllerModule then
                    error("Module characterStaminaController not found.", 0)
                end

                local loaded, module = pcall(require, controllerModule)
                if not loaded then
                    error("Failed to require " .. controllerModule:GetFullName() .. ": " .. tostring(module), 0)
                end
                if not module or not module.CharacterStaminaController then
                    error("Module does not export CharacterStaminaController.", 0)
                end

                local class = module.CharacterStaminaController
                class.useStamina = function(self, amount)
                    return true
                end
                class.giveStamina = function(self, amount)
                    self.stamina = 1
                end
                class.onTick = function(self, dt)
                    self.stamina = 1
                end
                class.setStamina = function(self, value)
                    self.stamina = 1
                end
            end)

            if not success then
                warn("[Thunderware] Infinite Stamina failed: " .. tostring(failure))
                NotifyError(tostring(failure), "STAMINA_FAIL")
                return
            end

            NotifySuccess("Infinite Stamina patch applied.", "STAMINA_ON")
        end,
    }, "INFINITE_STAMINA_BUTTON")
end

-- Revive Myself ------------------------------------------------------------

LocalActionsGroupbox:CreateButton({
    Name = "Revive Myself",
    Icon = NebulaIcons:GetIcon("heart-pulse", "Lucide"),
    Callback = function()
        local Success, Result = InvokeExecute("health", { LocalPlayer.Name, "125" })
        if not Success then
            warn("[Thunderware] Revive Myself failed:", Result)
            NotifyError("Failed to revive.", "REVIVE_ERROR")
            return
        end
        NotifySuccess("Revive sent.", "REVIVE_SUCCESS")
    end,
}, "REVIVE_MYSELF_BUTTON")

-- ============================================================
-- TAB : VISUAL
-- ============================================================

local VisualTab = UniversalTabSection:CreateTab({
    Name = "Visual",
    Icon = NebulaIcons:GetIcon("eye", "Lucide"),
    Columns = 1,
}, "VISUAL_TAB")

local VisualGroupbox = VisualTab:CreateGroupbox({
    Name = "Lighting",
    Column = 1,
}, "VISUAL_GROUPBOX")

VisualGroupbox:CreateButton({
    Name = "Remove Atmosphere",
    Icon = NebulaIcons:GetIcon("cloud-off", "Lucide"),
    Callback = function()
        local Removed = 0
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Atmosphere") then
                child:Destroy()
                Removed += 1
            end
        end

        -- Au cas où l'Atmosphere serait dans un autre dossier.
        local WorkspaceAtmosphere = workspace:FindFirstChildOfClass("Atmosphere")
        if WorkspaceAtmosphere then
            WorkspaceAtmosphere:Destroy()
            Removed += 1
        end

        if Removed > 0 then
            NotifySuccess("Atmosphere removed (" .. Removed .. ").", "ATMOSPHERE_REMOVED")
        else
            NotifyError("No Atmosphere found.", "ATMOSPHERE_NOT_FOUND")
        end
    end,
}, "REMOVE_ATMOSPHERE_BUTTON")

-- ============================================================
-- TAB : ANTI-CHEAT
-- ============================================================

local AntiCheatTab = UniversalTabSection:CreateTab({
    Name = "Anti-Cheat",
    Icon = NebulaIcons:GetIcon("shield-check", "Lucide"),
    Columns = 1,
}, "ANTICHEAT_TAB")

local AntiCheatGroupbox = AntiCheatTab:CreateGroupbox({
    Name = "Detection Modules",
    Column = 1,
}, "ANTICHEAT_GROUPBOX")

_G.ThrowableDetectorEnabled = true
_G.VehicleFlyDetectionEnabled = true

_G.__FlyDetectionCounts = _G.__FlyDetectionCounts or {}
_G.__FlyAlertShown = _G.__FlyAlertShown or {}

AntiCheatGroupbox:CreateToggle({
    Name = "Car Fly Detection",
    Icon = NebulaIcons:GetIcon("car", "Lucide"),
    CurrentValue = true,
    Callback = function(Value)
        _G.VehicleFlyDetectionEnabled = Value

        if _G.__FlyDetectionCounts then
            for key in pairs(_G.__FlyDetectionCounts) do
                _G.__FlyDetectionCounts[key] = 0
            end
        end
        if _G.__FlyAlertShown then
            for key in pairs(_G.__FlyAlertShown) do
                _G.__FlyAlertShown[key] = false
            end
        end

        Starlight:Notification({
            Title = "Anti-Cheat",
            Icon = NebulaIcons:GetIcon(Value and "check" or "x", "Material"),
            Content = "Car Fly Detection " .. (Value and "enabled." or "disabled."),
        }, "CAR_FLY_TOGGLE_" .. tostring(os.clock()))
    end,
}, "CAR_FLY_TOGGLE")

AntiCheatGroupbox:CreateToggle({
    Name = "Raid Detection",
    Icon = NebulaIcons:GetIcon("bomb", "Lucide"),
    CurrentValue = true,
    Callback = function(Value)
        _G.ThrowableDetectorEnabled = Value

        Starlight:Notification({
            Title = "Anti-Cheat",
            Icon = NebulaIcons:GetIcon(Value and "check" or "x", "Material"),
            Content = "Raid Detection " .. (Value and "enabled." or "disabled."),
        }, "RAID_TOGGLE_" .. tostring(os.clock()))
    end,
}, "RAID_TOGGLE")

-- ============================================================
-- ANTI-CHEAT : THROWABLES (Bomb / Grenade)
-- ============================================================

_G.ThrowableRaidWebhookSent = _G.ThrowableRaidWebhookSent or {}

local MAX_ALERTS = 5
local ALERT_DURATION = 60

local ThrowablesFolder = workspace:WaitForChild("Objects"):WaitForChild("Throwables")
local BombFolder = ThrowablesFolder:WaitForChild("Bomb")
local GrenadeFolder = ThrowablesFolder:WaitForChild("Grenade")

do
    local ExistingCoreGui = CoreGui:FindFirstChild("ThunderwareThrowableAlerts")
    local ExistingPlayerGui = PlayerGui:FindFirstChild("ThunderwareThrowableAlerts")
    if ExistingCoreGui then ExistingCoreGui:Destroy() end
    if ExistingPlayerGui then ExistingPlayerGui:Destroy() end
end

local ThrowableAlertGui = Instance.new("ScreenGui")
ThrowableAlertGui.Name = "ThunderwareThrowableAlerts"
ThrowableAlertGui.ResetOnSpawn = false
ThrowableAlertGui.IgnoreGuiInset = true
ThrowableAlertGui.DisplayOrder = 999999

if not pcall(function() ThrowableAlertGui.Parent = CoreGui end) then
    ThrowableAlertGui.Parent = PlayerGui
end

local ThrowableAlertContainer = Instance.new("Frame")
ThrowableAlertContainer.Name = "AlertContainer"
ThrowableAlertContainer.Size = UDim2.new(0, 500, 1, -20)
ThrowableAlertContainer.Position = UDim2.new(0.5, -250, 0, 20)
ThrowableAlertContainer.BackgroundTransparency = 1
ThrowableAlertContainer.Parent = ThrowableAlertGui

local ThrowableAlertLayout = Instance.new("UIListLayout")
ThrowableAlertLayout.FillDirection = Enum.FillDirection.Vertical
ThrowableAlertLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ThrowableAlertLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ThrowableAlertLayout.SortOrder = Enum.SortOrder.LayoutOrder
ThrowableAlertLayout.Padding = UDim.new(0, 10)
ThrowableAlertLayout.Parent = ThrowableAlertContainer

local AlertSoundTemplate = Instance.new("Sound")
AlertSoundTemplate.Name = "ThrowableAlertSound"
AlertSoundTemplate.SoundId = ALERT_SOUND_ID
AlertSoundTemplate.Volume = 1

local function PlayAlertSound()
    local Sound = AlertSoundTemplate:Clone()
    Sound.Parent = SoundService
    Sound:Play()
    Sound.Ended:Connect(function() Sound:Destroy() end)
    task.delay(10, function()
        if Sound and Sound.Parent then Sound:Destroy() end
    end)
end

local function CreateAlertButton(Parent, Name, Color, Callback)
    local Button = Instance.new("TextButton")
    Button.Name = Name .. "Button"
    Button.Size = UDim2.new(0, 88, 0, 30)
    Button.BackgroundColor3 = Color
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Active = false
    Button.Font = Enum.Font.GothamBold
    Button.Text = Name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextTransparency = 0.35
    Button.TextSize = 11
    Button.Parent = Parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local CanClick = false
    task.delay(0.75, function()
        if Button and Button.Parent then
            CanClick = true
            Button.Active = true
            Button.AutoButtonColor = true
            Button.TextTransparency = 0
        end
    end)

    Button.Activated:Connect(function()
        if CanClick then Callback() end
    end)

    return Button
end

local function GetCurrentThrowableAlerts()
    local Alerts = {}
    for _, Object in ipairs(ThrowableAlertContainer:GetChildren()) do
        if Object:IsA("Frame") and Object.Name == "ThrowableAlert" then
            table.insert(Alerts, Object)
        end
    end
    table.sort(Alerts, function(A, B) return A.LayoutOrder < B.LayoutOrder end)
    return Alerts
end

local ThrowableAlertCounter = 0

local function SendRaidWebhook(Player, ThrowableName)
    if not Player or not HttpRequest then return end
    if WEBHOOK_URL == "PUT_YOUR_RAID_WEBHOOK_HERE" then
        warn("[RAID WEBHOOK] Configure WEBHOOK_URL.")
        return
    end
    if _G.ThrowableRaidWebhookSent[Player.UserId] then return end
    _G.ThrowableRaidWebhookSent[Player.UserId] = true

    local ProfileUrl = "https://www.roblox.com/users/" .. Player.UserId .. "/profile"
    local AvatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Player.UserId .. "&width=420&height=420&format=png"

    local Payload = {
        embeds = {{
            title = "Raid détecté - " .. ThrowableName,
            url = ProfileUrl,
            color = 15158332,
            description = "**" .. Player.DisplayName .. "** (@" .. Player.Name .. ") a été banni manuellement.",
            thumbnail = {url = AvatarUrl},
            fields = {
                {name = "Utilisateur", value = "[" .. Player.DisplayName .. " (@" .. Player.Name .. ")] (" .. ProfileUrl .. ")", inline = false},
                {name = "User ID", value = "`" .. Player.UserId .. "`", inline = true},
                {name = "Objet détecté", value = ThrowableName, inline = true},
                {name = "Durée", value = "Permanent", inline = true},
                {name = "Raison", value = "Anti-Cheat : raid détecté", inline = false},
                {name = "Serveur", value = "Place ID : `" .. game.PlaceId .. "`\nJob ID : `" .. game.JobId .. "`", inline = false}
            },
            footer = {text = "Thunderware - Raid Anti-Cheat"},
            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    local Success, Result = pcall(function()
        return HttpRequest({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(Payload)
        })
    end)
    if not Success then
        _G.ThrowableRaidWebhookSent[Player.UserId] = nil
        warn("[RAID WEBHOOK ERROR]", Result)
    end
end

local function BanRaidPlayer(PlayerName, ThrowableName)
    local Player = Players:FindFirstChild(PlayerName:gsub("^@", ""))
    if not Player then
        NotifyError("Player not found; ban cancelled.", "RAID_BAN_NO_PLAYER")
        return false
    end

    local PlayerId = tostring(Player.UserId)
    local KickMessage = "Vous avez été banni définitivement pour Raid Anti-Cheat : raid détecté"

    local KickSuccess, KickResult = pcall(function()
        return ExecuteEvent:InvokeServer("server/kick", { Player.Name, KickMessage })
    end)
    if not KickSuccess then
        warn("[RAID KICK ERROR]", Player.Name, KickResult)
    end

    local BanSuccess, BanResult = pcall(function()
        return ExecuteEvent:InvokeServer("server/ban/id", { PlayerId, "perm" })
    end)
    if not BanSuccess then
        warn("[RAID BAN ERROR]", Player.Name, BanResult)
        NotifyError("Failed to ban " .. Player.Name .. ".", "RAID_BAN_ERROR")
        return false
    end

    task.spawn(SendRaidWebhook, Player, ThrowableName)
    NotifySuccess(Player.Name .. " has been permanently banned.", "RAID_BAN_SUCCESS")
    return true
end

local function ShowThrowableScreenAlert(PlayerName, ThrowableName)
    local CommandPlayerName = PlayerName:gsub("^@", "")
    local CurrentAlerts = GetCurrentThrowableAlerts()

    while #CurrentAlerts >= MAX_ALERTS do
        CurrentAlerts[1]:Destroy()
        table.remove(CurrentAlerts, 1)
    end

    ThrowableAlertCounter += 1

    local Alert = Instance.new("Frame")
    Alert.Name = "ThrowableAlert"
    Alert.Size = UDim2.new(1, 0, 0, 105)
    Alert.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Alert.BorderSizePixel = 0
    Alert.LayoutOrder = ThrowableAlertCounter
    Alert.Parent = ThrowableAlertContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Alert

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = ThrowableName == "Bomb"
        and Color3.fromRGB(255, 70, 70)
        or Color3.fromRGB(255, 170, 50)
    Stroke.Thickness = 2
    Stroke.Parent = Alert

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚠ " .. string.upper(ThrowableName) .. " DETECTED"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 17
    Title.Parent = Alert

    local Content = Instance.new("TextLabel")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 0, 24)
    Content.Position = UDim2.new(0, 10, 0, 34)
    Content.BackgroundTransparency = 1
    Content.Font = Enum.Font.Gotham
    Content.Text = PlayerName .. " is using a " .. ThrowableName:lower() .. "!"
    Content.TextColor3 = Color3.fromRGB(210, 210, 215)
    Content.TextSize = 14
    Content.Parent = Alert

    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Name = "Buttons"
    ButtonContainer.Size = UDim2.new(1, -20, 0, 30)
    ButtonContainer.Position = UDim2.new(0, 10, 1, -38)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = Alert

    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ButtonLayout.Padding = UDim.new(0, 8)
    ButtonLayout.Parent = ButtonContainer

    CreateAlertButton(ButtonContainer, "OK", Color3.fromRGB(65, 65, 75), function()
        Alert:Destroy()
    end)

    CreateAlertButton(ButtonContainer, "TP", Color3.fromRGB(40, 120, 220), function()
        InvokeExecute("to/player", { CommandPlayerName })
    end)

    local IsFrozen = false
    local FreezeButton
    FreezeButton = CreateAlertButton(ButtonContainer, "FREEZE", Color3.fromRGB(60, 160, 220), function()
        if IsFrozen then
            local Success = InvokeExecute("unfreeze", { CommandPlayerName })
            if Success then
                IsFrozen = false
                FreezeButton.Text = "FREEZE"
                FreezeButton.BackgroundColor3 = Color3.fromRGB(60, 160, 220)
            end
        else
            local Success = InvokeExecute("freeze", { CommandPlayerName })
            if Success then
                IsFrozen = true
                FreezeButton.Text = "UNFREEZE"
                FreezeButton.BackgroundColor3 = Color3.fromRGB(220, 120, 50)
            end
        end
    end)

    local IsWatching = false
    local WatchButton
    WatchButton = CreateAlertButton(ButtonContainer, "WATCH", Color3.fromRGB(145, 75, 220), function()
        if IsWatching then
            local Success = InvokeExecute("watch", { LocalPlayer.Name })
            if Success then
                IsWatching = false
                WatchButton.Text = "WATCH"
                WatchButton.BackgroundColor3 = Color3.fromRGB(145, 75, 220)
            end
        else
            local Success = InvokeExecute("watch", { CommandPlayerName })
            if Success then
                IsWatching = true
                WatchButton.Text = "UNWATCH"
                WatchButton.BackgroundColor3 = Color3.fromRGB(210, 70, 150)
            end
        end
    end)

    local BanClicked = false
    CreateAlertButton(ButtonContainer, "BAN", Color3.fromRGB(190, 45, 45), function()
        if BanClicked then return end
        BanClicked = true
        if BanRaidPlayer(CommandPlayerName, ThrowableName) then
            Alert:Destroy()
        else
            BanClicked = false
        end
    end)

    PlayAlertSound()

    task.delay(ALERT_DURATION, function()
        if Alert and Alert.Parent then Alert:Destroy() end
    end)
end

local function DetectThrowable(NewObject, ThrowableName)
    if not _G.ThrowableDetectorEnabled then return end
    local PlayerName = NewObject.Name

    Starlight:Notification({
        Title = ThrowableName .. " Detected",
        Icon = NebulaIcons:GetIcon(
            ThrowableName == "Bomb" and "bomb" or "circle-alert",
            "Lucide"
        ),
        Content = PlayerName .. " is using a " .. ThrowableName:lower() .. "!",
    }, "THROWABLE_" .. tostring(os.clock()))

    ShowThrowableScreenAlert(PlayerName, ThrowableName)
end

BombFolder.ChildAdded:Connect(function(NewBomb)
    DetectThrowable(NewBomb, "Bomb")
end)

GrenadeFolder.ChildAdded:Connect(function(NewGrenade)
    DetectThrowable(NewGrenade, "Grenade")
end)

-- ============================================================
-- ANTI-CHEAT : VEHICLE FLY
-- ============================================================

local MAX_GROUND_DISTANCE = 5
local MAX_FLY_DETECTIONS = 10
local MAX_FLY_ALERTS = 5
local MAX_DETECTION_DISTANCE = 1500
local MAX_VALID_TILT = 55

local VehiclesFolder = workspace:WaitForChild("Vehicles")

if _G.VehicleFlyDetectionConnection then _G.VehicleFlyDetectionConnection:Disconnect() end
if _G.VehicleAddedConnection then _G.VehicleAddedConnection:Disconnect() end
if _G.VehiclePlayerRemovingConnection then _G.VehiclePlayerRemovingConnection:Disconnect() end
if _G.VehicleFlyAlertGui then _G.VehicleFlyAlertGui:Destroy() end

_G.VehicleFlyWebhookSent = _G.VehicleFlyWebhookSent or {}

_G.__FlyDetectionCounts = _G.__FlyDetectionCounts or {}
_G.__FlyAlertShown = _G.__FlyAlertShown or {}

local FlyDetectionCounts = _G.__FlyDetectionCounts
local FlyAlertShown = _G.__FlyAlertShown

local FlyBanReasons = {
    "Nice RP Anti-Cheat : Fly détecté.",
    "Nice RP Anti-Cheat : déplacement de véhicule invalide.",
    "Nice RP Anti-Cheat : Car fly détecté."
}

local function GetRandomBanReason()
    return FlyBanReasons[math.random(1, #FlyBanReasons)]
end

local function GetVehicleParts(Vehicle)
    local Parts = {}
    if Vehicle:IsA("BasePart") then table.insert(Parts, Vehicle) end
    for _, Object in ipairs(Vehicle:GetDescendants()) do
        if Object:IsA("BasePart") then table.insert(Parts, Object) end
    end
    return Parts
end

local function GetVehicleRoot(Vehicle, Parts)
    if Vehicle:IsA("Model") and Vehicle.PrimaryPart then
        return Vehicle.PrimaryPart
    end
    return Vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
        or Vehicle:FindFirstChild("Chassis", true)
        or Vehicle:FindFirstChild("Body", true)
        or Parts[1]
end

local function IsVehicleUpright(VehiclePart)
    if not VehiclePart then return false end
    local MinimumUpDot = math.cos(math.rad(MAX_VALID_TILT))
    return VehiclePart.CFrame.UpVector:Dot(Vector3.yAxis) >= MinimumUpDot
end

local function HasGroundBelow(Vehicle, Parts)
    if #Parts == 0 then return true end

    local LowestY = math.huge
    for _, Part in ipairs(Parts) do
        local BottomY = Part.Position.Y - (Part.Size.Y / 2)
        if BottomY < LowestY then LowestY = BottomY end
    end

    local Parameters = RaycastParams.new()
    Parameters.FilterType = Enum.RaycastFilterType.Exclude
    Parameters.FilterDescendantsInstances = {Vehicle}
    Parameters.IgnoreWater = false

    for _, Part in ipairs(Parts) do
        local BottomY = Part.Position.Y - (Part.Size.Y / 2)
        if BottomY <= LowestY + 2 then
            local Origin = Vector3.new(Part.Position.X, BottomY + 0.5, Part.Position.Z)
            if workspace:Raycast(Origin, Vector3.new(0, -MAX_GROUND_DISTANCE, 0), Parameters) then
                return true
            end
        end
    end

    return false
end

local FlyAlertGui = Instance.new("ScreenGui")
FlyAlertGui.Name = "ThunderwareVehicleFlyAlerts"
FlyAlertGui.ResetOnSpawn = false
FlyAlertGui.IgnoreGuiInset = true
FlyAlertGui.DisplayOrder = 999999
_G.VehicleFlyAlertGui = FlyAlertGui

if not pcall(function() FlyAlertGui.Parent = CoreGui end) then
    FlyAlertGui.Parent = PlayerGui
end

local FlyAlertContainer = Instance.new("Frame")
FlyAlertContainer.Name = "AlertContainer"
FlyAlertContainer.Size = UDim2.new(0, 520, 1, -20)
FlyAlertContainer.Position = UDim2.new(0.5, -260, 0, 20)
FlyAlertContainer.BackgroundTransparency = 1
FlyAlertContainer.Parent = FlyAlertGui

local FlyAlertLayout = Instance.new("UIListLayout")
FlyAlertLayout.FillDirection = Enum.FillDirection.Vertical
FlyAlertLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FlyAlertLayout.SortOrder = Enum.SortOrder.LayoutOrder
FlyAlertLayout.Padding = UDim.new(0, 10)
FlyAlertLayout.Parent = FlyAlertContainer

local FlyAlertCounter = 0

local function SendFlyWebhook(Player, DetectionCount, BanReason)
    if WEBHOOK_URL == "PUT_YOUR_NEW_WEBHOOK_HERE" or not HttpRequest or not Player then return end
    if _G.VehicleFlyWebhookSent[Player.UserId] then return end
    _G.VehicleFlyWebhookSent[Player.UserId] = true

    local ProfileUrl = "https://www.roblox.com/users/" .. Player.UserId .. "/profile"
    local AvatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Player.UserId .. "&width=420&height=420&format=png"

    local Payload = {
        embeds = {{
            title = "🚨 Vehicle Fly confirmé",
            url = ProfileUrl,
            color = 15158332,
            description = "**" .. Player.DisplayName .. "** (@" .. Player.Name .. ") a été sanctionné manuellement.",
            thumbnail = {url = AvatarUrl},
            fields = {
                {name = "👤 Utilisateur", value = "[" .. Player.DisplayName .. " (@" .. Player.Name .. ")] (" .. ProfileUrl .. ")", inline = false},
                {name = "🆔 User ID", value = "`" .. Player.UserId .. "`", inline = true},
                {name = "📅 Âge du compte", value = Player.AccountAge .. " jours", inline = true},
                {name = "🚗 Détections", value = DetectionCount .. "/" .. MAX_FLY_DETECTIONS, inline = true},
                {name = "🔨 Action", value = "Bannissement permanent manuel", inline = true},
                {name = "📝 Raison", value = BanReason, inline = false},
                {name = "🎮 Serveur", value = "Place ID : `" .. game.PlaceId .. "`\nJob ID : `" .. game.JobId .. "`", inline = false}
            },
            footer = {text = "Nice RP Anti-Cheat • Thunderware • Crée par ethone"},
            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    local Success, Result = pcall(function()
        return HttpRequest({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(Payload)
        })
    end)
    if not Success then
        _G.VehicleFlyWebhookSent[Player.UserId] = nil
        warn("[FLY WEBHOOK ERROR]", Result)
    end
end

local function BanFlyPlayer(PlayerName, DetectionCount)
    local Player = Players:FindFirstChild(PlayerName)
    if not Player then
        warn("[BAN ERROR] Player not found:", PlayerName)
        return false
    end

    local PlayerId = tostring(Player.UserId)
    local Reason = GetRandomBanReason()
    local KickMessage = "Vous avez été banni définitivement pour " .. Reason

    local KickSuccess, KickResult = pcall(function()
        return ExecuteEvent:InvokeServer("server/kick", { PlayerName, KickMessage })
    end)
    if not KickSuccess then
        warn("[FLY KICK ERROR]", PlayerName, KickResult)
    end

    local BanSuccess, BanResult = pcall(function()
        return ExecuteEvent:InvokeServer("server/ban/id", { PlayerId, "perm" })
    end)
    if BanSuccess then
        print("[MANUAL PERM BAN]", PlayerName)
        task.spawn(SendFlyWebhook, Player, DetectionCount, Reason)
    else
        warn("[FLY BAN ERROR]", PlayerName, BanResult)
    end

    return BanSuccess
end

local function RemoveOldestFlyAlertIfNeeded()
    local Alerts = {}
    for _, Object in ipairs(FlyAlertContainer:GetChildren()) do
        if Object:IsA("Frame") and Object.Name == "VehicleFlyAlert" then
            table.insert(Alerts, Object)
        end
    end
    table.sort(Alerts, function(A, B) return A.LayoutOrder < B.LayoutOrder end)
    while #Alerts >= MAX_FLY_ALERTS do
        Alerts[1]:Destroy()
        table.remove(Alerts, 1)
    end
end

local function CreateFlyAlertButton(Parent, Text, Color, Callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 120, 0, 32)
    Button.BackgroundColor3 = Color
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Active = false
    Button.Font = Enum.Font.GothamBold
    Button.Text = Text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextTransparency = 0.35
    Button.TextSize = 12
    Button.Parent = Parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    local CanClick = false
    task.delay(0.75, function()
        if Button.Parent then
            CanClick = true
            Button.Active = true
            Button.AutoButtonColor = true
            Button.TextTransparency = 0
        end
    end)

    Button.Activated:Connect(function()
        if CanClick then Callback(Button) end
    end)

    return Button
end

local function ShowVehicleFlyAlert(PlayerName, DetectionCount)
    RemoveOldestFlyAlertIfNeeded()
    FlyAlertCounter += 1

    local Alert = Instance.new("Frame")
    Alert.Name = "VehicleFlyAlert"
    Alert.Size = UDim2.new(1, 0, 0, 112)
    Alert.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Alert.BorderSizePixel = 0
    Alert.LayoutOrder = FlyAlertCounter
    Alert.Parent = FlyAlertContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Alert

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 75, 75)
    Stroke.Thickness = 2
    Stroke.Parent = Alert

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 6)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚠ POSSIBLE VEHICLE FLY"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 17
    Title.Parent = Alert

    local Content = Instance.new("TextLabel")
    Content.Size = UDim2.new(1, -20, 0, 24)
    Content.Position = UDim2.new(0, 10, 0, 35)
    Content.BackgroundTransparency = 1
    Content.Font = Enum.Font.Gotham
    Content.Text = PlayerName .. " a atteint " .. DetectionCount .. "/" .. MAX_FLY_DETECTIONS .. " détections. Vérification manuelle requise."
    Content.TextColor3 = Color3.fromRGB(215, 215, 220)
    Content.TextSize = 13
    Content.Parent = Alert

    local Buttons = Instance.new("Frame")
    Buttons.Size = UDim2.new(1, -20, 0, 32)
    Buttons.Position = UDim2.new(0, 10, 1, -40)
    Buttons.BackgroundTransparency = 1
    Buttons.Parent = Alert

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = Buttons

    local IsWatching = false
    CreateFlyAlertButton(Buttons, "WATCH", Color3.fromRGB(135, 80, 220), function(Button)
        if IsWatching then
            InvokeExecute("watch", { LocalPlayer.Name })
            IsWatching = false
            Button.Text = "WATCH"
            Button.BackgroundColor3 = Color3.fromRGB(135, 80, 220)
        else
            InvokeExecute("watch", { PlayerName })
            IsWatching = true
            Button.Text = "UNWATCH"
            Button.BackgroundColor3 = Color3.fromRGB(210, 70, 150)
        end
    end)

    local BanClicked = false
    CreateFlyAlertButton(Buttons, "BAN", Color3.fromRGB(210, 65, 65), function()
        if BanClicked then return end
        BanClicked = true
        if BanFlyPlayer(PlayerName, DetectionCount) then
            Alert:Destroy()
        else
            BanClicked = false
        end
    end)

    CreateFlyAlertButton(Buttons, "OK", Color3.fromRGB(65, 65, 75), function()
        Alert:Destroy()
    end)

    PlayAlertSound()
end

_G.VehicleFlyDetectionConnection = RunService.Heartbeat:Connect(function()
    if not _G.VehicleFlyDetectionEnabled then return end

    for _, Vehicle in ipairs(VehiclesFolder:GetChildren()) do
        local Parts = GetVehicleParts(Vehicle)
        local PlayerName = Vehicle.Name:gsub("^@", "")
        local LocalCharacter = LocalPlayer.Character
        local LocalRoot = LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart")
        local VehiclePart = GetVehicleRoot(Vehicle, Parts)

        if not LocalRoot
            or not VehiclePart
            or (VehiclePart.Position - LocalRoot.Position).Magnitude > MAX_DETECTION_DISTANCE then
            FlyDetectionCounts[PlayerName] = 0
            FlyAlertShown[PlayerName] = false
            continue
        end

        if not IsVehicleUpright(VehiclePart) then
            FlyDetectionCounts[PlayerName] = 0
            FlyAlertShown[PlayerName] = false
            continue
        end

        local IsFlying = #Parts > 0 and not HasGroundBelow(Vehicle, Parts)

        if IsFlying then
            FlyDetectionCounts[PlayerName] = math.min((FlyDetectionCounts[PlayerName] or 0) + 1, MAX_FLY_DETECTIONS)
            local Count = FlyDetectionCounts[PlayerName]
            print("[FLY DETECTED]", PlayerName, Count .. "/" .. MAX_FLY_DETECTIONS)

            if Count >= MAX_FLY_DETECTIONS and not FlyAlertShown[PlayerName] then
                FlyAlertShown[PlayerName] = true
                Starlight:Notification({
                    Title = "Possible Car Fly",
                    Icon = NebulaIcons:GetIcon("triangle-alert", "Lucide"),
                    Content = PlayerName .. " doit être vérifié manuellement."
                }, "CAR_FLY_" .. PlayerName)
                ShowVehicleFlyAlert(PlayerName, Count)
            end
        else
            FlyDetectionCounts[PlayerName] = 0
            FlyAlertShown[PlayerName] = false
        end
    end
end)

_G.VehicleAddedConnection = VehiclesFolder.ChildAdded:Connect(function(Vehicle)
    local PlayerName = Vehicle.Name:gsub("^@", "")
    FlyDetectionCounts[PlayerName] = 0
    FlyAlertShown[PlayerName] = false
end)

_G.VehiclePlayerRemovingConnection = Players.PlayerRemoving:Connect(function(Player)
    FlyDetectionCounts[Player.Name] = nil
    FlyAlertShown[Player.Name] = nil
    _G.VehicleFlyWebhookSent[Player.UserId] = nil
end)

-- ============================================================
-- CONTEXT MENU (Ctrl + clic droit sur un joueur)
-- ============================================================

do
    local ContextEnvironment = (getgenv and getgenv()) or _G
    local ContextKey = "ThunderwarePlayerContextMenu"

    local PreviousContext = ContextEnvironment[ContextKey]
    if PreviousContext then
        for _, Connection in ipairs(PreviousContext.Connections or {}) do
            pcall(function() Connection:Disconnect() end)
        end
        if PreviousContext.Gui then
            pcall(function() PreviousContext.Gui:Destroy() end)
        end
    end

    local ContextData = { Connections = {}, Gui = nil }
    ContextEnvironment[ContextKey] = ContextData

    local function ContextConnect(Signal, Callback)
        local Connection = Signal:Connect(Callback)
        table.insert(ContextData.Connections, Connection)
        return Connection
    end

    local ContextGui = Instance.new("ScreenGui")
    ContextGui.Name = "ThunderwarePlayerContextMenu"
    ContextGui.ResetOnSpawn = false
    ContextGui.IgnoreGuiInset = true
    ContextGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ContextGui.DisplayOrder = 999999
    ContextData.Gui = ContextGui

    if not pcall(function() ContextGui.Parent = CoreGui end) then
        ContextGui.Parent = PlayerGui
    end

    local Menu = Instance.new("Frame")
    Menu.Name = "ContextMenu"
    Menu.Size = UDim2.fromOffset(190, 478)
    Menu.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    Menu.BorderSizePixel = 0
    Menu.Visible = false
    Menu.Active = true
    Menu.ZIndex = 100
    Menu.Parent = ContextGui

    local MenuCorner = Instance.new("UICorner")
    MenuCorner.CornerRadius = UDim.new(0, 8)
    MenuCorner.Parent = Menu

    local MenuStroke = Instance.new("UIStroke")
    MenuStroke.Color = Color3.fromRGB(60, 60, 68)
    MenuStroke.Thickness = 1
    MenuStroke.Parent = Menu

    local TargetLabel = Instance.new("TextLabel")
    TargetLabel.Position = UDim2.fromOffset(8, 7)
    TargetLabel.Size = UDim2.new(1, -16, 0, 22)
    TargetLabel.BackgroundTransparency = 1
    TargetLabel.Font = Enum.Font.GothamMedium
    TargetLabel.Text = "No player"
    TargetLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
    TargetLabel.TextSize = 12
    TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
    TargetLabel.TextTruncate = Enum.TextTruncate.AtEnd
    TargetLabel.ZIndex = 101
    TargetLabel.Parent = Menu

    local function ContextButton(Name, Text, Y)
        local Button = Instance.new("TextButton")
        Button.Name = Name
        Button.Position = UDim2.fromOffset(8, Y)
        Button.Size = UDim2.new(1, -16, 0, 36)
        Button.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
        Button.BorderSizePixel = 0
        Button.AutoButtonColor = false
        Button.Font = Enum.Font.GothamMedium
        Button.Text = Text
        Button.TextColor3 = Color3.fromRGB(245, 245, 248)
        Button.TextSize = 13
        Button.ZIndex = 101
        Button.Parent = Menu

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Button

        return Button
    end

    local TeleportOptionsButton = ContextButton("TeleportOptionsButton", "Teleport options", 34)
    local HealthButton = ContextButton("HealthButton", "Set health to 100", 78)
    local DownButton = ContextButton("DownButton", "Knock down player", 122)
    local LoopButton = ContextButton("LoopTeleportButton", "Loop teleport (3s)", 166)
    local FreezeButton = ContextButton("FreezeButton", "Freeze player", 210)
    local WatchButton = ContextButton("WatchButton", "Watch player", 254)
    local UnwatchButton = ContextButton("UnwatchButton", "Unwatch player", 298)
    local RespawnButton = ContextButton("RespawnButton", "Respawn player", 342)
    local KickButton = ContextButton("KickButton", "Kick player", 386)
    local BanButton = ContextButton("BanButton", "Ban player", 430)
    local ToButton = ContextButton("ToPlayerButton", "Teleport Player", 34)
    local BringButton = ContextButton("BringPlayerButton", "Bring Player", 78)
    local ToVehicleButton = ContextButton("ToVehicleButton", "Teleport to vehicle", 122)
    local BackButton = ContextButton("BackButton", "Back", 166)

    local MainMenuButtons = {
        TeleportOptionsButton, HealthButton, DownButton, LoopButton,
        FreezeButton, WatchButton, UnwatchButton, RespawnButton,
        KickButton, BanButton
    }
    local TeleportMenuButtons = { ToButton, BringButton, ToVehicleButton, BackButton }

    local AllContextButtons = {}
    for _, Button in ipairs(MainMenuButtons) do
        table.insert(AllContextButtons, Button)
    end
    for _, Button in ipairs(TeleportMenuButtons) do
        table.insert(AllContextButtons, Button)
    end

    local function ShowContextPage(IsTeleportPage)
        for _, Button in ipairs(MainMenuButtons) do
            Button.Visible = not IsTeleportPage
        end
        for _, Button in ipairs(TeleportMenuButtons) do
            Button.Visible = IsTeleportPage
        end
        Menu.Size = UDim2.fromOffset(190, IsTeleportPage and 214 or 478)
    end
    ShowContextPage(false)

    local ContextTarget
    local ContextTargetId
    local ContextTargetName
    local ContextBusy = false
    local FrozenTargets = {}

    local function ResetContextButtons()
        ToButton.Text = "Teleport Player"
        BringButton.Text = "Bring Player"
        ToVehicleButton.Text = "Teleport to vehicle"
        HealthButton.Text = "Set health to 100"
        DownButton.Text = "Knock down player"
        LoopButton.Text = "Loop teleport (3s)"
        FreezeButton.Text = ContextTarget and FrozenTargets[ContextTarget.UserId]
            and "Unfreeze player" or "Freeze player"
        WatchButton.Text = "Watch player"
        UnwatchButton.Text = "Unwatch player"
        RespawnButton.Text = "Respawn player"
        KickButton.Text = "Kick player"
        BanButton.Text = "Ban player"
        for _, Button in ipairs(AllContextButtons) do
            Button.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
        end
    end

    local function CloseContextMenu()
        Menu.Visible = false
        ContextTarget = nil
        ContextTargetId = nil
        ContextTargetName = nil
        ShowContextPage(false)
        ResetContextButtons()
    end

    local function GetContextTarget()
        if not ContextTarget or ContextTarget.Parent ~= Players then
            CloseContextMenu()
            return nil
        end
        return ContextTarget
    end

    local function ContextError(Button, DefaultText, ErrorMessage)
        warn(ErrorMessage)
        Button.Text = "Error"
        Button.BackgroundColor3 = Color3.fromRGB(120, 42, 42)
        task.wait(1)
        Button.Text = DefaultText
        Button.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    end

    local function InvokeContextCommand(Command, Arguments)
        return pcall(function()
            return ExecuteEvent:InvokeServer(Command, Arguments)
        end)
    end

    local function ContextNotification(Content, Id)
        NotifyError(Content, Id)
    end

    local function SendContextModerationLog(Action, Reason, Status, UserId, UserName)
        if not HttpRequest or not WEBHOOK_URL or WEBHOOK_URL == "PUT_YOUR_NEW_WEBHOOK_HERE" then return end
        UserId = UserId or "Unknown"
        UserName = UserName or "Unknown"

        local Payload = {
            embeds = {{
                title = "Context Menu - " .. Action,
                color = Action == "Ban" and 15158332 or 15105570,
                fields = {
                    {name = "Utilisateur", value = "@" .. UserName, inline = true},
                    {name = "User ID", value = "`" .. UserId .. "`", inline = true},
                    {name = "Raison", value = Reason, inline = false},
                    {name = "Statut", value = Status, inline = false},
                    {name = "Serveur", value = "Place ID : `" .. game.PlaceId .. "`\nJob ID : `" .. game.JobId .. "`", inline = false},
                },
                footer = {text = "Thunderware - Context Menu"},
                timestamp = DateTime.now():ToIsoDate(),
            }}
        }

        task.spawn(function()
            local Success, Result = pcall(function()
                return HttpRequest({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(Payload),
                })
            end)
            if not Success then
                warn("[Context Menu] Webhook error: " .. tostring(Result))
            end
        end)
    end

    -- Fenêtre de kick avec raison
    local KickOverlay = Instance.new("Frame")
    KickOverlay.Name = "KickReasonOverlay"
    KickOverlay.Size = UDim2.fromScale(1, 1)
    KickOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    KickOverlay.BackgroundTransparency = 0.35
    KickOverlay.Visible = false
    KickOverlay.Active = true
    KickOverlay.ZIndex = 200
    KickOverlay.Parent = ContextGui

    local KickPanel = Instance.new("Frame")
    KickPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    KickPanel.Position = UDim2.fromScale(0.5, 0.5)
    KickPanel.Size = UDim2.fromOffset(420, 118)
    KickPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    KickPanel.BorderSizePixel = 0
    KickPanel.ZIndex = 201
    KickPanel.Parent = KickOverlay

    local KickPanelCorner = Instance.new("UICorner")
    KickPanelCorner.CornerRadius = UDim.new(0, 8)
    KickPanelCorner.Parent = KickPanel

    local KickTitle = Instance.new("TextLabel")
    KickTitle.Position = UDim2.fromOffset(12, 8)
    KickTitle.Size = UDim2.new(1, -24, 0, 22)
    KickTitle.BackgroundTransparency = 1
    KickTitle.Font = Enum.Font.GothamMedium
    KickTitle.Text = "Kick player"
    KickTitle.TextColor3 = Color3.fromRGB(245, 245, 248)
    KickTitle.TextSize = 14
    KickTitle.TextXAlignment = Enum.TextXAlignment.Left
    KickTitle.ZIndex = 202
    KickTitle.Parent = KickPanel

    local KickReasonInput = Instance.new("TextBox")
    KickReasonInput.Position = UDim2.fromOffset(12, 38)
    KickReasonInput.Size = UDim2.new(1, -24, 0, 38)
    KickReasonInput.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    KickReasonInput.BorderSizePixel = 0
    KickReasonInput.ClearTextOnFocus = false
    KickReasonInput.Font = Enum.Font.Gotham
    KickReasonInput.PlaceholderText = "Reason (Enter to kick)"
    KickReasonInput.PlaceholderColor3 = Color3.fromRGB(125, 125, 135)
    KickReasonInput.TextColor3 = Color3.fromRGB(245, 245, 248)
    KickReasonInput.TextSize = 14
    KickReasonInput.TextXAlignment = Enum.TextXAlignment.Left
    KickReasonInput.ZIndex = 202
    KickReasonInput.Parent = KickPanel

    local KickInputCorner = Instance.new("UICorner")
    KickInputCorner.CornerRadius = UDim.new(0, 6)
    KickInputCorner.Parent = KickReasonInput

    local KickHint = Instance.new("TextLabel")
    KickHint.Position = UDim2.fromOffset(12, 84)
    KickHint.Size = UDim2.new(1, -140, 0, 20)
    KickHint.BackgroundTransparency = 1
    KickHint.Font = Enum.Font.Gotham
    KickHint.Text = "Enter to confirm · Escape to cancel"
    KickHint.TextColor3 = Color3.fromRGB(150, 150, 160)
    KickHint.TextSize = 11
    KickHint.TextXAlignment = Enum.TextXAlignment.Left
    KickHint.ZIndex = 202
    KickHint.Parent = KickPanel

    local KickConfirmButton = Instance.new("TextButton")
    KickConfirmButton.Name = "KickConfirmButton"
    KickConfirmButton.Position = UDim2.fromOffset(306, 80)
    KickConfirmButton.Size = UDim2.fromOffset(100, 28)
    KickConfirmButton.BackgroundColor3 = Color3.fromRGB(55, 95, 170)
    KickConfirmButton.BorderSizePixel = 0
    KickConfirmButton.AutoButtonColor = true
    KickConfirmButton.Font = Enum.Font.GothamMedium
    KickConfirmButton.Text = "Kick"
    KickConfirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KickConfirmButton.TextSize = 13
    KickConfirmButton.ZIndex = 202
    KickConfirmButton.Parent = KickPanel

    local KickConfirmCorner = Instance.new("UICorner")
    KickConfirmCorner.CornerRadius = UDim.new(0, 6)
    KickConfirmCorner.Parent = KickConfirmButton

    local function CloseKickWindow()
        KickOverlay.Visible = false
        KickReasonInput.Text = ""
    end

    local function SubmitKick()
        if ContextBusy or not KickOverlay.Visible then return end

        local Reason = KickReasonInput.Text:match("^%s*(.-)%s*$")
        if Reason == "" then
            Reason = "[NICE ANTICHEAT] Aucune raison spécifié."
        end

        CloseKickWindow()

        local UserId, UserName = ContextTargetId, ContextTargetName
        local CurrentPlayer = UserName and Players:FindFirstChild(UserName)

        if not CurrentPlayer or tostring(CurrentPlayer.UserId) ~= UserId then
            ContextNotification("User not found.", "CONTEXT_KICK_USER_NOT_FOUND_")
            SendContextModerationLog("Kick", "No reason (user not found)", "Skipped: user not found", UserId, UserName)
            CloseContextMenu()
            return
        end

        ContextBusy = true
        local Success, Result = InvokeContextCommand("server/kick", { CurrentPlayer.Name, Reason })
        if not Success then
            warn("[Context Menu] Kick error: " .. tostring(Result))
        end
        SendContextModerationLog("Kick", Reason, Success and "Kick sent" or "Kick failed", UserId, UserName)

        ContextBusy = false
        CloseContextMenu()
    end

    -- Connexions des boutons
    ContextConnect(TeleportOptionsButton.MouseButton1Click, function()
        if ContextBusy or not GetContextTarget() then return end
        ResetContextButtons()
        ShowContextPage(true)
    end)

    ContextConnect(BackButton.MouseButton1Click, function()
        if ContextBusy then return end
        ResetContextButtons()
        ShowContextPage(false)
    end)

    ContextConnect(BringButton.MouseButton1Click, function()
        if ContextBusy then return end
        local Target = GetContextTarget()
        if not Target then return end
        ContextBusy = true
        BringButton.Text = "Bringing..."
        local Success, Result = InvokeContextCommand("bring", { Target.Name })
        if not Success then
            ContextError(BringButton, "Bring Player", "[Context Menu] Bring error: " .. tostring(Result))
        end
        ContextBusy = false
        CloseContextMenu()
    end)

    ContextConnect(ToButton.MouseButton1Click, function()
        if ContextBusy then return end
        local Target = GetContextTarget()
        if not Target then return end
        ContextBusy = true
        ToButton.Text = "Teleporting..."
        local Success, Result = InvokeContextCommand("to/player", { Target.Name })
        if not Success then
            ContextError(ToButton, "Teleport Player", "[Context Menu] Teleport error: " .. tostring(Result))
        end
        ContextBusy = false
        CloseContextMenu()
    end)

    ContextConnect(ToVehicleButton.MouseButton1Click, function()
        if ContextBusy then return end
        local Target = GetContextTarget()
        if not Target then return end
        ContextBusy = true
        ToVehicleButton.Text = "Teleporting..."
        local Success, Result = InvokeContextCommand("to/vehicle", { Target.Name })
        if not Success then
            ContextError(ToVehicleButton, "Teleport to vehicle", "[Context Menu] Teleport to vehicle error: " .. tostring(Result))
        end
        ContextBusy = false
        CloseContextMenu()
    end)

    ContextConnect(HealthButton.MouseButton1Click, function()
        if ContextBusy then return end
        local Target = GetContextTarget()
        if not Target then return end
        ContextBusy = true
        HealthButton.Text = "Applying..."
        local Success, Result = InvokeContextCommand("health", { Target.Name, "125" })
        if not Success then
            ContextError(HealthButton, "Set health to 100", "[Context Menu] Health error: " .. tostring(Result))
        end
        ContextBusy = false
        CloseContextMenu()
    end)

    ContextConnect(DownButton.MouseButton1Click, function()
        if ContextBusy then return end
        local Target = GetContextTarget()
        if not Target then return end
        ContextBusy = true
        DownButton.Text = "Applying..."
        local Success, Result = InvokeContextCommand("health", { Target.Name, "24" })
        if not Success then
            ContextError(DownButton, "Knock down player", "[Context Menu] Knock-down error: " .. tostring(Result))
        end
        ContextBusy = false
        CloseContextMenu()
    end)

    ContextConnect(WatchButton.MouseButton1Click, function()
        if ContextBusy then return end
        local Target = GetContextTarget()
        if not Target then return end
        ContextBusy = true
        WatchButton.Text = "Watching..."
        local Success, Result = InvokeContextCommand("watch", { Target.Name })
        if not Success then
            ContextError(WatchButton, "Watch player", "[Context Menu] Watch error: " .. tostring(Result))
        end
        ContextBusy = false
        CloseContextMenu()
    end)

    ContextConnect(UnwatchButton.MouseButton1Click, function()
        if ContextBusy then return end
        ContextBusy = true
        UnwatchButton.Text = "Unwatching..."
        local Success, Result = InvokeContextCommand("watch", { LocalPlayer.Name })
        if not Success then
            ContextError(UnwatchButton, "Unwatch player", "[Context Menu] Unwatch error: " .. tostring(Result))
        end
        ContextBusy = false
        CloseContextMenu()
    end)

    ContextConnect(RespawnButton.MouseButton1Click, function()
        if ContextBusy then return end
        local Target = GetContextTarget()
        if not Target then return end
        ContextBusy = true
        RespawnButton.Text = "Respawning..."
        local Success, Result = InvokeContextCommand("respawn", { Target.Name })
        if not Success then
            ContextError(RespawnButton, "Respawn player", "[Context Menu] Respawn error: " .. tostring(Result))
        end
        ContextBusy = false
        CloseContextMenu()
    end)

    ContextConnect(KickButton.MouseButton1Click, function()
        if ContextBusy or not GetContextTarget() then return end
        KickTitle.Text = "Kick @" .. ContextTargetName
        Menu.Visible = false
        KickOverlay.Visible = true
        KickReasonInput.Text = ""
        task.defer(function() KickReasonInput:CaptureFocus() end)
    end)

    ContextConnect(BanButton.MouseButton1Click, function()
        if ContextBusy or not ContextTargetId or not ContextTargetName then return end

        local UserId, UserName = ContextTargetId, ContextTargetName
        ContextBusy = true
        BanButton.Text = "Banning..."

        local CurrentPlayer = Players:FindFirstChild(UserName)
        local UserFound = CurrentPlayer and tostring(CurrentPlayer.UserId) == UserId

        if UserFound then
            local KickSuccess, KickResult = InvokeContextCommand("server/kick", {
                CurrentPlayer.Name,
                "[NICE ANTICHEAT] Ban permanent."
            })
            if not KickSuccess then
                warn("[Context Menu] Ban kick error: " .. tostring(KickResult))
            end
        else
            ContextNotification("User not found. Banned by ID only.", "CONTEXT_BAN_USER_NOT_FOUND_")
        end

        local BanSuccess, BanResult = InvokeContextCommand("server/ban/id", { UserId, "perm" })
        if not BanSuccess then
            ContextError(BanButton, "Ban player", "[Context Menu] Ban error: " .. tostring(BanResult))
        end

        SendContextModerationLog(
            "Ban",
            "[NICE ANTICHEAT] Ban permanent.",
            BanSuccess and (UserFound and "Kick + permanent ban sent" or "Permanent ban sent by ID only") or "Ban failed",
            UserId,
            UserName
        )

        ContextBusy = false
        CloseContextMenu()
    end)

    ContextConnect(FreezeButton.MouseButton1Click, function()
        if ContextBusy then return end
        local Target = GetContextTarget()
        if not Target then return end

        local WasFrozen = FrozenTargets[Target.UserId] == true
        ContextBusy = true
        FreezeButton.Text = WasFrozen and "Unfreezing..." or "Freezing..."

        local Success, Result = InvokeContextCommand(WasFrozen and "unfreeze" or "freeze", { Target.Name })
        if Success then
            FrozenTargets[Target.UserId] = not WasFrozen
        else
            ContextError(
                FreezeButton,
                WasFrozen and "Unfreeze player" or "Freeze player",
                "[Context Menu] Freeze error: " .. tostring(Result)
            )
        end

        ContextBusy = false
        CloseContextMenu()
    end)

    ContextConnect(LoopButton.MouseButton1Click, function()
        if ContextBusy then return end
        local Target = GetContextTarget()
        if not Target then return end

        local RemoteFolder = ReplicatedStorage:FindFirstChild("2Wz")
        local Control = RemoteFolder and RemoteFolder:FindFirstChild("1233a0fc-374a-4ac2-96f3-4869c6e9b28d")
        local Handcuffs = RemoteFolder and RemoteFolder:FindFirstChild("6aedfa38-d174-4a3f-a0cd-18b072271e1d")
        local Finish = RemoteFolder and RemoteFolder:FindFirstChild("f7f2148f-d07b-4df6-af31-4a545128baff")

        if not Control or not Handcuffs or not Finish then
            ContextError(LoopButton, "Loop teleport (3s)", "[Context Menu] Loop teleport remote unavailable.")
            return
        end

        ContextBusy = true
        LoopButton.Text = "Running..."

        local Success, Result = pcall(function()
            Handcuffs:FireServer("Handcuffs")
            task.wait(0.25)
            InvokeContextCommand("to/player", { Target.Name })
            task.wait(0.25)

            local Character = Target.Character
            local Root = Character and Character:FindFirstChild("HumanoidRootPart")
            if not Root then
                error("Target has no HumanoidRootPart.")
            end

            Control:FireServer(Root, "51O", "start")

            local Deadline = os.clock() + 3
            repeat
                InvokeContextCommand("to/player", { Target.Name })
                task.wait()
            until os.clock() >= Deadline

            Control:FireServer(Root, "51O", "stop")
            Finish:FireServer()
        end)

        if not Success then
            ContextError(LoopButton, "Loop teleport (3s)", "[Context Menu] Loop teleport error: " .. tostring(Result))
        end

        ContextBusy = false
        CloseContextMenu()
    end)

    -- Raycast + ouverture du menu (traverse murs et véhicules)
    local function PlayerFromPart(Part)
        local Object = Part
        while Object and Object ~= workspace do
            if Object:IsA("Model") then
                local Player = Players:GetPlayerFromCharacter(Object)
                if Player then return Player end
            end
            Object = Object.Parent
        end
        return nil
    end

    -- Filtre tout ce qui ne doit pas bloquer le raycast :
    -- - le personnage local (on ne veut pas se viser soi-même),
    -- - le dossier Vehicles (pour traverser les voitures),
    -- - le dossier Objects / Map / Buildings (pour traverser les murs),
    -- - la caméra (sécurité).
    local function BuildContextRaycastFilter()
        local Filter = {}

        if LocalPlayer.Character then
            table.insert(Filter, LocalPlayer.Character)
        end

        local Camera = workspace.CurrentCamera
        if Camera then
            table.insert(Filter, Camera)
        end

        -- On exclut récursivement tous les dossiers "décor" pour que
        -- le raycast traverse murs, bâtiments, véhicules, props.
        local DecorFolderNames = {
            "Vehicles",
            "Objects",
            "Map",
            "Buildings",
            "Props",
            "Decorations",
            "Deco",
            "MapFolder",
            "World",
        }

        for _, FolderName in ipairs(DecorFolderNames) do
            local Folder = workspace:FindFirstChild(FolderName)
            if Folder then
                table.insert(Filter, Folder)
            end
        end

        return Filter
    end

    local function PlayerUnderCursor()
        local Camera = workspace.CurrentCamera
        if not Camera then return nil end

        local MousePosition = UserInputService:GetMouseLocation()
        local Ray = Camera:ViewportPointToRay(MousePosition.X, MousePosition.Y)

        local Parameters = RaycastParams.new()
        Parameters.FilterType = Enum.RaycastFilterType.Exclude
        Parameters.FilterDescendantsInstances = BuildContextRaycastFilter()
        Parameters.IgnoreWater = true

        -- Raycast principal sur 100k studs : traverse murs et véhicules
        -- grâce au filtre ci-dessus. On ne touche que les personnages.
        local Result = workspace:Raycast(Ray.Origin, Ray.Direction * 100000, Parameters)

        if Result then
            local Player = PlayerFromPart(Result.Instance)
            if Player then return Player end

            -- Si on touche un Accessory / Tool d'un perso, on remonte
            -- la hiérarchie au cas où PlayerFromPart ait loupé le Model.
            local Current = Result.Instance
            while Current and Current ~= workspace do
                if Current:IsA("Model") then
                    local Found = Players:GetPlayerFromCharacter(Current)
                    if Found then return Found end
                end
                Current = Current.Parent
            end
        end

        -- Fallback : si le raycast n'a touché que du décor (parce que
        -- tous les personnages étaient hors du chemin), on fait un
        -- second passage en ne gardant QUE les personnages.
        local CharacterFilter = {}
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player.Character then
                table.insert(CharacterFilter, Player.Character)
            end
        end

        if #CharacterFilter > 0 then
            local StrictParams = RaycastParams.new()
            StrictParams.FilterType = Enum.RaycastFilterType.Include
            StrictParams.FilterDescendantsInstances = CharacterFilter
            StrictParams.IgnoreWater = true

            local StrictResult = workspace:Raycast(Ray.Origin, Ray.Direction * 100000, StrictParams)
            if StrictResult then
                return PlayerFromPart(StrictResult.Instance)
            end
        end

        return nil
    end

    local function OpenContextMenu(Target)
        if not Target or Target == LocalPlayer then
            CloseContextMenu()
            return
        end

        ContextTarget = Target
        ContextTargetId = tostring(Target.UserId)
        ContextTargetName = Target.Name

        ShowContextPage(false)
        ResetContextButtons()
        TargetLabel.Text = string.format("%s  (@%s)", Target.DisplayName, Target.Name)

        local MousePosition = UserInputService:GetMouseLocation()
        local Viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
            or Vector2.new(1920, 1080)

        Menu.Position = UDim2.fromOffset(
            math.clamp(MousePosition.X + 8, 5, Viewport.X - 195),
            math.clamp(MousePosition.Y + 8, 5, Viewport.Y - 483)
        )
        Menu.Visible = true
    end

    -- Hover effects
    for _, Button in ipairs(AllContextButtons) do
        ContextConnect(Button.MouseEnter, function()
            if not ContextBusy then
                Button.BackgroundColor3 = Color3.fromRGB(52, 52, 60)
            end
        end)
        ContextConnect(Button.MouseLeave, function()
            if not ContextBusy then
                Button.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
            end
        end)
    end

    -- Input global
    ContextConnect(UserInputService.InputBegan, function(Input, Processed)
        if not Processed and KickOverlay.Visible then
            if Input.KeyCode == Enum.KeyCode.Return
                or Input.KeyCode == Enum.KeyCode.KeypadEnter then
                SubmitKick()
                return
            end
        end

        if Input.UserInputType == Enum.UserInputType.MouseButton2 then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                OpenContextMenu(PlayerUnderCursor())
            else
                CloseContextMenu()
            end
        elseif Input.KeyCode == Enum.KeyCode.Escape then
            if KickOverlay.Visible then CloseKickWindow() end
            CloseContextMenu()
        end
    end)

    ContextConnect(KickConfirmButton.MouseButton1Click, function()
        SubmitKick()
    end)

    ContextConnect(KickReasonInput.FocusLost, function(EnterPressed)
        if EnterPressed then
            SubmitKick()
        elseif KickOverlay.Visible then
            CloseKickWindow()
        end
    end)

    ContextConnect(Players.PlayerRemoving, function(Player)
        FrozenTargets[Player.UserId] = nil
    end)
end
