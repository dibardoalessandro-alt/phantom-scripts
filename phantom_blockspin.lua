--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║     PHANTOM · BlockSpin Stealth Suite v1.1                    ║
    ║     Built for Xeno Executor (compatibility mode)              ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    F1 = ESP | F2 = Inventory ESP | F3 = Aimbot | F4 = Triggerbot
    RMB = Aimbot hold | Left Alt = Triggerbot hold | F8 = Unload
--]]

-- ═══════════════════════════════════════════
-- SAFE ENVIRONMENT CHECK
-- Controlla cosa supporta l'executor
-- ═══════════════════════════════════════════
local function safeCheck(name)
    local ok, result = pcall(function()
        return getfenv()[name] or _G[name]
    end)
    if ok and result then return result end
    return nil
end

-- Detect available font
local function getFont()
    local ok, fonts = pcall(function() return Drawing.Fonts end)
    if ok and fonts then
        if fonts.Plex then return fonts.Plex end
        if fonts.UI then return fonts.UI end
        if fonts.System then return fonts.System end
        if fonts.Monospace then return fonts.Monospace end
    end
    return 2 -- fallback numeric font ID
end

local FONT = getFont()

-- Check for key functions
local HAS_MOUSEMOVEREL = (typeof(mousemoverel) == "function")
local HAS_MOUSE1CLICK  = (typeof(mouse1click) == "function")
local HAS_HOOKMETAMETHOD = pcall(function() return typeof(hookmetamethod) == "function" end)
local HAS_NEWCCLOSURE = pcall(function() return typeof(newcclosure) == "function" end)

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

local mFloor  = math.floor
local mSqrt   = math.sqrt
local mRandom = math.random
local mAbs    = math.abs
local mHuge   = math.huge
local mClamp  = math.clamp
local V2      = Vector2.new
local V3      = Vector3.new
local C3      = Color3.fromRGB
local RParams = RaycastParams.new
local tInsert = table.insert
local tRemove = table.remove
local tClear  = table.clear
local tConcat = table.concat
local Tick    = tick
local tWait   = task.wait
local tSpawn  = task.spawn

-- ═══════════════════════════════════════════
-- CONFIGURAZIONE
-- Modifica qui i tuoi settings!
-- ═══════════════════════════════════════════
local Config = {
    ESP = {
        Enabled         = false,
        ToggleKey       = Enum.KeyCode.F1,
        Boxes           = true,
        BoxColor        = C3(255, 50, 80),
        BoxThickness    = 1.3,
        Names           = true,
        NameColor       = C3(255, 255, 255),
        NameSize        = 14,
        HealthBar       = true,
        HealthBarWidth  = 3,
        Distance        = true,
        DistanceColor   = C3(200, 200, 200),
        Tracers         = true,
        TracerColor     = C3(255, 50, 80),
        TracerThickness = 1,
        TracerOrigin    = "Bottom",
        VisibilityCheck = true,
        VisibleColor    = C3(50, 255, 100),
        NotVisibleColor = C3(255, 50, 80),
        MaxDistance      = 1000,
        TeamCheck        = false,
    },

    InventoryESP = {
        Enabled      = false,
        ToggleKey    = Enum.KeyCode.F2,
        ShowEquipped = true,
        ShowBackpack = true,
        TextColor    = C3(0, 255, 210),
        TextSize     = 12,
    },

    Aimbot = {
        Enabled              = false,
        ToggleKey            = Enum.KeyCode.F3,
        ActivationKey        = Enum.UserInputType.MouseButton2,
        TargetPart           = "Head",
        MaxDistance           = 500,
        FOV                  = 120,
        ShowFOV              = true,
        FOVColor             = C3(255, 255, 255),
        FOVThickness         = 1,
        FOVTransparency      = 0.6,
        FOVSides             = 64,
        Smoothing            = 6,
        HumanizeJitter       = true,
        JitterStrength       = 0.4,
        Prediction           = true,
        PredictionMultiplier = 0.135,
        WallCheck            = true,
        StickyAim            = false,
        TeamCheck            = false,
    },

    Triggerbot = {
        Enabled       = false,
        ToggleKey     = Enum.KeyCode.F4,
        ActivationKey = Enum.KeyCode.LeftAlt,
        MinDelay      = 0.06,
        MaxDelay      = 0.18,
        MaxDistance    = 300,
        HitChance     = 95,
        TargetParts   = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
        TeamCheck     = false,
    },

    Misc = {
        UnloadKey            = Enum.KeyCode.F8,
        NotificationDuration = 2.5,
        ShowWatermark        = true,
    },
}

-- ═══════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════
local State = {
    Running        = true,
    AimbotHeld     = false,
    TriggerbotHeld = false,
    CurrentTarget  = nil,
    Connections    = {},
    ESPCache       = {},
    Notifications  = {},
}

-- ═══════════════════════════════════════════
-- ANTI-DETECTION (safe, wrapped in pcall)
-- ═══════════════════════════════════════════
pcall(function()
    if not hookmetamethod then return end
    if not newcclosure then return end
    if not getnamecallmethod then return end

    local blacklist = {
        "anticheat", "anti_cheat", "anti-cheat",
        "ac_check", "ac_flag", "ac_report",
        "detect", "security", "validate",
        "verify", "integrity", "guard",
        "shield", "monitor", "cheat",
        "exploit", "kick_player", "ban",
    }

    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            if self and self.Name then
                local rName = self.Name:lower()
                for _, pat in ipairs(blacklist) do
                    if rName:find(pat, 1, true) then
                        return nil
                    end
                end
            end
        end
        return old(self, ...)
    end))
end)

-- ═══════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════
local Util = {}

function Util.WorldToScreen(worldPos)
    local sp, on = Camera:WorldToViewportPoint(worldPos)
    return V2(sp.X, sp.Y), on, sp.Z
end

function Util.Dist2D(a, b)
    return mSqrt((a.X - b.X)^2 + (a.Y - b.Y)^2)
end

function Util.Dist3D(a, b)
    return (a - b).Magnitude
end

function Util.IsAlive(player)
    if not player or not player.Parent then return false end
    local c = player.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    if not c:FindFirstChild("HumanoidRootPart") then return false end
    return true
end

function Util.IsVisible(origin, targetPos, targetPlayer)
    local params = RParams()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local fl = {Camera}
    if LocalPlayer.Character then tInsert(fl, LocalPlayer.Character) end
    params.FilterDescendantsInstances = fl

    local result = Workspace:Raycast(origin, targetPos - origin, params)
    if not result then return true end
    if targetPlayer and targetPlayer.Character then
        if result.Instance:IsDescendantOf(targetPlayer.Character) then
            return true
        end
    end
    return false
end

function Util.IsTeammate(player)
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    return false
end

function Util.ScreenCenter()
    local vp = Camera.ViewportSize
    return V2(vp.X / 2, vp.Y / 2)
end

function Util.RandFloat(min, max)
    return min + math.random() * (max - min)
end

-- ═══════════════════════════════════════════
-- NOTIFICATIONS
-- ═══════════════════════════════════════════
local Notify = {}

function Notify.Send(text, color, duration)
    color = color or C3(255, 255, 255)
    duration = duration or Config.Misc.NotificationDuration

    local ok, label = pcall(function()
        local d = Drawing.new("Text")
        d.Text         = "  [PHANTOM]  " .. text
        d.Size         = 16
        d.Font         = FONT
        d.Color        = color
        d.OutlineColor = C3(0, 0, 0)
        d.Outline      = true
        d.Position     = V2(12, 10 + (#State.Notifications * 22))
        d.Visible      = true
        return d
    end)

    if not ok or not label then
        warn("[PHANTOM] " .. text)
        return
    end

    local entry = {Drawing = label, Expire = Tick() + duration}
    tInsert(State.Notifications, entry)

    tSpawn(function()
        tWait(duration)
        for i = 1, 10 do
            pcall(function() label.Transparency = 1 - (i / 10) end)
            tWait(0.03)
        end
        pcall(function() label:Remove() end)
        for idx, n in ipairs(State.Notifications) do
            if n == entry then
                tRemove(State.Notifications, idx)
                for j = idx, #State.Notifications do
                    pcall(function()
                        State.Notifications[j].Drawing.Position = V2(12, 10 + ((j-1) * 22))
                    end)
                end
                break
            end
        end
    end)
end

-- ═══════════════════════════════════════════
-- ESP MODULE
-- ═══════════════════════════════════════════
local ESP = {}

function ESP.CreateDrawings()
    local d = {}
    pcall(function()
        d.Box = Drawing.new("Square")
        d.Box.Thickness = Config.ESP.BoxThickness
        d.Box.Filled = false
        d.Box.Visible = false

        d.Name = Drawing.new("Text")
        d.Name.Size = Config.ESP.NameSize
        d.Name.Font = FONT
        d.Name.Outline = true
        d.Name.OutlineColor = C3(0, 0, 0)
        d.Name.Visible = false

        d.Dist = Drawing.new("Text")
        d.Dist.Size = 12
        d.Dist.Font = FONT
        d.Dist.Outline = true
        d.Dist.OutlineColor = C3(0, 0, 0)
        d.Dist.Visible = false

        d.HealthBG = Drawing.new("Line")
        d.HealthBG.Thickness = Config.ESP.HealthBarWidth + 2
        d.HealthBG.Visible = false

        d.Health = Drawing.new("Line")
        d.Health.Thickness = Config.ESP.HealthBarWidth
        d.Health.Visible = false

        d.Tracer = Drawing.new("Line")
        d.Tracer.Thickness = Config.ESP.TracerThickness
        d.Tracer.Visible = false

        d.Inventory = Drawing.new("Text")
        d.Inventory.Size = Config.InventoryESP.TextSize
        d.Inventory.Font = FONT
        d.Inventory.Outline = true
        d.Inventory.OutlineColor = C3(0, 0, 0)
        d.Inventory.Visible = false
    end)
    return d
end

function ESP.DestroyDrawings(drawings)
    if not drawings then return end
    for _, d in pairs(drawings) do
        pcall(function() d:Remove() end)
    end
end

function ESP.HideAll(drawings)
    if not drawings then return end
    for _, d in pairs(drawings) do
        pcall(function() d.Visible = false end)
    end
end

function ESP.Register(player)
    if player == LocalPlayer then return end
    if State.ESPCache[player] then return end
    State.ESPCache[player] = ESP.CreateDrawings()
end

function ESP.Unregister(player)
    if State.ESPCache[player] then
        ESP.DestroyDrawings(State.ESPCache[player])
        State.ESPCache[player] = nil
    end
end

function ESP.UpdatePlayer(player, drawings)
    if not Util.IsAlive(player) then
        ESP.HideAll(drawings)
        return
    end

    if Config.ESP.TeamCheck and Util.IsTeammate(player) then
        ESP.HideAll(drawings)
        return
    end

    local char = player.Character
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if not rootPart or not humanoid then
        ESP.HideAll(drawings)
        return
    end

    local camPos = Camera.CFrame.Position
    local distance = Util.Dist3D(rootPart.Position, camPos)

    if distance > Config.ESP.MaxDistance then
        ESP.HideAll(drawings)
        return
    end

    local topWorld = rootPart.Position + V3(0, 3.2, 0)
    local bottomWorld = rootPart.Position - V3(0, 3.2, 0)
    local screenTop, onTop = Util.WorldToScreen(topWorld)
    local screenBottom, onBottom = Util.WorldToScreen(bottomWorld)

    if not onTop and not onBottom then
        ESP.HideAll(drawings)
        return
    end

    local boxH = mAbs(screenBottom.Y - screenTop.Y)
    local boxW = boxH * 0.55
    local boxX = screenTop.X - boxW / 2
    local boxY = screenTop.Y

    -- Color based on visibility
    local espColor
    if Config.ESP.VisibilityCheck then
        local vis = Util.IsVisible(camPos, rootPart.Position, player)
        espColor = vis and Config.ESP.VisibleColor or Config.ESP.NotVisibleColor
    else
        espColor = Config.ESP.BoxColor
    end

    -- BOX
    if Config.ESP.Enabled and Config.ESP.Boxes and drawings.Box then
        drawings.Box.Position  = V2(boxX, boxY)
        drawings.Box.Size      = V2(boxW, boxH)
        drawings.Box.Color     = espColor
        drawings.Box.Thickness = Config.ESP.BoxThickness
        drawings.Box.Visible   = true
    elseif drawings.Box then
        drawings.Box.Visible = false
    end

    -- NAME
    if Config.ESP.Enabled and Config.ESP.Names and drawings.Name then
        drawings.Name.Text  = player.DisplayName
        drawings.Name.Color = Config.ESP.NameColor
        drawings.Name.Size  = Config.ESP.NameSize
        local tb = drawings.Name.TextBounds
        drawings.Name.Position = V2(screenTop.X - tb.X / 2, screenTop.Y - tb.Y - 3)
        drawings.Name.Visible  = true
    elseif drawings.Name then
        drawings.Name.Visible = false
    end

    -- DISTANCE
    if Config.ESP.Enabled and Config.ESP.Distance and drawings.Dist then
        drawings.Dist.Text  = mFloor(distance) .. "m"
        drawings.Dist.Color = Config.ESP.DistanceColor
        local tb = drawings.Dist.TextBounds
        drawings.Dist.Position = V2(screenBottom.X - tb.X / 2, screenBottom.Y + 3)
        drawings.Dist.Visible  = true
    elseif drawings.Dist then
        drawings.Dist.Visible = false
    end

    -- HEALTH BAR
    if Config.ESP.Enabled and Config.ESP.HealthBar and drawings.HealthBG and drawings.Health then
        local pct = mClamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local barX = boxX - Config.ESP.HealthBarWidth - 4

        drawings.HealthBG.From    = V2(barX, boxY)
        drawings.HealthBG.To      = V2(barX, boxY + boxH)
        drawings.HealthBG.Color   = C3(25, 25, 25)
        drawings.HealthBG.Visible = true

        local hH = boxH * pct
        drawings.Health.From    = V2(barX, boxY + boxH - hH)
        drawings.Health.To      = V2(barX, boxY + boxH)
        drawings.Health.Color   = C3(mFloor((1 - pct) * 255), mFloor(pct * 255), 50)
        drawings.Health.Visible = true
    elseif drawings.HealthBG then
        drawings.HealthBG.Visible = false
        drawings.Health.Visible   = false
    end

    -- TRACERS
    if Config.ESP.Enabled and Config.ESP.Tracers and drawings.Tracer then
        local vp = Camera.ViewportSize
        local origin
        if Config.ESP.TracerOrigin == "Bottom" then
            origin = V2(vp.X / 2, vp.Y)
        elseif Config.ESP.TracerOrigin == "Top" then
            origin = V2(vp.X / 2, 0)
        else
            origin = V2(vp.X / 2, vp.Y / 2)
        end
        drawings.Tracer.From      = origin
        drawings.Tracer.To        = screenBottom
        drawings.Tracer.Color     = espColor
        drawings.Tracer.Thickness = Config.ESP.TracerThickness
        drawings.Tracer.Visible   = true
    elseif drawings.Tracer then
        drawings.Tracer.Visible = false
    end

    -- INVENTORY ESP
    if Config.InventoryESP.Enabled and drawings.Inventory then
        local items = {}

        if Config.InventoryESP.ShowEquipped then
            for _, child in ipairs(char:GetChildren()) do
                if child:IsA("Tool") then
                    tInsert(items, "[E] " .. child.Name)
                end
            end
        end

        if Config.InventoryESP.ShowBackpack then
            local bp = player:FindFirstChild("Backpack")
            if bp then
                for _, child in ipairs(bp:GetChildren()) do
                    if child:IsA("Tool") then
                        tInsert(items, "[B] " .. child.Name)
                    end
                end
            end
        end

        if #items > 0 then
            drawings.Inventory.Text  = tConcat(items, " | ")
            drawings.Inventory.Color = Config.InventoryESP.TextColor
            drawings.Inventory.Size  = Config.InventoryESP.TextSize
            local yOff = screenBottom.Y + 18
            if Config.ESP.Distance then yOff = yOff + 16 end
            local tb = drawings.Inventory.TextBounds
            drawings.Inventory.Position = V2(screenBottom.X - tb.X / 2, yOff)
            drawings.Inventory.Visible  = true
        else
            drawings.Inventory.Visible = false
        end
    elseif drawings.Inventory then
        drawings.Inventory.Visible = false
    end
end

-- ═══════════════════════════════════════════
-- AIMBOT MODULE
-- ═══════════════════════════════════════════
local Aimbot = {}

local FOVCircle, TargetDot

pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Filled       = false
    FOVCircle.NumSides     = Config.Aimbot.FOVSides
    FOVCircle.Radius       = Config.Aimbot.FOV
    FOVCircle.Thickness    = Config.Aimbot.FOVThickness
    FOVCircle.Color        = Config.Aimbot.FOVColor
    FOVCircle.Transparency = Config.Aimbot.FOVTransparency
    FOVCircle.Visible      = false

    TargetDot = Drawing.new("Circle")
    TargetDot.Filled   = true
    TargetDot.NumSides = 16
    TargetDot.Radius   = 4
    TargetDot.Color    = C3(255, 50, 80)
    TargetDot.Visible  = false
end)

function Aimbot.FindTarget()
    local best = nil
    local bestDist = mHuge
    local center = Util.ScreenCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Util.IsAlive(player) then
            if not (Config.Aimbot.TeamCheck and Util.IsTeammate(player)) then
                local char = player.Character
                local part = char:FindFirstChild(Config.Aimbot.TargetPart)

                if part then
                    local d3 = Util.Dist3D(part.Position, Camera.CFrame.Position)
                    if d3 <= Config.Aimbot.MaxDistance then
                        local sp, on = Util.WorldToScreen(part.Position)
                        if on then
                            local sd = Util.Dist2D(sp, center)
                            if sd <= Config.Aimbot.FOV and sd < bestDist then
                                if Config.Aimbot.WallCheck then
                                    if Util.IsVisible(Camera.CFrame.Position, part.Position, player) then
                                        best = player
                                        bestDist = sd
                                    end
                                else
                                    best = player
                                    bestDist = sd
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

function Aimbot.PredictPosition(part)
    if not Config.Aimbot.Prediction then return part.Position end
    local vel = V3(0, 0, 0)
    pcall(function() vel = part.AssemblyLinearVelocity end)
    if vel.Magnitude < 0.1 then
        pcall(function() vel = part.Velocity end)
    end
    return part.Position + (vel * Config.Aimbot.PredictionMultiplier)
end

function Aimbot.AimAt(worldPos)
    if not HAS_MOUSEMOVEREL then return end

    local sp, on = Util.WorldToScreen(worldPos)
    if not on then return end

    local center = Util.ScreenCenter()
    local delta = sp - center

    local moveX = delta.X / Config.Aimbot.Smoothing
    local moveY = delta.Y / Config.Aimbot.Smoothing

    if Config.Aimbot.HumanizeJitter then
        local js = Config.Aimbot.JitterStrength
        moveX = moveX + Util.RandFloat(-js, js)
        moveY = moveY + Util.RandFloat(-js, js)
    end

    mousemoverel(moveX, moveY)

    if TargetDot then
        TargetDot.Position = sp
        TargetDot.Visible = true
    end
end

-- ═══════════════════════════════════════════
-- TRIGGERBOT MODULE
-- ═══════════════════════════════════════════
local Triggerbot = {}
local _lastTrigger = 0

function Triggerbot.Process()
    if not Config.Triggerbot.Enabled then return end
    if not State.TriggerbotHeld then return end
    if not HAS_MOUSE1CLICK then return end

    local now = Tick()
    local delay = Util.RandFloat(Config.Triggerbot.MinDelay, Config.Triggerbot.MaxDelay)
    if now - _lastTrigger < delay then return end

    if mRandom(1, 100) > Config.Triggerbot.HitChance then
        _lastTrigger = now
        return
    end

    local center = Util.ScreenCenter()
    local ray = Camera:ViewportPointToRay(center.X, center.Y)

    local params = RParams()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local fl = {Camera}
    if LocalPlayer.Character then tInsert(fl, LocalPlayer.Character) end
    params.FilterDescendantsInstances = fl

    local result = Workspace:Raycast(ray.Origin, ray.Direction * Config.Triggerbot.MaxDistance, params)

    if result and result.Instance then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        if hitChar then
            local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
            if hitPlayer and hitPlayer ~= LocalPlayer then
                if not (Config.Triggerbot.TeamCheck and Util.IsTeammate(hitPlayer)) then
                    local valid = false
                    for _, pn in ipairs(Config.Triggerbot.TargetParts) do
                        if result.Instance.Name == pn then valid = true break end
                    end
                    if valid then
                        mouse1click()
                        _lastTrigger = now
                    end
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════
-- HUD MODULE
-- ═══════════════════════════════════════════
local HUD = {}
local _hud = {}

function HUD.Init()
    pcall(function()
        _hud.Title = Drawing.new("Text")
        _hud.Title.Text         = "PHANTOM v1.1"
        _hud.Title.Size         = 20
        _hud.Title.Font         = FONT
        _hud.Title.Color        = C3(180, 80, 255)
        _hud.Title.OutlineColor = C3(0, 0, 0)
        _hud.Title.Outline      = true
        _hud.Title.Position     = V2(12, 42)
        _hud.Title.Visible      = true

        _hud.Line = Drawing.new("Line")
        _hud.Line.From      = V2(12, 64)
        _hud.Line.To        = V2(170, 64)
        _hud.Line.Color     = C3(180, 80, 255)
        _hud.Line.Thickness = 1
        _hud.Line.Visible   = true

        local names = {"ESP", "InvESP", "Aimbot", "Trigger"}
        for i, name in ipairs(names) do
            _hud["S_" .. name] = Drawing.new("Text")
            _hud["S_" .. name].Size         = 13
            _hud["S_" .. name].Font         = FONT
            _hud["S_" .. name].OutlineColor = C3(0, 0, 0)
            _hud["S_" .. name].Outline      = true
            _hud["S_" .. name].Position     = V2(12, 68 + (i - 1) * 18)
            _hud["S_" .. name].Visible      = true
        end
    end)
end

function HUD.Update()
    pcall(function()
        local s = {
            {K = "S_ESP",     L = "[F1] ESP",       On = Config.ESP.Enabled},
            {K = "S_InvESP",  L = "[F2] InvESP",    On = Config.InventoryESP.Enabled},
            {K = "S_Aimbot",  L = "[F3] Aimbot",    On = Config.Aimbot.Enabled},
            {K = "S_Trigger", L = "[F4] Trigger",   On = Config.Triggerbot.Enabled},
        }
        for _, v in ipairs(s) do
            local d = _hud[v.K]
            if d then
                d.Text  = v.L .. (v.On and " ON" or " OFF")
                d.Color = v.On and C3(80, 255, 120) or C3(255, 80, 80)
            end
        end
    end)
end

function HUD.Destroy()
    for _, d in pairs(_hud) do
        pcall(function() d:Remove() end)
    end
    _hud = {}
end

-- ═══════════════════════════════════════════
-- INPUT HANDLER
-- ═══════════════════════════════════════════
local function OnInputBegan(input, gp)
    if gp then return end

    local kc = input.KeyCode

    if kc == Config.ESP.ToggleKey then
        Config.ESP.Enabled = not Config.ESP.Enabled
        local on = Config.ESP.Enabled
        Notify.Send("ESP " .. (on and "ON" or "OFF"), on and C3(80,255,120) or C3(255,80,80))

    elseif kc == Config.InventoryESP.ToggleKey then
        Config.InventoryESP.Enabled = not Config.InventoryESP.Enabled
        local on = Config.InventoryESP.Enabled
        Notify.Send("Inventory ESP " .. (on and "ON" or "OFF"), on and C3(80,255,120) or C3(255,80,80))

    elseif kc == Config.Aimbot.ToggleKey then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
        local on = Config.Aimbot.Enabled
        Notify.Send("Aimbot " .. (on and "ON" or "OFF"), on and C3(80,255,120) or C3(255,80,80))

    elseif kc == Config.Triggerbot.ToggleKey then
        Config.Triggerbot.Enabled = not Config.Triggerbot.Enabled
        local on = Config.Triggerbot.Enabled
        Notify.Send("Triggerbot " .. (on and "ON" or "OFF"), on and C3(80,255,120) or C3(255,80,80))

    elseif kc == Config.Misc.UnloadKey then
        State.Running = false
        return
    end

    if input.UserInputType == Config.Aimbot.ActivationKey then
        State.AimbotHeld = true
    end
    if kc == Config.Triggerbot.ActivationKey then
        State.TriggerbotHeld = true
    end
end

local function OnInputEnded(input, _)
    if input.UserInputType == Config.Aimbot.ActivationKey then
        State.AimbotHeld = false
        State.CurrentTarget = nil
        if TargetDot then pcall(function() TargetDot.Visible = false end) end
    end
    if input.KeyCode == Config.Triggerbot.ActivationKey then
        State.TriggerbotHeld = false
    end
end

-- ═══════════════════════════════════════════
-- MAIN RENDER LOOP
-- ═══════════════════════════════════════════
local function RenderLoop()
    -- ESP
    for player, drawings in pairs(State.ESPCache) do
        if player and player.Parent then
            if Config.ESP.Enabled or Config.InventoryESP.Enabled then
                local ok, err = pcall(ESP.UpdatePlayer, player, drawings)
                if not ok then
                    ESP.HideAll(drawings)
                end
            else
                ESP.HideAll(drawings)
            end
        else
            ESP.DestroyDrawings(drawings)
            State.ESPCache[player] = nil
        end
    end

    -- FOV Circle
    if FOVCircle then
        if Config.Aimbot.Enabled and Config.Aimbot.ShowFOV then
            FOVCircle.Position     = Util.ScreenCenter()
            FOVCircle.Radius       = Config.Aimbot.FOV
            FOVCircle.Color        = Config.Aimbot.FOVColor
            FOVCircle.Transparency = Config.Aimbot.FOVTransparency
            FOVCircle.Visible      = true
        else
            FOVCircle.Visible = false
        end
    end

    -- Aimbot
    if Config.Aimbot.Enabled and State.AimbotHeld then
        local target
        if Config.Aimbot.StickyAim and State.CurrentTarget and Util.IsAlive(State.CurrentTarget) then
            target = State.CurrentTarget
        else
            target = Aimbot.FindTarget()
            State.CurrentTarget = target
        end

        if target and target.Character then
            local part = target.Character:FindFirstChild(Config.Aimbot.TargetPart)
            if part then
                local pos = Aimbot.PredictPosition(part)
                Aimbot.AimAt(pos)
            end
        else
            if TargetDot then pcall(function() TargetDot.Visible = false end) end
        end
    else
        if TargetDot then pcall(function() TargetDot.Visible = false end) end
    end

    -- Triggerbot
    pcall(Triggerbot.Process)

    -- HUD
    HUD.Update()
end

-- ═══════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════
local function Unload()
    for _, conn in pairs(State.Connections) do
        pcall(function()
            if conn and conn.Connected then conn:Disconnect() end
        end)
    end
    tClear(State.Connections)

    for _, drawings in pairs(State.ESPCache) do
        ESP.DestroyDrawings(drawings)
    end
    tClear(State.ESPCache)

    pcall(function() FOVCircle:Remove() end)
    pcall(function() TargetDot:Remove() end)

    HUD.Destroy()

    for _, n in ipairs(State.Notifications) do
        pcall(function() n.Drawing:Remove() end)
    end
    tClear(State.Notifications)

    -- Bye bye message
    pcall(function()
        local bye = Drawing.new("Text")
        bye.Text = "  [PHANTOM] Unloaded - Ciao!"
        bye.Size = 16
        bye.Font = FONT
        bye.Color = C3(255, 80, 80)
        bye.OutlineColor = C3(0, 0, 0)
        bye.Outline = true
        bye.Position = V2(12, 10)
        bye.Visible = true
        tSpawn(function()
            tWait(2)
            pcall(function() bye:Remove() end)
        end)
    end)
end

-- ═══════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════
local function Init()
    -- HUD
    HUD.Init()

    -- Register existing players
    for _, player in ipairs(Players:GetPlayers()) do
        ESP.Register(player)
    end

    State.Connections.Added = Players.PlayerAdded:Connect(function(p)
        ESP.Register(p)
    end)

    State.Connections.Removing = Players.PlayerRemoving:Connect(function(p)
        ESP.Unregister(p)
    end)

    State.Connections.InputBegan = UserInputService.InputBegan:Connect(OnInputBegan)
    State.Connections.InputEnded = UserInputService.InputEnded:Connect(OnInputEnded)

    State.Connections.Render = RunService.RenderStepped:Connect(function()
        if State.Running then
            local ok, err = pcall(RenderLoop)
            if not ok then
                warn("[PHANTOM] Render error: " .. tostring(err))
            end
        else
            Unload()
        end
    end)

    -- Welcome
    Notify.Send("Loaded! Premi F8 per Unload", C3(180, 80, 255), 4)
    Notify.Send("F1=ESP  F2=Inv  F3=Aim  F4=Trig", C3(200, 200, 200), 5)

    -- Debug info
    local info = "Mouse:" .. (HAS_MOUSEMOVEREL and "OK" or "NO")
    info = info .. " | Click:" .. (HAS_MOUSE1CLICK and "OK" or "NO")
    Notify.Send(info, C3(150, 150, 150), 6)
end

-- GO!
local initOk, initErr = pcall(Init)
if not initOk then
    warn("[PHANTOM] INIT ERROR: " .. tostring(initErr))
    -- Try to show error on screen
    pcall(function()
        local err = Drawing.new("Text")
        err.Text = "[PHANTOM] ERROR: " .. tostring(initErr)
        err.Size = 16
        err.Font = 2
        err.Color = C3(255, 0, 0)
        err.OutlineColor = C3(0, 0, 0)
        err.Outline = true
        err.Position = V2(12, 10)
        err.Visible = true
    end)
end
