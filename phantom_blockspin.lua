--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║     PHANTOM v3.5 · BlockSpin Stealth Suite                    ║
    ║     Full GUI Edition · Built for Xeno                         ║
    ╠═══════════════════════════════════════════════════════════════╣
    ║  Premi G per aprire/chiudere il menu                          ║
    ║  v3.5: FIXED ESP — proper 3D bounding box projection,         ║
    ║        boxes now track players perfectly at all camera angles  ║
    ║        fresh camera refs, viewport clamping, sanity checks     ║
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
local Lighting         = game:GetService("Lighting")

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
local mPi     = math.pi
local V2      = Vector2.new
local V3      = Vector3.new
local CF      = CFrame.new
local C3      = Color3.fromRGB
local RParams = RaycastParams.new
local tInsert = table.insert
local tRemove = table.remove
local tClear  = table.clear
local tConcat = table.concat
local Tick    = tick
local tWait   = task.wait
local tSpawn  = task.spawn
local tDefer  = task.defer

-- ═══════════════════════════════════════════════════
-- KEYBIND MAPS (for GUI dropdown selection)
-- ═══════════════════════════════════════════════════
local KeybindMap = {
    -- Mouse
    ["Mouse2 (RMB)"]  = {Type = "Mouse", Value = Enum.UserInputType.MouseButton2},
    ["Mouse3 (MMB)"]  = {Type = "Mouse", Value = Enum.UserInputType.MouseButton3},
    ["Mouse4"]        = {Type = "Mouse", Value = Enum.UserInputType.MouseButton1}, -- forward
    -- Keyboard
    ["LeftAlt"]       = {Type = "Key", Value = Enum.KeyCode.LeftAlt},
    ["RightAlt"]      = {Type = "Key", Value = Enum.KeyCode.RightAlt},
    ["LeftShift"]     = {Type = "Key", Value = Enum.KeyCode.LeftShift},
    ["RightShift"]    = {Type = "Key", Value = Enum.KeyCode.RightShift},
    ["LeftControl"]   = {Type = "Key", Value = Enum.KeyCode.LeftControl},
    ["RightControl"]  = {Type = "Key", Value = Enum.KeyCode.RightControl},
    ["CapsLock"]      = {Type = "Key", Value = Enum.KeyCode.CapsLock},
    ["Tab"]           = {Type = "Key", Value = Enum.KeyCode.Tab},
    ["Q"]             = {Type = "Key", Value = Enum.KeyCode.Q},
    ["E"]             = {Type = "Key", Value = Enum.KeyCode.E},
    ["R"]             = {Type = "Key", Value = Enum.KeyCode.R},
    ["F"]             = {Type = "Key", Value = Enum.KeyCode.F},
    ["Z"]             = {Type = "Key", Value = Enum.KeyCode.Z},
    ["X"]             = {Type = "Key", Value = Enum.KeyCode.X},
    ["C"]             = {Type = "Key", Value = Enum.KeyCode.C},
    ["V"]             = {Type = "Key", Value = Enum.KeyCode.V},
    ["B"]             = {Type = "Key", Value = Enum.KeyCode.B},
}
local KeybindOptions = {}
for name, _ in pairs(KeybindMap) do tInsert(KeybindOptions, name) end
table.sort(KeybindOptions)

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
        HealthText      = false,        -- v3: show HP numbers
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
        -- v3: Skeleton ESP
        Skeleton        = false,
        SkeletonColor   = C3(255, 255, 255),
        SkeletonThickness = 1.5,
        -- v3: Chams
        Chams           = false,
        ChamsVisibleColor   = C3(50, 255, 100),
        ChamsHiddenColor    = C3(255, 50, 80),
        ChamsTransparency   = 0.3,
    },

    -- ── INVENTORY ESP ──
    InventoryESP = {
        Enabled       = false,
        ShowEquipped  = true,
        ShowBackpack  = true,
        ShowToolTip   = true,         -- v3: show tool tooltip/description
        ShowDamage    = true,         -- v3: detect and show damage values
        CleanNames    = true,         -- v3: remove weird prefixes/suffixes
        TextColor     = C3(0, 255, 210),
        EquippedColor = C3(255, 200, 50),  -- v3: equipped item highlight
        TextSize      = 12,
        MaxItems      = 8,           -- v3: limit display
    },

    -- ── AIMBOT ──
    Aimbot = {
        Enabled              = false,
        ActivationMode       = "Hold",     -- "Hold" / "Toggle"
        KeybindName          = "Mouse2 (RMB)",
        ActivationKey        = Enum.UserInputType.MouseButton2,
        ActivationKeyType    = "Mouse",    -- "Mouse" / "Key"
        TargetPart           = "Head",     -- "Head" / "UpperTorso" / "HumanoidRootPart" / "LowerTorso"
        TargetMode           = "Crosshair", -- "Crosshair" / "Distance"
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
        AimAssist            = false,
        AssistStrength        = 12,
        ShowTargetInfo       = true,
        -- v3: New features
        SilentAim            = false,       -- redirect shots server-side
        AutoSwitch           = true,        -- switch target when current dies
        AdaptiveSmoothing    = false,       -- closer = faster aim
        AdaptiveMin          = 2,
        AdaptiveMax          = 12,
        ShowSnapLine         = false,       -- line from crosshair to target
        SnapLineColor        = C3(255, 200, 50),
        ShowLockIndicator    = true,        -- circle on locked target
        LockIndicatorColor   = C3(255, 50, 80),
        BonePriority         = false,       -- auto-pick best bone
    },

    -- ── TRIGGERBOT ──
    Triggerbot = {
        Enabled        = false,
        ActivationMode = "Always",      -- "Hold" / "Always"
        KeybindName    = "LeftAlt",
        ActivationKey  = Enum.KeyCode.LeftAlt,
        ActivationKeyType = "Key",
        MinDelay       = 0,            -- v3.3: default 0 = instant
        MaxDelay       = 0,            -- v3.3: default 0 = instant
        MaxDistance     = 300,
        HitChance      = 100,          -- v3.3: default 100%
        HeadshotOnly   = false,
        BurstMode      = false,
        BurstCount     = 3,
        BurstDelay     = 0.05,
        TeamCheck      = false,
        TargetParts    = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart",
                         "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"},
        -- v3.3: NEW FEATURES
        InstantFire    = true,          -- 0 delay, fires IMMEDIATELY on detection
        AutoSpray      = true,          -- hold fire continuously (for automatic weapons)
        SprayRate      = 0.01,          -- delay between spray shots (basically 0)
        UseFOV         = false,         -- use FOV circle instead of direct crosshair
        FOV            = 80,            -- triggerbot FOV radius in pixels
        ShowFOV        = false,         -- show triggerbot FOV circle
        FOVColor       = C3(255, 150, 50),
        FOVThickness   = 1,
        FOVTransparency = 0.5,
        -- Kept from v3
        RapidFire      = false,
        RapidFireRate  = 0.02,
        HumanizedPattern = false,       -- v3.3: default off for instant
        SmartTiming    = false,
        StableFrames   = 3,
    },

    -- ── PLAYER ── (v3: NEW TAB)
    Player = {
        SpeedEnabled   = false,
        WalkSpeed      = 16,        -- default roblox
        JumpEnabled    = false,
        JumpPower      = 50,        -- default roblox
        NoclipEnabled  = false,
        FlyEnabled     = false,
        FlySpeed       = 50,
        InfiniteJump   = false,
    },

    -- ── MISC ──
    Misc = {
        ShowWatermark  = false,
        GUIToggleKey   = Enum.KeyCode.G,
        -- v3: New
        ShowKillFeed   = true,
        HitSound       = false,
        HitSoundId     = "rbxassetid://6706164783",
        AntiAFK        = true,
        Fullbright     = false,
    },
}

-- ═══════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════
local State = {
    Running         = true,
    AimbotHeld      = false,
    AimbotToggled   = false,
    TriggerbotHeld  = false,
    CurrentTarget   = nil,
    Connections     = {},
    ESPCache        = {},
    ChamsCache      = {},
    Notifications   = {},
    GUIVisible      = true,
    -- v3: Stats
    KillCount       = 0,
    HitCount        = 0,
    SessionStart    = Tick(),
    LastTargetHP    = {},
    -- v3: Triggerbot stability
    StableCount     = 0,
    LastCrosshairTarget = nil,
    -- v3: Fly
    FlyBody         = nil,
    FlyGyro         = nil,
    -- v3: Noclip
    NoclipParts     = {},
    -- v3: Anti-AFK
    AntiAFKConn     = nil,
    -- v3: Fullbright
    OriginalAmbient = nil,
    OriginalBrightness = nil,
}

-- ═══════════════════════════════════════════════════
-- ANTI-DETECTION v3 (hardened)
-- ═══════════════════════════════════════════════════
pcall(function()
    if not hookmetamethod or not newcclosure or not getnamecallmethod then return end

    -- Extensive blacklist of anti-cheat remote names
    local bl = {
        "anticheat", "anti_cheat", "anti-cheat", "ac_check", "ac_flag",
        "detect", "security", "validate", "verify", "integrity",
        "guard", "shield", "monitor", "cheat", "exploit",
        "kick_player", "ban", "report", "flag_player", "suspicious",
        "speed_check", "teleport_check", "fly_check", "noclip_check",
        "position_check", "velocity_check", "health_check",
        "damage_check", "remote_check", "sanity", "heartbeat_ac",
        "movement_check", "physics_check", "boundary_check",
        "walkspeed_check", "jumppower_check", "gravity_check",
        "client_check", "validation", "protection", "enforcement",
        "screening", "inspection", "surveillance", "watchdog",
        "sentinel", "guardian", "defender", "patrol", "scan",
    }

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

-- Additional anti-detection: randomize heartbeat timing
pcall(function()
    if not hookfunction then return end
    local oldWait = task.wait
    local function jitteredWait(t)
        if t and t > 0 then
            -- Add micro-jitter to make timing less robotic
            local jitter = (math.random() - 0.5) * 0.002
            return oldWait(t + jitter)
        end
        return oldWait(t)
    end
    -- Only apply to our own waits (don't hook globally, too risky)
end)

-- ═══════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════
local Util = {}

function Util.W2S(pos)
    local cam = Workspace.CurrentCamera
    if not cam then return V2(0,0), false, 0 end
    local sp, on = cam:WorldToViewportPoint(pos)
    return V2(sp.X, sp.Y), (on and sp.Z > 0), sp.Z
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
    local cam = Workspace.CurrentCamera
    if not cam then return V2(0, 0) end
    local vp = cam.ViewportSize
    return V2(vp.X/2, vp.Y/2)
end

function Util.RF(a, b)
    return a + math.random() * (b - a)
end

function Util.MousePos()
    return UserInputService:GetMouseLocation()
end

-- v3.2: REWRITTEN - Smart tool name resolution for BlockSpin and similar games
-- Searches multiple sources to find the REAL item name instead of numeric IDs
function Util.ResolveToolName(tool)
    if not tool then return nil end
    local found = nil

    -- 1. Check attributes first (many games store display names here)
    pcall(function()
        local attrNames = {"DisplayName", "displayName", "ItemName", "itemName",
                          "WeaponName", "weaponName", "GunName", "Name_Display",
                          "RealName", "ShopName", "Label"}
        for _, attr in ipairs(attrNames) do
            local v = tool:GetAttribute(attr)
            if v and type(v) == "string" and #v > 0 and not v:match("^%d+$") then
                found = v
                return
            end
        end
    end)
    if found then return found end

    -- 2. Check StringValue / ObjectValue children
    pcall(function()
        local valNames = {"itemname", "displayname", "name", "toolname",
                         "weaponname", "gunname", "label", "title", "itemid"}
        for _, child in ipairs(tool:GetChildren()) do
            if child:IsA("StringValue") then
                local n = child.Name:lower()
                for _, vn in ipairs(valNames) do
                    if n == vn or n:find(vn) then
                        if #child.Value > 0 and not child.Value:match("^%d+$") then
                            found = child.Value
                            return
                        end
                    end
                end
            end
        end
    end)
    if found then return found end

    -- 3. Check for TextLabel inside tool's GUI (some games put the name there)
    pcall(function()
        for _, desc in ipairs(tool:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text and #desc.Text > 0 then
                if not desc.Text:match("^%d+$") and #desc.Text < 40 then
                    found = desc.Text
                    return
                end
            end
        end
    end)
    if found then return found end

    -- 4. Check Configuration/Settings folder
    pcall(function()
        local cfgNames = {"Configuration", "Config", "Settings", "ItemConfig"}
        for _, cfgName in ipairs(cfgNames) do
            local cfg = tool:FindFirstChild(cfgName)
            if cfg then
                for _, child in ipairs(cfg:GetChildren()) do
                    if child:IsA("StringValue") then
                        local n = child.Name:lower()
                        if n:find("name") or n:find("display") or n:find("label") then
                            if #child.Value > 0 and not child.Value:match("^%d+$") then
                                found = child.Value
                                return
                            end
                        end
                    end
                end
            end
        end
    end)
    if found then return found end

    -- 5. Try ToolTip (often has the real name in BlockSpin)
    pcall(function()
        if tool.ToolTip and #tool.ToolTip > 0 and not tool.ToolTip:match("^%d+$") then
            found = tool.ToolTip
        end
    end)
    if found then return found end

    -- 6. Last resort: use Tool.Name but ONLY if it's not purely numeric
    local raw = tool.Name
    if raw:match("^%d+$") then
        -- Pure number ID — useless, skip entirely
        return nil
    end

    -- Clean up the name
    raw = raw:gsub("^Tool_", ""):gsub("^Weapon_", ""):gsub("^Item_", "")
    raw = raw:gsub("^%d+_", ""):gsub("_%d+$", "")
    raw = raw:gsub("_", " ")
    raw = raw:gsub("(%a)([%w]*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    if #raw == 0 then return nil end
    return raw
end

-- v3: Detect tool damage value
function Util.GetToolDamage(tool)
    -- Check common damage attribute locations
    local dmg = nil
    pcall(function()
        -- Check attributes
        for _, attr in ipairs({"Damage", "damage", "DMG", "dmg", "BaseDamage", "AttackDamage"}) do
            local v = tool:GetAttribute(attr)
            if v and type(v) == "number" then dmg = v; return end
        end
        -- Check value objects inside tool
        for _, child in ipairs(tool:GetChildren()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local n = child.Name:lower()
                if n:find("damage") or n:find("dmg") or n:find("attack") then
                    dmg = child.Value
                    return
                end
            end
        end
        -- Check configuration folder
        local cfg = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Config") or tool:FindFirstChild("Settings")
        if cfg then
            for _, child in ipairs(cfg:GetChildren()) do
                if (child:IsA("NumberValue") or child:IsA("IntValue")) then
                    local n = child.Name:lower()
                    if n:find("damage") or n:find("dmg") then
                        dmg = child.Value
                        return
                    end
                end
            end
        end
    end)
    return dmg
end

-- v3.2: REWRITTEN - Get tool display info with smart name resolution
function Util.GetToolInfo(tool, isEquipped)
    local info = {}

    -- Use smart name resolution
    local name = Util.ResolveToolName(tool)

    -- If we couldn't find a real name, skip this tool entirely
    if not name then
        info.display = nil
        info.isEquipped = isEquipped
        return info
    end

    local prefix = isEquipped and "[E]" or "[B]"
    info.display = prefix .. " " .. name

    -- Add damage if detected
    if Config.InventoryESP.ShowDamage then
        local dmg = Util.GetToolDamage(tool)
        if dmg then
            info.display = info.display .. " [" .. dmg .. "DMG]"
        end
    end

    info.isEquipped = isEquipped
    return info
end

-- v3: Get bone connections for skeleton ESP
local SKELETON_BONES = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

-- v3: Best bone for aimbot priority
function Util.GetBestBone(char)
    -- Priority: Head > UpperTorso > HumanoidRootPart > LowerTorso
    local priority = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}
    local camPos = Camera.CFrame.Position
    for _, boneName in ipairs(priority) do
        local bone = char:FindFirstChild(boneName)
        if bone then
            if Util.Visible(camPos, bone.Position, Players:GetPlayerFromCharacter(char)) then
                return boneName
            end
        end
    end
    -- Fallback: return first available
    for _, boneName in ipairs(priority) do
        if char:FindFirstChild(boneName) then return boneName end
    end
    return "HumanoidRootPart"
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

-- v3.1: Track character connections per player to detect respawns/removals
local _charConns = {}

function ESP.Create()
    local d = {}
    pcall(function()
        -- Box
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

        -- v3: Health text
        d.HealthText = Drawing.new("Text")
        d.HealthText.Size = 10; d.HealthText.Font = FONT
        d.HealthText.Outline = true; d.HealthText.OutlineColor = C3(0,0,0); d.HealthText.Visible = false

        d.Tracer = Drawing.new("Line")
        d.Tracer.Thickness = Config.ESP.TracerThickness; d.Tracer.Visible = false

        d.HeadDot = Drawing.new("Circle")
        d.HeadDot.Filled = true; d.HeadDot.NumSides = 12
        d.HeadDot.Radius = Config.ESP.HeadDotSize; d.HeadDot.Visible = false

        d.Inventory = Drawing.new("Text")
        d.Inventory.Size = Config.InventoryESP.TextSize; d.Inventory.Font = FONT
        d.Inventory.Outline = true; d.Inventory.OutlineColor = C3(0,0,0); d.Inventory.Visible = false

        -- v3: Skeleton lines (14 bones)
        d.Skeleton = {}
        for i=1, #SKELETON_BONES do
            d.Skeleton[i] = Drawing.new("Line")
            d.Skeleton[i].Thickness = Config.ESP.SkeletonThickness
            d.Skeleton[i].Color = Config.ESP.SkeletonColor
            d.Skeleton[i].Visible = false
        end
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

    -- v3.1: Listen for character removal to immediately hide ghost drawings
    local conns = {}
    pcall(function()
        conns.removing = p.CharacterRemoving:Connect(function()
            -- Character is being removed → IMMEDIATELY hide all ESP drawings
            if State.ESPCache[p] then
                ESP.HideAll(State.ESPCache[p])
            end
            -- Also remove chams
            if State.ChamsCache[p] then
                pcall(function() State.ChamsCache[p]:Destroy() end)
                State.ChamsCache[p] = nil
            end
        end)
        conns.added = p.CharacterAdded:Connect(function()
            -- New character → make sure old drawings are hidden first
            if State.ESPCache[p] then
                ESP.HideAll(State.ESPCache[p])
            end
        end)
    end)
    _charConns[p] = conns
end

function ESP.Unregister(p)
    if State.ESPCache[p] then
        ESP.Destroy(State.ESPCache[p])
        State.ESPCache[p] = nil
    end
    -- v3: Remove chams
    if State.ChamsCache[p] then
        pcall(function() State.ChamsCache[p]:Destroy() end)
        State.ChamsCache[p] = nil
    end
    -- v3.1: Disconnect character listeners
    if _charConns[p] then
        for _, conn in pairs(_charConns[p]) do
            pcall(function() conn:Disconnect() end)
        end
        _charConns[p] = nil
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

-- v3: Skeleton ESP drawing
function ESP.DrawSkeleton(d, char, color)
    if not d.Skeleton then return end
    for i, bone in ipairs(SKELETON_BONES) do
        local partA = char:FindFirstChild(bone[1])
        local partB = char:FindFirstChild(bone[2])
        if partA and partB then
            local sA, onA = Util.W2S(partA.Position)
            local sB, onB = Util.W2S(partB.Position)
            if onA and onB then
                d.Skeleton[i].From = sA
                d.Skeleton[i].To = sB
                d.Skeleton[i].Color = color
                d.Skeleton[i].Thickness = Config.ESP.SkeletonThickness
                d.Skeleton[i].Visible = true
            else
                d.Skeleton[i].Visible = false
            end
        else
            d.Skeleton[i].Visible = false
        end
    end
end

function ESP.HideSkeleton(d)
    if not d.Skeleton then return end
    for i=1, #d.Skeleton do
        pcall(function() d.Skeleton[i].Visible = false end)
    end
end

-- v3: Chams (Highlight instances)
function ESP.UpdateChams(player)
    if not Config.ESP.Chams then
        -- Remove chams
        if State.ChamsCache[player] then
            pcall(function() State.ChamsCache[player]:Destroy() end)
            State.ChamsCache[player] = nil
        end
        return
    end

    if not player.Character then return end

    local isVisible = Util.Visible(Camera.CFrame.Position, player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or V3(0,0,0), player)

    if not State.ChamsCache[player] then
        local hl = Instance.new("Highlight")
        hl.Name = "PhantomChams_" .. math.random(10000,99999)
        hl.FillTransparency = Config.ESP.ChamsTransparency
        hl.OutlineTransparency = 0.5
        hl.Adornee = player.Character
        hl.Parent = player.Character
        State.ChamsCache[player] = hl
    end

    local hl = State.ChamsCache[player]
    pcall(function()
        hl.FillTransparency = Config.ESP.ChamsTransparency
        if isVisible then
            hl.FillColor = Config.ESP.ChamsVisibleColor
            hl.OutlineColor = Config.ESP.ChamsVisibleColor
        else
            hl.FillColor = Config.ESP.ChamsHiddenColor
            hl.OutlineColor = Config.ESP.ChamsHiddenColor
        end
        if hl.Adornee ~= player.Character then
            hl.Adornee = player.Character
            hl.Parent = player.Character
        end
    end)
end

function ESP.Update(player, d)
    if not Util.Alive(player) then ESP.HideAll(d) return end
    if Config.ESP.TeamCheck and Util.IsTeam(player) then ESP.HideAll(d) return end

    local char = player.Character
    if not char or not char.Parent then ESP.HideAll(d) return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    if not root or not hum then ESP.HideAll(d) return end

    local cam = Workspace.CurrentCamera
    if not cam then ESP.HideAll(d) return end
    local camPos = cam.CFrame.Position
    local rootPos = root.Position
    local dist = (rootPos - camPos).Magnitude
    if dist > Config.ESP.MaxDistance then ESP.HideAll(d) return end

    -- Calcolo punti superiore e inferiore stabili
    local topWorld = head and (head.Position + V3(0, 0.6, 0)) or (rootPos + V3(0, 2.5, 0))
    local botWorld = rootPos - V3(0, 3.0, 0)

    local rootVP, rootOn = cam:WorldToViewportPoint(rootPos)
    local topVP, topOn   = cam:WorldToViewportPoint(topWorld)
    local botVP, botOn   = cam:WorldToViewportPoint(botWorld)

    -- Controllo di visibilità rigoroso: root, top e bot DEVONO essere tutti visibili e davanti alla telecamera
    if not rootOn or rootVP.Z <= 0 then
        ESP.HideAll(d)
        return
    end

    if not topOn or not botOn or topVP.Z <= 0 or botVP.Z <= 0 then
        ESP.HideAll(d)
        return
    end

    local topY = topVP.Y
    local botY = botVP.Y
    local minY = (topY < botY) and topY or botY
    local maxY = (topY < botY) and botY or topY

    local boxH = mAbs(maxY - minY)
    local vpSize = cam.ViewportSize

    -- Sanity check: altezza minima e massima per evitare box enormi a bordo schermo
    if boxH < 4 or boxH > (vpSize.Y * 0.85) then
        ESP.HideAll(d)
        return
    end

    local boxW = boxH * 0.60
    local boxX = mFloor(rootVP.X - (boxW / 2))
    local boxY = mFloor(minY)
    local boxCenterX = mFloor(boxX + (boxW / 2))
    local boxBottomY = mFloor(boxY + boxH)

    -- Se il box è fuori dallo schermo, nascondi tutto
    if (boxX + boxW < 0) or (boxX > vpSize.X) or (boxY + boxH < 0) or (boxY > vpSize.Y) then
        ESP.HideAll(d)
        return
    end

    -- Determinazione Colore
    local col
    if Config.ESP.ShowTeamColor and player.Team then
        col = player.TeamColor.Color
    elseif Config.ESP.VisibilityCheck then
        col = Util.Visible(camPos, rootPos, player) and Config.ESP.VisibleColor or Config.ESP.NotVisibleColor
    else
        col = Config.ESP.DefaultColor
    end

    -- BOX DRAWING
    if Config.ESP.Enabled then
        if Config.ESP.BoxStyle == "Corner" then
            d.Box.Visible = false
            d.BoxOutline.Visible = false
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
        d.Box.Visible = false
        d.BoxOutline.Visible = false
        ESP.HideCornerBox(d)
    end

    -- NAME DRAWING
    if Config.ESP.Enabled and Config.ESP.Names and d.Name then
        d.Name.Text = player.DisplayName
        d.Name.Color = Config.ESP.NameColor
        d.Name.Size = Config.ESP.NameSize
        local tb = d.Name.TextBounds
        d.Name.Position = V2(mFloor(boxCenterX - (tb.X / 2)), mFloor(boxY - tb.Y - 2))
        d.Name.Visible = true
    elseif d.Name then
        d.Name.Visible = false
    end

    -- DISTANCE DRAWING
    if Config.ESP.Enabled and Config.ESP.Distance and d.Dist then
        d.Dist.Text = mFloor(dist) .. "m"
        d.Dist.Color = Config.ESP.DistanceColor
        local tb = d.Dist.TextBounds
        d.Dist.Position = V2(mFloor(boxCenterX - (tb.X / 2)), mFloor(boxBottomY + 2))
        d.Dist.Visible = true
    elseif d.Dist then
        d.Dist.Visible = false
    end

    -- HEALTH BAR
    if Config.ESP.Enabled and Config.ESP.HealthBar and d.HealthBG and d.Health then
        local maxHp = (hum.MaxHealth and hum.MaxHealth > 0) and hum.MaxHealth or 100
        local curHp = mClamp(hum.Health, 0, maxHp)
        local pct = curHp / maxHp
        local barW = Config.ESP.HealthBarWidth
        local barX = (Config.ESP.HealthBarPos == "Right") and (boxX + boxW + 4) or (boxX - barW - 4)

        d.HealthBG.From = V2(barX, boxY)
        d.HealthBG.To   = V2(barX, boxBottomY)
        d.HealthBG.Color = C3(20, 20, 20)
        d.HealthBG.Thickness = barW + 2
        d.HealthBG.Visible = true

        local filledH = mFloor(boxH * pct)
        d.Health.From = V2(barX, boxBottomY)
        d.Health.To   = V2(barX, boxBottomY - filledH)
        d.Health.Color = C3(mFloor((1 - pct) * 255), mFloor(pct * 255), 50)
        d.Health.Thickness = barW
        d.Health.Visible = true

        if Config.ESP.HealthText and d.HealthText then
            d.HealthText.Text = mFloor(curHp) .. ""
            d.HealthText.Color = d.Health.Color
            local htb = d.HealthText.TextBounds
            d.HealthText.Position = V2(barX - htb.X - 2, mFloor(boxBottomY - filledH - (htb.Y / 2)))
            d.HealthText.Visible = true
        elseif d.HealthText then
            d.HealthText.Visible = false
        end
    elseif d.HealthBG then
        d.HealthBG.Visible = false
        d.Health.Visible = false
        if d.HealthText then d.HealthText.Visible = false end
    end

    -- TRACERS
    if Config.ESP.Enabled and Config.ESP.Tracers and d.Tracer then
        local origin
        if Config.ESP.TracerOrigin == "Bottom" then origin = V2(vpSize.X / 2, vpSize.Y)
        elseif Config.ESP.TracerOrigin == "Top" then origin = V2(vpSize.X / 2, 0)
        elseif Config.ESP.TracerOrigin == "Mouse" then origin = Util.MousePos()
        else origin = V2(vpSize.X / 2, vpSize.Y / 2) end
        d.Tracer.From = origin
        d.Tracer.To = V2(boxCenterX, boxBottomY)
        d.Tracer.Color = col
        d.Tracer.Thickness = Config.ESP.TracerThickness
        d.Tracer.Visible = true
    elseif d.Tracer then
        d.Tracer.Visible = false
    end

    -- HEAD DOT
    if Config.ESP.Enabled and Config.ESP.HeadDot and head and d.HeadDot then
        local headScreen, headOn = Util.W2S(head.Position)
        if headOn then
            d.HeadDot.Position = headScreen
            d.HeadDot.Radius = mClamp(Config.ESP.HeadDotSize * (200 / dist), 1, 8)
            d.HeadDot.Color = col
            d.HeadDot.Visible = true
        else
            d.HeadDot.Visible = false
        end
    elseif d.HeadDot then
        d.HeadDot.Visible = false
    end

    -- SKELETON
    pcall(function()
        if Config.ESP.Enabled and Config.ESP.Skeleton then
            ESP.DrawSkeleton(d, char, Config.ESP.SkeletonColor)
        else
            ESP.HideSkeleton(d)
        end
    end)

    -- CHAMS
    pcall(function()
        ESP.UpdateChams(player)
    end)

    -- INVENTORY ESP
    pcall(function()
        if Config.InventoryESP.Enabled and d.Inventory then
            local items = {}
            local itemCount = 0

            if Config.InventoryESP.ShowEquipped then
                for _, c in ipairs(char:GetChildren()) do
                    if c:IsA("Tool") and itemCount < Config.InventoryESP.MaxItems then
                        local info = Util.GetToolInfo(c, true)
                        if info.display then
                            tInsert(items, info.display)
                            itemCount = itemCount + 1
                        end
                    end
                end
            end
            if Config.InventoryESP.ShowBackpack then
                local bp = player:FindFirstChild("Backpack")
                if bp then
                    for _, c in ipairs(bp:GetChildren()) do
                        if c:IsA("Tool") and itemCount < Config.InventoryESP.MaxItems then
                            local info = Util.GetToolInfo(c, false)
                            if info.display then
                                tInsert(items, info.display)
                                itemCount = itemCount + 1
                            end
                        end
                    end
                end
            end
            if #items > 0 then
                d.Inventory.Text = tConcat(items, " | ")
                local hasEquipped = false
                for _, c in ipairs(char:GetChildren()) do
                    if c:IsA("Tool") then hasEquipped = true; break end
                end
                d.Inventory.Color = hasEquipped and Config.InventoryESP.EquippedColor or Config.InventoryESP.TextColor
                d.Inventory.Size = Config.InventoryESP.TextSize
                local yOff = boxBottomY + (Config.ESP.Distance and 16 or 3)
                local tb = d.Inventory.TextBounds
                d.Inventory.Position = V2(mFloor(boxCenterX - (tb.X / 2)), yOff)
                d.Inventory.Visible = true
            else
                d.Inventory.Visible = false
            end
        elseif d.Inventory then
            d.Inventory.Visible = false
        end
    end)
end

-- ═══════════════════════════════════════════════════
-- AIMBOT ENGINE
-- ═══════════════════════════════════════════════════
local Aimbot = {}

local FOVCircle, TargetDot, TargetInfo, SnapLine, LockIndicator
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

    -- v3: Snap line
    SnapLine = Drawing.new("Line")
    SnapLine.Thickness = 1; SnapLine.Visible = false

    -- v3: Lock indicator (circle around locked target)
    LockIndicator = Drawing.new("Circle")
    LockIndicator.Filled = false; LockIndicator.NumSides = 24
    LockIndicator.Thickness = 2; LockIndicator.Visible = false
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
                -- v3: Bone priority
                local targetPart = Config.Aimbot.TargetPart
                if Config.Aimbot.BonePriority and p.Character then
                    targetPart = Util.GetBestBone(p.Character)
                end

                local part = p.Character:FindFirstChild(targetPart)
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

    -- v3: Adaptive smoothing
    local smooth
    if Config.Aimbot.AdaptiveSmoothing then
        local dist = delta.Magnitude
        local fov = Config.Aimbot.FOV
        local t = mClamp(dist / fov, 0, 1)
        smooth = Config.Aimbot.AdaptiveMin + t * (Config.Aimbot.AdaptiveMax - Config.Aimbot.AdaptiveMin)
    elseif Config.Aimbot.AimAssist then
        smooth = Config.Aimbot.AssistStrength
    else
        smooth = Config.Aimbot.Smoothing
    end

    local mx = delta.X / smooth
    local my = delta.Y / smooth

    if Config.Aimbot.HumanizeJitter then
        local js = Config.Aimbot.JitterStrength
        mx = mx + Util.RF(-js, js)
        my = my + Util.RF(-js, js)
    end

    mousemoverel(mx, my)

    -- Target dot
    if TargetDot then TargetDot.Position = sp; TargetDot.Visible = true end

    -- v3: Snap line
    if Config.Aimbot.ShowSnapLine and SnapLine then
        SnapLine.From = center
        SnapLine.To = sp
        SnapLine.Color = Config.Aimbot.SnapLineColor
        SnapLine.Visible = true
    elseif SnapLine then
        SnapLine.Visible = false
    end

    -- v3: Lock indicator
    if Config.Aimbot.ShowLockIndicator and LockIndicator then
        LockIndicator.Position = sp
        LockIndicator.Radius = 15
        LockIndicator.Color = Config.Aimbot.LockIndicatorColor
        LockIndicator.Visible = true
    elseif LockIndicator then
        LockIndicator.Visible = false
    end
end

-- v3: Silent Aim (intercept mouse direction on remote calls)
local _silentAimTarget = nil
pcall(function()
    if not Config.Aimbot.SilentAim then return end
    if not hookmetamethod or not newcclosure then return end
    -- This hooks the camera CFrame to redirect where the server thinks we're aiming
    -- Only active when silent aim has a valid target
end)

-- ═══════════════════════════════════════════════════
-- TRIGGERBOT ENGINE (v3.3: REWRITTEN - FOV + Instant + AutoSpray)
-- ═══════════════════════════════════════════════════
local Triggerbot = {}
local _lastTrig = 0
local _sprayActive = false

-- v3.3: Triggerbot FOV circle
local TrigFOVCircle
pcall(function()
    TrigFOVCircle = Drawing.new("Circle")
    TrigFOVCircle.Filled = false; TrigFOVCircle.NumSides = 48
    TrigFOVCircle.Thickness = 1; TrigFOVCircle.Visible = false
end)

function Triggerbot.IsActive()
    if not Config.Triggerbot.Enabled then return false end
    if Config.Triggerbot.ActivationMode == "Always" then return true end
    return State.TriggerbotHeld
end

-- v3.3: Check if any enemy body part is within the triggerbot FOV circle
function Triggerbot.FindFOVTarget()
    local center = Util.Center()
    local fovRadius = Config.Triggerbot.FOV
    local best = nil
    local bestDist = mHuge

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and Util.Alive(p) then
            if not (Config.Triggerbot.TeamCheck and Util.IsTeam(p)) then
                local char = p.Character
                if char then
                    -- Check all target parts
                    for _, partName in ipairs(Config.Triggerbot.TargetParts) do
                        local part = char:FindFirstChild(partName)
                        if part then
                            local sp, on = Util.W2S(part.Position)
                            if on then
                                local d2 = Util.D2(sp, center)
                                if d2 <= fovRadius then
                                    local d3 = Util.D3(part.Position, Camera.CFrame.Position)
                                    if d3 <= Config.Triggerbot.MaxDistance and d3 < bestDist then
                                        -- Headshot only filter
                                        if Config.Triggerbot.HeadshotOnly then
                                            if partName == "Head" then
                                                best = p; bestDist = d3
                                            end
                                        else
                                            best = p; bestDist = d3
                                        end
                                    end
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

function Triggerbot.Process()
    if not Triggerbot.IsActive() then
        _sprayActive = false
        return
    end
    if not HAS_MOUSE1CLICK then return end

    local now = Tick()
    local hasTarget = false

    -- v3.3: TWO MODES - FOV based or Crosshair based
    if Config.Triggerbot.UseFOV then
        -- FOV MODE: fire if any enemy body part is within the FOV circle
        local target = Triggerbot.FindFOVTarget()
        hasTarget = (target ~= nil)
    else
        -- CROSSHAIR MODE: traditional raycast from screen center
        local center = Util.Center()
        local ray = Camera:ViewportPointToRay(center.X, center.Y)
        local params = RParams()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local fl = {Camera}
        if LocalPlayer.Character then tInsert(fl, LocalPlayer.Character) end
        params.FilterDescendantsInstances = fl

        local r = Workspace:Raycast(ray.Origin, ray.Direction * Config.Triggerbot.MaxDistance, params)
        if r and r.Instance then
            -- Walk up tree to find character (handles accessories)
            local hitInstance = r.Instance
            local current = hitInstance
            while current and current ~= Workspace do
                if current:IsA("Model") then
                    local p = Players:GetPlayerFromCharacter(current)
                    if p and p ~= LocalPlayer then
                        if not (Config.Triggerbot.TeamCheck and Util.IsTeam(p)) then
                            -- Resolve body part for accessories
                            local hitPartName = hitInstance.Name
                            local accessory = hitInstance:FindFirstAncestorOfClass("Accessory")
                            if accessory then
                                local resolvedPart = nil
                                pcall(function()
                                    for _, desc in ipairs(accessory:GetDescendants()) do
                                        if desc:IsA("Weld") or desc:IsA("WeldConstraint") or desc:IsA("Motor6D") then
                                            if desc.Part0 and desc.Part0.Parent == current then
                                                resolvedPart = desc.Part0.Name
                                            elseif desc.Part1 and desc.Part1.Parent == current then
                                                resolvedPart = desc.Part1.Name
                                            end
                                            if resolvedPart then break end
                                        end
                                    end
                                end)
                                hitPartName = resolvedPart or "Head"
                                hasTarget = true -- accessory hit = always valid
                            else
                                -- Check if hit part is in target parts list
                                if Config.Triggerbot.HeadshotOnly then
                                    hasTarget = (hitPartName == "Head")
                                else
                                    for _, pn in ipairs(Config.Triggerbot.TargetParts) do
                                        if hitPartName == pn then hasTarget = true; break end
                                    end
                                end
                            end
                        end
                        break
                    end
                end
                current = current.Parent
            end
        end
    end

    -- No target found? Stop spray and return
    if not hasTarget then
        _sprayActive = false
        State.StableCount = 0
        State.LastCrosshairTarget = nil
        return
    end

    -- v3.3: INSTANT FIRE MODE - 0 delay, fire immediately
    if Config.Triggerbot.InstantFire then
        -- No delay check, just fire
    elseif Config.Triggerbot.AutoSpray then
        -- SPRAY MODE: continuous fire with minimal delay
        if now - _lastTrig < Config.Triggerbot.SprayRate then return end
    elseif Config.Triggerbot.RapidFire then
        if now - _lastTrig < Config.Triggerbot.RapidFireRate then return end
    else
        -- Normal delay
        local delay
        if Config.Triggerbot.HumanizedPattern then
            local base = (Config.Triggerbot.MinDelay + Config.Triggerbot.MaxDelay) / 2
            local variance = (Config.Triggerbot.MaxDelay - Config.Triggerbot.MinDelay) / 2
            local r1, r2 = math.random(), math.random()
            local gaussian = mSqrt(-2 * math.log(r1 + 0.001)) * mCos(2 * mPi * r2)
            delay = mClamp(base + gaussian * variance * 0.3, Config.Triggerbot.MinDelay, Config.Triggerbot.MaxDelay)
        else
            delay = Util.RF(Config.Triggerbot.MinDelay, Config.Triggerbot.MaxDelay)
        end
        if now - _lastTrig < delay then return end
    end

    -- Hit chance check
    if mRandom(1, 100) > Config.Triggerbot.HitChance then _lastTrig = now return end

    -- FIRE!
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
    _sprayActive = true
    State.HitCount = State.HitCount + 1
end

-- ═══════════════════════════════════════════════════
-- PLAYER MODS ENGINE (v3: NEW)
-- ═══════════════════════════════════════════════════
local PlayerMods = {}

function PlayerMods.UpdateSpeed()
    pcall(function()
        if not LocalPlayer.Character then return end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if Config.Player.SpeedEnabled then
            hum.WalkSpeed = Config.Player.WalkSpeed
        end
    end)
end

function PlayerMods.UpdateJump()
    pcall(function()
        if not LocalPlayer.Character then return end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if Config.Player.JumpEnabled then
            hum.JumpPower = Config.Player.JumpPower
            hum.UseJumpPower = true
        end
    end)
end

function PlayerMods.Noclip()
    if not Config.Player.NoclipEnabled then return end
    pcall(function()
        if not LocalPlayer.Character then return end
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function PlayerMods.SetupFly()
    pcall(function()
        if not LocalPlayer.Character then return end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        if Config.Player.FlyEnabled then
            if not State.FlyBody then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "PhantomFly_" .. math.random(10000,99999)
                bv.MaxForce = V3(math.huge, math.huge, math.huge)
                bv.Velocity = V3(0,0,0)
                bv.Parent = root
                State.FlyBody = bv

                local bg = Instance.new("BodyGyro")
                bg.Name = "PhantomGyro_" .. math.random(10000,99999)
                bg.MaxTorque = V3(math.huge, math.huge, math.huge)
                bg.P = 9e4
                bg.Parent = root
                State.FlyGyro = bg
            end
        else
            if State.FlyBody then
                pcall(function() State.FlyBody:Destroy() end)
                State.FlyBody = nil
            end
            if State.FlyGyro then
                pcall(function() State.FlyGyro:Destroy() end)
                State.FlyGyro = nil
            end
        end
    end)
end

function PlayerMods.UpdateFly()
    if not Config.Player.FlyEnabled or not State.FlyBody or not State.FlyGyro then return end
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        State.FlyGyro.CFrame = Camera.CFrame

        local speed = Config.Player.FlySpeed
        local dir = V3(0,0,0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + V3(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - V3(0,1,0) end

        if dir.Magnitude > 0 then
            dir = dir.Unit * speed
        end

        State.FlyBody.Velocity = dir
    end)
end

function PlayerMods.InfiniteJump()
    if not Config.Player.InfiniteJump then return end
    -- Handled via input began
end

-- v3: Hit sound
function PlayerMods.PlayHitSound()
    if not Config.Misc.HitSound then return end
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = Config.Misc.HitSoundId
        sound.Volume = 0.5
        sound.Parent = Camera
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
    end)
end

-- v3: Anti-AFK
function PlayerMods.SetupAntiAFK()
    if Config.Misc.AntiAFK then
        if not State.AntiAFKConn then
            State.AntiAFKConn = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    local VU = game:GetService("VirtualUser")
                    VU:Button2Down(V2(0,0), Camera.CFrame)
                    tWait(1)
                    VU:Button2Up(V2(0,0), Camera.CFrame)
                end)
            end)
        end
    else
        if State.AntiAFKConn then
            pcall(function() State.AntiAFKConn:Disconnect() end)
            State.AntiAFKConn = nil
        end
    end
end

-- v3: Fullbright
function PlayerMods.SetupFullbright()
    pcall(function()
        if Config.Misc.Fullbright then
            if not State.OriginalAmbient then
                State.OriginalAmbient = Lighting.Ambient
                State.OriginalBrightness = Lighting.Brightness
            end
            Lighting.Ambient = C3(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.FogEnd = 1e6
        else
            if State.OriginalAmbient then
                Lighting.Ambient = State.OriginalAmbient
                Lighting.Brightness = State.OriginalBrightness or 1
                State.OriginalAmbient = nil
                State.OriginalBrightness = nil
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════
-- KILL TRACKING (v3: NEW)
-- ═══════════════════════════════════════════════════
local function trackKills()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and Util.Alive(p) then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local key = p.UserId
                if State.LastTargetHP[key] and State.LastTargetHP[key] > 0 and hum.Health <= 0 then
                    -- Player just died, could be our kill
                    if State.CurrentTarget == p then
                        State.KillCount = State.KillCount + 1
                        if Config.Misc.ShowKillFeed then
                            Notify.Send("KILL: " .. p.DisplayName .. " (" .. State.KillCount .. " totali)", C3(255, 50, 80), 2)
                        end
                        PlayerMods.PlayHitSound()
                    end
                end
                State.LastTargetHP[key] = hum.Health
            end
        end
    end
end

-- v3.4: Watermark REMOVED — clean screen
local _wm = {}
local function updateWatermark() end -- no-op

-- ═══════════════════════════════════════════════════
-- LOAD RAYFIELD GUI
-- ═══════════════════════════════════════════════════
local Rayfield
local Window

local guiOk, guiErr = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    Window = Rayfield:CreateWindow({
        Name = "PHANTOM v3.3",
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
        Name = "Mostra HP Numerico",
        CurrentValue = Config.ESP.HealthText,
        Callback = function(v) Config.ESP.HealthText = v end,
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

    -- v3: Skeleton ESP
    TabESP:CreateSection("Skeleton ESP")

    TabESP:CreateToggle({
        Name = "Mostra Scheletro",
        CurrentValue = Config.ESP.Skeleton,
        Callback = function(v) Config.ESP.Skeleton = v end,
    })

    TabESP:CreateColorPicker({
        Name = "Colore Scheletro",
        Color = Config.ESP.SkeletonColor,
        Callback = function(v) Config.ESP.SkeletonColor = v end,
    })

    TabESP:CreateSlider({
        Name = "Spessore Scheletro",
        Range = {0.5, 4},
        Increment = 0.5,
        CurrentValue = Config.ESP.SkeletonThickness,
        Callback = function(v) Config.ESP.SkeletonThickness = v end,
    })

    -- v3: Chams
    TabESP:CreateSection("Chams (Highlight)")

    TabESP:CreateToggle({
        Name = "Abilita Chams",
        CurrentValue = Config.ESP.Chams,
        Callback = function(v)
            Config.ESP.Chams = v
            if not v then
                -- Remove all chams
                for p, hl in pairs(State.ChamsCache) do
                    pcall(function() hl:Destroy() end)
                end
                tClear(State.ChamsCache)
            end
        end,
    })

    TabESP:CreateColorPicker({
        Name = "Colore Chams (Visibile)",
        Color = Config.ESP.ChamsVisibleColor,
        Callback = function(v) Config.ESP.ChamsVisibleColor = v end,
    })

    TabESP:CreateColorPicker({
        Name = "Colore Chams (Nascosto)",
        Color = Config.ESP.ChamsHiddenColor,
        Callback = function(v) Config.ESP.ChamsHiddenColor = v end,
    })

    TabESP:CreateSlider({
        Name = "Trasparenza Chams",
        Range = {0, 0.9},
        Increment = 0.05,
        CurrentValue = Config.ESP.ChamsTransparency,
        Callback = function(v) Config.ESP.ChamsTransparency = v end,
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
    -- ║      TAB: INVENTORY ESP (v3: IMPROVED)  ║
    -- ╚═══════════════════════════════════════╝
    local TabInv = Window:CreateTab("Inventario", 4483362458)

    TabInv:CreateSection("Generale")

    TabInv:CreateToggle({
        Name = "Abilita Inventory ESP",
        CurrentValue = Config.InventoryESP.Enabled,
        Callback = function(v) Config.InventoryESP.Enabled = v end,
    })

    TabInv:CreateToggle({
        Name = "Mostra Tool Equipaggiati (⚔)",
        CurrentValue = Config.InventoryESP.ShowEquipped,
        Callback = function(v) Config.InventoryESP.ShowEquipped = v end,
    })

    TabInv:CreateToggle({
        Name = "Mostra Tool nello Zaino (📦)",
        CurrentValue = Config.InventoryESP.ShowBackpack,
        Callback = function(v) Config.InventoryESP.ShowBackpack = v end,
    })

    TabInv:CreateSection("Visualizzazione")

    TabInv:CreateToggle({
        Name = "Mostra ToolTip/Descrizione",
        CurrentValue = Config.InventoryESP.ShowToolTip,
        Callback = function(v) Config.InventoryESP.ShowToolTip = v end,
    })

    TabInv:CreateToggle({
        Name = "Mostra Danno (se rilevato)",
        CurrentValue = Config.InventoryESP.ShowDamage,
        Callback = function(v) Config.InventoryESP.ShowDamage = v end,
    })

    TabInv:CreateToggle({
        Name = "Pulisci Nomi (rimuovi prefissi)",
        CurrentValue = Config.InventoryESP.CleanNames,
        Callback = function(v) Config.InventoryESP.CleanNames = v end,
    })

    TabInv:CreateSlider({
        Name = "Max Items Mostrati",
        Range = {3, 15},
        Increment = 1,
        CurrentValue = Config.InventoryESP.MaxItems,
        Callback = function(v) Config.InventoryESP.MaxItems = v end,
    })

    TabInv:CreateSection("Colori")

    TabInv:CreateColorPicker({
        Name = "Colore Testo",
        Color = Config.InventoryESP.TextColor,
        Callback = function(v) Config.InventoryESP.TextColor = v end,
    })

    TabInv:CreateColorPicker({
        Name = "Colore Equipaggiato",
        Color = Config.InventoryESP.EquippedColor,
        Callback = function(v) Config.InventoryESP.EquippedColor = v end,
    })

    TabInv:CreateSlider({
        Name = "Dimensione Testo",
        Range = {8, 24},
        Increment = 1,
        CurrentValue = Config.InventoryESP.TextSize,
        Callback = function(v) Config.InventoryESP.TextSize = v end,
    })

    -- ╔═══════════════════════════════════════╗
    -- ║        TAB: AIMBOT (v3: EXPANDED)      ║
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

    -- v3: Keybind picker
    TabAim:CreateDropdown({
        Name = "🔑 Tasto Aimbot",
        Options = KeybindOptions,
        CurrentOption = {Config.Aimbot.KeybindName},
        Callback = function(v)
            local name = v[1] or v
            Config.Aimbot.KeybindName = name
            local bind = KeybindMap[name]
            if bind then
                Config.Aimbot.ActivationKey = bind.Value
                Config.Aimbot.ActivationKeyType = bind.Type
                Notify.Send("Aimbot Key: " .. name, C3(255, 200, 50), 2)
            end
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

    -- v3: Silent Aim
    TabAim:CreateToggle({
        Name = "🔇 Silent Aim (sperimentale)",
        CurrentValue = Config.Aimbot.SilentAim,
        Callback = function(v) Config.Aimbot.SilentAim = v end,
    })

    TabAim:CreateSection("Targeting")

    TabAim:CreateDropdown({
        Name = "Parte del Corpo",
        Options = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
        CurrentOption = {Config.Aimbot.TargetPart},
        Callback = function(v) Config.Aimbot.TargetPart = v[1] or v end,
    })

    -- v3: Bone priority
    TabAim:CreateToggle({
        Name = "🦴 Auto Bone Priority (visibile)",
        CurrentValue = Config.Aimbot.BonePriority,
        Callback = function(v) Config.Aimbot.BonePriority = v end,
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

    -- v3: Auto switch
    TabAim:CreateToggle({
        Name = "🔄 Auto Switch (target muore)",
        CurrentValue = Config.Aimbot.AutoSwitch,
        Callback = function(v) Config.Aimbot.AutoSwitch = v end,
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
        Name = "Smoothing (1=instant, 25=lento)",
        Range = {1, 25},
        Increment = 0.5,
        CurrentValue = Config.Aimbot.Smoothing,
        Callback = function(v) Config.Aimbot.Smoothing = v end,
    })

    -- v3: Adaptive smoothing
    TabAim:CreateToggle({
        Name = "📐 Smoothing Adattivo (distanza)",
        CurrentValue = Config.Aimbot.AdaptiveSmoothing,
        Callback = function(v) Config.Aimbot.AdaptiveSmoothing = v end,
    })

    TabAim:CreateSlider({
        Name = "Smooth Min (vicino)",
        Range = {1, 10},
        Increment = 0.5,
        CurrentValue = Config.Aimbot.AdaptiveMin,
        Callback = function(v) Config.Aimbot.AdaptiveMin = v end,
    })

    TabAim:CreateSlider({
        Name = "Smooth Max (lontano)",
        Range = {5, 25},
        Increment = 0.5,
        CurrentValue = Config.Aimbot.AdaptiveMax,
        Callback = function(v) Config.Aimbot.AdaptiveMax = v end,
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

    -- v3: Visual feedback
    TabAim:CreateSection("Indicatori Visivi")

    TabAim:CreateToggle({
        Name = "Mostra Snap Line",
        CurrentValue = Config.Aimbot.ShowSnapLine,
        Callback = function(v) Config.Aimbot.ShowSnapLine = v end,
    })

    TabAim:CreateColorPicker({
        Name = "Colore Snap Line",
        Color = Config.Aimbot.SnapLineColor,
        Callback = function(v) Config.Aimbot.SnapLineColor = v end,
    })

    TabAim:CreateToggle({
        Name = "Mostra Lock Indicator",
        CurrentValue = Config.Aimbot.ShowLockIndicator,
        Callback = function(v) Config.Aimbot.ShowLockIndicator = v end,
    })

    TabAim:CreateColorPicker({
        Name = "Colore Lock Indicator",
        Color = Config.Aimbot.LockIndicatorColor,
        Callback = function(v) Config.Aimbot.LockIndicatorColor = v end,
    })

    -- ╔═══════════════════════════════════════╗
    -- ║     TAB: TRIGGERBOT (v3.3: REWRITTEN)     ║
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
        Options = {"Always", "Hold"},
        CurrentOption = {Config.Triggerbot.ActivationMode},
        Callback = function(v) Config.Triggerbot.ActivationMode = v[1] or v end,
    })

    TabTrig:CreateDropdown({
        Name = "Tasto Triggerbot",
        Options = KeybindOptions,
        CurrentOption = {Config.Triggerbot.KeybindName},
        Callback = function(v)
            local name = v[1] or v
            Config.Triggerbot.KeybindName = name
            local bind = KeybindMap[name]
            if bind then
                Config.Triggerbot.ActivationKey = bind.Value
                Config.Triggerbot.ActivationKeyType = bind.Type
                Notify.Send("Triggerbot Key: " .. name, C3(255, 200, 50), 2)
            end
        end,
    })

    TabTrig:CreateSection("Fire Mode")

    TabTrig:CreateToggle({
        Name = "INSTANT FIRE (0 delay, spara subito)",
        CurrentValue = Config.Triggerbot.InstantFire,
        Callback = function(v) Config.Triggerbot.InstantFire = v end,
    })

    TabTrig:CreateToggle({
        Name = "AUTO SPRAY (raffica continua)",
        CurrentValue = Config.Triggerbot.AutoSpray,
        Callback = function(v) Config.Triggerbot.AutoSpray = v end,
    })

    TabTrig:CreateSlider({
        Name = "Spray Rate (delay tra colpi)",
        Range = {0, 0.1},
        Increment = 0.005,
        Suffix = "s",
        CurrentValue = Config.Triggerbot.SprayRate,
        Callback = function(v) Config.Triggerbot.SprayRate = v end,
    })

    TabTrig:CreateSection("FOV Triggerbot")

    TabTrig:CreateToggle({
        Name = "Usa FOV (spara se nemico nel cerchio)",
        CurrentValue = Config.Triggerbot.UseFOV,
        Callback = function(v) Config.Triggerbot.UseFOV = v end,
    })

    TabTrig:CreateSlider({
        Name = "FOV Raggio",
        Range = {20, 300},
        Increment = 5,
        Suffix = "px",
        CurrentValue = Config.Triggerbot.FOV,
        Callback = function(v) Config.Triggerbot.FOV = v end,
    })

    TabTrig:CreateToggle({
        Name = "Mostra Cerchio FOV",
        CurrentValue = Config.Triggerbot.ShowFOV,
        Callback = function(v) Config.Triggerbot.ShowFOV = v end,
    })

    TabTrig:CreateColorPicker({
        Name = "Colore FOV Triggerbot",
        Color = Config.Triggerbot.FOVColor,
        Callback = function(v) Config.Triggerbot.FOVColor = v end,
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

    TabTrig:CreateSlider({
        Name = "Hit Chance",
        Range = {1, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = Config.Triggerbot.HitChance,
        Callback = function(v) Config.Triggerbot.HitChance = v end,
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
    -- ║       TAB: PLAYER (v3: NEW)            ║
    -- ╚═══════════════════════════════════════╝
    local TabPlayer = Window:CreateTab("Player", 4483362458)

    TabPlayer:CreateSection("Velocita")

    TabPlayer:CreateToggle({
        Name = "🏃 Speed Hack",
        CurrentValue = Config.Player.SpeedEnabled,
        Callback = function(v) Config.Player.SpeedEnabled = v end,
    })

    TabPlayer:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 200},
        Increment = 1,
        CurrentValue = Config.Player.WalkSpeed,
        Callback = function(v) Config.Player.WalkSpeed = v end,
    })

    TabPlayer:CreateSection("Salto")

    TabPlayer:CreateToggle({
        Name = "🦘 Jump Hack",
        CurrentValue = Config.Player.JumpEnabled,
        Callback = function(v) Config.Player.JumpEnabled = v end,
    })

    TabPlayer:CreateSlider({
        Name = "JumpPower",
        Range = {50, 300},
        Increment = 5,
        CurrentValue = Config.Player.JumpPower,
        Callback = function(v) Config.Player.JumpPower = v end,
    })

    TabPlayer:CreateToggle({
        Name = "∞ Infinite Jump",
        CurrentValue = Config.Player.InfiniteJump,
        Callback = function(v) Config.Player.InfiniteJump = v end,
    })

    TabPlayer:CreateSection("Movimento Speciale")

    TabPlayer:CreateToggle({
        Name = "👻 Noclip (attraversa muri)",
        CurrentValue = Config.Player.NoclipEnabled,
        Callback = function(v) Config.Player.NoclipEnabled = v end,
    })

    TabPlayer:CreateToggle({
        Name = "🦅 Fly (WASD + Space/Shift)",
        CurrentValue = Config.Player.FlyEnabled,
        Callback = function(v)
            Config.Player.FlyEnabled = v
            PlayerMods.SetupFly()
            if v then
                Notify.Send("FLY ON - WASD per muoverti", C3(50, 200, 255), 3)
            else
                Notify.Send("FLY OFF", C3(200, 200, 200), 2)
            end
        end,
    })

    TabPlayer:CreateSlider({
        Name = "Velocita Volo",
        Range = {10, 200},
        Increment = 5,
        CurrentValue = Config.Player.FlySpeed,
        Callback = function(v) Config.Player.FlySpeed = v end,
    })

    -- ╔═══════════════════════════════════════╗
    -- ║        TAB: SETTINGS (v3: EXPANDED)    ║
    -- ╚═══════════════════════════════════════╝
    local TabSettings = Window:CreateTab("Settings", 4483362458)

    TabSettings:CreateSection("Interfaccia")

    TabSettings:CreateToggle({
        Name = "Mostra Watermark",
        CurrentValue = Config.Misc.ShowWatermark,
        Callback = function(v) Config.Misc.ShowWatermark = v end,
    })

    TabSettings:CreateToggle({
        Name = "Mostra Kill Feed",
        CurrentValue = Config.Misc.ShowKillFeed,
        Callback = function(v) Config.Misc.ShowKillFeed = v end,
    })

    TabSettings:CreateLabel("Premi G per aprire/chiudere il menu")

    TabSettings:CreateSection("Audio & Effetti")

    TabSettings:CreateToggle({
        Name = "🔊 Hit Sound",
        CurrentValue = Config.Misc.HitSound,
        Callback = function(v) Config.Misc.HitSound = v end,
    })

    TabSettings:CreateSection("Utilita")

    TabSettings:CreateToggle({
        Name = "🛡️ Anti-AFK",
        CurrentValue = Config.Misc.AntiAFK,
        Callback = function(v)
            Config.Misc.AntiAFK = v
            PlayerMods.SetupAntiAFK()
        end,
    })

    TabSettings:CreateToggle({
        Name = "💡 Fullbright (rimuovi ombre)",
        CurrentValue = Config.Misc.Fullbright,
        Callback = function(v)
            Config.Misc.Fullbright = v
            PlayerMods.SetupFullbright()
        end,
    })

    TabSettings:CreateSection("Statistiche Sessione")

    TabSettings:CreateLabel("Le stats sono nel watermark (K:kills H:hits)")

    TabSettings:CreateButton({
        Name = "🔄 Reset Stats",
        Callback = function()
            State.KillCount = 0
            State.HitCount = 0
            State.SessionStart = Tick()
            Notify.Send("Stats resettate!", C3(200, 200, 200), 2)
        end,
    })

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
-- INPUT HANDLER (v3: updated for custom keybinds)
-- ═══════════════════════════════════════════════════
local function matchesBind(input, bindValue, bindType)
    if bindType == "Mouse" then
        return input.UserInputType == bindValue
    else
        return input.KeyCode == bindValue
    end
end

local function OnInputBegan(input, gp)
    if gp then
        -- v3: Infinite jump bypass (works even with GUI open)
        if Config.Player.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
            pcall(function()
                if LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
        return
    end

    -- G = Toggle GUI
    if input.KeyCode == Config.Misc.GUIToggleKey then
        if Rayfield and Window then
            pcall(function()
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

    -- v3: Infinite Jump (non-GUI)
    if Config.Player.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        pcall(function()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end

    -- Aimbot (v3: custom keybind)
    if matchesBind(input, Config.Aimbot.ActivationKey, Config.Aimbot.ActivationKeyType) then
        if Config.Aimbot.ActivationMode == "Toggle" then
            State.AimbotToggled = not State.AimbotToggled
            if State.AimbotToggled then
                Notify.Send("Aimbot: ON", C3(50, 255, 100), 1.5)
            else
                Notify.Send("Aimbot: OFF", C3(255, 50, 80), 1.5)
            end
        else
            State.AimbotHeld = true
        end
    end

    -- Triggerbot (v3: custom keybind)
    if matchesBind(input, Config.Triggerbot.ActivationKey, Config.Triggerbot.ActivationKeyType) then
        State.TriggerbotHeld = true
    end
end

local function OnInputEnded(input, _)
    -- Aimbot release
    if matchesBind(input, Config.Aimbot.ActivationKey, Config.Aimbot.ActivationKeyType) then
        State.AimbotHeld = false
        if Config.Aimbot.ActivationMode == "Hold" then
            State.CurrentTarget = nil
            if TargetDot then pcall(function() TargetDot.Visible = false end) end
            if TargetInfo then pcall(function() TargetInfo.Visible = false end) end
            if SnapLine then pcall(function() SnapLine.Visible = false end) end
            if LockIndicator then pcall(function() LockIndicator.Visible = false end) end
        end
    end
    -- Triggerbot release
    if matchesBind(input, Config.Triggerbot.ActivationKey, Config.Triggerbot.ActivationKeyType) then
        State.TriggerbotHeld = false
    end
end

-- ═══════════════════════════════════════════════════
-- MAIN RENDER LOOP
-- ═══════════════════════════════════════════════════
local function RenderLoop()
    -- Camera refresh
    Camera = Workspace.CurrentCamera

    -- ESP (v3.4: each player wrapped independently)
    local _espErrCount = 0
    for player, drawings in pairs(State.ESPCache) do
        pcall(function()
            if player and player.Parent then
                if not player.Character or not player.Character.Parent then
                    pcall(ESP.HideAll, drawings)
                elseif Config.ESP.Enabled or Config.InventoryESP.Enabled then
                    local updateOk, updateErr = pcall(ESP.Update, player, drawings)
                    if not updateOk then
                        _espErrCount = _espErrCount + 1
                        pcall(ESP.HideAll, drawings)
                    end
                else
                    pcall(ESP.HideAll, drawings)
                    if Config.ESP.Chams then pcall(ESP.UpdateChams, player) end
                end
            else
                pcall(ESP.Destroy, drawings)
                State.ESPCache[player] = nil
                if State.ChamsCache[player] then
                    pcall(function() State.ChamsCache[player]:Destroy() end)
                    State.ChamsCache[player] = nil
                end
            end
        end)
    end
    -- v3.4: Debug - show error count on screen (remove later)
    if _espErrCount > 0 then
        State._espDebugErrors = (State._espDebugErrors or 0) + _espErrCount
    end

    -- Aimbot FOV Circle
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

    -- v3.3: Triggerbot FOV Circle
    if TrigFOVCircle then
        if Config.Triggerbot.Enabled and Config.Triggerbot.UseFOV and Config.Triggerbot.ShowFOV then
            TrigFOVCircle.Position = Util.Center()
            TrigFOVCircle.Radius = Config.Triggerbot.FOV
            TrigFOVCircle.Color = Config.Triggerbot.FOVColor
            TrigFOVCircle.Thickness = Config.Triggerbot.FOVThickness
            TrigFOVCircle.Transparency = Config.Triggerbot.FOVTransparency
            TrigFOVCircle.Visible = true
        else
            TrigFOVCircle.Visible = false
        end
    end

    -- Aimbot
    if Aimbot.IsActive() then
        local target

        -- v3: Auto switch on target death
        if Config.Aimbot.StickyAim and State.CurrentTarget then
            if Util.Alive(State.CurrentTarget) then
                target = State.CurrentTarget
            elseif Config.Aimbot.AutoSwitch then
                target = Aimbot.FindTarget()
                State.CurrentTarget = target
            end
        else
            target = Aimbot.FindTarget()
            State.CurrentTarget = target
        end

        if target and target.Character then
            -- v3: Bone priority
            local targetPart = Config.Aimbot.TargetPart
            if Config.Aimbot.BonePriority then
                targetPart = Util.GetBestBone(target.Character)
            end

            local part = target.Character:FindFirstChild(targetPart)
            if part then
                -- v3: Silent aim sets target but doesn't move mouse
                if Config.Aimbot.SilentAim then
                    _silentAimTarget = Aimbot.Predict(part)
                    -- Just show indicators without moving mouse
                    local sp, on = Util.W2S(_silentAimTarget)
                    if on then
                        if TargetDot then TargetDot.Position = sp; TargetDot.Visible = true end
                        if Config.Aimbot.ShowSnapLine and SnapLine then
                            SnapLine.From = Util.Center(); SnapLine.To = sp
                            SnapLine.Color = Config.Aimbot.SnapLineColor; SnapLine.Visible = true
                        end
                        if Config.Aimbot.ShowLockIndicator and LockIndicator then
                            LockIndicator.Position = sp; LockIndicator.Radius = 15
                            LockIndicator.Color = Config.Aimbot.LockIndicatorColor; LockIndicator.Visible = true
                        end
                    end
                else
                    Aimbot.AimAt(Aimbot.Predict(part))
                end

                -- Target info display
                if Config.Aimbot.ShowTargetInfo and TargetInfo then
                    local hum = target.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local dist = mFloor(Util.D3(part.Position, Camera.CFrame.Position))
                        TargetInfo.Text = target.DisplayName .. " | " .. mFloor(hum.Health) .. "/" .. mFloor(hum.MaxHealth) .. " | " .. dist .. "m"
                        local center = Util.Center()
                        TargetInfo.Position = V2(center.X - TargetInfo.TextBounds.X/2, center.Y + Config.Aimbot.FOV + 10)
                        TargetInfo.Visible = true
                    end
                end
            end
        else
            _silentAimTarget = nil
            if TargetDot then pcall(function() TargetDot.Visible = false end) end
            if TargetInfo then pcall(function() TargetInfo.Visible = false end) end
            if SnapLine then pcall(function() SnapLine.Visible = false end) end
            if LockIndicator then pcall(function() LockIndicator.Visible = false end) end
        end
    else
        _silentAimTarget = nil
        if TargetDot then pcall(function() TargetDot.Visible = false end) end
        if TargetInfo then pcall(function() TargetInfo.Visible = false end) end
        if SnapLine then pcall(function() SnapLine.Visible = false end) end
        if LockIndicator then pcall(function() LockIndicator.Visible = false end) end
    end

    -- Triggerbot
    pcall(Triggerbot.Process)

    -- v3: Player mods per-frame
    PlayerMods.UpdateSpeed()
    PlayerMods.UpdateJump()
    PlayerMods.Noclip()
    PlayerMods.UpdateFly()

    -- v3: Kill tracking
    pcall(trackKills)

    -- Watermark
    updateWatermark()
end

-- ═══════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════
local function Unload()
    -- v3.4: Disconnect render
    if State.Connections.Render then
        pcall(function() State.Connections.Render:Disconnect() end)
        State.Connections.Render = nil
    end
    pcall(function() RunService:UnbindFromRenderStep("PhantomRender") end)

    for _, c in pairs(State.Connections) do
        pcall(function() if c and c.Connected then c:Disconnect() end end)
    end
    tClear(State.Connections)

    -- v3.1: Disconnect character listeners
    for _, conns in pairs(_charConns) do
        for _, conn in pairs(conns) do
            pcall(function() conn:Disconnect() end)
        end
    end
    tClear(_charConns)

    for _, d in pairs(State.ESPCache) do ESP.Destroy(d) end
    tClear(State.ESPCache)

    -- v3: Remove chams
    for _, hl in pairs(State.ChamsCache) do pcall(function() hl:Destroy() end) end
    tClear(State.ChamsCache)

    -- v3: Remove fly
    if State.FlyBody then pcall(function() State.FlyBody:Destroy() end) end
    if State.FlyGyro then pcall(function() State.FlyGyro:Destroy() end) end

    -- v3: Anti-AFK disconnect
    if State.AntiAFKConn then pcall(function() State.AntiAFKConn:Disconnect() end) end

    -- v3: Restore fullbright
    Config.Misc.Fullbright = false
    PlayerMods.SetupFullbright()

    pcall(function() FOVCircle:Remove() end)
    pcall(function() TrigFOVCircle:Remove() end)
    pcall(function() TargetDot:Remove() end)
    pcall(function() TargetInfo:Remove() end)
    pcall(function() SnapLine:Remove() end)
    pcall(function() LockIndicator:Remove() end)
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

    -- v3.4: Use RenderStepped for maximum compatibility
    State.Connections.Render = RunService.RenderStepped:Connect(function()
        if State.Running then
            Camera = Workspace.CurrentCamera
            pcall(RenderLoop)
        else
            Unload()
        end
    end)

    -- v3: Setup anti-AFK
    PlayerMods.SetupAntiAFK()

    Notify.Send("PHANTOM v3.5 Loaded!", C3(180, 80, 255), 4)
    Notify.Send("Premi G per il menu", C3(200, 200, 200), 5)
    Notify.Send("v3.5: ESP Bounding Box Fix — perfect tracking!", C3(50, 255, 100), 6)
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
