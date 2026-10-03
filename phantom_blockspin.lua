--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║     PRV SERVICE v8.5 · BlockSpin Master Cyber Edition             ║
    ║     Mouse Unlock · Tab Fix · Floating Pill · Built for Xeno   ║
    ╠═══════════════════════════════════════════════════════════════╣
    ║  Premi K per aprire/chiudere il menu                          ║
    ║  v6.0: SBLOCCO MOUSE AUTOMATICO — Cursore visibile e libero,   ║
    ║        Triggerbot, Player & Settings scrollabili al 100%,     ║
    ║        Sidebar scorrevole, Logo Pill flottante drag & touch   ║
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
        VisualBadges  = true,         -- v8: Badge grafici con loghi e contorni di rarità
        ShowRarityGlow = true,        -- v8: Contorno Leggendario dorato (RPG, Minigun)
        BadgeSize     = 20,           -- v8.1: Dimensione badge compatta (20px)
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

-- ═══════════════════════════════════════════════════
-- v8: WEAPON DATABASE & RARITY SYSTEM (Visual ESP Badges)
-- ═══════════════════════════════════════════════════
local WEAPON_DB = {
    { keys = {"rpg", "rocket", "launcher", "missile", "bazooka"}, rarity = "Legendary", color = C3(255, 190, 20), symbol = "RPG", icon = "rbxassetid://6034685361" },
    { keys = {"minigun", "railgun", "laser", "plasma", "gold"}, rarity = "Legendary", color = C3(255, 190, 20), symbol = "MINI", icon = "rbxassetid://6034685338" },
    { keys = {"sniper", "awp", "barrett", "marksman"}, rarity = "Epic", color = C3(168, 85, 247), symbol = "AWP", icon = "rbxassetid://6034685338" },
    { keys = {"deagle", "desert", "katana", "sword", "blade"}, rarity = "Epic", color = C3(168, 85, 247), symbol = "EPIC", icon = "rbxassetid://6034685375" },
    { keys = {"ak", "m4", "rifle", "ar", "shotgun", "spas", "pump"}, rarity = "Rare", color = C3(56, 189, 248), symbol = "RARE", icon = "rbxassetid://6034685382" },
    { keys = {"smg", "mp5", "uzi", "pistol", "glock", "revolver"}, rarity = "Uncommon", color = C3(34, 197, 94), symbol = "GUN", icon = "rbxassetid://6034685368" },
    { keys = {"medkit", "heal", "bandage", "potion"}, rarity = "Utilities", color = C3(52, 211, 153), symbol = "MED", icon = "rbxassetid://6034685364" },
    { keys = {"grenade", "c4", "bomb", "flash"}, rarity = "Uncommon", color = C3(251, 146, 60), symbol = "BOMB", icon = "rbxassetid://6034685355" }
}

function Util.GetWeaponDetails(tool, isEquipped)
    if not tool then return nil end
    local name = Util.ResolveToolName(tool) or tool.Name
    local lower = name:lower()

    local matched = nil
    for _, w in ipairs(WEAPON_DB) do
        for _, k in ipairs(w.keys) do
            if lower:find(k) then
                matched = w
                break
            end
        end
        if matched then break end
    end

    local rarity = matched and matched.rarity or "Common"
    local color = matched and matched.color or C3(160, 160, 175)
    local symbol = matched and matched.symbol or "TOOL"
    local icon = matched and matched.icon or ""

    pcall(function()
        if tool.TextureId and #tool.TextureId > 5 then
            icon = tool.TextureId
        end
    end)

    local dmg = Util.GetToolDamage(tool)

    return {
        name = name,
        rarity = rarity,
        color = color,
        symbol = symbol,
        icon = icon,
        isEquipped = isEquipped,
        damage = dmg
    }
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
        d.Text = "  [PRV SERVICE]  " .. text
        d.Size = 16; d.Font = FONT
        d.Color = color; d.OutlineColor = C3(0,0,0); d.Outline = true
        d.Position = V2(12, 10 + (#State.Notifications * 22))
        d.Visible = true
        return d
    end)
    if not ok then warn("[PRV SERVICE] " .. text) return end
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
        hl.DepthMode = Enum.HighlightDepthMode.Occluded
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
        bb.Size = UDim2.new(0, 200, 0, 75)
        bb.StudsOffset = V3(0, 3.2, 0)
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

        -- v8: Visual Inventory Badges Frame (Loghi & Contorni Rarita Leggendaria/Epica/Rara)
        local badgesFrame = Instance.new("Frame")
        badgesFrame.Name = "BadgesFrame"
        badgesFrame.BackgroundTransparency = 1
        badgesFrame.Size = UDim2.new(1, 0, 0, 24)
        badgesFrame.Position = UDim2.new(0, 0, 0, 22)
        badgesFrame.Visible = false
        badgesFrame.Parent = bb
        d.BadgesFrame = badgesFrame

        local bLayout = Instance.new("UIListLayout")
        bLayout.FillDirection = Enum.FillDirection.Horizontal
        bLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        bLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        bLayout.Padding = UDim.new(0, 3)
        bLayout.Parent = badgesFrame

        d.BadgeSlots = {}
        for i = 1, 5 do
            local slot = Instance.new("Frame")
            slot.Name = "Slot_" .. i
            slot.Size = UDim2.new(0, 20, 0, 20)
            slot.BackgroundColor3 = C3(16, 15, 25)
            slot.BorderSizePixel = 0
            slot.Visible = false
            slot.Parent = badgesFrame

            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(0, 4)
            sCorner.Parent = slot

            local sStroke = Instance.new("UIStroke")
            sStroke.Color = C3(160, 160, 175)
            sStroke.Thickness = 1
            sStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            sStroke.Parent = slot

            local img = Instance.new("ImageLabel")
            img.Name = "Icon"
            img.Size = UDim2.new(1, -2, 1, -2)
            img.Position = UDim2.new(0, 1, 0, 1)
            img.BackgroundTransparency = 1
            img.ScaleType = Enum.ScaleType.Fit
            img.Visible = false
            img.Parent = slot

            local lbl = Instance.new("TextLabel")
            lbl.Name = "CodeLabel"
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 7
            lbl.TextColor3 = C3(255, 255, 255)
            lbl.TextStrokeTransparency = 0.5
            lbl.Visible = false
            lbl.Parent = slot

            local eqTag = Instance.new("Frame")
            eqTag.Name = "EquippedTag"
            eqTag.Size = UDim2.new(0, 7, 0, 7)
            eqTag.Position = UDim2.new(0, -1, 0, -1)
            eqTag.BackgroundColor3 = C3(255, 190, 20)
            eqTag.BorderSizePixel = 0
            eqTag.Visible = false
            eqTag.Parent = slot
            local eqCorner = Instance.new("UICorner")
            eqCorner.CornerRadius = UDim.new(1, 0)
            eqCorner.Parent = eqTag

            local eqTxt = Instance.new("TextLabel")
            eqTxt.Size = UDim2.new(1, 0, 1, 0)
            eqTxt.BackgroundTransparency = 1
            eqTxt.Text = "E"
            eqTxt.TextColor3 = C3(0, 0, 0)
            eqTxt.Font = Enum.Font.GothamBold
            eqTxt.TextSize = 6
            eqTxt.Parent = eqTag

            local dmgLbl = Instance.new("TextLabel")
            dmgLbl.Name = "DmgLabel"
            dmgLbl.Size = UDim2.new(1, 0, 0, 8)
            dmgLbl.Position = UDim2.new(0, 0, 1, -7)
            dmgLbl.BackgroundTransparency = 1
            dmgLbl.Font = Enum.Font.GothamBold
            dmgLbl.TextSize = 7
            dmgLbl.TextColor3 = C3(255, 255, 255)
            dmgLbl.TextStrokeTransparency = 0
            dmgLbl.TextStrokeColor3 = C3(0, 0, 0)
            dmgLbl.Visible = false
            dmgLbl.Parent = slot

            d.BadgeSlots[i] = {
                Frame = slot,
                Stroke = sStroke,
                Corner = sCorner,
                Image = img,
                Text = lbl,
                EquippedTag = eqTag,
                DmgLabel = dmgLbl
            }
        end

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

    -- 1. NATIVE HIGHLIGHT (Outline / Chams - Depth Mode Occluded to prevent map flickering)
    if d.Highlight then
        if (Config.ESP.Chams or (Config.ESP.Enabled and Config.ESP.BoxStyle == "Highlight")) and dist < 350 then
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

            -- Inventory ESP (Visual Badges con Loghi Arme e Contorni Rarita Leggendaria/Epica)
            if Config.InventoryESP.Enabled then
                local now = Tick()
                if not d._lastInvCheck or (now - d._lastInvCheck > 0.25) then
                    d._lastInvCheck = now
                    local toolList = {}
                    local textItems = {}
                    local itemCount = 0
                    local hasEquipped = false

                    if Config.InventoryESP.ShowEquipped then
                        for _, c in ipairs(char:GetChildren()) do
                            if c:IsA("Tool") and itemCount < Config.InventoryESP.MaxItems then
                                hasEquipped = true
                                local details = Util.GetWeaponDetails(c, true)
                                if details then
                                    tInsert(toolList, details)
                                    itemCount = itemCount + 1
                                end
                                local info = Util.GetToolInfo(c, true)
                                if info and info.display then
                                    tInsert(textItems, info.display)
                                end
                            end
                        end
                    end
                    if Config.InventoryESP.ShowBackpack then
                        local bp = player:FindFirstChild("Backpack")
                        if bp then
                            for _, c in ipairs(bp:GetChildren()) do
                                if c:IsA("Tool") and itemCount < Config.InventoryESP.MaxItems then
                                    local details = Util.GetWeaponDetails(c, false)
                                    if details then
                                        tInsert(toolList, details)
                                        itemCount = itemCount + 1
                                    end
                                    local info = Util.GetToolInfo(c, false)
                                    if info and info.display then
                                        tInsert(textItems, info.display)
                                    end
                                end
                            end
                        end
                    end

                    d._cachedToolList = toolList
                    d._lastInvText = (#textItems > 0) and tConcat(textItems, " | ") or ""
                    d._lastHasEquipped = hasEquipped
                end

                local toolList = d._cachedToolList or {}

                if Config.InventoryESP.VisualBadges and d.BadgesFrame and d.BadgeSlots then
                    local yOffset = (Config.ESP.HealthBar and (Config.ESP.HealthText and 34 or 24)) or (Config.ESP.Names and 18 or 4)
                    d.BadgesFrame.Position = UDim2.new(0, 0, 0, yOffset)

                    if #toolList > 0 then
                        d.BadgesFrame.Visible = true
                        for i = 1, 5 do
                            local slotData = d.BadgeSlots[i]
                            local item = toolList[i]
                            if item and slotData then
                                slotData.Frame.Visible = true
                                slotData.Stroke.Color = item.color

                                local baseSize = Config.InventoryESP.BadgeSize or 20
                                if item.isEquipped then
                                    slotData.Frame.Size = UDim2.new(0, baseSize, 0, baseSize)
                                    slotData.Stroke.Thickness = (item.rarity == "Legendary") and 1.8 or 1.3
                                    slotData.EquippedTag.Visible = true
                                    slotData.Frame.BackgroundColor3 = C3(26, 22, 38)
                                else
                                    local subSize = math.floor(baseSize * 0.8)
                                    slotData.Frame.Size = UDim2.new(0, subSize, 0, subSize)
                                    slotData.Stroke.Thickness = (item.rarity == "Legendary") and 1.4 or 1
                                    slotData.EquippedTag.Visible = false
                                    slotData.Frame.BackgroundColor3 = C3(16, 15, 25)
                                end

                                if item.icon and #item.icon > 5 then
                                    slotData.Image.Image = item.icon
                                    slotData.Image.Visible = true
                                    slotData.Text.Visible = false
                                else
                                    slotData.Image.Visible = false
                                    slotData.Text.Text = item.symbol
                                    slotData.Text.TextColor3 = item.color
                                    slotData.Text.Visible = true
                                end

                                if Config.InventoryESP.ShowDamage and item.damage then
                                    slotData.DmgLabel.Text = tostring(item.damage)
                                    slotData.DmgLabel.Visible = true
                                else
                                    slotData.DmgLabel.Visible = false
                                end
                            elseif slotData then
                                slotData.Frame.Visible = false
                            end
                        end
                        if d.InventoryLabel then d.InventoryLabel.Visible = false end
                    else
                        d.BadgesFrame.Visible = false
                        if d.InventoryLabel then d.InventoryLabel.Visible = false end
                    end
                else
                    if d.BadgesFrame then d.BadgesFrame.Visible = false end
                    if d.InventoryLabel then
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
                    end
                end
            else
                if d.BadgesFrame then d.BadgesFrame.Visible = false end
                if d.InventoryLabel then d.InventoryLabel.Visible = false end
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
                bv.Name = "PRVFly_" .. math.random(10000,99999)
                bv.MaxForce = V3(math.huge, math.huge, math.huge)
                bv.Velocity = V3(0,0,0)
                bv.Parent = root
                State.FlyBody = bv

                local bg = Instance.new("BodyGyro")
                bg.Name = "PRVGyro_" .. math.random(10000,99999)
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
-- ═══════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════
-- PRV SERVICE CYBER-NEON V8.5 (Flawless Inset Borders · Pure Smooth Curves · Mouse Unlocker · Safe Tabs · Draggable Pill)
-- ═══════════════════════════════════════════════════
local PRVServiceUI = {}
local NativeGUI = nil
local cursorConnection = nil

-- Persistent Mouse Unlocker (keeps cursor visible & free against camera locks)
local function SetCursorState(active)
    if active then
        pcall(function()
            UserInputService.MouseIconEnabled = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
        if not cursorConnection then
            cursorConnection = RunService.RenderStepped:Connect(function()
                if State.GUIVisible then
                    pcall(function()
                        UserInputService.MouseIconEnabled = true
                        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                    end)
                else
                    if cursorConnection then
                        cursorConnection:Disconnect()
                        cursorConnection = nil
                    end
                end
            end)
        end
    else
        if cursorConnection then
            cursorConnection:Disconnect()
            cursorConnection = nil
        end
        -- Keep mouse cursor visible and free
        pcall(function()
            UserInputService.MouseIconEnabled = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
    end
end

local function BuildNativeGUI()
    local coreGui = game:GetService("CoreGui")
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local parentTarget = coreGui
    pcall(function()
        if not pcall(function() return coreGui.Name end) then
            parentTarget = playerGui
        end
    end)

    pcall(function()
        local old = parentTarget:FindFirstChild("PRV_SERVICE_GUI")
        if old then old:Destroy() end
        if playerGui then
            local old2 = playerGui:FindFirstChild("PRV_SERVICE_GUI")
            if old2 then old2:Destroy() end
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PRV_SERVICE_GUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999999
    pcall(function() ScreenGui.IgnoreGuiInset = true end)
    pcall(function() ScreenGui.Parent = parentTarget end)
    if not ScreenGui.Parent and playerGui then ScreenGui.Parent = playerGui end

    NativeGUI = ScreenGui

    -- Palette Cyber-Neon
    local C_MAIN_BG    = Color3.fromRGB(13, 13, 20)
    local C_SIDE_BG    = Color3.fromRGB(18, 17, 28)
    local C_CARD       = Color3.fromRGB(22, 22, 34)
    local C_BORDER     = Color3.fromRGB(65, 52, 95)
    local C_GLOW       = Color3.fromRGB(192, 132, 252)
    local C_NEON       = Color3.fromRGB(168, 85, 247)
    local C_TEXT       = Color3.fromRGB(245, 245, 255)
    local C_MUTED      = Color3.fromRGB(145, 145, 172)
    local C_TOGGLE_ON  = Color3.fromRGB(168, 85, 247)
    local C_TOGGLE_OFF = Color3.fromRGB(36, 36, 50)

    -- Window Outer Glow Container (Curved Floating Window 730x520)
    local Window = Instance.new("Frame")
    Window.Name = "MainWindow"
    Window.Size = UDim2.new(0, 730, 0, 520)
    Window.Position = UDim2.new(0.5, -365, 0.5, -260)
    Window.BackgroundColor3 = C_MAIN_BG
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = false -- Permette ai contorni curvi di non essere tagliati bruscamente!
    Window.Parent = ScreenGui

    -- Curvatura 18px per contorni impeccabili
    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 18)
    WindowCorner.Parent = Window

    -- Bordo esterno luminoso con gradiente neon
    local WindowStroke = Instance.new("UIStroke")
    WindowStroke.Color = Color3.fromRGB(168, 85, 247)
    WindowStroke.Thickness = 1.4
    WindowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    WindowStroke.Parent = Window

    local StrokeGrad = Instance.new("UIGradient")
    StrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 132, 252)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(140, 70, 220)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(60, 40, 90)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 70, 220))
    })
    StrokeGrad.Rotation = 45
    StrokeGrad.Parent = WindowStroke

    -- Gradiente di sfondo della finestra
    local WinGrad = Instance.new("UIGradient")
    WinGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 18, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 11, 16))
    })
    WinGrad.Rotation = 45
    WinGrad.Parent = Window

    -- ═══════════════════════════════════════════════════
    -- FLOATING DRAGGABLE LOGO PILL (Tasto/Icona per riaprire!)
    -- ═══════════════════════════════════════════════════
    local FloatPill = Instance.new("Frame")
    FloatPill.Name = "FloatPill"
    FloatPill.Size = UDim2.new(0, 165, 0, 44)
    FloatPill.Position = UDim2.new(0, 30, 0, 30)
    FloatPill.BackgroundColor3 = Color3.fromRGB(20, 18, 32)
    FloatPill.BorderSizePixel = 0
    FloatPill.Visible = false
    FloatPill.Active = true
    FloatPill.Parent = ScreenGui

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0)
    FloatCorner.Parent = FloatPill

    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Color = C_NEON
    FloatStroke.Thickness = 1.5
    FloatStroke.Parent = FloatPill

    local PillIcon = Instance.new("TextLabel")
    PillIcon.Size = UDim2.new(0, 38, 0, 30)
    PillIcon.Position = UDim2.new(0, 7, 0.5, -15)
    PillIcon.BackgroundColor3 = C_NEON
    PillIcon.Text = "PRV"
    PillIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    PillIcon.Font = Enum.Font.GothamBold
    PillIcon.TextSize = 11
    PillIcon.Parent = FloatPill
    local PillIconCorner = Instance.new("UICorner")
    PillIconCorner.CornerRadius = UDim.new(1, 0)
    PillIconCorner.Parent = PillIcon

    local PillLabel = Instance.new("TextButton")
    PillLabel.Size = UDim2.new(1, -44, 1, 0)
    PillLabel.Position = UDim2.new(0, 46, 0, 0)
    PillLabel.BackgroundTransparency = 1
    PillLabel.Text = "PRV SERVICE"
    PillLabel.TextColor3 = C_TEXT
    PillLabel.Font = Enum.Font.GothamBold
    PillLabel.TextSize = 13
    PillLabel.TextXAlignment = Enum.TextXAlignment.Left
    PillLabel.Parent = FloatPill

    -- Dragging Pill
    local pDragging, pDragInput, pDragStart, pStartPos
    FloatPill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pDragging = true
            pDragStart = input.Position
            pStartPos = FloatPill.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    pDragging = false
                end
            end)
        end
    end)
    FloatPill.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            pDragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == pDragInput and pDragging then
            local delta = input.Position - pDragStart
            FloatPill.Position = UDim2.new(
                pStartPos.X.Scale, pStartPos.X.Offset + delta.X,
                pStartPos.Y.Scale, pStartPos.Y.Offset + delta.Y
            )
        end
    end)

    local function ReopenFromPill()
        FloatPill.Visible = false
        State.GUIVisible = true
        Window.Visible = true
        SetCursorState(true)
        Window.Position = UDim2.new(0.5, -365, 0.5, -240)
        TweenService:Create(Window, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -365, 0.5, -260)
        }):Play()
    end
    PillLabel.MouseButton1Click:Connect(ReopenFromPill)
    FloatPill.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not pDragStart or (input.Position - pDragStart).Magnitude < 6 then
                ReopenFromPill()
            end
        end
    end)

    -- ═══════════════════════════════════════════════════
    -- TOPBAR (Transparent background, inset, no edge bleeding)
    -- ═══════════════════════════════════════════════════
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 52)
    Topbar.Position = UDim2.new(0, 0, 0, 0)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = Window

    -- Dragging Handler per Topbar
    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Brand Icon Badge (Clean "P" with neon violet gradient)
    local LogoBadge = Instance.new("Frame")
    LogoBadge.Size = UDim2.new(0, 32, 0, 32)
    LogoBadge.Position = UDim2.new(0, 16, 0, 10)
    LogoBadge.BackgroundColor3 = C_NEON
    LogoBadge.BorderSizePixel = 0
    LogoBadge.Parent = Topbar

    local LCorner = Instance.new("UICorner")
    LCorner.CornerRadius = UDim.new(0, 8)
    LCorner.Parent = LogoBadge

    local LogoGrad = Instance.new("UIGradient")
    LogoGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 132, 252)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 70, 220))
    })
    LogoGrad.Rotation = 45
    LogoGrad.Parent = LogoBadge

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "PRV"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 11
    LogoText.Parent = LogoBadge

    local BrandTitle = Instance.new("TextLabel")
    BrandTitle.Position = UDim2.new(0, 58, 0, 9)
    BrandTitle.Size = UDim2.new(0, 220, 0, 20)
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.Text = "PRV <font color=\"#c084fc\">SERVICE</font>"
    BrandTitle.RichText = true
    BrandTitle.TextColor3 = C_TEXT
    BrandTitle.Font = Enum.Font.GothamBold
    BrandTitle.TextSize = 16
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.Parent = Topbar

    local BrandSub = Instance.new("TextLabel")
    BrandSub.Position = UDim2.new(0, 58, 0, 28)
    BrandSub.Size = UDim2.new(0, 260, 0, 14)
    BrandSub.BackgroundTransparency = 1
    BrandSub.Text = "BlockSpin Stealth · Key [K] · 60 FPS"
    BrandSub.TextColor3 = C_MUTED
    BrandSub.Font = Enum.Font.GothamMedium
    BrandSub.TextSize = 11
    BrandSub.TextXAlignment = Enum.TextXAlignment.Left
    BrandSub.Parent = Topbar

    -- Window Controls (Minus & Close buttons with smooth styling)
    local BtnBox = Instance.new("Frame")
    BtnBox.Size = UDim2.new(0, 68, 0, 30)
    BtnBox.Position = UDim2.new(1, -84, 0, 11)
    BtnBox.BackgroundTransparency = 1
    BtnBox.Parent = Topbar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(0, 0, 0, 1)
    MinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = C_MUTED
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 15
    MinBtn.Parent = BtnBox
    local MCorner = Instance.new("UICorner")
    MCorner.CornerRadius = UDim.new(0, 8)
    MCorner.Parent = MinBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(0, 36, 0, 1)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 30)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(244, 63, 94)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.Parent = BtnBox
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 8)
    CCorner.Parent = CloseBtn

    -- Clic su "-" (minimizza) -> Nasconde finestra, mostra Logo Flottante
    MinBtn.MouseButton1Click:Connect(function()
        State.GUIVisible = false
        Window.Visible = false
        FloatPill.Visible = true
        SetCursorState(false)
        Notify.Send("Tap logo or press K to reopen", C3(168, 85, 247), 3)
    end)

    -- Clic su "X" (chiudi) -> Chiude tutto
    CloseBtn.MouseButton1Click:Connect(function()
        State.GUIVisible = false
        Window.Visible = false
        FloatPill.Visible = false
        SetCursorState(false)
    end)

    -- Divider Line (Inset 16px to prevent clipping outer corners)
    local TopDivider = Instance.new("Frame")
    TopDivider.Size = UDim2.new(1, -32, 0, 1)
    TopDivider.Position = UDim2.new(0, 16, 0, 52)
    TopDivider.BackgroundColor3 = Color3.fromRGB(45, 40, 65)
    TopDivider.BorderSizePixel = 0
    TopDivider.Parent = Window

    -- ═══════════════════════════════════════════════════
    -- SIDEBAR (Inset 14px, scrollable, pure curved edges)
    -- ═══════════════════════════════════════════════════
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, -72)
    Sidebar.Position = UDim2.new(0, 14, 0, 60)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 300)
    Sidebar.Parent = Window

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding = UDim.new(0, 6)
    SideLayout.Parent = Sidebar

    -- Vertical Divider between Sidebar and Content
    local VertDivider = Instance.new("Frame")
    VertDivider.Size = UDim2.new(0, 1, 1, -74)
    VertDivider.Position = UDim2.new(0, 202, 0, 60)
    VertDivider.BackgroundColor3 = Color3.fromRGB(35, 32, 50)
    VertDivider.BorderSizePixel = 0
    VertDivider.Parent = Window

    -- ═══════════════════════════════════════════════════
    -- CONTENT AREA (Inset 14px from right & bottom - zero border clipping!)
    -- ═══════════════════════════════════════════════════
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -222, 1, -68)
    ContentHolder.Position = UDim2.new(0, 210, 0, 56)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.ClipsDescendants = true
    ContentHolder.Parent = Window

    local Tabs = {}
    local TabButtons = {}
    local activeTab = nil

    local function SwitchTab(tabName)
        for name, container in pairs(Tabs) do
            local isTarget = (name == tabName)
            container.Visible = isTarget
            local btn = TabButtons[name]
            if btn then
                local pill = btn:FindFirstChild("IndicatorPill")
                if isTarget then
                    TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(34, 30, 52),
                        TextColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                    if pill then
                        TweenService:Create(pill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(0, 4, 0.65, 0),
                            BackgroundTransparency = 0
                        }):Play()
                    end
                else
                    TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(22, 22, 32),
                        TextColor3 = C_MUTED
                    }):Play()
                    if pill then
                        TweenService:Create(pill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(0, 4, 0, 0),
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end
            end
        end
        activeTab = tabName
    end

    local function CreateTab(name, icon)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        btn.BorderSizePixel = 0
        btn.Text = "    " .. icon .. "   " .. name
        btn.TextColor3 = C_MUTED
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = Sidebar

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 10)
        bCorner.Parent = btn

        local pill = Instance.new("Frame")
        pill.Name = "IndicatorPill"
        pill.Size = UDim2.new(0, 4, 0, 0)
        pill.Position = UDim2.new(0, 4, 0.18, 0)
        pill.BackgroundColor3 = C_NEON
        pill.BorderSizePixel = 0
        pill.BackgroundTransparency = 1
        pill.Parent = btn
        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(1, 0)
        pCorner.Parent = pill

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Name = name .. "_Page"
        Scroll.Size = UDim2.new(1, 0, 1, 0)
        Scroll.BackgroundTransparency = 1
        Scroll.ScrollBarThickness = 4
        Scroll.ScrollBarImageColor3 = C_BORDER
        Scroll.BorderSizePixel = 0
        Scroll.Visible = false
        Scroll.CanvasSize = UDim2.new(0, 0, 0, 1600)
        Scroll.Parent = ContentHolder

        local pLayout = Instance.new("UIListLayout")
        pLayout.Padding = UDim.new(0, 10)
        pLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pLayout.Parent = Scroll

        pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Scroll.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 40)
        end)

        local pPad = Instance.new("UIPadding")
        pPad.PaddingTop = UDim.new(0, 10)
        pPad.PaddingBottom = UDim.new(0, 20)
        pPad.PaddingLeft = UDim.new(0, 10)
        pPad.PaddingRight = UDim.new(0, 14)
        pPad.Parent = Scroll

        Tabs[name] = Scroll
        TabButtons[name] = btn

        btn.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)

        local tabMethods = {}

        function tabMethods:AddSection(secName)
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, 0, 0, 26)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = Scroll

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(0, 3, 0, 14)
            Bar.Position = UDim2.new(0, 0, 0.5, -7)
            Bar.BackgroundColor3 = C_NEON
            Bar.BorderSizePixel = 0
            Bar.Parent = SecFrame
            local bCorner2 = Instance.new("UICorner")
            bCorner2.CornerRadius = UDim.new(1, 0)
            bCorner2.Parent = Bar

            local SecLabel = Instance.new("TextLabel")
            SecLabel.Size = UDim2.new(1, -12, 1, 0)
            SecLabel.Position = UDim2.new(0, 10, 0, 0)
            SecLabel.BackgroundTransparency = 1
            SecLabel.Text = string.upper(secName)
            SecLabel.TextColor3 = C_GLOW
            SecLabel.Font = Enum.Font.GothamBold
            SecLabel.TextSize = 11
            SecLabel.TextXAlignment = Enum.TextXAlignment.Left
            SecLabel.Parent = SecFrame
        end

        function tabMethods:AddToggle(title, defaultVal, callback)
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 44)
            Card.BackgroundColor3 = C_CARD
            Card.BorderSizePixel = 0
            Card.Parent = Scroll

            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 12)
            cCorner.Parent = Card

            local cStroke = Instance.new("UIStroke")
            cStroke.Color = C_BORDER
            cStroke.Thickness = 1
            cStroke.Parent = Card

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -64, 1, 0)
            Label.Position = UDim2.new(0, 16, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = title
            Label.TextColor3 = C_TEXT
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 44, 0, 24)
            Switch.Position = UDim2.new(1, -54, 0.5, -12)
            Switch.BackgroundColor3 = defaultVal and C_TOGGLE_ON or C_TOGGLE_OFF
            Switch.Text = ""
            Switch.AutoButtonColor = false
            Switch.Parent = Card

            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(1, 0)
            sCorner.Parent = Switch

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 18, 0, 18)
            Knob.Position = defaultVal and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel = 0
            Knob.Parent = Switch
            local kCorner = Instance.new("UICorner")
            kCorner.CornerRadius = UDim.new(1, 0)
            kCorner.Parent = Knob

            local state = defaultVal
            local function toggle()
                state = not state
                local targetX = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                local targetCol = state and C_TOGGLE_ON or C_TOGGLE_OFF

                TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = targetX
                }):Play()

                TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = targetCol
                }):Play()

                pcall(callback, state)
            end

            Switch.MouseButton1Click:Connect(toggle)
            local CardBtn = Instance.new("TextButton")
            CardBtn.Size = UDim2.new(1, -64, 1, 0)
            CardBtn.BackgroundTransparency = 1
            CardBtn.Text = ""
            CardBtn.Parent = Card
            CardBtn.MouseButton1Click:Connect(toggle)
        end

        function tabMethods:AddSlider(title, minVal, maxVal, defaultVal, suffix, step, callback)
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 56)
            Card.BackgroundColor3 = C_CARD
            Card.BorderSizePixel = 0
            Card.Parent = Scroll

            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 12)
            cCorner.Parent = Card

            local cStroke = Instance.new("UIStroke")
            cStroke.Color = C_BORDER
            cStroke.Thickness = 1
            cStroke.Parent = Card

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 0, 22)
            Label.Position = UDim2.new(0, 16, 0, 8)
            Label.BackgroundTransparency = 1
            Label.Text = title
            Label.TextColor3 = C_TEXT
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0.3, -32, 0, 22)
            ValLabel.Position = UDim2.new(0.7, 0, 0, 8)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(defaultVal) .. (suffix or "")
            ValLabel.TextColor3 = C_NEON
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 13
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = Card

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -32, 0, 6)
            Track.Position = UDim2.new(0, 16, 0, 36)
            Track.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            Track.BorderSizePixel = 0
            Track.Parent = Card
            local tCorner = Instance.new("UICorner")
            tCorner.CornerRadius = UDim.new(1, 0)
            tCorner.Parent = Track

            local curRatio = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(curRatio, 0, 1, 0)
            Fill.BackgroundColor3 = C_NEON
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(1, 0)
            fCorner.Parent = Fill

            local sliding = false
            local function updateSlider(inputX)
                local trackAbsPos = Track.AbsolutePosition.X
                local trackAbsSize = Track.AbsoluteSize.X
                local rel = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
                local rawVal = minVal + rel * (maxVal - minVal)
                local val = step and (math.floor(rawVal / step + 0.5) * step) or rawVal
                val = math.clamp(val, minVal, maxVal)

                Fill.Size = UDim2.new(rel, 0, 1, 0)
                ValLabel.Text = (step and step < 1 and string.format("%.2f", val) or tostring(math.floor(val))) .. (suffix or "")
                pcall(callback, val)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateSlider(input.Position.X)
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            sliding = false
                        end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)
        end

        function tabMethods:AddDropdown(title, rawOptions, defaultVal, callback)
            local options = rawOptions or {}
            if type(options) ~= "table" then options = {} end

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 46)
            Card.BackgroundColor3 = C_CARD
            Card.BorderSizePixel = 0
            Card.ClipsDescendants = true
            Card.Parent = Scroll

            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 12)
            cCorner.Parent = Card

            local cStroke = Instance.new("UIStroke")
            cStroke.Color = C_BORDER
            cStroke.Thickness = 1
            cStroke.Parent = Card

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 0, 46)
            Label.Position = UDim2.new(0, 16, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = title
            Label.TextColor3 = C_TEXT
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(0.46, -16, 0, 30)
            DropBtn.Position = UDim2.new(0.54, 0, 0, 8)
            DropBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
            DropBtn.Text = tostring(defaultVal) .. "  v"
            DropBtn.TextColor3 = C_TEXT
            DropBtn.Font = Enum.Font.GothamMedium
            DropBtn.TextSize = 12
            DropBtn.Parent = Card

            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(0, 8)
            dCorner.Parent = DropBtn

            local dList = Instance.new("Frame")
            dList.Size = UDim2.new(1, -32, 0, #options * 28 + 6)
            dList.Position = UDim2.new(0, 16, 0, 50)
            dList.BackgroundTransparency = 1
            dList.Parent = Card

            local dlLayout = Instance.new("UIListLayout")
            dlLayout.Padding = UDim.new(0, 3)
            dlLayout.Parent = dList

            local isOpen = false
            for _, opt in ipairs(options) do
                local oBtn = Instance.new("TextButton")
                oBtn.Size = UDim2.new(1, 0, 0, 26)
                oBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
                oBtn.Text = "   " .. tostring(opt)
                oBtn.TextColor3 = (opt == defaultVal) and C_NEON or C_MUTED
                oBtn.Font = Enum.Font.Gotham
                oBtn.TextSize = 12
                oBtn.TextXAlignment = Enum.TextXAlignment.Left
                oBtn.Parent = dList
                local oCorner = Instance.new("UICorner")
                oCorner.CornerRadius = UDim.new(0, 6)
                oCorner.Parent = oBtn

                oBtn.MouseButton1Click:Connect(function()
                    DropBtn.Text = tostring(opt) .. "  v"
                    isOpen = false
                    TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, 46)
                    }):Play()
                    pcall(callback, opt)
                end)
            end

            DropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local targetH = isOpen and (50 + #options * 29 + 8) or 46
                TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, targetH)
                }):Play()
            end)
        end

        function tabMethods:AddButton(title, desc, callback)
            local Card = Instance.new("TextButton")
            Card.Size = UDim2.new(1, 0, 0, 44)
            Card.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
            Card.BorderSizePixel = 0
            Card.AutoButtonColor = false
            Card.Text = ""
            Card.Parent = Scroll

            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 12)
            cCorner.Parent = Card

            local cStroke = Instance.new("UIStroke")
            cStroke.Color = C_BORDER
            cStroke.Thickness = 1
            cStroke.Parent = Card

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -32, 1, 0)
            Label.Position = UDim2.new(0, 16, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = title
            Label.TextColor3 = C_TEXT
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            Card.MouseButton1Click:Connect(function()
                TweenService:Create(Card, TweenInfo.new(0.1), { BackgroundColor3 = C_NEON }):Play()
                task.delay(0.15, function()
                    TweenService:Create(Card, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(28, 28, 42) }):Play()
                end)
                pcall(callback)
            end)
        end

        function tabMethods:AddColorPicker(title, defaultColor, callback)
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 44)
            Card.BackgroundColor3 = C_CARD
            Card.BorderSizePixel = 0
            Card.Parent = Scroll

            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 12)
            cCorner.Parent = Card

            local cStroke = Instance.new("UIStroke")
            cStroke.Color = C_BORDER
            cStroke.Thickness = 1
            cStroke.Parent = Card

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -74, 1, 0)
            Label.Position = UDim2.new(0, 16, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = title
            Label.TextColor3 = C_TEXT
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local Preview = Instance.new("TextButton")
            Preview.Size = UDim2.new(0, 42, 0, 24)
            Preview.Position = UDim2.new(1, -54, 0.5, -12)
            Preview.BackgroundColor3 = defaultColor
            Preview.Text = ""
            Preview.AutoButtonColor = false
            Preview.Parent = Card

            local pCorner = Instance.new("UICorner")
            pCorner.CornerRadius = UDim.new(0, 8)
            pCorner.Parent = Preview

            local palette = {
                Color3.fromRGB(244, 63, 94),
                Color3.fromRGB(34, 197, 94),
                Color3.fromRGB(56, 189, 248),
                Color3.fromRGB(168, 85, 247),
                Color3.fromRGB(250, 204, 21),
                Color3.fromRGB(249, 115, 22),
                Color3.fromRGB(255, 255, 255)
            }
            local curIdx = 1
            Preview.MouseButton1Click:Connect(function()
                curIdx = (curIdx % #palette) + 1
                local picked = palette[curIdx]
                Preview.BackgroundColor3 = picked
                pcall(callback, picked)
            end)
        end

        return tabMethods
    end

    -- Create Native Tabs
    local tESP      = CreateTab("ESP", "ESP")
    local tInv      = CreateTab("Inventory", "INV")
    local tAim      = CreateTab("Aimbot", "AIM")
    local tTrig     = CreateTab("Triggerbot", "TRG")
    local tPlayer   = CreateTab("Player", "PLY")
    local tSettings = CreateTab("Settings", "CFG")

    local safeKeybinds = (KeybindOptions and #KeybindOptions > 0) and KeybindOptions or {
        "Mouse2 (RMB)", "LeftAlt", "RightAlt", "LeftShift", "RightShift",
        "LeftControl", "RightControl", "CapsLock", "Tab", "Q", "E", "R", "F", "Z", "X", "C", "V", "B"
    }

    -- ──────────────────────────────────────────
    -- 1. POPULATE ESP
    -- ──────────────────────────────────────────
    pcall(function()
        tESP:AddSection("General")
        tESP:AddToggle("Enable ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
        tESP:AddDropdown("Box Style", {"Full", "Corner"}, Config.ESP.BoxStyle, function(v) Config.ESP.BoxStyle = v end)
        tESP:AddSlider("Box Thickness", 1, 5, Config.ESP.BoxThickness, "px", 0.5, function(v) Config.ESP.BoxThickness = v end)
        tESP:AddToggle("Box Outline", Config.ESP.BoxOutline, function(v) Config.ESP.BoxOutline = v end)

        tESP:AddSection("Player Details")
        tESP:AddToggle("Show Names", Config.ESP.Names, function(v) Config.ESP.Names = v end)
        tESP:AddSlider("Name Size", 10, 22, Config.ESP.NameSize, "pt", 1, function(v) Config.ESP.NameSize = v end)
        tESP:AddToggle("Show Distance", Config.ESP.Distance, function(v) Config.ESP.Distance = v end)
        tESP:AddToggle("Health Bar", Config.ESP.HealthBar, function(v) Config.ESP.HealthBar = v end)
        tESP:AddDropdown("Health Bar Position", {"Left", "Right"}, Config.ESP.HealthBarPos, function(v) Config.ESP.HealthBarPos = v end)
        tESP:AddToggle("Show Numeric HP", Config.ESP.HealthText, function(v) Config.ESP.HealthText = v end)

        tESP:AddSection("Tracers & Look Vector")
        tESP:AddToggle("Enable Tracers", Config.ESP.Tracers, function(v) Config.ESP.Tracers = v end)
        tESP:AddDropdown("Tracer Origin", {"Bottom", "Center", "Mouse"}, Config.ESP.TracerOrigin, function(v) Config.ESP.TracerOrigin = v end)
        tESP:AddSlider("Tracer Thickness", 1, 4, Config.ESP.TracerThickness, "px", 0.5, function(v) Config.ESP.TracerThickness = v end)
        tESP:AddToggle("Show Look Vector", Config.ESP.LookVector, function(v) Config.ESP.LookVector = v end)

        tESP:AddSection("Skeleton & Chams")
        tESP:AddToggle("Enable Skeleton", Config.ESP.Skeleton, function(v) Config.ESP.Skeleton = v end)
        tESP:AddColorPicker("Skeleton Color", Config.ESP.SkeletonColor, function(v) Config.ESP.SkeletonColor = v end)
        tESP:AddToggle("Enable Chams Highlight", Config.ESP.Chams, function(v)
            Config.ESP.Chams = v
            if not v then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local h = p.Character:FindFirstChild("PRV_Highlight")
                        if h then h:Destroy() end
                    end
                end
            end
        end)
        tESP:AddColorPicker("Chams Visible Color", Config.ESP.ChamsVisibleColor, function(v) Config.ESP.ChamsVisibleColor = v end)
        tESP:AddColorPicker("Chams Hidden Color", Config.ESP.ChamsHiddenColor, function(v) Config.ESP.ChamsHiddenColor = v end)

        tESP:AddSection("Filters & Range")
        tESP:AddToggle("Wall Check (Visibility)", Config.ESP.VisibilityCheck, function(v) Config.ESP.VisibilityCheck = v end)
        tESP:AddToggle("Team Check (Ignore Team)", Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)
        tESP:AddSlider("Max Distance", 100, 2000, Config.ESP.MaxDistance, " studs", 50, function(v) Config.ESP.MaxDistance = v end)
    end)

    -- ──────────────────────────────────────────
    -- 2. POPULATE INVENTARIO
    -- ──────────────────────────────────────────
    pcall(function()
        tInv:AddSection("Visual Badges & Rarity")
        tInv:AddToggle("Enable Inventory ESP", Config.InventoryESP.Enabled, function(v) Config.InventoryESP.Enabled = v end)
        tInv:AddToggle("Visual Badges (Icons & Rarity)", Config.InventoryESP.VisualBadges, function(v) Config.InventoryESP.VisualBadges = v end)
        tInv:AddToggle("Golden Legendary Border (RPG)", Config.InventoryESP.ShowRarityGlow, function(v) Config.InventoryESP.ShowRarityGlow = v end)
        tInv:AddSlider("Badge Size (Compact)", 14, 32, Config.InventoryESP.BadgeSize, "px", 1, function(v) Config.InventoryESP.BadgeSize = v end)

        tInv:AddSection("Item Filters")
        tInv:AddToggle("Show Equipped Weapon", Config.InventoryESP.ShowEquipped, function(v) Config.InventoryESP.ShowEquipped = v end)
        tInv:AddToggle("Show Backpack Items", Config.InventoryESP.ShowBackpack, function(v) Config.InventoryESP.ShowBackpack = v end)
        tInv:AddToggle("Show Detected Damage", Config.InventoryESP.ShowDamage, function(v) Config.InventoryESP.ShowDamage = v end)
        tInv:AddToggle("Clean Item Names", Config.InventoryESP.CleanNames, function(v) Config.InventoryESP.CleanNames = v end)
        tInv:AddSlider("Max Displayed Items", 1, 5, Config.InventoryESP.MaxItems, "", 1, function(v) Config.InventoryESP.MaxItems = v end)
    end)

    -- ──────────────────────────────────────────
    -- 3. POPULATE AIMBOT
    -- ──────────────────────────────────────────
    pcall(function()
        tAim:AddSection("Status & Activation")
        tAim:AddToggle("Enable Aimbot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
        tAim:AddDropdown("Activation Mode", {"Hold", "Toggle", "Always"}, Config.Aimbot.ActivationMode, function(v) Config.Aimbot.ActivationMode = v end)
        tAim:AddDropdown("Aimbot Keybind", safeKeybinds, Config.Aimbot.KeybindName, function(v)
            Config.Aimbot.KeybindName = v
            local bind = KeybindMap[v]
            if bind then
                Config.Aimbot.ActivationKey = bind.Value
                Config.Aimbot.ActivationKeyType = bind.Type
                Notify.Send("Aimbot Key: " .. v, C3(255, 200, 50), 2)
            end
        end)
        tAim:AddToggle("Silent Aim (Experimental)", Config.Aimbot.SilentAim, function(v) Config.Aimbot.SilentAim = v end)
        tAim:AddToggle("Light Aim Assist", Config.Aimbot.AimAssist, function(v) Config.Aimbot.AimAssist = v end)
        tAim:AddSlider("Aim Assist Strength", 4, 30, Config.Aimbot.AssistStrength, "%", 1, function(v) Config.Aimbot.AssistStrength = v end)

        tAim:AddSection("Targeting")
        tAim:AddDropdown("Target Body Part", {"Head", "UpperTorso", "HumanoidRootPart"}, Config.Aimbot.TargetPart, function(v) Config.Aimbot.TargetPart = v end)
        tAim:AddToggle("Prioritize Visible Bones", Config.Aimbot.BonePriority, function(v) Config.Aimbot.BonePriority = v end)
        tAim:AddDropdown("Target Priority", {"Crosshair", "Distance"}, Config.Aimbot.TargetMode, function(v) Config.Aimbot.TargetMode = v end)
        tAim:AddToggle("Wall Check (Obstacles)", Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end)
        tAim:AddToggle("Ignore Teammates", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
        tAim:AddToggle("Ignore Dead / Knocked", Config.Aimbot.IgnoreKnocked, function(v) Config.Aimbot.IgnoreKnocked = v end)

        tAim:AddSection("FOV & Precision")
        tAim:AddSlider("FOV Radius", 20, 500, Config.Aimbot.FOV, "px", 5, function(v) Config.Aimbot.FOV = v end)
        tAim:AddToggle("Show FOV Circle", Config.Aimbot.ShowFOV, function(v) Config.Aimbot.ShowFOV = v end)
        tAim:AddColorPicker("FOV Circle Color", Config.Aimbot.FOVColor, function(v) Config.Aimbot.FOVColor = v end)
        tAim:AddSlider("Smoothing (Fluidity)", 1, 20, Config.Aimbot.Smoothness, "", 0.5, function(v) Config.Aimbot.Smoothness = v end)
        tAim:AddToggle("Humanize Movement", Config.Aimbot.Humanize, function(v) Config.Aimbot.Humanize = v end)
        tAim:AddToggle("Movement Prediction", Config.Aimbot.Prediction, function(v) Config.Aimbot.Prediction = v end)
    end)

    -- ──────────────────────────────────────────
    -- 4. POPULATE TRIGGERBOT
    -- ──────────────────────────────────────────
    pcall(function()
        tTrig:AddSection("General")
        tTrig:AddToggle("Enable Triggerbot", Config.Triggerbot.Enabled, function(v) Config.Triggerbot.Enabled = v end)
        tTrig:AddDropdown("Activation Mode", {"Hold", "Toggle", "Always"}, Config.Triggerbot.ActivationMode, function(v) Config.Triggerbot.ActivationMode = v end)
        tTrig:AddDropdown("Triggerbot Keybind", safeKeybinds, Config.Triggerbot.KeybindName, function(v)
            Config.Triggerbot.KeybindName = v
            local bind = KeybindMap[v]
            if bind then
                Config.Triggerbot.ActivationKey = bind.Value
                Config.Triggerbot.ActivationKeyType = bind.Type
                Notify.Send("Triggerbot Key: " .. v, C3(255, 200, 50), 2)
            end
        end)

        tTrig:AddSection("Firing Parameters")
        tTrig:AddToggle("Continuous Auto-Shoot", Config.Triggerbot.AutoShoot, function(v) Config.Triggerbot.AutoShoot = v end)
        tTrig:AddToggle("Spray Mode", Config.Triggerbot.Spray, function(v) Config.Triggerbot.Spray = v end)
        tTrig:AddSlider("Shot Delay", 0.01, 0.15, Config.Triggerbot.SprayRate, "s", 0.01, function(v) Config.Triggerbot.SprayRate = v end)
        tTrig:AddSlider("Hit Chance", 1, 100, Config.Triggerbot.HitChance, "%", 1, function(v) Config.Triggerbot.HitChance = v end)
        tTrig:AddToggle("Headshot Only", Config.Triggerbot.HeadshotOnly, function(v) Config.Triggerbot.HeadshotOnly = v end)
    end)

    -- ──────────────────────────────────────────
    -- 5. POPULATE PLAYER
    -- ──────────────────────────────────────────
    pcall(function()
        tPlayer:AddSection("Movement")
        tPlayer:AddToggle("Speed Hack", Config.Player.SpeedEnabled, function(v) Config.Player.SpeedEnabled = v end)
        tPlayer:AddSlider("Walk Speed", 16, 200, Config.Player.WalkSpeed, " studs", 2, function(v) Config.Player.WalkSpeed = v end)
        tPlayer:AddToggle("Super Jump", Config.Player.JumpEnabled, function(v) Config.Player.JumpEnabled = v end)
        tPlayer:AddSlider("Jump Power", 50, 300, Config.Player.JumpPower, "", 5, function(v) Config.Player.JumpPower = v end)
        tPlayer:AddToggle("Infinite Jump", Config.Player.InfiniteJump, function(v) Config.Player.InfiniteJump = v end)

        tPlayer:AddSection("Movement Bypass")
        tPlayer:AddToggle("Noclip (Walk Through Walls)", Config.Player.NoclipEnabled, function(v) Config.Player.NoclipEnabled = v end)
        tPlayer:AddToggle("Fly (WASD + Space/Shift)", Config.Player.FlyEnabled, function(v)
            Config.Player.FlyEnabled = v
            PlayerMods.SetupFly()
            if v then
                Notify.Send("FLY ACTIVE - Use WASD to move", C3(50, 200, 255), 3)
            else
                Notify.Send("FLY DISABLED", C3(200, 200, 200), 2)
            end
        end)
        tPlayer:AddSlider("Fly Speed", 10, 200, Config.Player.FlySpeed, "", 5, function(v) Config.Player.FlySpeed = v end)
    end)

    -- ──────────────────────────────────────────
    -- 6. POPULATE SETTINGS
    -- ──────────────────────────────────────────
    pcall(function()
        tSettings:AddSection("Interface")
        tSettings:AddToggle("Show Kill Feed", Config.Misc.ShowKillFeed, function(v) Config.Misc.ShowKillFeed = v end)
        tSettings:AddToggle("Kill Sound (Hit Sound)", Config.Misc.HitSound, function(v) Config.Misc.HitSound = v end)

        tSettings:AddSection("Utilities")
        tSettings:AddToggle("Anti-AFK", Config.Misc.AntiAFK, function(v)
            Config.Misc.AntiAFK = v
            PlayerMods.SetupAntiAFK()
        end)
        tSettings:AddToggle("Fullbright (Max Light)", Config.Misc.Fullbright, function(v)
            Config.Misc.Fullbright = v
            PlayerMods.SetupFullbright()
        end)

        tSettings:AddSection("Commands & Session")
        tSettings:AddButton("Reset Session Stats", "", function()
            State.KillCount = 0
            State.HitCount = 0
            State.SessionStart = Tick()
            Notify.Send("Stats Reset!", C3(200, 200, 200), 2)
        end)

        tSettings:AddButton("UNLOAD (Close Script)", "", function()
            State.Running = false
        end)
    end)

    SwitchTab("ESP")
    State.GUIVisible = true
    SetCursorState(true)

    Notify.Send("PRV SERVICE Pronta! [K] per il menu", C3(168, 85, 247), 4)
end

PRVServiceUI.Build = BuildNativeGUI
PRVServiceUI.Toggle = function()
    if NativeGUI and NativeGUI:FindFirstChild("MainWindow") then
        local win = NativeGUI.MainWindow
        local pill = NativeGUI:FindFirstChild("FloatPill")
        State.GUIVisible = not State.GUIVisible
        win.Visible = State.GUIVisible
        SetCursorState(State.GUIVisible)
        if State.GUIVisible and pill then
            pill.Visible = false
        end
    end
end
PRVServiceUI.Destroy = function()
    pcall(function()
        SetCursorState(false)
        if NativeGUI then NativeGUI:Destroy() end
    end)
end

task.spawn(function()
    local ok, err = pcall(PRVServiceUI.Build)
    if not ok then
        warn("[PRV SERVICE] Ultra GUI Error: " .. tostring(err))
        Notify.Send("GUI Error: " .. tostring(err), C3(255, 60, 60), 6)
    end
end)

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
    -- K or G = Toggle GUI (Always responsive!)
    if input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.G or input.KeyCode == Config.Misc.GUIToggleKey then
        PRVServiceUI.Toggle()
        return
    end

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
    pcall(function() RunService:UnbindFromRenderStep("PRVRender") end)

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

    -- Destroy GUI
    pcall(function() PRVServiceUI.Destroy() end)

    Notify.Send("PRV SERVICE Unloaded!", C3(255, 80, 80), 2)
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

    Notify.Send("PRV SERVICE v8.5 Loaded!", C3(192, 132, 252), 4)
    Notify.Send("Press K to open/close menu", C3(200, 200, 200), 5)
    Notify.Send("v8.5: Visual Badges & Full English UI!", C3(56, 189, 248), 6)
end

local ok, err = pcall(Init)
if not ok then
    warn("[PRV SERVICE] INIT ERROR: " .. tostring(err))
    pcall(function()
        local e = Drawing.new("Text")
        e.Text = "[PRV SERVICE] ERROR: " .. tostring(err)
        e.Size = 16; e.Font = 2; e.Color = C3(255,0,0)
        e.OutlineColor = C3(0,0,0); e.Outline = true
        e.Position = V2(12, 10); e.Visible = true
    end)
end
