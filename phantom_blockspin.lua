--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║     PHANTOM v3.7 · BlockSpin Stealth Suite                    ║
    ║     Fluent UI Edition · Built for Xeno                        ║
    ╠═══════════════════════════════════════════════════════════════╣
    ║  Premi G per aprire/chiudere il menu                          ║
    ║  v3.7: FLUENT UI UPGRADE — Windows 11 Modern Acrylic Style,   ║
    ║        Ultra-fluid 60 FPS, Zero Frame Drops, Lucide Icons,    ║
    ║        Native ESP Highlight + BillboardGui engine             ║
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
local GuiService       = game:GetService("GuiService")

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
        VisibleColor    = C3(255, 40, 40),
        NotVisibleColor = C3(160, 20, 20),
        DefaultColor    = C3(255, 40, 40),
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
        ChamsVisibleColor   = C3(255, 40, 40),
        ChamsHiddenColor    = C3(160, 20, 20),
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
    return V2(vp.X / 2, vp.Y / 2)
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

    -- 3. Check for TextLabel inside tool's GUI
    pcall(function()
        for _, child in ipairs(tool:GetChildren()) do
            if child:IsA("BillboardGui") or child:IsA("SurfaceGui") or child:IsA("ScreenGui") then
                for _, lbl in ipairs(child:GetChildren()) do
                    if lbl:IsA("TextLabel") and lbl.Text and #lbl.Text > 0 and not lbl.Text:match("^%d+$") and #lbl.Text < 40 then
                        found = lbl.Text
                        return
                    end
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

-- v3.6: Cached tool display info with smart name resolution
local _toolInfoCache = setmetatable({}, {__mode = "k"})

function Util.GetToolInfo(tool, isEquipped)
    if not tool then return {display = nil, isEquipped = isEquipped} end
    local cached = _toolInfoCache[tool]
    local now = Tick()
    if cached and cached.isEquipped == isEquipped and (now - (cached.time or 0) < 3.0) then
        return cached
    end

    local info = {}
    local name = Util.ResolveToolName(tool)
    if not name then
        info.display = nil
        info.isEquipped = isEquipped
        info.time = now
        _toolInfoCache[tool] = info
        return info
    end

    local prefix = isEquipped and "[E]" or "[B]"
    info.display = prefix .. " " .. name

    if Config.InventoryESP.ShowDamage then
        local dmg = Util.GetToolDamage(tool)
        if dmg then
            info.display = info.display .. " [" .. dmg .. "DMG]"
        end
    end

    info.isEquipped = isEquipped
    info.time = now
    _toolInfoCache[tool] = info
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
-- ESP ENGINE (v3.6 NATIVE HIGHLIGHT & BILLBOARDGUI SYSTEM)
-- ═══════════════════════════════════════════════════
local ESP = {}

local _charConns = {}

function ESP.Create(player)
    local d = {}
    d.Player = player

    -- 1. Native Roblox Highlight (Silhouettes, Chams, Depth-Aware Outline)
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "P_HL_" .. (player and player.UserId or mRandom(1000, 9999))
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.85
        hl.OutlineTransparency = 0
        hl.Enabled = false
        d.Highlight = hl
    end)

    -- 2. Native Roblox SelectionBox (3D Bounding Box around character)
    pcall(function()
        local sb = Instance.new("SelectionBox")
        sb.Name = "P_SB_" .. (player and player.UserId or mRandom(1000, 9999))
        sb.AlwaysOnTop = true
        sb.LineThickness = 0.04
        sb.SurfaceTransparency = 1
        sb.Visible = false
        d.SelectionBox = sb
    end)

    -- 3. Native Roblox BillboardGui (Name, Distance, Health Bar, Inventory)
    pcall(function()
        local bb = Instance.new("BillboardGui")
        bb.Name = "P_ESP_" .. (player and player.UserId or mRandom(1000, 9999))
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 160, 0, 65)
        bb.StudsOffset = V3(0, 2.8, 0)
        bb.LightInfluence = 0
        bb.MaxDistance = Config.ESP.MaxDistance
        bb.Enabled = false

        -- Name & Distance Label
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Name = "NameLabel"
        nameLbl.BackgroundTransparency = 1
        nameLbl.Size = UDim2.new(1, 0, 0, 14)
        nameLbl.Position = UDim2.new(0, 0, 0, 0)
        nameLbl.Font = Enum.Font.SourceSansBold
        nameLbl.TextSize = Config.ESP.NameSize
        nameLbl.TextColor3 = Config.ESP.NameColor
        nameLbl.TextStrokeTransparency = 0
        nameLbl.TextStrokeColor3 = C3(0, 0, 0)
        nameLbl.Text = ""
        nameLbl.Visible = false
        nameLbl.Parent = bb
        d.NameLabel = nameLbl

        -- Health Bar Background
        local hpBG = Instance.new("Frame")
        hpBG.Name = "HealthBG"
        hpBG.BackgroundColor3 = C3(20, 20, 20)
        hpBG.BorderSizePixel = 0
        hpBG.Size = UDim2.new(0, 70, 0, 4)
        hpBG.Position = UDim2.new(0.5, -35, 0, 16)
        hpBG.Visible = false
        hpBG.Parent = bb
        d.HealthBG = hpBG

        -- Health Bar Fill
        local hpFill = Instance.new("Frame")
        hpFill.Name = "HealthFill"
        hpFill.BorderSizePixel = 0
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = C3(50, 255, 100)
        hpFill.Parent = hpBG
        d.HealthFill = hpFill

        -- Health Text
        local hpText = Instance.new("TextLabel")
        hpText.Name = "HealthText"
        hpText.BackgroundTransparency = 1
        hpText.Size = UDim2.new(1, 0, 0, 11)
        hpText.Position = UDim2.new(0, 0, 0, 21)
        hpText.Font = Enum.Font.SourceSans
        hpText.TextSize = 10
        hpText.TextColor3 = C3(255, 255, 255)
        hpText.TextStrokeTransparency = 0
        hpText.TextStrokeColor3 = C3(0, 0, 0)
        hpText.Text = ""
        hpText.Visible = false
        hpText.Parent = bb
        d.HealthText = hpText

        -- Inventory Label
        local invLbl = Instance.new("TextLabel")
        invLbl.Name = "InventoryLabel"
        invLbl.BackgroundTransparency = 1
        invLbl.Size = UDim2.new(1, 0, 0, 13)
        invLbl.Position = UDim2.new(0, 0, 0, 22)
        invLbl.Font = Enum.Font.SourceSans
        invLbl.TextSize = Config.InventoryESP.TextSize
        invLbl.TextColor3 = Config.InventoryESP.TextColor
        invLbl.TextStrokeTransparency = 0
        invLbl.TextStrokeColor3 = C3(0, 0, 0)
        invLbl.Text = ""
        invLbl.Visible = false
        invLbl.Parent = bb
        d.InventoryLabel = invLbl

        d.Billboard = bb
    end)

    -- 4. Drawing Tracer (for optional screen tracers, with border-escape safeguard)
    pcall(function()
        if Drawing and Drawing.new then
            local tr = Drawing.new("Line")
            tr.Thickness = Config.ESP.TracerThickness
            tr.Visible = false
            tr.From = V2(-2000, -2000)
            tr.To = V2(-2000, -2000)
            d.Tracer = tr
        end
    end)

    -- 5. Optional Skeleton lines container
    d.Skeleton = {}

    return d
end

function ESP.Destroy(d)
    if not d then return end
    pcall(function() if d.Highlight then d.Highlight:Destroy() end end)
    pcall(function() if d.SelectionBox then d.SelectionBox:Destroy() end end)
    pcall(function() if d.Billboard then d.Billboard:Destroy() end end)
    pcall(function() if d.Tracer then d.Tracer:Remove() end end)
    pcall(function() if d.HeadDot then d.HeadDot:Remove() end end)
    if d.Skeleton then
        for _, line in pairs(d.Skeleton) do
            pcall(function() line:Remove() end)
        end
    end
end

function ESP.HideAll(d)
    if not d then return end
    pcall(function() if d.Highlight then d.Highlight.Enabled = false end end)
    pcall(function() if d.SelectionBox then d.SelectionBox.Visible = false end end)
    pcall(function() if d.Billboard then d.Billboard.Enabled = false end end)
    pcall(function()
        if d.Tracer then
            d.Tracer.Visible = false
            d.Tracer.From = V2(-2000, -2000)
            d.Tracer.To = V2(-2000, -2000)
        end
    end)
    pcall(function()
        if d.HeadDot then
            d.HeadDot.Visible = false
            d.HeadDot.Position = V2(-2000, -2000)
        end
    end)
    if d.Skeleton then
        for _, line in pairs(d.Skeleton) do
            pcall(function()
                line.Visible = false
                line.From = V2(-2000, -2000)
                line.To = V2(-2000, -2000)
            end)
        end
    end
end

function ESP.Register(p)
    if p == LocalPlayer or State.ESPCache[p] then return end
    local entry = ESP.Create(p)
    State.ESPCache[p] = entry
    if entry.Highlight then
        State.ChamsCache[p] = entry.Highlight
    end

    local conns = {}
    pcall(function()
        conns.removing = p.CharacterRemoving:Connect(function()
            if State.ESPCache[p] then
                ESP.HideAll(State.ESPCache[p])
            end
        end)
        conns.added = p.CharacterAdded:Connect(function()
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
    if State.ChamsCache[p] then
        State.ChamsCache[p] = nil
    end
    if _charConns[p] then
        for _, conn in pairs(_charConns[p]) do
            pcall(function() conn:Disconnect() end)
        end
        _charConns[p] = nil
    end
end

function ESP.DrawSkeleton(d, char, color)
    if not d.Skeleton then d.Skeleton = {} end
    for i, bone in ipairs(SKELETON_BONES) do
        local partA = char:FindFirstChild(bone[1])
        local partB = char:FindFirstChild(bone[2])
        if partA and partB then
            if not d.Skeleton[i] and Drawing and Drawing.new then
                pcall(function()
                    d.Skeleton[i] = Drawing.new("Line")
                end)
            end
            local line = d.Skeleton[i]
            if line then
                local sA, onA = Util.W2S(partA.Position)
                local sB, onB = Util.W2S(partB.Position)
                if onA and onB then
                    line.From = sA
                    line.To = sB
                    line.Color = color
                    line.Thickness = Config.ESP.SkeletonThickness
                    line.Visible = true
                else
                    line.Visible = false
                    line.From = V2(-2000, -2000)
                    line.To = V2(-2000, -2000)
                end
            end
        elseif d.Skeleton[i] then
            d.Skeleton[i].Visible = false
            d.Skeleton[i].From = V2(-2000, -2000)
            d.Skeleton[i].To = V2(-2000, -2000)
        end
    end
end

function ESP.HideSkeleton(d)
    if not d or not d.Skeleton then return end
    for _, line in pairs(d.Skeleton) do
        pcall(function()
            line.Visible = false
            line.From = V2(-2000, -2000)
            line.To = V2(-2000, -2000)
        end)
    end
end

function ESP.UpdateChams(player)
    local entry = State.ESPCache[player]
    if entry then
        ESP.Update(player, entry)
    end
end

function ESP.Update(player, d)
    if not player or not player.Parent then ESP.HideAll(d) return end
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

    -- Color determination
    local isVisible = Util.Visible(camPos, rootPos, player)
    local col
    if Config.ESP.ShowTeamColor and player.Team then
        col = player.TeamColor.Color
    elseif Config.ESP.VisibilityCheck then
        col = isVisible and Config.ESP.VisibleColor or Config.ESP.NotVisibleColor
    else
        col = Config.ESP.DefaultColor
    end

    -- 1. NATIVE HIGHLIGHT (Outline / Chams)
    if d.Highlight then
        if Config.ESP.Chams or Config.ESP.Enabled then
            if d.Highlight.Parent ~= char then d.Highlight.Parent = char end
            if d.Highlight.Adornee ~= char then d.Highlight.Adornee = char end
            d.Highlight.OutlineColor = col
            if Config.ESP.Chams then
                d.Highlight.FillColor = isVisible and Config.ESP.ChamsVisibleColor or Config.ESP.ChamsHiddenColor
                d.Highlight.FillTransparency = Config.ESP.ChamsTransparency
                d.Highlight.OutlineTransparency = 0
            else
                d.Highlight.FillColor = col
                d.Highlight.FillTransparency = 0.85
                d.Highlight.OutlineTransparency = 0
            end
            d.Highlight.Enabled = true
        else
            d.Highlight.Enabled = false
        end
    end

    -- 2. NATIVE SELECTIONBOX (3D Box bounding character)
    if d.SelectionBox then
        if Config.ESP.Enabled and Config.ESP.BoxStyle ~= "None" then
            if d.SelectionBox.Parent ~= char then d.SelectionBox.Parent = char end
            if d.SelectionBox.Adornee ~= char then d.SelectionBox.Adornee = char end
            d.SelectionBox.Color3 = col
            d.SelectionBox.LineThickness = (Config.ESP.BoxThickness or 1.3) * 0.025
            d.SelectionBox.Visible = true
        else
            d.SelectionBox.Visible = false
        end
    end

    -- 3. NATIVE BILLBOARDGUI (Name, Distance, Health, Inventory)
    if d.Billboard then
        local showGui = Config.ESP.Enabled or Config.InventoryESP.Enabled
        if showGui then
            local adorneePart = head or root
            if d.Billboard.Parent ~= char then d.Billboard.Parent = char end
            if d.Billboard.Adornee ~= adorneePart then d.Billboard.Adornee = adorneePart end
            d.Billboard.MaxDistance = Config.ESP.MaxDistance
            d.Billboard.Enabled = true

            -- Name & Distance
            if d.NameLabel then
                if Config.ESP.Names or Config.ESP.Distance then
                    local txt = ""
                    if Config.ESP.Names then txt = player.DisplayName end
                    if Config.ESP.Distance then
                        txt = txt .. (txt ~= "" and " " or "") .. "[" .. mFloor(dist) .. "m]"
                    end
                    d.NameLabel.Text = txt
                    d.NameLabel.TextColor3 = Config.ESP.NameColor
                    d.NameLabel.TextSize = Config.ESP.NameSize
                    d.NameLabel.Visible = true
                else
                    d.NameLabel.Visible = false
                end
            end

            -- Health Bar & Health Text
            if d.HealthBG and d.HealthFill then
                if Config.ESP.HealthBar then
                    local maxHp = (hum.MaxHealth and hum.MaxHealth > 0) and hum.MaxHealth or 100
                    local curHp = mClamp(hum.Health, 0, maxHp)
                    local pct = mClamp(curHp / maxHp, 0, 1)
                    d.HealthFill.Size = UDim2.new(pct, 0, 1, 0)
                    local hpColor = C3(mFloor((1 - pct) * 255), mFloor(pct * 255), 50)
                    d.HealthFill.BackgroundColor3 = hpColor
                    d.HealthBG.Visible = true

                    if d.HealthText then
                        if Config.ESP.HealthText then
                            d.HealthText.Text = mFloor(curHp) .. " HP"
                            d.HealthText.TextColor3 = hpColor
                            d.HealthText.Visible = true
                        else
                            d.HealthText.Visible = false
                        end
                    end
                else
                    d.HealthBG.Visible = false
                    if d.HealthText then d.HealthText.Visible = false end
                end
            end

            -- Inventory ESP (Ultra-optimized with 0.3s throttle & diff cache)
            if d.InventoryLabel then
                if Config.InventoryESP.Enabled then
                    local now = Tick()
                    if not d._lastInvCheck or (now - d._lastInvCheck > 0.3) then
                        d._lastInvCheck = now
                        local items = {}
                        local itemCount = 0
                        local hasEquipped = false

                        if Config.InventoryESP.ShowEquipped then
                            for _, c in ipairs(char:GetChildren()) do
                                if c:IsA("Tool") and itemCount < Config.InventoryESP.MaxItems then
                                    hasEquipped = true
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

                        d._lastInvText = (#items > 0) and tConcat(items, " | ") or ""
                        d._lastHasEquipped = hasEquipped
                    end

                    local text = d._lastInvText or ""
                    if #text > 0 then
                        if d.InventoryLabel.Text ~= text then
                            d.InventoryLabel.Text = text
                        end
                        local targetCol = d._lastHasEquipped and Config.InventoryESP.EquippedColor or Config.InventoryESP.TextColor
                        if d.InventoryLabel.TextColor3 ~= targetCol then
                            d.InventoryLabel.TextColor3 = targetCol
                        end
                        d.InventoryLabel.TextSize = Config.InventoryESP.TextSize
                        d.InventoryLabel.Position = UDim2.new(0, 0, 0, (Config.ESP.HealthBar and (Config.ESP.HealthText and 33 or 23)) or (Config.ESP.Names and 16 or 0))
                        d.InventoryLabel.Visible = true
                    else
                        d.InventoryLabel.Visible = false
                    end
                else
                    d.InventoryLabel.Visible = false
                end
            end
        else
            d.Billboard.Enabled = false
        end
    end

    -- 4. TRACERS (Safe 2D Fallback with offscreen reset)
    if d.Tracer then
        if Config.ESP.Enabled and Config.ESP.Tracers then
            local rootScreen, onScreen = Util.W2S(rootPos)
            local vpSize = cam.ViewportSize
            if onScreen and rootScreen.X >= -10 and rootScreen.X <= vpSize.X + 10 and rootScreen.Y >= -10 and rootScreen.Y <= vpSize.Y + 10 then
                local origin
                if Config.ESP.TracerOrigin == "Bottom" then origin = V2(vpSize.X / 2, vpSize.Y)
                elseif Config.ESP.TracerOrigin == "Top" then origin = V2(vpSize.X / 2, 0)
                elseif Config.ESP.TracerOrigin == "Mouse" then origin = Util.MousePos()
                else origin = V2(vpSize.X / 2, vpSize.Y / 2) end
                d.Tracer.From = origin
                d.Tracer.To = rootScreen
                d.Tracer.Color = col
                d.Tracer.Thickness = Config.ESP.TracerThickness
                d.Tracer.Visible = true
            else
                d.Tracer.Visible = false
                d.Tracer.From = V2(-2000, -2000)
                d.Tracer.To = V2(-2000, -2000)
            end
        else
            d.Tracer.Visible = false
            d.Tracer.From = V2(-2000, -2000)
            d.Tracer.To = V2(-2000, -2000)
        end
    end

    -- 5. SKELETON
    pcall(function()
        if Config.ESP.Enabled and Config.ESP.Skeleton then
            ESP.DrawSkeleton(d, char, Config.ESP.SkeletonColor)
        else
            ESP.HideSkeleton(d)
        end
    end)

    -- 6. HEAD DOT
    if Config.ESP.Enabled and Config.ESP.HeadDot and head then
        if not d.HeadDot and Drawing and Drawing.new then
            pcall(function()
                d.HeadDot = Drawing.new("Circle")
                d.HeadDot.Filled = true
                d.HeadDot.NumSides = 12
            end)
        end
        if d.HeadDot then
            local headScreen, headOn = Util.W2S(head.Position)
            if headOn then
                d.HeadDot.Position = headScreen
                d.HeadDot.Radius = mClamp(Config.ESP.HeadDotSize * (200 / dist), 1, 8)
                d.HeadDot.Color = col
                d.HeadDot.Visible = true
            else
                d.HeadDot.Visible = false
                d.HeadDot.Position = V2(-2000, -2000)
            end
        end
    elseif d.HeadDot then
        d.HeadDot.Visible = false
        d.HeadDot.Position = V2(-2000, -2000)
    end
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
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local center = V2(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

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
                    local d3 = Util.D3(part.Position, cam.CFrame.Position)
                    if d3 <= Config.Aimbot.MaxDistance then
                        local vp, on = cam:WorldToViewportPoint(part.Position)
                        if on and vp.Z > 0 then
                            local sp = V2(vp.X, vp.Y)
                            local val
                            if Config.Aimbot.TargetMode == "Distance" then
                                val = d3
                            else
                                val = Util.D2(sp, center)
                            end

                            if val <= Config.Aimbot.FOV and val < bestVal then
                                if Config.Aimbot.WallCheck then
                                    if Util.Visible(cam.CFrame.Position, part.Position, p) then
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
    local targetPos = part.Position
    -- Calibrate head aim down by 0.65 studs to hit direct face/chin center and eliminate overshooting above head
    if part.Name == "Head" then
        targetPos = targetPos - V3(0, 0.65, 0)
    end
    if not Config.Aimbot.Prediction then return targetPos end
    local vel = V3(0,0,0)
    pcall(function() vel = part.AssemblyLinearVelocity end)
    if vel.Magnitude < 0.1 then pcall(function() vel = part.Velocity end) end
    -- Only predict X and Z velocity to prevent vertical jumping over head
    return targetPos + (V3(vel.X, 0, vel.Z) * Config.Aimbot.PredictionMultiplier)
end

function Aimbot.AimAt(worldPos)
    if not HAS_MOUSEMOVEREL then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    
    local vp, on = cam:WorldToViewportPoint(worldPos)
    if not on or vp.Z <= 0 then return end

    local vpSize = cam.ViewportSize
    local center = V2(vpSize.X / 2, vpSize.Y / 2)
    local delta = V2(vp.X, vp.Y) - center

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

    local mx = delta.X / math.max(smooth, 1)
    local my = delta.Y / math.max(smooth, 1)

    if Config.Aimbot.HumanizeJitter then
        local js = Config.Aimbot.JitterStrength
        mx = mx + Util.RF(-js, js)
        my = my + Util.RF(-js, js)
    end

    mousemoverel(mx, my)

    local sp = Util.W2S(worldPos)
    -- Target dot
    if TargetDot then TargetDot.Position = sp; TargetDot.Visible = true end

    -- v3: Snap line
    if Config.Aimbot.ShowSnapLine and SnapLine then
        SnapLine.From = Util.Center()
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
        -- CROSSHAIR MODE: hybrid raycast + screen-center part intersection (flawless at ANY distance)
        local center = Util.Center()

        -- 1. Check direct 2D crosshair alignment with all target parts (immune to transparent barriers / hitboxes)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and Util.Alive(p) then
                if not (Config.Triggerbot.TeamCheck and Util.IsTeam(p)) then
                    local char = p.Character
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local d3 = Util.D3(root.Position, Camera.CFrame.Position)
                            if d3 <= Config.Triggerbot.MaxDistance then
                                for _, partName in ipairs(Config.Triggerbot.TargetParts) do
                                    local part = char:FindFirstChild(partName)
                                    if part then
                                        local vp, on = Camera:WorldToViewportPoint(part.Position)
                                        if on and vp.Z > 0 then
                                            local partScreenRadius = mClamp((part.Size.Magnitude / 2) * (Camera.ViewportSize.Y / (2 * math.tan(math.rad(Camera.FieldOfView / 2)) * vp.Z)), 4, 30)
                                            if Util.D2(V2(vp.X, vp.Y), center) <= partScreenRadius then
                                                if Config.Triggerbot.HeadshotOnly then
                                                    if partName == "Head" then hasTarget = true break end
                                                else
                                                    hasTarget = true
                                                    break
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
            if hasTarget then break end
        end

        -- 2. Fallback to physical Raycast if 2D check didn't trip
        if not hasTarget then
            local ray = Camera:ViewportPointToRay(center.X, center.Y)
            local params = RParams()
            params.FilterType = Enum.RaycastFilterType.Exclude
            local fl = {Camera}
            if LocalPlayer.Character then tInsert(fl, LocalPlayer.Character) end
            params.FilterDescendantsInstances = fl

            local r = Workspace:Raycast(ray.Origin, ray.Direction * Config.Triggerbot.MaxDistance, params)
            if r and r.Instance then
                local hitInstance = r.Instance
                local current = hitInstance
                while current and current ~= Workspace do
                    if current:IsA("Model") then
                        local p = Players:GetPlayerFromCharacter(current)
                        if p and p ~= LocalPlayer then
                            if not (Config.Triggerbot.TeamCheck and Util.IsTeam(p)) then
                                hasTarget = true
                            end
                            break
                        end
                    end
                    current = current.Parent
                end
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
-- LOAD FLUENT UI (Modern, Ultra-Fluid, Zero-Lag)
-- ═══════════════════════════════════════════════════
local Fluent
local Window
local Tabs = {}

local guiOk, guiErr = pcall(function()
    Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dibardoalessandro-alt/phantom-scripts/main/fluent.lua"))()
    
    local SaveManager
    local InterfaceManager
    pcall(function()
        SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)

    Window = Fluent:CreateWindow({
        Title = "PHANTOM v3.7",
        SubTitle = "BlockSpin Stealth Suite",
        TabWidth = 160,
        Size = UDim2.fromOffset(590, 470),
        Acrylic = false, -- false di default per garantire 60 FPS senza cali su qualsiasi executor (anche Xeno)
        Theme = "Dark",
        MinimizeKey = Config.Misc.GUIToggleKey or Enum.KeyCode.G
    })

    -- ╔═══════════════════════════════════════╗
    -- ║              TABS SETUP               ║
    -- ╚═══════════════════════════════════════╝
    Tabs = {
        ESP        = Window:AddTab({ Title = "ESP", Icon = "eye" }),
        Inventory  = Window:AddTab({ Title = "Inventario", Icon = "box" }),
        Aimbot     = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
        Triggerbot = Window:AddTab({ Title = "Triggerbot", Icon = "target" }),
        Player     = Window:AddTab({ Title = "Player", Icon = "user" }),
        Settings   = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- ═══════════════════════════════════════
    -- TAB: ESP
    -- ═══════════════════════════════════════
    Tabs.ESP:AddSection("Generale")

    Tabs.ESP:AddToggle("ESPToggle", {
        Title = "Abilita ESP",
        Default = Config.ESP.Enabled,
        Callback = function(v) Config.ESP.Enabled = v end
    })

    Tabs.ESP:AddDropdown("ESPBoxStyle", {
        Title = "Stile Box",
        Values = {"Full", "Corner"},
        Default = Config.ESP.BoxStyle,
        Multi = false,
        Callback = function(v) Config.ESP.BoxStyle = v end
    })

    Tabs.ESP:AddSlider("ESPBoxThickness", {
        Title = "Spessore Box",
        Min = 1,
        Max = 5,
        Default = Config.ESP.BoxThickness,
        Rounding = 1,
        Callback = function(v) Config.ESP.BoxThickness = v end
    })

    Tabs.ESP:AddToggle("ESPBoxOutline", {
        Title = "Contorno Box (Outline)",
        Default = Config.ESP.BoxOutline,
        Callback = function(v) Config.ESP.BoxOutline = v end
    })

    Tabs.ESP:AddSection("Informazioni Bersaglio")

    Tabs.ESP:AddToggle("ESPNames", {
        Title = "Mostra Nomi",
        Default = Config.ESP.Names,
        Callback = function(v) Config.ESP.Names = v end
    })

    Tabs.ESP:AddSlider("ESPNameSize", {
        Title = "Dimensione Nome",
        Min = 10,
        Max = 24,
        Default = Config.ESP.NameSize,
        Rounding = 0,
        Callback = function(v) Config.ESP.NameSize = v end
    })

    Tabs.ESP:AddToggle("ESPDistance", {
        Title = "Mostra Distanza",
        Default = Config.ESP.Distance,
        Callback = function(v) Config.ESP.Distance = v end
    })

    Tabs.ESP:AddToggle("ESPHealthBar", {
        Title = "Barra Vita",
        Default = Config.ESP.HealthBar,
        Callback = function(v) Config.ESP.HealthBar = v end
    })

    Tabs.ESP:AddDropdown("ESPHealthBarPos", {
        Title = "Posizione Barra Vita",
        Values = {"Left", "Right"},
        Default = Config.ESP.HealthBarPos,
        Multi = false,
        Callback = function(v) Config.ESP.HealthBarPos = v end
    })

    Tabs.ESP:AddToggle("ESPHealthText", {
        Title = "Mostra HP Numerico",
        Default = Config.ESP.HealthText,
        Callback = function(v) Config.ESP.HealthText = v end
    })

    Tabs.ESP:AddToggle("ESPLookVector", {
        Title = "Mostra Angolo Visuale",
        Default = Config.ESP.LookVector,
        Callback = function(v) Config.ESP.LookVector = v end
    })

    Tabs.ESP:AddSlider("ESPLookVectorLen", {
        Title = "Lunghezza Linea Sguardo",
        Min = 5,
        Max = 30,
        Default = Config.ESP.LookVectorLength,
        Rounding = 0,
        Callback = function(v) Config.ESP.LookVectorLength = v end
    })

    Tabs.ESP:AddSection("Tracers")

    Tabs.ESP:AddToggle("ESPTracers", {
        Title = "Abilita Tracers",
        Default = Config.ESP.Tracers,
        Callback = function(v) Config.ESP.Tracers = v end
    })

    Tabs.ESP:AddDropdown("ESPTracerOrigin", {
        Title = "Origine Tracers",
        Values = {"Bottom", "Center", "Mouse"},
        Default = Config.ESP.TracerOrigin,
        Multi = false,
        Callback = function(v) Config.ESP.TracerOrigin = v end
    })

    Tabs.ESP:AddSlider("ESPTracerThickness", {
        Title = "Spessore Tracers",
        Min = 1,
        Max = 4,
        Default = Config.ESP.TracerThickness,
        Rounding = 1,
        Callback = function(v) Config.ESP.TracerThickness = v end
    })

    Tabs.ESP:AddSection("Skeleton ESP")

    Tabs.ESP:AddToggle("ESPSkeleton", {
        Title = "Abilita Scheletro",
        Default = Config.ESP.Skeleton,
        Callback = function(v) Config.ESP.Skeleton = v end
    })

    Tabs.ESP:AddColorpicker("ESPSkeletonColor", {
        Title = "Colore Scheletro",
        Default = Config.ESP.SkeletonColor,
        Callback = function(v) Config.ESP.SkeletonColor = v end
    })

    Tabs.ESP:AddSlider("ESPSkeletonThickness", {
        Title = "Spessore Scheletro",
        Min = 1,
        Max = 4,
        Default = Config.ESP.SkeletonThickness,
        Rounding = 1,
        Callback = function(v) Config.ESP.SkeletonThickness = v end
    })

    Tabs.ESP:AddSection("Chams (Highlight)")

    Tabs.ESP:AddToggle("ESPChams", {
        Title = "Abilita Chams",
        Default = Config.ESP.Chams,
        Callback = function(v)
            Config.ESP.Chams = v
            if not v then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local h = p.Character:FindFirstChild("PHANTOM_Highlight")
                        if h then h:Destroy() end
                    end
                end
            end
        end
    })

    Tabs.ESP:AddColorpicker("ESPChamsVisColor", {
        Title = "Colore Chams (Visibile)",
        Default = Config.ESP.ChamsVisibleColor,
        Callback = function(v) Config.ESP.ChamsVisibleColor = v end
    })

    Tabs.ESP:AddColorpicker("ESPChamsHidColor", {
        Title = "Colore Chams (Nascosto)",
        Default = Config.ESP.ChamsHiddenColor,
        Callback = function(v) Config.ESP.ChamsHiddenColor = v end
    })

    Tabs.ESP:AddSlider("ESPChamsTrans", {
        Title = "Trasparenza Chams",
        Min = 0,
        Max = 0.9,
        Default = Config.ESP.ChamsTransparency,
        Rounding = 2,
        Callback = function(v) Config.ESP.ChamsTransparency = v end
    })

    Tabs.ESP:AddSection("Colori & Visibilita")

    Tabs.ESP:AddToggle("ESPVisCheck", {
        Title = "Check Visibilita (verde/rosso)",
        Default = Config.ESP.VisibilityCheck,
        Callback = function(v) Config.ESP.VisibilityCheck = v end
    })

    Tabs.ESP:AddToggle("ESPShowTeamColor", {
        Title = "Mostra Colore Squadra",
        Default = Config.ESP.ShowTeamColor,
        Callback = function(v) Config.ESP.ShowTeamColor = v end
    })

    Tabs.ESP:AddColorpicker("ESPVisibleColor", {
        Title = "Colore Visibile",
        Default = Config.ESP.VisibleColor,
        Callback = function(v) Config.ESP.VisibleColor = v end
    })

    Tabs.ESP:AddColorpicker("ESPNotVisibleColor", {
        Title = "Colore Non Visibile",
        Default = Config.ESP.NotVisibleColor,
        Callback = function(v) Config.ESP.NotVisibleColor = v end
    })

    Tabs.ESP:AddColorpicker("ESPDefaultColor", {
        Title = "Colore Default",
        Default = Config.ESP.DefaultColor,
        Callback = function(v) Config.ESP.DefaultColor = v end
    })

    Tabs.ESP:AddColorpicker("ESPNameColor", {
        Title = "Colore Nome",
        Default = Config.ESP.NameColor,
        Callback = function(v) Config.ESP.NameColor = v end
    })

    Tabs.ESP:AddSection("Limiti")

    Tabs.ESP:AddSlider("ESPMaxDist", {
        Title = "Distanza Massima (studs)",
        Min = 100,
        Max = 2000,
        Default = Config.ESP.MaxDistance,
        Rounding = 0,
        Callback = function(v) Config.ESP.MaxDistance = v end
    })

    Tabs.ESP:AddToggle("ESPTeamCheck", {
        Title = "Ignora Squadra",
        Default = Config.ESP.TeamCheck,
        Callback = function(v) Config.ESP.TeamCheck = v end
    })

    -- ═══════════════════════════════════════
    -- TAB: INVENTARIO
    -- ═══════════════════════════════════════
    Tabs.Inventory:AddSection("Generale")

    Tabs.Inventory:AddToggle("InvEnabled", {
        Title = "Abilita Inventory ESP",
        Default = Config.InventoryESP.Enabled,
        Callback = function(v) Config.InventoryESP.Enabled = v end
    })

    Tabs.Inventory:AddToggle("InvShowEquipped", {
        Title = "Mostra Tool Equipaggiati (⚔)",
        Default = Config.InventoryESP.ShowEquipped,
        Callback = function(v) Config.InventoryESP.ShowEquipped = v end
    })

    Tabs.Inventory:AddToggle("InvShowBackpack", {
        Title = "Mostra Tool nello Zaino (📦)",
        Default = Config.InventoryESP.ShowBackpack,
        Callback = function(v) Config.InventoryESP.ShowBackpack = v end
    })

    Tabs.Inventory:AddSection("Visualizzazione")

    Tabs.Inventory:AddToggle("InvShowToolTip", {
        Title = "Mostra ToolTip / Descrizione",
        Default = Config.InventoryESP.ShowToolTip,
        Callback = function(v) Config.InventoryESP.ShowToolTip = v end
    })

    Tabs.Inventory:AddToggle("InvShowDamage", {
        Title = "Mostra Danno (se rilevato)",
        Default = Config.InventoryESP.ShowDamage,
        Callback = function(v) Config.InventoryESP.ShowDamage = v end
    })

    Tabs.Inventory:AddToggle("InvCleanNames", {
        Title = "Pulisci Nomi (rimuovi prefissi)",
        Default = Config.InventoryESP.CleanNames,
        Callback = function(v) Config.InventoryESP.CleanNames = v end
    })

    Tabs.Inventory:AddSlider("InvMaxItems", {
        Title = "Max Items Mostrati",
        Min = 3,
        Max = 15,
        Default = Config.InventoryESP.MaxItems,
        Rounding = 0,
        Callback = function(v) Config.InventoryESP.MaxItems = v end
    })

    Tabs.Inventory:AddSection("Colori & Font")

    Tabs.Inventory:AddColorpicker("InvTextColor", {
        Title = "Colore Testo",
        Default = Config.InventoryESP.TextColor,
        Callback = function(v) Config.InventoryESP.TextColor = v end
    })

    Tabs.Inventory:AddColorpicker("InvEquippedColor", {
        Title = "Colore Equipaggiato",
        Default = Config.InventoryESP.EquippedColor,
        Callback = function(v) Config.InventoryESP.EquippedColor = v end
    })

    Tabs.Inventory:AddSlider("InvTextSize", {
        Title = "Dimensione Testo",
        Min = 8,
        Max = 24,
        Default = Config.InventoryESP.TextSize,
        Rounding = 0,
        Callback = function(v) Config.InventoryESP.TextSize = v end
    })

    -- ═══════════════════════════════════════
    -- TAB: AIMBOT
    -- ═══════════════════════════════════════
    Tabs.Aimbot:AddSection("Generale")

    Tabs.Aimbot:AddToggle("AimEnabled", {
        Title = "Abilita Aimbot",
        Default = Config.Aimbot.Enabled,
        Callback = function(v) Config.Aimbot.Enabled = v end
    })

    Tabs.Aimbot:AddDropdown("AimActivationMode", {
        Title = "Modalita Attivazione",
        Values = {"Hold", "Toggle"},
        Default = Config.Aimbot.ActivationMode,
        Multi = false,
        Callback = function(v)
            Config.Aimbot.ActivationMode = v
            State.AimbotToggled = false
        end
    })

    Tabs.Aimbot:AddDropdown("AimKeybind", {
        Title = "🔑 Tasto Aimbot",
        Values = KeybindOptions,
        Default = Config.Aimbot.KeybindName,
        Multi = false,
        Callback = function(v)
            Config.Aimbot.KeybindName = v
            local bind = KeybindMap[v]
            if bind then
                Config.Aimbot.ActivationKey = bind.Value
                Config.Aimbot.ActivationKeyType = bind.Type
                Notify.Send("Aimbot Key: " .. v, C3(255, 200, 50), 2)
            end
        end
    })

    Tabs.Aimbot:AddToggle("AimAssistToggle", {
        Title = "Aim Assist (piu leggero)",
        Default = Config.Aimbot.AimAssist,
        Callback = function(v) Config.Aimbot.AimAssist = v end
    })

    Tabs.Aimbot:AddSlider("AimAssistStrength", {
        Title = "Forza Aim Assist",
        Min = 4,
        Max = 30,
        Default = Config.Aimbot.AssistStrength,
        Rounding = 0,
        Callback = function(v) Config.Aimbot.AssistStrength = v end
    })

    Tabs.Aimbot:AddToggle("AimSilentAim", {
        Title = "🔇 Silent Aim (sperimentale)",
        Default = Config.Aimbot.SilentAim,
        Callback = function(v) Config.Aimbot.SilentAim = v end
    })

    Tabs.Aimbot:AddSection("Targeting")

    Tabs.Aimbot:AddDropdown("AimTargetPart", {
        Title = "Parte del Corpo",
        Values = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
        Default = Config.Aimbot.TargetPart,
        Multi = false,
        Callback = function(v) Config.Aimbot.TargetPart = v end
    })

    Tabs.Aimbot:AddToggle("AimBonePriority", {
        Title = "🦴 Auto Bone Priority (visibile)",
        Default = Config.Aimbot.BonePriority,
        Callback = function(v) Config.Aimbot.BonePriority = v end
    })

    Tabs.Aimbot:AddDropdown("AimTargetMode", {
        Title = "Modalita Target",
        Values = {"Crosshair", "Distance"},
        Default = Config.Aimbot.TargetMode,
        Multi = false,
        Callback = function(v) Config.Aimbot.TargetMode = v end
    })

    Tabs.Aimbot:AddSlider("AimMaxDist", {
        Title = "Distanza Massima",
        Min = 100,
        Max = 1000,
        Default = Config.Aimbot.MaxDistance,
        Rounding = 0,
        Callback = function(v) Config.Aimbot.MaxDistance = v end
    })

    Tabs.Aimbot:AddToggle("AimWallCheck", {
        Title = "Wall Check (controllo ostacoli)",
        Default = Config.Aimbot.WallCheck,
        Callback = function(v) Config.Aimbot.WallCheck = v end
    })

    Tabs.Aimbot:AddToggle("AimVisibleCheck", {
        Title = "Check Visibilita",
        Default = Config.Aimbot.VisibleCheck,
        Callback = function(v) Config.Aimbot.VisibleCheck = v end
    })

    Tabs.Aimbot:AddToggle("AimTeamCheck", {
        Title = "Ignora Squadra",
        Default = Config.Aimbot.TeamCheck,
        Callback = function(v) Config.Aimbot.TeamCheck = v end
    })

    Tabs.Aimbot:AddToggle("AimIgnoreKnocked", {
        Title = "Ignora Knockati / Morti",
        Default = Config.Aimbot.IgnoreKnocked,
        Callback = function(v) Config.Aimbot.IgnoreKnocked = v end
    })

    Tabs.Aimbot:AddToggle("AimForcefieldCheck", {
        Title = "Bypass / Ignora Forcefield",
        Default = Config.Aimbot.ForcefieldCheck,
        Callback = function(v) Config.Aimbot.ForcefieldCheck = v end
    })

    Tabs.Aimbot:AddSection("FOV")

    Tabs.Aimbot:AddSlider("AimFOVRadius", {
        Title = "Raggio FOV",
        Min = 20,
        Max = 500,
        Default = Config.Aimbot.FOV,
        Rounding = 0,
        Callback = function(v) Config.Aimbot.FOV = v end
    })

    Tabs.Aimbot:AddToggle("AimShowFOV", {
        Title = "Mostra Cerchio FOV",
        Default = Config.Aimbot.ShowFOV,
        Callback = function(v) Config.Aimbot.ShowFOV = v end
    })

    Tabs.Aimbot:AddColorpicker("AimFOVColor", {
        Title = "Colore Cerchio FOV",
        Default = Config.Aimbot.FOVColor,
        Callback = function(v) Config.Aimbot.FOVColor = v end
    })

    Tabs.Aimbot:AddSlider("AimFOVSides", {
        Title = "Lati Cerchio FOV (qualita)",
        Min = 12,
        Max = 64,
        Default = Config.Aimbot.FOVSides,
        Rounding = 0,
        Callback = function(v) Config.Aimbot.FOVSides = v end
    })

    Tabs.Aimbot:AddSection("Smoothing & Umanizzazione")

    Tabs.Aimbot:AddSlider("AimSmoothing", {
        Title = "Smoothing",
        Min = 1,
        Max = 20,
        Default = Config.Aimbot.Smoothness,
        Rounding = 1,
        Callback = function(v) Config.Aimbot.Smoothness = v end
    })

    Tabs.Aimbot:AddToggle("AimDynamicSmoothing", {
        Title = "Dynamic Smoothing (distanza)",
        Default = Config.Aimbot.DynamicSmoothing,
        Callback = function(v) Config.Aimbot.DynamicSmoothing = v end
    })

    Tabs.Aimbot:AddSlider("AimMinSmoothing", {
        Title = "Smoothing Minimo",
        Min = 1,
        Max = 10,
        Default = Config.Aimbot.MinSmoothing,
        Rounding = 1,
        Callback = function(v) Config.Aimbot.MinSmoothing = v end
    })

    Tabs.Aimbot:AddSlider("AimMaxSmoothing", {
        Title = "Smoothing Massimo",
        Min = 5,
        Max = 30,
        Default = Config.Aimbot.MaxSmoothing,
        Rounding = 0,
        Callback = function(v) Config.Aimbot.MaxSmoothing = v end
    })

    Tabs.Aimbot:AddToggle("AimHumanize", {
        Title = "Humanize (movimento naturale)",
        Default = Config.Aimbot.Humanize,
        Callback = function(v) Config.Aimbot.Humanize = v end
    })

    Tabs.Aimbot:AddSlider("AimHumanizeFactor", {
        Title = "Intensita Humanize",
        Min = 0.5,
        Max = 5,
        Default = Config.Aimbot.HumanizeFactor,
        Rounding = 1,
        Callback = function(v) Config.Aimbot.HumanizeFactor = v end
    })

    Tabs.Aimbot:AddSection("Predizione Movimento")

    Tabs.Aimbot:AddToggle("AimPrediction", {
        Title = "Predizione Attiva",
        Default = Config.Aimbot.Prediction,
        Callback = function(v) Config.Aimbot.Prediction = v end
    })

    Tabs.Aimbot:AddSlider("AimPredictionAmount", {
        Title = "Intensita Predizione",
        Min = 0.05,
        Max = 0.5,
        Default = Config.Aimbot.PredictionAmount,
        Rounding = 2,
        Callback = function(v) Config.Aimbot.PredictionAmount = v end
    })

    Tabs.Aimbot:AddSection("Indicatori Visivi")

    Tabs.Aimbot:AddToggle("AimTargetDot", {
        Title = "Punto sul Bersaglio",
        Default = Config.Aimbot.TargetDot,
        Callback = function(v) Config.Aimbot.TargetDot = v end
    })

    Tabs.Aimbot:AddColorpicker("AimTargetDotColor", {
        Title = "Colore Punto Bersaglio",
        Default = Config.Aimbot.TargetDotColor,
        Callback = function(v) Config.Aimbot.TargetDotColor = v end
    })

    Tabs.Aimbot:AddToggle("AimSnapLine", {
        Title = "Snap Line (linea al bersaglio)",
        Default = Config.Aimbot.SnapLine,
        Callback = function(v) Config.Aimbot.SnapLine = v end
    })

    Tabs.Aimbot:AddColorpicker("AimSnapLineColor", {
        Title = "Colore Snap Line",
        Default = Config.Aimbot.SnapLineColor,
        Callback = function(v) Config.Aimbot.SnapLineColor = v end
    })

    -- ═══════════════════════════════════════
    -- TAB: TRIGGERBOT
    -- ═══════════════════════════════════════
    Tabs.Triggerbot:AddSection("Generale")

    Tabs.Triggerbot:AddToggle("TrigEnabled", {
        Title = "Abilita Triggerbot",
        Default = Config.Triggerbot.Enabled,
        Callback = function(v) Config.Triggerbot.Enabled = v end
    })

    Tabs.Triggerbot:AddDropdown("TrigActivationMode", {
        Title = "Modalita Attivazione",
        Values = {"Hold", "Toggle", "Always"},
        Default = Config.Triggerbot.ActivationMode,
        Multi = false,
        Callback = function(v) Config.Triggerbot.ActivationMode = v end
    })

    Tabs.Triggerbot:AddDropdown("TrigKeybind", {
        Title = "🔑 Tasto Triggerbot",
        Values = KeybindOptions,
        Default = Config.Triggerbot.KeybindName,
        Multi = false,
        Callback = function(v)
            Config.Triggerbot.KeybindName = v
            local bind = KeybindMap[v]
            if bind then
                Config.Triggerbot.ActivationKey = bind.Value
                Config.Triggerbot.ActivationKeyType = bind.Type
                Notify.Send("Triggerbot Key: " .. v, C3(255, 200, 50), 2)
            end
        end
    })

    Tabs.Triggerbot:AddSection("Fire Mode")

    Tabs.Triggerbot:AddToggle("TrigAutoShoot", {
        Title = "Auto Shoot (sparo continuo)",
        Default = Config.Triggerbot.AutoShoot,
        Callback = function(v) Config.Triggerbot.AutoShoot = v end
    })

    Tabs.Triggerbot:AddToggle("TrigSpray", {
        Title = "Spray Mode (full auto simulato)",
        Default = Config.Triggerbot.Spray,
        Callback = function(v) Config.Triggerbot.Spray = v end
    })

    Tabs.Triggerbot:AddSlider("TrigSprayRate", {
        Title = "Spray Rate (delay tra colpi)",
        Min = 0,
        Max = 0.1,
        Default = Config.Triggerbot.SprayRate,
        Rounding = 3,
        Callback = function(v) Config.Triggerbot.SprayRate = v end
    })

    Tabs.Triggerbot:AddSection("FOV Triggerbot")

    Tabs.Triggerbot:AddToggle("TrigUseFOV", {
        Title = "Usa FOV (spara se nemico nel cerchio)",
        Default = Config.Triggerbot.UseFOV,
        Callback = function(v) Config.Triggerbot.UseFOV = v end
    })

    Tabs.Triggerbot:AddSlider("TrigFOVRadius", {
        Title = "FOV Raggio",
        Min = 20,
        Max = 300,
        Default = Config.Triggerbot.FOV,
        Rounding = 0,
        Callback = function(v) Config.Triggerbot.FOV = v end
    })

    Tabs.Triggerbot:AddToggle("TrigShowFOV", {
        Title = "Mostra Cerchio FOV",
        Default = Config.Triggerbot.ShowFOV,
        Callback = function(v) Config.Triggerbot.ShowFOV = v end
    })

    Tabs.Triggerbot:AddColorpicker("TrigFOVColor", {
        Title = "Colore FOV Triggerbot",
        Default = Config.Triggerbot.FOVColor,
        Callback = function(v) Config.Triggerbot.FOVColor = v end
    })

    Tabs.Triggerbot:AddSection("Targeting")

    Tabs.Triggerbot:AddSlider("TrigMaxDist", {
        Title = "Distanza Massima",
        Min = 50,
        Max = 500,
        Default = Config.Triggerbot.MaxDistance,
        Rounding = 0,
        Callback = function(v) Config.Triggerbot.MaxDistance = v end
    })

    Tabs.Triggerbot:AddSlider("TrigHitChance", {
        Title = "Hit Chance (% probabilita)",
        Min = 1,
        Max = 100,
        Default = Config.Triggerbot.HitChance,
        Rounding = 0,
        Callback = function(v) Config.Triggerbot.HitChance = v end
    })

    Tabs.Triggerbot:AddToggle("TrigHeadshotOnly", {
        Title = "Solo Headshot",
        Default = Config.Triggerbot.HeadshotOnly,
        Callback = function(v) Config.Triggerbot.HeadshotOnly = v end
    })

    Tabs.Triggerbot:AddToggle("TrigTeamCheck", {
        Title = "Ignora Squadra",
        Default = Config.Triggerbot.TeamCheck,
        Callback = function(v) Config.Triggerbot.TeamCheck = v end
    })

    Tabs.Triggerbot:AddSection("Burst Mode")

    Tabs.Triggerbot:AddToggle("TrigBurstMode", {
        Title = "Burst Mode",
        Default = Config.Triggerbot.BurstMode,
        Callback = function(v) Config.Triggerbot.BurstMode = v end
    })

    Tabs.Triggerbot:AddSlider("TrigBurstCount", {
        Title = "Colpi per Burst",
        Min = 2,
        Max = 8,
        Default = Config.Triggerbot.BurstCount,
        Rounding = 0,
        Callback = function(v) Config.Triggerbot.BurstCount = v end
    })

    Tabs.Triggerbot:AddSlider("TrigBurstDelay", {
        Title = "Delay tra Colpi",
        Min = 0.01,
        Max = 0.15,
        Default = Config.Triggerbot.BurstDelay,
        Rounding = 2,
        Callback = function(v) Config.Triggerbot.BurstDelay = v end
    })

    -- ═══════════════════════════════════════
    -- TAB: PLAYER
    -- ═══════════════════════════════════════
    Tabs.Player:AddSection("Velocita")

    Tabs.Player:AddToggle("PlayerSpeedToggle", {
        Title = "🏃 Speed Hack",
        Default = Config.Player.SpeedEnabled,
        Callback = function(v) Config.Player.SpeedEnabled = v end
    })

    Tabs.Player:AddSlider("PlayerSpeedSlider", {
        Title = "WalkSpeed",
        Min = 16,
        Max = 200,
        Default = Config.Player.WalkSpeed,
        Rounding = 0,
        Callback = function(v) Config.Player.WalkSpeed = v end
    })

    Tabs.Player:AddSection("Salto")

    Tabs.Player:AddToggle("PlayerJumpToggle", {
        Title = "🦘 Jump Hack",
        Default = Config.Player.JumpEnabled,
        Callback = function(v) Config.Player.JumpEnabled = v end
    })

    Tabs.Player:AddSlider("PlayerJumpSlider", {
        Title = "JumpPower",
        Min = 50,
        Max = 300,
        Default = Config.Player.JumpPower,
        Rounding = 0,
        Callback = function(v) Config.Player.JumpPower = v end
    })

    Tabs.Player:AddToggle("PlayerInfJumpToggle", {
        Title = "∞ Infinite Jump",
        Default = Config.Player.InfiniteJump,
        Callback = function(v) Config.Player.InfiniteJump = v end
    })

    Tabs.Player:AddSection("Movimento Speciale")

    Tabs.Player:AddToggle("PlayerNoclipToggle", {
        Title = "👻 Noclip (attraversa muri)",
        Default = Config.Player.NoclipEnabled,
        Callback = function(v) Config.Player.NoclipEnabled = v end
    })

    Tabs.Player:AddToggle("PlayerFlyToggle", {
        Title = "🦅 Fly (WASD + Space/Shift)",
        Default = Config.Player.FlyEnabled,
        Callback = function(v)
            Config.Player.FlyEnabled = v
            PlayerMods.SetupFly()
            if v then
                Notify.Send("FLY ON - WASD per muoverti", C3(50, 200, 255), 3)
            else
                Notify.Send("FLY OFF", C3(200, 200, 200), 2)
            end
        end
    })

    Tabs.Player:AddSlider("PlayerFlySpeed", {
        Title = "Velocita Volo",
        Min = 10,
        Max = 200,
        Default = Config.Player.FlySpeed,
        Rounding = 0,
        Callback = function(v) Config.Player.FlySpeed = v end
    })

    -- ═══════════════════════════════════════
    -- TAB: SETTINGS
    -- ═══════════════════════════════════════
    Tabs.Settings:AddSection("Interfaccia & HUD")

    Tabs.Settings:AddToggle("MiscWatermark", {
        Title = "Mostra Watermark",
        Default = Config.Misc.ShowWatermark,
        Callback = function(v) Config.Misc.ShowWatermark = v end
    })

    Tabs.Settings:AddToggle("MiscKillFeed", {
        Title = "Mostra Kill Feed",
        Default = Config.Misc.ShowKillFeed,
        Callback = function(v) Config.Misc.ShowKillFeed = v end
    })

    Tabs.Settings:AddParagraph({
        Title = "Comandi Menu",
        Content = "Premi G per aprire o nascondere il menu.\nInterfaccia Fluent ultra-leggera, 60fps locked."
    })

    Tabs.Settings:AddSection("Audio & Effetti")

    Tabs.Settings:AddToggle("MiscHitSound", {
        Title = "🔊 Hit Sound",
        Default = Config.Misc.HitSound,
        Callback = function(v) Config.Misc.HitSound = v end
    })

    Tabs.Settings:AddSection("Utilita & Protezione")

    Tabs.Settings:AddToggle("MiscAntiAFK", {
        Title = "🛡️ Anti-AFK",
        Default = Config.Misc.AntiAFK,
        Callback = function(v)
            Config.Misc.AntiAFK = v
            PlayerMods.SetupAntiAFK()
        end
    })

    Tabs.Settings:AddToggle("MiscFullbright", {
        Title = "💡 Fullbright (rimuovi ombre)",
        Default = Config.Misc.Fullbright,
        Callback = function(v)
            Config.Misc.Fullbright = v
            PlayerMods.SetupFullbright()
        end
    })

    Tabs.Settings:AddSection("Statistiche Sessione")

    Tabs.Settings:AddButton({
        Title = "🔄 Reset Stats",
        Description = "Azzera contatore Kills e Hits",
        Callback = function()
            State.KillCount = 0
            State.HitCount = 0
            State.SessionStart = Tick()
            Notify.Send("Stats resettate!", C3(200, 200, 200), 2)
        end
    })

    Tabs.Settings:AddSection("Pericolo / Unload")

    Tabs.Settings:AddButton({
        Title = "❌ UNLOAD (Rimuovi Phantom)",
        Description = "Chiude il menu e rimuove tutti i componenti di gioco",
        Callback = function()
            State.Running = false
        end
    })

    -- Config & Interface Addons (Fluent)
    pcall(function()
        if InterfaceManager and SaveManager then
            InterfaceManager:SetLibrary(Fluent)
            SaveManager:SetLibrary(Fluent)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({})
            InterfaceManager:SetFolder("PhantomSuite")
            SaveManager:SetFolder("PhantomSuite/BlockSpin")
            InterfaceManager:BuildInterfaceSection(Tabs.Settings)
            SaveManager:BuildConfigSection(Tabs.Settings)
        end
    end)

    Window:SelectTab(1)
    Notify.Send("Fluent GUI Caricata! Premi G", C3(180, 80, 255), 3)
end)

if not guiOk then
    warn("[PHANTOM] Fluent GUI Error: " .. tostring(guiErr))
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

    -- G = Toggle GUI (Fluent handles MinimizeKey natively)
    if input.KeyCode == Config.Misc.GUIToggleKey then
        State.GUIVisible = not State.GUIVisible
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

    -- ESP (v3.6: native Roblox rendering with safe cleanup)
    for player, drawings in pairs(State.ESPCache) do
        pcall(function()
            if player and player.Parent then
                if not player.Character or not player.Character.Parent then
                    pcall(ESP.HideAll, drawings)
                elseif Config.ESP.Enabled or Config.InventoryESP.Enabled or Config.ESP.Chams then
                    pcall(ESP.Update, player, drawings)
                else
                    pcall(ESP.HideAll, drawings)
                end
            else
                pcall(ESP.Destroy, drawings)
                State.ESPCache[player] = nil
                State.ChamsCache[player] = nil
            end
        end)
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

    -- Destroy Fluent
    pcall(function() Fluent:Destroy() end)

    Notify.Send("PHANTOM Unloaded!", C3(255, 80, 80), 2)
end

-- ═══════════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════════
local function Init()
    task.spawn(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                ESP.Register(p)
                task.wait(0.02)
            end
        end
    end)

    State.Connections.Added = Players.PlayerAdded:Connect(function(p)
        task.spawn(function()
            task.wait(0.1)
            ESP.Register(p)
        end)
    end)
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

    Notify.Send("PHANTOM v3.7 Loaded!", C3(180, 80, 255), 4)
    Notify.Send("Premi G per il menu Fluent", C3(200, 200, 200), 5)
    Notify.Send("v3.7: Fluent UI — 60 FPS, Fluido, Zero Lag!", C3(50, 255, 100), 6)
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
