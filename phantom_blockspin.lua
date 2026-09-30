--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║     PHANTOM v2.0 · BlockSpin Stealth Suite                    ║
    ║     Full GUI Edition · Built for Xeno                         ║
    ╠═══════════════════════════════════════════════════════════════╣
    ║  Premi G per aprire/chiudere il menu                          ║
    ║  Tutte le opzioni sono nel GUI                                ║
    ╚═══════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════
-- SAFE FONT DETECTION
-- ═══════════════════════════════════════════════════
local function getFont()
    local ok, fonts = pcall(function() return Drawing.Fonts end)
    if ok and fonts then
        if fonts.Plex then return fonts.Plex end
        if fonts.UI then return fonts.UI end
        if fonts.System then return fonts.System end
    end
    return 2
end
local FONT = getFont()

-- Feature detection
local HAS_MOUSEMOVEREL = pcall(function() return typeof(mousemoverel) == "function" end)
local HAS_MOUSE1CLICK  = pcall(function() return typeof(mouse1click) == "function" end)

-- ═══════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- Cached math
local mFloor  = math.floor
local mSqrt   = math.sqrt
local mRandom = math.random
local mAbs    = math.abs
local mHuge   = math.huge
local mClamp  = math.clamp
local mCos    = math.cos
local mSin    = math.sin
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

-- ═══════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════
local Config = {
    -- ── ESP ──
    ESP = {
        Enabled         = false,
        BoxStyle        = "Full",       -- "Full" / "Corner"
        BoxThickness    = 1.3,
        BoxOutline      = true,
        Names           = true,
        NameSize        = 14,
        HealthBar       = true,
        HealthBarPos    = "Left",       -- "Left" / "Right"
        HealthBarWidth  = 3,
        Distance        = true,
        Tracers         = false,
        TracerOrigin    = "Bottom",     -- "Bottom" / "Center" / "Top" / "Mouse"
        TracerThickness = 1,
        HeadDot         = false,
        HeadDotSize     = 3,
        VisibilityCheck = true,
        VisibleColor    = C3(50, 255, 100),
        NotVisibleColor = C3(255, 50, 80),
        DefaultColor    = C3(255, 50, 80),
        NameColor       = C3(255, 255, 255),
        DistanceColor   = C3(200, 200, 200),
        MaxDistance      = 1000,
        TeamCheck        = false,
        ShowTeamColor    = false,
    },

    -- ── INVENTORY ESP ──
    InventoryESP = {
        Enabled      = false,
        ShowEquipped = true,
        ShowBackpack = true,
        TextColor    = C3(0, 255, 210),
        TextSize     = 12,
    },

    -- ── AIMBOT ──
    Aimbot = {
        Enabled              = false,
        ActivationMode       = "Hold",     -- "Hold" / "Toggle"
        ActivationKey        = Enum.UserInputType.MouseButton2,
        TargetPart           = "Head",     -- "Head" / "UpperTorso" / "HumanoidRootPart" / "LowerTorso"
        TargetMode           = "Crosshair", -- "Crosshair" (nearest to center) / "Distance" (nearest 3D)
        MaxDistance           = 500,
        FOV                  = 120,
        ShowFOV              = true,
        FOVColor             = C3(255, 255, 255),
        FOVThickness         = 1,
        FOVTransparency      = 0.6,
        FOVSides             = 64,
        Smoothing            = 6,          -- 1 = instant (risky!), 20 = very slow
        HumanizeJitter       = true,
        JitterStrength       = 0.4,
        Prediction           = true,
        PredictionMultiplier = 0.135,
        WallCheck            = true,
        StickyAim            = false,
        TeamCheck            = false,
        AimAssist            = false,       -- Weaker aimbot, just nudges
        AssistStrength        = 12,         -- Higher = weaker assist
        ShowTargetInfo       = true,        -- Show target name/health on screen
    },

    -- ── TRIGGERBOT ──
    Triggerbot = {
        Enabled       = false,
        ActivationMode = "Hold",       -- "Hold" / "Always"
        ActivationKey = Enum.KeyCode.LeftAlt,
        MinDelay      = 0.06,
        MaxDelay      = 0.18,
        MaxDistance    = 300,
        HitChance     = 95,
        HeadshotOnly  = false,
        BurstMode     = false,
        BurstCount    = 3,
        BurstDelay    = 0.05,
        TeamCheck     = false,
        TargetParts   = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart",
                         "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"},
    },

    -- ── MISC ──
    Misc = {
        ShowWatermark = true,
        GUIToggleKey  = Enum.KeyCode.G,
    },
}

-- ═══════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════
local State = {
    Running        = true,
    AimbotHeld     = false,
    AimbotToggled  = false,
    TriggerbotHeld = false,
    CurrentTarget  = nil,
    Connections    = {},
    ESPCache       = {},
    Notifications  = {},
    GUIVisible     = true,
}

-- ═══════════════════════════════════════════════════
-- ANTI-DETECTION (safe)
-- ═══════════════════════════════════════════════════
pcall(function()
    if not hookmetamethod or not newcclosure or not getnamecallmethod then return end
    local bl = {"anticheat","anti_cheat","anti-cheat","ac_check","ac_flag","detect",
                "security","validate","verify","integrity","guard","shield",
                "monitor","cheat","exploit","kick_player","ban"}
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if m == "FireServer" or m == "InvokeServer" then
            if self and self.Name then
                local rn = self.Name:lower()
                for _, p in ipairs(bl) do
                    if rn:find(p, 1, true) then return nil end
                end
            end
        end
        return old(self, ...)
    end))
end)

-- ═══════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════
local Util = {}

function Util.W2S(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    return V2(sp.X, sp.Y), on, sp.Z
end

function Util.D2(a, b)
    return mSqrt((a.X-b.X)^2 + (a.Y-b.Y)^2)
end

function Util.D3(a, b)
    return (a - b).Magnitude
end

function Util.Alive(p)
    if not p or not p.Parent then return false end
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    if not c:FindFirstChild("HumanoidRootPart") then return false end
    return true
end

function Util.Visible(origin, target, plr)
    local params = RParams()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local fl = {Camera}
    if LocalPlayer.Character then tInsert(fl, LocalPlayer.Character) end
    params.FilterDescendantsInstances = fl
    local r = Workspace:Raycast(origin, target - origin, params)
    if not r then return true end
    if plr and plr.Character and r.Instance:IsDescendantOf(plr.Character) then return true end
    return false
end

function Util.IsTeam(p)
    if p.Team and LocalPlayer.Team then return p.Team == LocalPlayer.Team end
    return false
end

function Util.Center()
    local vp = Camera.ViewportSize
    return V2(vp.X/2, vp.Y/2)
end

function Util.RF(a, b)
    return a + math.random() * (b - a)
end

function Util.MousePos()
    return UserInputService:GetMouseLocation()
end

-- ═══════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════
local Notify = {}
function Notify.Send(text, color, dur)
    color = color or C3(255,255,255)
    dur = dur or 2.5
    local ok, lbl = pcall(function()
        local d = Drawing.new("Text")
        d.Text = "  [PHANTOM]  " .. text
        d.Size = 16; d.Font = FONT
        d.Color = color; d.OutlineColor = C3(0,0,0); d.Outline = true
        d.Position = V2(12, 10 + (#State.Notifications * 22))
        d.Visible = true
        return d
    end)
    if not ok then warn("[PHANTOM] " .. text) return end
    local entry = {Drawing = lbl}
    tInsert(State.Notifications, entry)
    tSpawn(function()
        tWait(dur)
        for i=1,10 do pcall(function() lbl.Transparency = 1-(i/10) end) tWait(0.03) end
        pcall(function() lbl:Remove() end)
        for idx, n in ipairs(State.Notifications) do
            if n == entry then
                tRemove(State.Notifications, idx)
                for j=idx,#State.Notifications do
                    pcall(function() State.Notifications[j].Drawing.Position = V2(12, 10+((j-1)*22)) end)
                end
                break
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════
-- ESP ENGINE
-- ═══════════════════════════════════════════════════
local ESP = {}

function ESP.Create()
    local d = {}
    pcall(function()
        -- Box (4 lines for corner style, or 1 square for full)
        d.Box = Drawing.new("Square")
        d.Box.Thickness = Config.ESP.BoxThickness; d.Box.Filled = false; d.Box.Visible = false

        d.BoxOutline = Drawing.new("Square")
        d.BoxOutline.Thickness = Config.ESP.BoxThickness + 2; d.BoxOutline.Filled = false; d.BoxOutline.Visible = false
        d.BoxOutline.Color = C3(0,0,0)

        -- Corner lines (8 lines for corner box)
        d.Corners = {}
        for i=1,8 do
            d.Corners[i] = Drawing.new("Line")
            d.Corners[i].Thickness = Config.ESP.BoxThickness; d.Corners[i].Visible = false
        end
        d.CornerOutlines = {}
        for i=1,8 do
            d.CornerOutlines[i] = Drawing.new("Line")
            d.CornerOutlines[i].Thickness = Config.ESP.BoxThickness + 2; d.CornerOutlines[i].Visible = false
            d.CornerOutlines[i].Color = C3(0,0,0)
        end

        d.Name = Drawing.new("Text")
        d.Name.Size = Config.ESP.NameSize; d.Name.Font = FONT
        d.Name.Outline = true; d.Name.OutlineColor = C3(0,0,0); d.Name.Visible = false

        d.Dist = Drawing.new("Text")
        d.Dist.Size = 12; d.Dist.Font = FONT
        d.Dist.Outline = true; d.Dist.OutlineColor = C3(0,0,0); d.Dist.Visible = false

        d.HealthBG = Drawing.new("Line")
        d.HealthBG.Thickness = Config.ESP.HealthBarWidth + 2; d.HealthBG.Visible = false

        d.Health = Drawing.new("Line")
        d.Health.Thickness = Config.ESP.HealthBarWidth; d.Health.Visible = false

        d.Tracer = Drawing.new("Line")
        d.Tracer.Thickness = Config.ESP.TracerThickness; d.Tracer.Visible = false

        d.HeadDot = Drawing.new("Circle")
        d.HeadDot.Filled = true; d.HeadDot.NumSides = 12
        d.HeadDot.Radius = Config.ESP.HeadDotSize; d.HeadDot.Visible = false

        d.Inventory = Drawing.new("Text")
        d.Inventory.Size = Config.InventoryESP.TextSize; d.Inventory.Font = FONT
        d.Inventory.Outline = true; d.Inventory.OutlineColor = C3(0,0,0); d.Inventory.Visible = false
    end)
    return d
end

function ESP.Destroy(d)
    if not d then return end
    for k, v in pairs(d) do
        if typeof(v) == "table" then
            for _, line in pairs(v) do pcall(function() line:Remove() end) end
        else
            pcall(function() v:Remove() end)
        end
    end
end

function ESP.HideAll(d)
    if not d then return end
    for k, v in pairs(d) do
        if typeof(v) == "table" then
            for _, line in pairs(v) do pcall(function() line.Visible = false end) end
        else
            pcall(function() v.Visible = false end)
        end
    end
end

function ESP.Register(p)
    if p == LocalPlayer or State.ESPCache[p] then return end
    State.ESPCache[p] = ESP.Create()
end

function ESP.Unregister(p)
    if State.ESPCache[p] then
        ESP.Destroy(State.ESPCache[p])
        State.ESPCache[p] = nil
    end
end

function ESP.DrawCornerBox(d, x, y, w, h, color)
    local cornerLen = mClamp(w * 0.25, 4, 20)
    local lines = d.Corners
    local outlines = d.CornerOutlines

    -- Top-left
    lines[1].From = V2(x, y); lines[1].To = V2(x + cornerLen, y)
    lines[2].From = V2(x, y); lines[2].To = V2(x, y + cornerLen)
    -- Top-right
    lines[3].From = V2(x+w, y); lines[3].To = V2(x+w - cornerLen, y)
    lines[4].From = V2(x+w, y); lines[4].To = V2(x+w, y + cornerLen)
    -- Bottom-left
    lines[5].From = V2(x, y+h); lines[5].To = V2(x + cornerLen, y+h)
    lines[6].From = V2(x, y+h); lines[6].To = V2(x, y+h - cornerLen)
    -- Bottom-right
    lines[7].From = V2(x+w, y+h); lines[7].To = V2(x+w - cornerLen, y+h)
    lines[8].From = V2(x+w, y+h); lines[8].To = V2(x+w, y+h - cornerLen)

    for i=1,8 do
        lines[i].Color = color
        lines[i].Thickness = Config.ESP.BoxThickness
        lines[i].Visible = true
        if Config.ESP.BoxOutline then
            outlines[i].From = lines[i].From
            outlines[i].To = lines[i].To
            outlines[i].Thickness = Config.ESP.BoxThickness + 2
            outlines[i].Visible = true
        else
            outlines[i].Visible = false
        end
    end
end

function ESP.HideCornerBox(d)
    for i=1,8 do
        pcall(function() d.Corners[i].Visible = false end)
        pcall(function() d.CornerOutlines[i].Visible = false end)
    end
end

function ESP.Update(player, d)
    if not Util.Alive(player) then ESP.HideAll(d) return end
    if Config.ESP.TeamCheck and Util.IsTeam(player) then ESP.HideAll(d) return end

    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    if not root or not hum then ESP.HideAll(d) return end

    local camPos = Camera.CFrame.Position
    local dist = Util.D3(root.Position, camPos)
    if dist > Config.ESP.MaxDistance then ESP.HideAll(d) return end

    local sTop, onT = Util.W2S(root.Position + V3(0, 3.2, 0))
    local sBot, onB = Util.W2S(root.Position - V3(0, 3.2, 0))
    if not onT and not onB then ESP.HideAll(d) return end

    local boxH = mAbs(sBot.Y - sTop.Y)
    local boxW = boxH * 0.55
    local boxX = sTop.X - boxW/2
    local boxY = sTop.Y

    -- Color
    local col
    if Config.ESP.ShowTeamColor and player.Team then
        col = player.TeamColor.Color
    elseif Config.ESP.VisibilityCheck then
        col = Util.Visible(camPos, root.Position, player) and Config.ESP.VisibleColor or Config.ESP.NotVisibleColor
    else
        col = Config.ESP.DefaultColor
    end

    -- ── BOX ──
    if Config.ESP.Enabled then
        if Config.ESP.BoxStyle == "Corner" then
            d.Box.Visible = false; d.BoxOutline.Visible = false
            ESP.DrawCornerBox(d, boxX, boxY, boxW, boxH, col)
        else
            ESP.HideCornerBox(d)
            if Config.ESP.BoxOutline and d.BoxOutline then
                d.BoxOutline.Position = V2(boxX, boxY)
                d.BoxOutline.Size = V2(boxW, boxH)
                d.BoxOutline.Thickness = Config.ESP.BoxThickness + 2
                d.BoxOutline.Visible = true
            elseif d.BoxOutline then
                d.BoxOutline.Visible = false
            end
            d.Box.Position = V2(boxX, boxY)
            d.Box.Size = V2(boxW, boxH)
            d.Box.Color = col
            d.Box.Thickness = Config.ESP.BoxThickness
            d.Box.Visible = true
        end
    else
        d.Box.Visible = false; d.BoxOutline.Visible = false
        ESP.HideCornerBox(d)
    end

    -- ── NAME ──
    if Config.ESP.Enabled and Config.ESP.Names and d.Name then
        d.Name.Text = player.DisplayName
        d.Name.Color = Config.ESP.NameColor
        d.Name.Size = Config.ESP.NameSize
        local tb = d.Name.TextBounds
        d.Name.Position = V2(sTop.X - tb.X/2, sTop.Y - tb.Y - 3)
        d.Name.Visible = true
    elseif d.Name then d.Name.Visible = false end

    -- ── DISTANCE ──
    if Config.ESP.Enabled and Config.ESP.Distance and d.Dist then
        d.Dist.Text = mFloor(dist) .. "m"
        d.Dist.Color = Config.ESP.DistanceColor
        local tb = d.Dist.TextBounds
        d.Dist.Position = V2(sBot.X - tb.X/2, sBot.Y + 3)
        d.Dist.Visible = true
    elseif d.Dist then d.Dist.Visible = false end

    -- ── HEALTH BAR ──
    if Config.ESP.Enabled and Config.ESP.HealthBar and d.HealthBG and d.Health then
        local pct = mClamp(hum.Health / hum.MaxHealth, 0, 1)
        local barX
        if Config.ESP.HealthBarPos == "Right" then
            barX = boxX + boxW + Config.ESP.HealthBarWidth + 2
        else
            barX = boxX - Config.ESP.HealthBarWidth - 4
        end
        d.HealthBG.From = V2(barX, boxY); d.HealthBG.To = V2(barX, boxY + boxH)
        d.HealthBG.Color = C3(25,25,25); d.HealthBG.Visible = true
        local hH = boxH * pct
        d.Health.From = V2(barX, boxY + boxH - hH); d.Health.To = V2(barX, boxY + boxH)
        d.Health.Color = C3(mFloor((1-pct)*255), mFloor(pct*255), 50)
        d.Health.Visible = true
    elseif d.HealthBG then d.HealthBG.Visible = false; d.Health.Visible = false end

    -- ── TRACERS ──
    if Config.ESP.Enabled and Config.ESP.Tracers and d.Tracer then
        local vp = Camera.ViewportSize
        local origin
        if Config.ESP.TracerOrigin == "Bottom" then origin = V2(vp.X/2, vp.Y)
        elseif Config.ESP.TracerOrigin == "Top" then origin = V2(vp.X/2, 0)
        elseif Config.ESP.TracerOrigin == "Mouse" then origin = Util.MousePos()
        else origin = V2(vp.X/2, vp.Y/2) end
        d.Tracer.From = origin; d.Tracer.To = sBot
        d.Tracer.Color = col; d.Tracer.Thickness = Config.ESP.TracerThickness
        d.Tracer.Visible = true
    elseif d.Tracer then d.Tracer.Visible = false end

    -- ── HEAD DOT ──
    if Config.ESP.Enabled and Config.ESP.HeadDot and head and d.HeadDot then
        local headScreen, headOn = Util.W2S(head.Position)
        if headOn then
            d.HeadDot.Position = headScreen
            d.HeadDot.Radius = mClamp(Config.ESP.HeadDotSize * (200 / dist), 1, 8)
            d.HeadDot.Color = col
            d.HeadDot.Visible = true
        else d.HeadDot.Visible = false end
    elseif d.HeadDot then d.HeadDot.Visible = false end

    -- ── INVENTORY ESP ──
    if Config.InventoryESP.Enabled and d.Inventory then
        local items = {}
        if Config.InventoryESP.ShowEquipped then
            for _, c in ipairs(char:GetChildren()) do
                if c:IsA("Tool") then tInsert(items, "[E] " .. c.Name) end
            end
        end
        if Config.InventoryESP.ShowBackpack then
            local bp = player:FindFirstChild("Backpack")
            if bp then
                for _, c in ipairs(bp:GetChildren()) do
                    if c:IsA("Tool") then tInsert(items, "[B] " .. c.Name) end
                end
            end
        end
        if #items > 0 then
            d.Inventory.Text = tConcat(items, " | ")
            d.Inventory.Color = Config.InventoryESP.TextColor
            d.Inventory.Size = Config.InventoryESP.TextSize
            local yOff = sBot.Y + 18
            if Config.ESP.Distance then yOff = yOff + 16 end
            local tb = d.Inventory.TextBounds
            d.Inventory.Position = V2(sBot.X - tb.X/2, yOff)
            d.Inventory.Visible = true
        else d.Inventory.Visible = false end
    elseif d.Inventory then d.Inventory.Visible = false end
end

-- ═══════════════════════════════════════════════════
-- AIMBOT ENGINE
-- ═══════════════════════════════════════════════════
local Aimbot = {}

local FOVCircle, TargetDot, TargetInfo
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Filled = false; FOVCircle.NumSides = 64
    FOVCircle.Thickness = 1; FOVCircle.Visible = false

    TargetDot = Drawing.new("Circle")
    TargetDot.Filled = true; TargetDot.NumSides = 16
    TargetDot.Radius = 4; TargetDot.Color = C3(255,50,80); TargetDot.Visible = false

    TargetInfo = Drawing.new("Text")
    TargetInfo.Size = 14; TargetInfo.Font = FONT
    TargetInfo.Outline = true; TargetInfo.OutlineColor = C3(0,0,0)
    TargetInfo.Color = C3(255,200,50); TargetInfo.Visible = false
end)

function Aimbot.IsActive()
    if not Config.Aimbot.Enabled then return false end
    if Config.Aimbot.ActivationMode == "Toggle" then
        return State.AimbotToggled
    else
        return State.AimbotHeld
    end
end

function Aimbot.FindTarget()
    local best, bestVal = nil, mHuge
    local center = Util.Center()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and Util.Alive(p) then
            if not (Config.Aimbot.TeamCheck and Util.IsTeam(p)) then
                local part = p.Character:FindFirstChild(Config.Aimbot.TargetPart)
                if part then
                    local d3 = Util.D3(part.Position, Camera.CFrame.Position)
                    if d3 <= Config.Aimbot.MaxDistance then
                        local sp, on = Util.W2S(part.Position)
                        if on then
                            local val
                            if Config.Aimbot.TargetMode == "Distance" then
                                val = d3
                            else
                                val = Util.D2(sp, center)
                            end

                            if val <= Config.Aimbot.FOV and val < bestVal then
                                if Config.Aimbot.WallCheck then
                                    if Util.Visible(Camera.CFrame.Position, part.Position, p) then
                                        best = p; bestVal = val
                                    end
                                else
                                    best = p; bestVal = val
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

function Aimbot.Predict(part)
    if not Config.Aimbot.Prediction then return part.Position end
    local vel = V3(0,0,0)
    pcall(function() vel = part.AssemblyLinearVelocity end)
    if vel.Magnitude < 0.1 then pcall(function() vel = part.Velocity end) end
    return part.Position + (vel * Config.Aimbot.PredictionMultiplier)
end

function Aimbot.AimAt(worldPos)
    if not HAS_MOUSEMOVEREL then return end
    local sp, on = Util.W2S(worldPos)
    if not on then return end

    local center = Util.Center()
    local delta = sp - center

    -- Use Aim Assist strength or regular smoothing
    local smooth = Config.Aimbot.AimAssist and Config.Aimbot.AssistStrength or Config.Aimbot.Smoothing

    local mx = delta.X / smooth
    local my = delta.Y / smooth

    if Config.Aimbot.HumanizeJitter then
        local js = Config.Aimbot.JitterStrength
        mx = mx + Util.RF(-js, js)
        my = my + Util.RF(-js, js)
    end

    mousemoverel(mx, my)

    if TargetDot then TargetDot.Position = sp; TargetDot.Visible = true end
end

-- ═══════════════════════════════════════════════════
-- TRIGGERBOT ENGINE
-- ═══════════════════════════════════════════════════
local Triggerbot = {}
local _lastTrig = 0
local _burstCount = 0

function Triggerbot.IsActive()
    if not Config.Triggerbot.Enabled then return false end
    if Config.Triggerbot.ActivationMode == "Always" then return true end
    return State.TriggerbotHeld
end

function Triggerbot.Process()
    if not Triggerbot.IsActive() then return end
    if not HAS_MOUSE1CLICK then return end

    local now = Tick()
    local delay = Util.RF(Config.Triggerbot.MinDelay, Config.Triggerbot.MaxDelay)
    if now - _lastTrig < delay then return end
    if mRandom(1, 100) > Config.Triggerbot.HitChance then _lastTrig = now return end

    local center = Util.Center()
    local ray = Camera:ViewportPointToRay(center.X, center.Y)
    local params = RParams()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local fl = {Camera}
    if LocalPlayer.Character then tInsert(fl, LocalPlayer.Character) end
    params.FilterDescendantsInstances = fl

    local r = Workspace:Raycast(ray.Origin, ray.Direction * Config.Triggerbot.MaxDistance, params)
    if not r or not r.Instance then return end

    local hitChar = r.Instance:FindFirstAncestorOfClass("Model")
    if not hitChar then return end
    local hitP = Players:GetPlayerFromCharacter(hitChar)
    if not hitP or hitP == LocalPlayer then return end
    if Config.Triggerbot.TeamCheck and Util.IsTeam(hitP) then return end

    -- Headshot only check
    if Config.Triggerbot.HeadshotOnly then
        if r.Instance.Name ~= "Head" then return end
    else
        local valid = false
        for _, pn in ipairs(Config.Triggerbot.TargetParts) do
            if r.Instance.Name == pn then valid = true; break end
        end
        if not valid then return end
    end

    -- Burst mode
    if Config.Triggerbot.BurstMode then
        for i = 1, Config.Triggerbot.BurstCount do
            mouse1click()
            if i < Config.Triggerbot.BurstCount then
                tWait(Config.Triggerbot.BurstDelay)
            end
        end
    else
        mouse1click()
    end
    _lastTrig = now
end

-- ═══════════════════════════════════════════════════
-- HUD WATERMARK
-- ═══════════════════════════════════════════════════
local _wm = {}
pcall(function()
    _wm.title = Drawing.new("Text")
    _wm.title.Text = "PHANTOM v2.0"; _wm.title.Size = 18; _wm.title.Font = FONT
    _wm.title.Color = C3(180,80,255); _wm.title.OutlineColor = C3(0,0,0)
    _wm.title.Outline = true; _wm.title.Position = V2(12, 8); _wm.title.Visible = true

    _wm.line = Drawing.new("Line")
    _wm.line.From = V2(12, 28); _wm.line.To = V2(155, 28)
    _wm.line.Color = C3(180,80,255); _wm.line.Thickness = 1; _wm.line.Visible = true

    _wm.fps = Drawing.new("Text")
    _wm.fps.Size = 12; _wm.fps.Font = FONT; _wm.fps.Color = C3(150,150,150)
    _wm.fps.Outline = true; _wm.fps.OutlineColor = C3(0,0,0)
    _wm.fps.Position = V2(12, 30); _wm.fps.Visible = true
end)

local _fpsFrames = {}
local function updateWatermark()
    if not Config.Misc.ShowWatermark then
        pcall(function() _wm.title.Visible = false; _wm.line.Visible = false; _wm.fps.Visible = false end)
        return
    end
    -- FPS counter
    local now = Tick()
    tInsert(_fpsFrames, now)
    while #_fpsFrames > 0 and _fpsFrames[1] < now - 1 do tRemove(_fpsFrames, 1) end
    pcall(function()
        _wm.fps.Text = #_fpsFrames .. " FPS | " .. #Players:GetPlayers() - 1 .. " players"
        _wm.title.Visible = true; _wm.line.Visible = true; _wm.fps.Visible = true
    end)
end

-- ═══════════════════════════════════════════════════
-- LOAD RAYFIELD GUI
-- ═══════════════════════════════════════════════════
local Rayfield
local Window

local guiOk, guiErr = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    Window = Rayfield:CreateWindow({
        Name = "PHANTOM v2.0",
        LoadingTitle = "PHANTOM",
        LoadingSubtitle = "BlockSpin Stealth Suite",
        Theme = "Amethyst",
        DisableRayfieldPrompts = true,
        DisableBuildWarnings = true,
        ConfigurationSaving = { Enabled = false },
        KeySystem = false,
    })

    -- ╔═══════════════════════════════════════╗
    -- ║           TAB: ESP                     ║
    -- ╚═══════════════════════════════════════╝
    local TabESP = Window:CreateTab("ESP", 4483362458)

    TabESP:CreateSection("Generale")

    TabESP:CreateToggle({
        Name = "Abilita ESP",
        CurrentValue = Config.ESP.Enabled,
        Callback = function(v) Config.ESP.Enabled = v end,
    })

    TabESP:CreateDropdown({
        Name = "Stile Box",
        Options = {"Full", "Corner"},
        CurrentOption = {Config.ESP.BoxStyle},
        Callback = function(v) Config.ESP.BoxStyle = v[1] or v end,
    })

    TabESP:CreateSlider({
        Name = "Spessore Box",
        Range = {1, 5},
        Increment = 0.1,
        CurrentValue = Config.ESP.BoxThickness,
        Callback = function(v) Config.ESP.BoxThickness = v end,
    })

    TabESP:CreateToggle({
        Name = "Contorno Box (Outline)",
        CurrentValue = Config.ESP.BoxOutline,
        Callback = function(v) Config.ESP.BoxOutline = v end,
    })

    TabESP:CreateSection("Informazioni")

    TabESP:CreateToggle({
        Name = "Mostra Nomi",
        CurrentValue = Config.ESP.Names,
        Callback = function(v) Config.ESP.Names = v end,
    })

    TabESP:CreateSlider({
        Name = "Dimensione Nome",
        Range = {10, 24},
        Increment = 1,
        CurrentValue = Config.ESP.NameSize,
        Callback = function(v) Config.ESP.NameSize = v end,
    })

    TabESP:CreateToggle({
        Name = "Mostra Distanza",
        CurrentValue = Config.ESP.Distance,
        Callback = function(v) Config.ESP.Distance = v end,
    })

    TabESP:CreateToggle({
        Name = "Barra Vita",
        CurrentValue = Config.ESP.HealthBar,
        Callback = function(v) Config.ESP.HealthBar = v end,
    })

    TabESP:CreateDropdown({
        Name = "Posizione Barra Vita",
        Options = {"Left", "Right"},
        CurrentOption = {Config.ESP.HealthBarPos},
        Callback = function(v) Config.ESP.HealthBarPos = v[1] or v end,
    })

    TabESP:CreateToggle({
        Name = "Punto sulla Testa (Head Dot)",
        CurrentValue = Config.ESP.HeadDot,
        Callback = function(v) Config.ESP.HeadDot = v end,
    })

    TabESP:CreateSlider({
        Name = "Dimensione Head Dot",
        Range = {1, 8},
        Increment = 0.5,
        CurrentValue = Config.ESP.HeadDotSize,
        Callback = function(v) Config.ESP.HeadDotSize = v end,
    })

    TabESP:CreateSection("Tracers")

    TabESP:CreateToggle({
        Name = "Mostra Tracers",
        CurrentValue = Config.ESP.Tracers,
        Callback = function(v) Config.ESP.Tracers = v end,
    })

    TabESP:CreateDropdown({
        Name = "Origine Tracer",
        Options = {"Bottom", "Center", "Top", "Mouse"},
        CurrentOption = {Config.ESP.TracerOrigin},
        Callback = function(v) Config.ESP.TracerOrigin = v[1] or v end,
    })

    TabESP:CreateSlider({
        Name = "Spessore Tracer",
        Range = {1, 5},
        Increment = 0.5,
        CurrentValue = Config.ESP.TracerThickness,
        Callback = function(v) Config.ESP.TracerThickness = v end,
    })

    TabESP:CreateSection("Colori & Visibilita")

    TabESP:CreateToggle({
        Name = "Check Visibilita (verde/rosso)",
        CurrentValue = Config.ESP.VisibilityCheck,
        Callback = function(v) Config.ESP.VisibilityCheck = v end,
    })

    TabESP:CreateToggle({
        Name = "Mostra Colore Squadra",
        CurrentValue = Config.ESP.ShowTeamColor,
        Callback = function(v) Config.ESP.ShowTeamColor = v end,
    })

    TabESP:CreateColorPicker({
        Name = "Colore Visibile",
        Color = Config.ESP.VisibleColor,
        Callback = function(v) Config.ESP.VisibleColor = v end,
    })

    TabESP:CreateColorPicker({
        Name = "Colore Non Visibile",
        Color = Config.ESP.NotVisibleColor,
        Callback = function(v) Config.ESP.NotVisibleColor = v end,
    })

    TabESP:CreateColorPicker({
        Name = "Colore Default",
        Color = Config.ESP.DefaultColor,
        Callback = function(v) Config.ESP.DefaultColor = v end,
    })

    TabESP:CreateColorPicker({
        Name = "Colore Nome",
        Color = Config.ESP.NameColor,
        Callback = function(v) Config.ESP.NameColor = v end,
    })

    TabESP:CreateSection("Limiti")

    TabESP:CreateSlider({
        Name = "Distanza Massima (studs)",
        Range = {100, 2000},
        Increment = 50,
        Suffix = "m",
        CurrentValue = Config.ESP.MaxDistance,
        Callback = function(v) Config.ESP.MaxDistance = v end,
    })

    TabESP:CreateToggle({
        Name = "Ignora Squadra",
        CurrentValue = Config.ESP.TeamCheck,
        Callback = function(v) Config.ESP.TeamCheck = v end,
    })

    -- ╔═══════════════════════════════════════╗
    -- ║      TAB: INVENTORY ESP                ║
    -- ╚═══════════════════════════════════════╝
    local TabInv = Window:CreateTab("Inventario", 4483362458)

    TabInv:CreateToggle({
        Name = "Abilita Inventory ESP",
        CurrentValue = Config.InventoryESP.Enabled,
        Callback = function(v) Config.InventoryESP.Enabled = v end,
    })

    TabInv:CreateToggle({
        Name = "Mostra Tool Equipaggiati",
        CurrentValue = Config.InventoryESP.ShowEquipped,
        Callback = function(v) Config.InventoryESP.ShowEquipped = v end,
    })

    TabInv:CreateToggle({
        Name = "Mostra Tool nello Zaino",
        CurrentValue = Config.InventoryESP.ShowBackpack,
        Callback = function(v) Config.InventoryESP.ShowBackpack = v end,
    })

    TabInv:CreateColorPicker({
        Name = "Colore Testo",
        Color = Config.InventoryESP.TextColor,
        Callback = function(v) Config.InventoryESP.TextColor = v end,
    })

    TabInv:CreateSlider({
        Name = "Dimensione Testo",
        Range = {8, 24},
        Increment = 1,
        CurrentValue = Config.InventoryESP.TextSize,
        Callback = function(v) Config.InventoryESP.TextSize = v end,
    })

    -- ╔═══════════════════════════════════════╗
    -- ║           TAB: AIMBOT                  ║
    -- ╚═══════════════════════════════════════╝
    local TabAim = Window:CreateTab("Aimbot", 4483362458)

    TabAim:CreateSection("Generale")

    TabAim:CreateToggle({
        Name = "Abilita Aimbot",
        CurrentValue = Config.Aimbot.Enabled,
        Callback = function(v) Config.Aimbot.Enabled = v end,
    })

    TabAim:CreateDropdown({
        Name = "Modalita Attivazione",
        Options = {"Hold", "Toggle"},
        CurrentOption = {Config.Aimbot.ActivationMode},
        Callback = function(v)
            Config.Aimbot.ActivationMode = v[1] or v
            State.AimbotToggled = false
        end,
    })

    TabAim:CreateToggle({
        Name = "Aim Assist (piu leggero)",
        CurrentValue = Config.Aimbot.AimAssist,
        Callback = function(v) Config.Aimbot.AimAssist = v end,
    })

    TabAim:CreateSlider({
        Name = "Forza Aim Assist",
        Range = {4, 30},
        Increment = 1,
        CurrentValue = Config.Aimbot.AssistStrength,
        Callback = function(v) Config.Aimbot.AssistStrength = v end,
    })

    TabAim:CreateSection("Targeting")

    TabAim:CreateDropdown({
        Name = "Parte del Corpo",
        Options = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
        CurrentOption = {Config.Aimbot.TargetPart},
        Callback = function(v) Config.Aimbot.TargetPart = v[1] or v end,
    })

    TabAim:CreateDropdown({
        Name = "Modalita Target",
        Options = {"Crosshair", "Distance"},
        CurrentOption = {Config.Aimbot.TargetMode},
        Callback = function(v) Config.Aimbot.TargetMode = v[1] or v end,
    })

    TabAim:CreateSlider({
        Name = "Distanza Massima",
        Range = {100, 1000},
        Increment = 25,
        Suffix = "m",
        CurrentValue = Config.Aimbot.MaxDistance,
        Callback = function(v) Config.Aimbot.MaxDistance = v end,
    })

    TabAim:CreateToggle({
        Name = "Wall Check",
        CurrentValue = Config.Aimbot.WallCheck,
        Callback = function(v) Config.Aimbot.WallCheck = v end,
    })

    TabAim:CreateToggle({
        Name = "Sticky Aim",
        CurrentValue = Config.Aimbot.StickyAim,
        Callback = function(v) Config.Aimbot.StickyAim = v end,
    })

    TabAim:CreateToggle({
        Name = "Ignora Squadra",
        CurrentValue = Config.Aimbot.TeamCheck,
        Callback = function(v) Config.Aimbot.TeamCheck = v end,
    })

    TabAim:CreateToggle({
        Name = "Mostra Info Target",
        CurrentValue = Config.Aimbot.ShowTargetInfo,
        Callback = function(v) Config.Aimbot.ShowTargetInfo = v end,
    })

    TabAim:CreateSection("FOV")

    TabAim:CreateSlider({
        Name = "Raggio FOV",
        Range = {30, 500},
        Increment = 5,
        Suffix = "px",
        CurrentValue = Config.Aimbot.FOV,
        Callback = function(v) Config.Aimbot.FOV = v end,
    })

    TabAim:CreateToggle({
        Name = "Mostra Cerchio FOV",
        CurrentValue = Config.Aimbot.ShowFOV,
        Callback = function(v) Config.Aimbot.ShowFOV = v end,
    })

    TabAim:CreateColorPicker({
        Name = "Colore FOV",
        Color = Config.Aimbot.FOVColor,
        Callback = function(v) Config.Aimbot.FOVColor = v end,
    })

    TabAim:CreateSlider({
        Name = "Trasparenza FOV",
        Range = {0, 1},
        Increment = 0.05,
        CurrentValue = Config.Aimbot.FOVTransparency,
        Callback = function(v) Config.Aimbot.FOVTransparency = v end,
    })

    TabAim:CreateSection("Smoothing & Umanizzazione")

    TabAim:CreateSlider({
        Name = "Smoothing (1=instant, 20=lento)",
        Range = {1, 25},
        Increment = 0.5,
        CurrentValue = Config.Aimbot.Smoothing,
        Callback = function(v) Config.Aimbot.Smoothing = v end,
    })

    TabAim:CreateToggle({
        Name = "Jitter Umano",
        CurrentValue = Config.Aimbot.HumanizeJitter,
        Callback = function(v) Config.Aimbot.HumanizeJitter = v end,
    })

    TabAim:CreateSlider({
        Name = "Forza Jitter",
        Range = {0.1, 2.0},
        Increment = 0.05,
        CurrentValue = Config.Aimbot.JitterStrength,
        Callback = function(v) Config.Aimbot.JitterStrength = v end,
    })

    TabAim:CreateSection("Predizione Movimento")

    TabAim:CreateToggle({
        Name = "Predizione",
        CurrentValue = Config.Aimbot.Prediction,
        Callback = function(v) Config.Aimbot.Prediction = v end,
    })

    TabAim:CreateSlider({
        Name = "Forza Predizione",
        Range = {0.05, 0.3},
        Increment = 0.005,
        CurrentValue = Config.Aimbot.PredictionMultiplier,
        Callback = function(v) Config.Aimbot.PredictionMultiplier = v end,
    })

    -- ╔═══════════════════════════════════════╗
    -- ║         TAB: TRIGGERBOT                ║
    -- ╚═══════════════════════════════════════╝
    local TabTrig = Window:CreateTab("Triggerbot", 4483362458)

    TabTrig:CreateSection("Generale")

    TabTrig:CreateToggle({
        Name = "Abilita Triggerbot",
        CurrentValue = Config.Triggerbot.Enabled,
        Callback = function(v) Config.Triggerbot.Enabled = v end,
    })

    TabTrig:CreateDropdown({
        Name = "Modalita Attivazione",
        Options = {"Hold", "Always"},
        CurrentOption = {Config.Triggerbot.ActivationMode},
        Callback = function(v) Config.Triggerbot.ActivationMode = v[1] or v end,
    })

    TabTrig:CreateSection("Timing")

    TabTrig:CreateSlider({
        Name = "Delay Minimo",
        Range = {0.01, 0.5},
        Increment = 0.01,
        Suffix = "s",
        CurrentValue = Config.Triggerbot.MinDelay,
        Callback = function(v) Config.Triggerbot.MinDelay = v end,
    })

    TabTrig:CreateSlider({
        Name = "Delay Massimo",
        Range = {0.05, 1.0},
        Increment = 0.01,
        Suffix = "s",
        CurrentValue = Config.Triggerbot.MaxDelay,
        Callback = function(v) Config.Triggerbot.MaxDelay = v end,
    })

    TabTrig:CreateSlider({
        Name = "Hit Chance",
        Range = {1, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = Config.Triggerbot.HitChance,
        Callback = function(v) Config.Triggerbot.HitChance = v end,
    })

    TabTrig:CreateSection("Targeting")

    TabTrig:CreateSlider({
        Name = "Distanza Massima",
        Range = {50, 500},
        Increment = 25,
        Suffix = "m",
        CurrentValue = Config.Triggerbot.MaxDistance,
        Callback = function(v) Config.Triggerbot.MaxDistance = v end,
    })

    TabTrig:CreateToggle({
        Name = "Solo Headshot",
        CurrentValue = Config.Triggerbot.HeadshotOnly,
        Callback = function(v) Config.Triggerbot.HeadshotOnly = v end,
    })

    TabTrig:CreateToggle({
        Name = "Ignora Squadra",
        CurrentValue = Config.Triggerbot.TeamCheck,
        Callback = function(v) Config.Triggerbot.TeamCheck = v end,
    })

    TabTrig:CreateSection("Burst Mode")

    TabTrig:CreateToggle({
        Name = "Burst Mode",
        CurrentValue = Config.Triggerbot.BurstMode,
        Callback = function(v) Config.Triggerbot.BurstMode = v end,
    })

    TabTrig:CreateSlider({
        Name = "Colpi per Burst",
        Range = {2, 8},
        Increment = 1,
        CurrentValue = Config.Triggerbot.BurstCount,
        Callback = function(v) Config.Triggerbot.BurstCount = v end,
    })

    TabTrig:CreateSlider({
        Name = "Delay tra Colpi",
        Range = {0.01, 0.15},
        Increment = 0.01,
        Suffix = "s",
        CurrentValue = Config.Triggerbot.BurstDelay,
        Callback = function(v) Config.Triggerbot.BurstDelay = v end,
    })

    -- ╔═══════════════════════════════════════╗
    -- ║        TAB: IMPOSTAZIONI               ║
    -- ╚═══════════════════════════════════════╝
    local TabSettings = Window:CreateTab("Settings", 4483362458)

    TabSettings:CreateSection("Interfaccia")

    TabSettings:CreateToggle({
        Name = "Mostra Watermark",
        CurrentValue = Config.Misc.ShowWatermark,
        Callback = function(v) Config.Misc.ShowWatermark = v end,
    })

    TabSettings:CreateLabel("Premi G per aprire/chiudere il menu")

    TabSettings:CreateSection("Pericolo")

    TabSettings:CreateButton({
        Name = "UNLOAD (Rimuovi Cheat)",
        Callback = function()
            State.Running = false
        end,
    })

    Notify.Send("GUI Caricata! Premi G per toggle", C3(180, 80, 255), 3)
end)

if not guiOk then
    warn("[PHANTOM] GUI Error: " .. tostring(guiErr))
    Notify.Send("GUI Error - vedi console (F9)", C3(255, 0, 0), 5)
end

-- ═══════════════════════════════════════════════════
-- INPUT HANDLER
-- ═══════════════════════════════════════════════════
local function OnInputBegan(input, gp)
    if gp then return end

    -- G = Toggle GUI
    if input.KeyCode == Config.Misc.GUIToggleKey then
        if Rayfield and Window then
            pcall(function()
                -- Rayfield window toggle
                State.GUIVisible = not State.GUIVisible
                if State.GUIVisible then
                    Rayfield:Show()
                else
                    Rayfield:Hide()
                end
            end)
        end
        return
    end

    -- Aimbot
    if input.UserInputType == Config.Aimbot.ActivationKey then
        if Config.Aimbot.ActivationMode == "Toggle" then
            State.AimbotToggled = not State.AimbotToggled
        else
            State.AimbotHeld = true
        end
    end

    -- Triggerbot
    if input.KeyCode == Config.Triggerbot.ActivationKey then
        State.TriggerbotHeld = true
    end
end

local function OnInputEnded(input, _)
    if input.UserInputType == Config.Aimbot.ActivationKey then
        State.AimbotHeld = false
        if Config.Aimbot.ActivationMode == "Hold" then
            State.CurrentTarget = nil
            if TargetDot then pcall(function() TargetDot.Visible = false end) end
            if TargetInfo then pcall(function() TargetInfo.Visible = false end) end
        end
    end
    if input.KeyCode == Config.Triggerbot.ActivationKey then
        State.TriggerbotHeld = false
    end
end

-- ═══════════════════════════════════════════════════
-- MAIN RENDER LOOP
-- ═══════════════════════════════════════════════════
local function RenderLoop()
    -- Camera refresh (in case it changes)
    Camera = Workspace.CurrentCamera

    -- ESP
    for player, drawings in pairs(State.ESPCache) do
        if player and player.Parent then
            if Config.ESP.Enabled or Config.InventoryESP.Enabled then
                pcall(ESP.Update, player, drawings)
            else
                ESP.HideAll(drawings)
            end
        else
            ESP.Destroy(drawings)
            State.ESPCache[player] = nil
        end
    end

    -- FOV Circle
    if FOVCircle then
        if Config.Aimbot.Enabled and Config.Aimbot.ShowFOV then
            FOVCircle.Position = Util.Center()
            FOVCircle.Radius = Config.Aimbot.FOV
            FOVCircle.Color = Config.Aimbot.FOVColor
            FOVCircle.Transparency = Config.Aimbot.FOVTransparency
            FOVCircle.NumSides = Config.Aimbot.FOVSides
            FOVCircle.Thickness = Config.Aimbot.FOVThickness
            FOVCircle.Visible = true
        else
            FOVCircle.Visible = false
        end
    end

    -- Aimbot
    if Aimbot.IsActive() then
        local target
        if Config.Aimbot.StickyAim and State.CurrentTarget and Util.Alive(State.CurrentTarget) then
            target = State.CurrentTarget
        else
            target = Aimbot.FindTarget()
            State.CurrentTarget = target
        end

        if target and target.Character then
            local part = target.Character:FindFirstChild(Config.Aimbot.TargetPart)
            if part then
                Aimbot.AimAt(Aimbot.Predict(part))

                -- Target info display
                if Config.Aimbot.ShowTargetInfo and TargetInfo then
                    local hum = target.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        TargetInfo.Text = target.DisplayName .. " | " .. mFloor(hum.Health) .. "/" .. mFloor(hum.MaxHealth)
                        local center = Util.Center()
                        TargetInfo.Position = V2(center.X - TargetInfo.TextBounds.X/2, center.Y + Config.Aimbot.FOV + 10)
                        TargetInfo.Visible = true
                    end
                end
            end
        else
            if TargetDot then pcall(function() TargetDot.Visible = false end) end
            if TargetInfo then pcall(function() TargetInfo.Visible = false end) end
        end
    else
        if TargetDot then pcall(function() TargetDot.Visible = false end) end
        if TargetInfo then pcall(function() TargetInfo.Visible = false end) end
    end

    -- Triggerbot
    pcall(Triggerbot.Process)

    -- Watermark
    updateWatermark()
end

-- ═══════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════
local function Unload()
    for _, c in pairs(State.Connections) do
        pcall(function() if c and c.Connected then c:Disconnect() end end)
    end
    tClear(State.Connections)

    for _, d in pairs(State.ESPCache) do ESP.Destroy(d) end
    tClear(State.ESPCache)

    pcall(function() FOVCircle:Remove() end)
    pcall(function() TargetDot:Remove() end)
    pcall(function() TargetInfo:Remove() end)
    for _, d in pairs(_wm) do pcall(function() d:Remove() end) end
    for _, n in ipairs(State.Notifications) do pcall(function() n.Drawing:Remove() end) end

    -- Destroy Rayfield
    pcall(function() Rayfield:Destroy() end)

    Notify.Send("PHANTOM Unloaded!", C3(255, 80, 80), 2)
end

-- ═══════════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════════
local function Init()
    for _, p in ipairs(Players:GetPlayers()) do ESP.Register(p) end

    State.Connections.Added = Players.PlayerAdded:Connect(function(p) ESP.Register(p) end)
    State.Connections.Removing = Players.PlayerRemoving:Connect(function(p) ESP.Unregister(p) end)
    State.Connections.InputBegan = UserInputService.InputBegan:Connect(OnInputBegan)
    State.Connections.InputEnded = UserInputService.InputEnded:Connect(OnInputEnded)

    State.Connections.Render = RunService.RenderStepped:Connect(function()
        if State.Running then
            pcall(RenderLoop)
        else
            Unload()
        end
    end)

    Notify.Send("PHANTOM v2.0 Loaded!", C3(180, 80, 255), 4)
    Notify.Send("Premi G per il menu", C3(200, 200, 200), 5)
end

local ok, err = pcall(Init)
if not ok then
    warn("[PHANTOM] INIT ERROR: " .. tostring(err))
    pcall(function()
        local e = Drawing.new("Text")
        e.Text = "[PHANTOM] ERROR: " .. tostring(err)
        e.Size = 16; e.Font = 2; e.Color = C3(255,0,0)
        e.OutlineColor = C3(0,0,0); e.Outline = true
        e.Position = V2(12, 10); e.Visible = true
    end)
end
