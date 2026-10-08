--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║     PRV SERVICE v12.0 · 120 FPS Ultra-Fluid Edition             ║
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

-- ═══════════════════════════════════════════════════
-- ULTRA UNLIMITED FPS ENGINE & FRAME SMOOTHNESS SYSTEM
-- ═══════════════════════════════════════════════════
local function setFPS(val)
    local target = tonumber(val) or 0
    pcall(function()
        local sfc = setfpscap or (getgenv and getgenv().setfpscap) or set_fps_cap or (getgenv and getgenv().set_fps_cap)
        if type(sfc) == "function" then
            sfc(target)
            if target == 0 then
                sfc(999) -- Fallback high cap for executors that treat 0 as pause
            end
        end
    end)
end

-- Immediately unlock unlimited framerate (Max FPS)
setFPS(0)

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
        Enabled         = true,
        -- Chams (Player Highlight - Xeno)
        Chams           = true,
        ChamsVisibleColor = C3(255, 50, 50),
        ChamsHiddenColor  = C3(160, 20, 20),
        ChamsTransparency = 0.35,

        -- 3D Box
        Boxes           = false,

        -- Info
        Names           = true,
        Distance        = true,
        HealthBar       = true,
        HealthText      = true,

        -- Skeleton & Tracers
        Skeleton        = false,
        SkeletonColor   = C3(255, 255, 255),
        SkeletonThickness = 1.5,
        Tracers         = false,
        TracerOrigin    = "Bottom",
        TracerThickness = 1,

        -- Settings
        VisibilityCheck = true,
        VisibleColor    = C3(255, 50, 50),
        NotVisibleColor = C3(160, 20, 20),
        DefaultColor    = C3(255, 50, 50),
        NameColor       = C3(255, 255, 255),
        MaxDistance     = 1000,
        TeamCheck       = false,
        ShowTeamColor   = false,
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
        ShowDamage       = false,        -- v9.5: Clean exact weapon names by default
        CleanNames    = true,         -- v3: remove weird prefixes/suffixes
        TextColor     = C3(0, 255, 210),
        EquippedColor = C3(255, 200, 50),  -- v3: equipped item highlight
        TextSize      = 12,
        MaxItems      = 8,           -- v3: limit display
    },

    -- ── AIMBOT (DUAL POWER & SOFT ENGINE) ──
    Aimbot = {
        -- Strong Aimbot (Aimbot Potente)
        StrongEnabled        = true,
        StrongMode           = "Hold",     -- "Hold" / "Always" / "Toggle"
        StrongKeyName        = "Mouse2 (RMB)",
        StrongKey            = Enum.UserInputType.MouseButton2,
        StrongKeyType        = "Mouse",
        StrongPart           = "Head",     -- "Head" / "UpperTorso" / "HumanoidRootPart"
        StrongFOV            = 180,
        StrongSmooth         = 1.0,

        -- Soft Aim (Morbido / Regolabile)
        SoftEnabled          = false,
        SoftMode             = "Hold",     -- "Hold" / "Always" / "Toggle"
        SoftKeyName          = "LeftAlt",
        SoftKey              = Enum.KeyCode.LeftAlt,
        SoftKeyType          = "Key",
        SoftPart             = "UpperTorso",
        SoftFOV              = 120,
        SoftSmooth           = 6.0,

        -- Vehicle Fix & Shared
        VehiclePenetration   = true,
        WallCheck            = true,
        TeamCheck            = false,
        ShowFOV              = true,
        FOVColor             = C3(255, 255, 255),
        FOVTransparency      = 0.6,
        PredictionMultiplier = 0.11,
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
    StrongAimHeld   = false,
    StrongAimToggled = false,
    SoftAimHeld     = false,
    SoftAimToggled  = false,
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

local _sharedRayParams = RParams()
_sharedRayParams.FilterType = Enum.RaycastFilterType.Exclude
_sharedRayParams.IgnoreWater = true

local function updateSharedRayFilter()
    local fl = {Camera}
    if LocalPlayer.Character then tInsert(fl, LocalPlayer.Character) end
    -- Filter out LocalPlayer's seated vehicle if driving/riding
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then
            local veh = hum.SeatPart:FindFirstAncestorOfClass("Model")
            tInsert(fl, veh or hum.SeatPart)
        end
    end)
    _sharedRayParams.FilterDescendantsInstances = fl
end
updateSharedRayFilter()
pcall(function()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        pcall(updateSharedRayFilter)
    end)
end)

function Util.Visible(origin, target, plr)
    local dir = target - origin
    local currentOrigin = origin
    local remainingDist = dir.Magnitude
    local rayDir = dir.Unit

    -- Up to 3 passes to penetrate vehicle glass, windshields, seats and car body
    for pass = 1, 3 do
        local r = Workspace:Raycast(currentOrigin, rayDir * remainingDist, _sharedRayParams)
        if not r then return true end
        local hit = r.Instance
        if not hit then return true end

        -- Direct hit on player character
        if plr and plr.Character and hit:IsDescendantOf(plr.Character) then
            return true
        end

        -- Check if hit is vehicle part or transparent glass
        local isVehicleOrGlass = false
        if plr and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart then
                local veh = hum.SeatPart:FindFirstAncestorOfClass("Model")
                if hit:IsDescendantOf(veh or hum.SeatPart) then
                    isVehicleOrGlass = true
                end
            end
        end

        if hit.Transparency >= 0.25 or not hit.CanCollide or hit:IsA("Seat") or hit:IsA("VehicleSeat") then
            isVehicleOrGlass = true
        end

        if isVehicleOrGlass and Config.Aimbot.VehiclePenetration then
            local hitPos = r.Position + (rayDir * 0.15)
            remainingDist = (target - hitPos).Magnitude
            if remainingDist <= 0.3 then return true end
            currentOrigin = hitPos
        else
            return false
        end
    end
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

-- ═══════════════════════════════════════════════════
-- v10.0: INVENTORY ESP RESOLVER — FINAL REWRITE
-- Xeno-safe, no require(), no false positives
-- ═══════════════════════════════════════════════════

-- ───────────────────────────────────────────────────
-- WEAPON NAME WHITELIST (lowercase)
-- If a string matches here, it's ALWAYS valid — skip garbage checks
-- ───────────────────────────────────────────────────
local KNOWN_WEAPONS = {
    -- BlockSpin confirmed firearms & special weapons
    ["anaconda"]=true, ["remington"]=true, ["mp5"]=true, ["rpg"]=true,
    ["minigun"]=true, ["flamethrower"]=true, ["double barrel"]=true,
    ["machete"]=true, ["machette"]=true, ["barrett .50 cal"]=true, ["barrett"]=true,
    ["sniper rifle"]=true, ["quantum hack tool"]=true, ["m24"]=true,
    ["sawed-off"]=true, ["sawed off"]=true, ["sawn-off"]=true, ["sawnoff"]=true, ["sawedoff"]=true,
    ["frying pan"]=true, ["pan"]=true, ["glock"]=true, ["glock 17"]=true, ["glock17"]=true,
    ["p226"]=true, ["ak-47"]=true, ["ak47"]=true, ["m16"]=true, ["m4a1"]=true,
    ["scar"]=true, ["vector"]=true, ["p90"]=true, ["draco"]=true,
    ["skorpion"]=true, ["c9"]=true, ["crossbow"]=true,
    ["fishing rod"]=true, ["energy shot"]=true,
    ["ac-9"]=true, ["ac9"]=true, ["g3"]=true, ["uzi"]=true,
    ["mac-10"]=true, ["mac10"]=true, ["tec-9"]=true, ["tec9"]=true,
    ["lockpick"]=true, ["c4"]=true, ["taser"]=true, ["stun gun"]=true,
    ["molotov"]=true, ["grenade"]=true, ["flashbang"]=true, ["smoke grenade"]=true,
    ["deagle"]=true, ["desert eagle"]=true, ["revolver"]=true, ["m1911"]=true, ["beretta"]=true,
    ["spas-12"]=true, ["spas12"]=true, ["aa-12"]=true, ["aa12"]=true,
    ["mp7"]=true, ["ump45"]=true, ["ump-45"]=true, ["aug"]=true,
    ["famas"]=true, ["m249"]=true, ["awp"]=true, ["dragunov"]=true,
    ["gold pistol"]=true, ["gold ak"]=true, ["gold uzi"]=true,
    ["gold shotgun"]=true, ["golden gun"]=true,
    ["laser gun"]=true, ["plasma gun"]=true, ["future gun"]=true,
    ["firework launcher"]=true, ["confetti gun"]=true, ["water gun"]=true,
    ["super soaker"]=true, ["nerf gun"]=true, ["toy gun"]=true,
    ["bb gun"]=true, ["slingshot"]=true, ["potato gun"]=true,
    ["blaster"]=true, ["ray gun"]=true, ["freeze gun"]=true,

    -- BlockSpin crate & loot melee weapons
    ["tactical axe"]=true, ["tactical knife"]=true, ["tactical shovel"]=true,
    ["sledge hammer"]=true, ["combat knife"]=true, ["baseball bat"]=true,
    ["crowbar"]=true, ["rusty shovel"]=true, ["tire iron"]=true,
    ["hammer"]=true, ["nailed wooden board"]=true, ["chair leg"]=true,
    ["shank"]=true, ["dumbbell plate"]=true, ["brick"]=true,
    ["metal pipe"]=true, ["bowling pin"]=true, ["rolling pin"]=true,
    ["jar"]=true, ["wooden board"]=true, ["bottle"]=true,
    ["mug"]=true, ["glass"]=true, ["cinder block"]=true,
    ["bike lock"]=true, ["pool cue"]=true, ["spray can"]=true,
    ["soda can"]=true, ["rock"]=true, ["knife"]=true,
    ["axe"]=true, ["bat"]=true, ["pipe"]=true, ["shovel"]=true,
    ["pickaxe"]=true, ["hatchet"]=true, ["cleaver"]=true, ["baton"]=true,
    ["katana"]=true, ["sword"]=true, ["wrench"]=true,
    ["diamond mop"]=true, ["mop"]=true, ["broom"]=true, ["plunger"]=true,
    ["golf club"]=true, ["cane"]=true, ["ruler"]=true,
    ["umbrella"]=true, ["briefcase"]=true, ["guitar"]=true, ["skateboard"]=true,
    ["brass knuckles"]=true, ["knuckles"]=true, ["pepper spray"]=true,
    ["brass bat"]=true, ["spiked bat"]=true, ["nail bat"]=true,
    ["fire axe"]=true, ["chainsaw"]=true,

    -- Utilities, Cures, Heals & Throwables
    ["blood bag"]=true, ["medkit"]=true, ["bandage"]=true,
    ["first aid kit"]=true, ["health pack"]=true, ["syringe"]=true,
    ["adrenaline"]=true, ["jerry can"]=true, ["fire cracker"]=true,
    ["armor vest"]=true, ["helmet"]=true, ["flare gun"]=true,
    ["riot shield"]=true, ["tomahawk"]=true, ["throwing knife"]=true,
    ["binoculars"]=true,
}

-- ───────────────────────────────────────────────────
-- GARBAGE WORDS — never display these as weapon names
-- ───────────────────────────────────────────────────
local GARBAGE_WORDS = {
    ["weapon"]=true, ["weapons"]=true, ["tool"]=true, ["tools"]=true,
    ["item"]=true, ["items"]=true, ["uncommon"]=true, ["common"]=true,
    ["rare"]=true, ["epic"]=true, ["legendary"]=true, ["mythic"]=true,
    ["handle"]=true, ["part"]=true, ["mesh"]=true, ["model"]=true,
    ["gun"]=true, ["sound"]=true, ["animation"]=true, ["config"]=true,
    ["default"]=true, ["nil"]=true, ["none"]=true, ["null"]=true,
    ["script"]=true, ["localscript"]=true, ["modulescript"]=true,
    ["server"]=true, ["client"]=true, ["remote"]=true, ["event"]=true,
    ["value"]=true, ["folder"]=true, ["frame"]=true, ["gui"]=true,
    ["effect"]=true, ["effects"]=true, ["particle"]=true, ["particles"]=true,
    ["light"]=true, ["fire"]=true, ["smoke"]=true, ["trail"]=true,
    ["attachment"]=true, ["weld"]=true, ["motor"]=true, ["joint"]=true,
    ["constraint"]=true, ["humanoid"]=true, ["character"]=true,
    ["camera"]=true, ["viewport"]=true, ["hitbox"]=true, ["collision"]=true,
    ["raycast"]=true, ["projectile"]=true, ["bullet"]=true, ["debris"]=true,
    ["container"]=true, ["storage"]=true, ["inventory"]=true, ["slot"]=true,
    ["data"]=true, ["stats"]=true, ["info"]=true, ["settings"]=true,
    ["manager"]=true, ["controller"]=true, ["handler"]=true, ["system"]=true,
    ["module"]=true, ["service"]=true, ["object"]=true, ["instance"]=true,
    ["undefined"]=true, ["unknown"]=true, ["unnamed"]=true, ["untitled"]=true,
    ["test"]=true, ["debug"]=true, ["temp"]=true, ["placeholder"]=true,
    ["new"]=true, ["old"]=true, ["copy"]=true, ["clone"]=true,
    ["body"]=true, ["head"]=true, ["torso"]=true, ["arm"]=true, ["leg"]=true,
    ["muzzle"]=true, ["flash"]=true, ["barrel"]=true, ["trigger"]=true,
    ["magazine"]=true, ["scope"]=true, ["stock"]=true, ["grip"]=true,
    ["gunscript"]=true, ["weaponscript"]=true, ["toolscript"]=true,
    ["anim"]=true, ["anims"]=true, ["sounds"]=true, ["parts"]=true,
    ["visuals"]=true, ["fx"]=true, ["vfx"]=true, ["sfx"]=true,
    ["meshpart"]=true, ["unionoperation"]=true, ["basepart"]=true,
    ["specialmesh"]=true, ["blockmesh"]=true, ["spawnlocation"]=true,
    ["terrain"]=true, ["seat"]=true,
}

-- ───────────────────────────────────────────────────
-- CHILD NAMES TO ALWAYS IGNORE IN TOOL SCAN
-- ───────────────────────────────────────────────────
local IGNORED_CHILDREN = {
    ["handle"]=true, ["parts"]=true, ["sounds"]=true, ["animations"]=true,
    ["settings"]=true, ["config"]=true, ["client"]=true, ["server"]=true,
    ["gunscript"]=true, ["hitbox"]=true, ["muzzle"]=true, ["flash"]=true,
    ["sound"]=true, ["particles"]=true, ["camera"]=true, ["visuals"]=true,
    ["meshpart"]=true, ["part"]=true, ["model"]=true, ["body"]=true,
    ["effect"]=true, ["effects"]=true, ["fx"]=true, ["vfx"]=true,
    ["trail"]=true, ["light"]=true, ["fire"]=true, ["smoke"]=true,
    ["weld"]=true, ["motor"]=true, ["joint"]=true, ["attachment"]=true,
    ["aim"]=true, ["shoot"]=true, ["reload"]=true, ["idle"]=true,
    ["equip"]=true, ["unequip"]=true, ["hold"]=true, ["swing"]=true,
    ["localscript"]=true, ["script"]=true, ["modulescript"]=true,
    ["remote"]=true, ["remoteevent"]=true, ["remotefunction"]=true,
    ["bindableevent"]=true, ["bindablefunction"]=true,
    ["raycast"]=true, ["projectile"]=true, ["bullet"]=true,
    ["anim"]=true, ["anims"]=true, ["sfx"]=true,
    ["accessory"]=true, ["hat"]=true, ["shirt"]=true, ["pants"]=true,
}

-- ───────────────────────────────────────────────────
-- IsGarbageName — returns true if a string is NOT a valid weapon name
-- ───────────────────────────────────────────────────
function Util.IsGarbageName(str)
    if not str or type(str) ~= "string" then return true end
    local s = str:match("^%s*(.-)%s*$")
    if #s <= 1 or #s > 40 then return true end

    -- Pure numeric = garbage
    if s:match("^%d+$") then return true end

    -- Whitelist check — always valid
    if KNOWN_WEAPONS[s:lower()] then return false end

    -- FILE PATHS: anything with / or \ is a mesh/model path (e.g. "Pistols/bloodbag", "Meshes/new Melees")
    if s:find("/") or s:find("\\") then return true end

    -- BLENDER MESH NAMES: "Cube.001", "Cube.003", "Weapon.002" — word + dot + 3 digits
    if s:match("%a+%.%d%d%d") then return true end
    -- Also catch single dot-number like "Part.1", "Mesh.5"
    if s:match("^[%a%d_]+%.[%d]+$") then return true end

    -- Full UUID pattern: 8-4-4-4-12 hex with optional braces
    if s:match("^{?%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x}?$") then
        return true
    end
    -- 3+ dash-separated hex groups (partial UUID)
    if s:match("^%x+%-%x+%-%x+") then return true end

    -- Pure hex > 8 chars (hashes, asset IDs)
    if #s > 8 and s:match("^%x+$") then return true end

    -- All digits with dots/dashes (versions, coords)
    if s:match("^[%d%.%-]+$") then return true end

    -- Roblox asset strings
    local low = s:lower()
    if low:find("rbxasset") or low:find("rbxgameasset") then return true end

    -- Garbage words (exact whole-string match only)
    if GARBAGE_WORDS[low] then return true end

    -- Must contain at least one letter (no pure symbols/numbers)
    if not s:match("%a") then return true end

    -- Mostly digits (70%+ digits, more than 2 chars)
    if #s > 2 then
        local digits = 0
        for _ in s:gmatch("%d") do digits = digits + 1 end
        if digits / #s >= 0.7 then return true end
    end

    return false
end

-- ───────────────────────────────────────────────────
-- CleanToolName — strips prefixes/suffixes, normalizes
-- ───────────────────────────────────────────────────
function Util.CleanToolName(raw)
    if not raw or type(raw) ~= "string" then return nil end

    -- Whitelist shortcut — return immediately for known names
    local trimmed = raw:match("^%s*(.-)%s*$")
    if KNOWN_WEAPONS[trimmed:lower()] then return trimmed end

    local name = trimmed
    -- Strip common prefixes
    name = name:gsub("^Tool_", ""):gsub("^Weapon_", ""):gsub("^Item_", "")
    name = name:gsub("^Melee_", ""):gsub("^Gun_", ""):gsub("^Equip_", "")
    -- Strip leading/trailing numeric IDs separated by underscore
    name = name:gsub("^%d+_", ""):gsub("_%d+$", "")
    -- Underscores → spaces
    name = name:gsub("_", " ")
    name = name:match("^%s*(.-)%s*$")

    if not name or #name == 0 then return nil end
    if Util.IsGarbageName(name) then return nil end
    return name
end

-- ───────────────────────────────────────────────────
-- CapitalizeName — proper display casing
-- Handles: "ak-47" → "AK-47", "double barrel" → "Double Barrel",
--          "mp5" → "MP5", "combat knife" → "Combat Knife"
-- ───────────────────────────────────────────────────
local function CapitalizeName(name)
    if not name then return name end

    -- If whole name is a known weapon, use a curated display form
    local low = name:lower():match("^%s*(.-)%s*$")
    -- Short alphanumeric names that should be ALL CAPS (weapon models)
    local ALL_CAPS = {
        ["rpg"]=true, ["mp5"]=true, ["mp7"]=true, ["m16"]=true, ["m4a1"]=true,
        ["p90"]=true, ["p226"]=true, ["g3"]=true, ["c4"]=true, ["uzi"]=true,
        ["awp"]=true, ["aug"]=true, ["m249"]=true, ["m1911"]=true,
        ["ump45"]=true, ["famas"]=true, ["m24"]=true, ["c9"]=true,
    }
    if ALL_CAPS[low] then return name:upper() end

    -- Hyphenated weapon models: keep both parts uppercase
    local HYPHEN_UPPER = {
        ["ak-47"]=true, ["ac-9"]=true, ["mac-10"]=true, ["tec-9"]=true,
        ["aa-12"]=true, ["spas-12"]=true, ["ump-45"]=true,
    }
    if HYPHEN_UPPER[low] then return name:upper() end

    -- No-hyphen variants
    local NO_HYPHEN_UPPER = {
        ["ak47"]=true, ["ac9"]=true, ["mac10"]=true, ["tec9"]=true,
        ["aa12"]=true, ["spas12"]=true, ["ump45"]=true,
    }
    if NO_HYPHEN_UPPER[low] then return name:upper() end

    -- General case: capitalize each word (split by space and dash)
    local result = {}
    -- Split by spaces first
    for word in name:gmatch("[^%s]+") do
        -- Split each word by dashes
        local parts = {}
        for part in word:gmatch("[^%-]+") do
            -- If part starts with a digit, keep as-is
            if part:match("^%d") then
                tInsert(parts, part)
            -- Short parts (1-2 chars) that are letters only → uppercase (likely acronym)
            elseif #part <= 2 and part:match("^%a+$") then
                tInsert(parts, part:upper())
            else
                -- Normal capitalize: first upper, rest lower
                tInsert(parts, part:sub(1,1):upper() .. part:sub(2):lower())
            end
        end
        tInsert(result, tConcat(parts, "-"))
    end
    return tConcat(result, " ")
end

-- ═══════════════════════════════════════════════════
-- RARITY SYSTEM
-- ═══════════════════════════════════════════════════
local RARITY_COLORS = {
    Mythic    = C3(239, 68, 68),
    Legendary = C3(255, 190, 20),
    Epic      = C3(168, 85, 247),
    Rare      = C3(56, 189, 248),
    Uncommon  = C3(34, 197, 94),
    Utility   = C3(52, 211, 153),
    Common    = C3(209, 213, 219),
}

local BLOCKSPIN_RARITIES = {
    -- Mythic (Red)
    ["anaconda"]            = { r = "Mythic",    c = RARITY_COLORS.Mythic },

    -- Legendary (Gold)
    ["remington"]           = { r = "Legendary", c = RARITY_COLORS.Legendary },
    ["mp5"]                 = { r = "Legendary", c = RARITY_COLORS.Legendary },
    ["rpg"]                 = { r = "Legendary", c = RARITY_COLORS.Legendary },
    ["minigun"]             = { r = "Legendary", c = RARITY_COLORS.Legendary },
    ["flamethrower"]        = { r = "Legendary", c = RARITY_COLORS.Legendary },
    ["gold ak"]             = { r = "Legendary", c = RARITY_COLORS.Legendary },
    ["golden gun"]          = { r = "Legendary", c = RARITY_COLORS.Legendary },
    ["gold pistol"]         = { r = "Legendary", c = RARITY_COLORS.Legendary },

    -- Epic (Purple)
    ["double barrel"]       = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["machete"]             = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["machette"]            = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["barrett .50 cal"]     = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["barrett"]             = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["sniper rifle"]        = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["awp"]                 = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["m24"]                 = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["katana"]              = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["g3"]                  = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["deagle"]              = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["desert eagle"]        = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["quantum hack tool"]   = { r = "Epic",      c = RARITY_COLORS.Epic },
    ["crossbow"]            = { r = "Epic",      c = RARITY_COLORS.Epic },

    -- Rare (Blue / Cyan)
    ["sawed-off"]           = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["sawed off"]           = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["sawn-off"]            = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["sawnoff"]             = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["sawedoff"]            = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["frying pan"]          = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["pan"]                 = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["glock"]               = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["glock 17"]            = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["glock17"]             = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["p226"]                = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["ak-47"]               = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["ak47"]                = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["m16"]                 = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["m4a1"]                = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["scar"]                = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["vector"]              = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["p90"]                 = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["draco"]               = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["fishing rod"]         = { r = "Rare",      c = RARITY_COLORS.Rare },
    ["energy shot"]         = { r = "Rare",      c = RARITY_COLORS.Rare },

    -- Uncommon (Green)
    ["ac-9"]                = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["ac9"]                 = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["uzi"]                 = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["mac-10"]              = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["mac10"]               = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["tec-9"]               = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["tec9"]                = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["skorpion"]            = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["c9"]                  = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["lockpick"]            = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["c4"]                  = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["taser"]               = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["molotov"]             = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },
    ["sledge hammer"]       = { r = "Uncommon",  c = RARITY_COLORS.Uncommon },

    -- Utility (Teal / Medical)
    ["blood bag"]           = { r = "Utility",   c = RARITY_COLORS.Utility },
    ["medkit"]              = { r = "Utility",   c = RARITY_COLORS.Utility },
    ["bandage"]             = { r = "Utility",   c = RARITY_COLORS.Utility },
    ["first aid kit"]       = { r = "Utility",   c = RARITY_COLORS.Utility },
    ["syringe"]             = { r = "Utility",   c = RARITY_COLORS.Utility },
    ["adrenaline"]          = { r = "Utility",   c = RARITY_COLORS.Utility },
    ["jerry can"]           = { r = "Utility",   c = RARITY_COLORS.Utility },
    ["fire cracker"]        = { r = "Utility",   c = RARITY_COLORS.Utility },

    -- Common (Grey / Silver)
    ["tactical axe"]        = { r = "Common",    c = RARITY_COLORS.Common },
    ["tactical knife"]      = { r = "Common",    c = RARITY_COLORS.Common },
    ["tactical shovel"]     = { r = "Common",    c = RARITY_COLORS.Common },
    ["combat knife"]        = { r = "Common",    c = RARITY_COLORS.Common },
    ["baseball bat"]        = { r = "Common",    c = RARITY_COLORS.Common },
    ["crowbar"]             = { r = "Common",    c = RARITY_COLORS.Common },
    ["rusty shovel"]        = { r = "Common",    c = RARITY_COLORS.Common },
    ["tire iron"]           = { r = "Common",    c = RARITY_COLORS.Common },
    ["hammer"]              = { r = "Common",    c = RARITY_COLORS.Common },
    ["nailed wooden board"] = { r = "Common",    c = RARITY_COLORS.Common },
    ["chair leg"]           = { r = "Common",    c = RARITY_COLORS.Common },
    ["shank"]               = { r = "Common",    c = RARITY_COLORS.Common },
    ["dumbbell plate"]      = { r = "Common",    c = RARITY_COLORS.Common },
    ["brick"]               = { r = "Common",    c = RARITY_COLORS.Common },
    ["metal pipe"]          = { r = "Common",    c = RARITY_COLORS.Common },
    ["bowling pin"]         = { r = "Common",    c = RARITY_COLORS.Common },
    ["rolling pin"]         = { r = "Common",    c = RARITY_COLORS.Common },
    ["jar"]                 = { r = "Common",    c = RARITY_COLORS.Common },
    ["wooden board"]        = { r = "Common",    c = RARITY_COLORS.Common },
    ["bottle"]              = { r = "Common",    c = RARITY_COLORS.Common },
    ["mug"]                 = { r = "Common",    c = RARITY_COLORS.Common },
    ["glass"]               = { r = "Common",    c = RARITY_COLORS.Common },
    ["cinder block"]        = { r = "Common",    c = RARITY_COLORS.Common },
    ["bike lock"]           = { r = "Common",    c = RARITY_COLORS.Common },
    ["pool cue"]            = { r = "Common",    c = RARITY_COLORS.Common },
    ["spray can"]           = { r = "Common",    c = RARITY_COLORS.Common },
    ["soda can"]            = { r = "Common",    c = RARITY_COLORS.Common },
    ["rock"]                = { r = "Common",    c = RARITY_COLORS.Common },
    ["knife"]               = { r = "Common",    c = RARITY_COLORS.Common },
    ["axe"]                 = { r = "Common",    c = RARITY_COLORS.Common },
    ["bat"]                 = { r = "Common",    c = RARITY_COLORS.Common },
    ["pipe"]                = { r = "Common",    c = RARITY_COLORS.Common },
    ["shovel"]              = { r = "Common",    c = RARITY_COLORS.Common },
    ["hatchet"]             = { r = "Common",    c = RARITY_COLORS.Common },
    ["baton"]             = { r = "Common",    c = RARITY_COLORS.Common },
}

-- ───────────────────────────────────────────────────
-- GetItemRarity — exact match first, then safe partial
-- ───────────────────────────────────────────────────
function Util.GetItemRarity(tool, itemName)
    if not itemName then return "Common", RARITY_COLORS.Common end
    local lower = itemName:lower():match("^%s*(.-)%s*$")

    -- 1. Check explicit tool Attributes (BlockSpin items often have Rarity/Tier attributes)
    if tool then
        local attrRarity = nil
        pcall(function()
            for _, rKey in ipairs({"Rarity","rarity","Tier","tier","ItemRarity","itemRarity","Quality","quality"}) do
                local rAttr = tool:GetAttribute(rKey)
                if rAttr and type(rAttr) == "string" and #rAttr > 0 then
                    attrRarity = rAttr
                    break
                end
            end
        end)
        if attrRarity then
            local erLow = attrRarity:lower()
            if erLow:find("mythic")    then return "Mythic", RARITY_COLORS.Mythic end
            if erLow:find("legend")    then return "Legendary", RARITY_COLORS.Legendary end
            if erLow:find("epic")      then return "Epic", RARITY_COLORS.Epic end
            if erLow:find("rare")      then return "Rare", RARITY_COLORS.Rare end
            if erLow:find("uncommon")   then return "Uncommon", RARITY_COLORS.Uncommon end
            if erLow:find("utility") or erLow:find("med") then return "Utility", RARITY_COLORS.Utility end
            if erLow:find("common")     then return "Common", RARITY_COLORS.Common end
        end
    end

    -- 2. Exact match in BLOCKSPIN_RARITIES
    local direct = BLOCKSPIN_RARITIES[lower]
    if direct then return direct.r, direct.c end

    -- 3. Partial keyword matching against known weapons
    for k, v in pairs(BLOCKSPIN_RARITIES) do
        if #k >= 3 and lower:find(k, 1, true) then
            return v.r, v.c
        end
    end

    -- 4. Semantic category matching (Fish, Cures, Food, Valuables, Melee, Guns)
    -- Utility: Healing, Cures, Medical, Food, Fish
    if lower:find("med") or lower:find("heal") or lower:find("blood") or lower:find("band") or lower:find("cure") or lower:find("pill")
       or lower:find("fish") or lower:find("pesce") or lower:find("salmon") or lower:find("trout") or lower:find("bass")
       or lower:find("drink") or lower:find("water") or lower:find("apple") or lower:find("burger") or lower:find("energy") then
        return "Utility", RARITY_COLORS.Utility
    end

    -- Legendary / Gold
    if lower:find("gold") or lower:find("golden") or lower:find("minigun") or lower:find("rpg") or lower:find("rocket") or lower:find("flamethrower") then
        return "Legendary", RARITY_COLORS.Legendary
    end

    -- Epic: Sniper, Heavy, Katana, Hack
    if lower:find("sniper") or lower:find("barrett") or lower:find("awp") or lower:find("katana") or lower:find("sword") or lower:find("hack") or lower:find("c4") then
        return "Epic", RARITY_COLORS.Epic
    end

    -- Rare: Rifles, Shotguns
    if lower:find("rifle") or lower:find("shotgun") or lower:find("glock") or lower:find("p226") or lower:find("ak") or lower:find("m4") or lower:find("vector") or lower:find("rod") then
        return "Rare", RARITY_COLORS.Rare
    end

    -- Uncommon: SMGs, Pistols, Lockpick
    if lower:find("smg") or lower:find("uzi") or lower:find("pistol") or lower:find("lockpick") or lower:find("revolver") then
        return "Uncommon", RARITY_COLORS.Uncommon
    end

    -- Default: Clean Common Silver (#D1D5DB)
    return "Common", RARITY_COLORS.Common
end

function Util.GetToolDamage(tool)
    local dmg = nil
    pcall(function()
        for _, attr in ipairs({"Damage","damage","DMG","dmg","BaseDamage","baseDamage","AttackDamage","attackDamage","HitDamage","hitDamage"}) do
            local v = tool:GetAttribute(attr)
            if v and type(v) == "number" then dmg = v; return end
        end
        for _, child in ipairs(tool:GetChildren()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local n = child.Name:lower()
                if n:find("damage") or n:find("dmg") or n:find("attack") or n == "power" then
                    dmg = child.Value
                    return
                end
            end
        end
    end)
    return dmg
end

-- ═══════════════════════════════════════════════════
-- REPLICATED STORAGE SCANNER (XENO-SAFE)
-- NO require() — only reads Tool instances and their properties
-- ═══════════════════════════════════════════════════
local _rsCache = nil
local _rsCacheTime = 0
local _rsScanFailed = false

local function BuildRSWeaponMap()
    local now = Tick()
    -- Return cached if fresh (30s TTL)
    if _rsCache and (now - _rsCacheTime < 30) then return _rsCache end
    -- If scan previously failed, retry every 60s
    if _rsScanFailed and _rsCache and (now - _rsCacheTime < 60) then return _rsCache end

    local map = {}
    local success = false

    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        if not RS then return end

        -- Scan ALL Tool instances in RS (safe, no require)
        for _, desc in ipairs(RS:GetDescendants()) do
            pcall(function()
                if desc:IsA("Tool") then
                    local toolName = desc.Name
                    local displayName = nil

                    -- Check attributes for display name
                    for _, key in ipairs({"DisplayName","displayName","ItemName","itemName","WeaponName","weaponName","Label","label"}) do
                        local val = desc:GetAttribute(key)
                        if type(val) == "string" and #val > 1 and #val < 40 and not Util.IsGarbageName(val) then
                            displayName = val:match("^%s*(.-)%s*$")
                            break
                        end
                    end

                    -- Fallback to ToolTip
                    if not displayName and desc.ToolTip and #desc.ToolTip > 1 and not Util.IsGarbageName(desc.ToolTip) then
                        displayName = desc.ToolTip:match("^%s*(.-)%s*$")
                    end

                    -- Fallback: if toolName itself is valid
                    if not displayName and not Util.IsGarbageName(toolName) then
                        local cleaned = Util.CleanToolName(toolName)
                        if cleaned then displayName = cleaned end
                    end

                    if displayName then
                        map[toolName:lower()] = displayName
                        success = true
                    end
                end
            end)
        end

        -- Also scan Configuration/Folder objects that hold weapon data
        for _, desc in ipairs(RS:GetDescendants()) do
            pcall(function()
                if desc:IsA("Configuration") or (desc:IsA("Folder") and desc.Name:lower():find("weapon")) then
                    for _, child in ipairs(desc:GetChildren()) do
                        if child:IsA("StringValue") then
                            local valName = child.Name:lower()
                            if valName:find("name") or valName:find("display") or valName:find("label") then
                                local val = child.Value
                                if type(val) == "string" and #val > 1 and not Util.IsGarbageName(val) then
                                    map[desc.Name:lower()] = val:match("^%s*(.-)%s*$")
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)

    _rsCache = map
    _rsCacheTime = now
    _rsScanFailed = not success and next(map) == nil
    return map
end

-- ═══════════════════════════════════════════════════
-- MASTER RESOLVER v10.0
-- Resolution order:
--   1. RS cache lookup by tool.Name
--   2. Known weapon whitelist check
--   3. tool.Name if human-readable
--   4. Attributes (DisplayName, ItemName, etc.)
--   5. ToolTip
--   6. String attribute scan (known weapons only)
--   7. RS cross-reference by attribute IDs
--   8. Child name scan (known weapons first, then valid 4+ char names)
--   9. Animation prefix scan
--  10. StringValue scan (known weapons only)
-- ═══════════════════════════════════════════════════
local BANNED_NAME_WORDS = {
    ["rare"]=true, ["melee"]=true, ["common"]=true, ["uncommon"]=true,
    ["epic"]=true, ["legendary"]=true, ["mythic"]=true, ["utility"]=true,
    ["weapon"]=true, ["weapons"]=true, ["tool"]=true, ["tools"]=true,
    ["gun"]=true, ["guns"]=true, ["item"]=true, ["items"]=true,
    ["primary"]=true, ["secondary"]=true, ["gear"]=true,
    ["handle"]=true, ["part"]=true, ["meshpart"]=true, ["model"]=true,
    ["hitbox"]=true, ["animation"]=true, ["sound"]=true, ["type"]=true,
    ["category"]=true, ["class"]=true, ["tier"]=true, ["rarity"]=true,
    ["none"]=true, ["nil"]=true, ["null"]=true, ["unknown"]=true,
    ["unarmed"]=true, ["hands"]=true, ["fist"]=true, ["fists"]=true,
    ["emote"]=true, ["emotes"]=true, ["action"]=true,
    -- Generic weapon classes that are NOT specific weapons:
    ["shotgun"]=true, ["pistol"]=true, ["rifle"]=true, ["smg"]=true, ["sniper"]=true,
}

local function isIgnoredEmoteOrCiv(name)
    if not name or type(name) ~= "string" then return false end
    local low = name:lower():match("^%s*(.-)%s*$")
    if low:find("nuthing") or low:find("nothing") or low:find("surrender")
       or low:find("hands%s*up") or low == "handsup"
       or low:find("emote") or low:find("action") then
        return true
    end
    return false
end

local function isValidHumanName(str)
    if not str or type(str) ~= "string" then return false end
    local s = str:match("^%s*(.-)%s*$")
    if #s <= 1 or #s > 45 then return false end
    -- Pure digits (e.g. "83570", "843997", "453488") are internal serial/asset IDs, NEVER human names!
    if s:match("^%d+$") then return false end
    -- UUID or pure hex hashes
    if s:match("^%x%x%x%x%x%x%x%x%-") then return false end
    if #s > 6 and s:match("^%x+$") and not s:match("[g-zG-Z]") then return false end
    -- Must contain at least one letter
    if not s:match("%a") then return false end
    -- Ignore generic technical words, classification words, and rarities
    local low = s:lower()
    if BANNED_NAME_WORDS[low] then return false end
    if GARBAGE_WORDS[low] then return false end
    -- BlockSpin default surrender / hands-up / empty-hands emote ("I Have Nuthingggggg")
    if isIgnoredEmoteOrCiv(low) then return false end
    if Util.IsGarbageName(s) then return false end
    return true
end

function Util.ResolveToolInfo(tool)
    if not tool or not tool:IsA("Tool") then return nil, nil, nil end

    local rawToolName = tool.Name or ""
    local lowToolName = rawToolName:lower():match("^%s*(.-)%s*$")

    -- 0. Completely ignore surrender emotes, hands up, civilian empty hands ("I Have Nuthingggggg")
    if isIgnoredEmoteOrCiv(rawToolName) or lowToolName == "unarmed" or lowToolName == "fists" or lowToolName == "hands" then
        return nil, nil, nil
    end

    local realName = nil

    -- Specific BlockSpin weapon alias mapping on tool.Name (e.g. if tool is called "Shotgun", it's the Sawed-Off!)
    if lowToolName == "shotgun" or lowToolName == "sawnoff" or lowToolName == "sawn-off" or lowToolName == "sawed off" or lowToolName == "sawedoff" then
        realName = "Sawed-Off"
    elseif lowToolName == "machette" then
        realName = "Machete"
    elseif lowToolName == "ak47" then
        realName = "AK-47"
    end

    -- 1. Whitelist direct check on tool.Name (Katana, Remington, Sawed-Off, Lockpick, Medkit, etc.)
    if not realName and KNOWN_WEAPONS[lowToolName] then
        realName = rawToolName:match("^%s*(.-)%s*$")
    end

    -- 2. Clean human-readable tool.Name (if not numeric serial ID and not banned/garbage words)
    if not realName and isValidHumanName(rawToolName) then
        realName = rawToolName:match("^%s*(.-)%s*$")
    end

    -- 3. Specific Display/Weapon attributes on the Tool (strictly excluding Type, Category, Rarity, etc.)
    if not realName then
        pcall(function()
            for _, attr in ipairs({"DisplayName", "ItemName", "WeaponName", "GunName", "ToolName", "FishName", "FishType", "Species", "RealName", "ActualName", "ItemTitle"}) do
                local val = tool:GetAttribute(attr)
                if isValidHumanName(val) then
                    realName = tostring(val):match("^%s*(.-)%s*$")
                    return
                end
            end
        end)
    end

    -- 4. Check tool.ToolTip
    if not realName then
        pcall(function()
            local tt = tool.ToolTip
            if isValidHumanName(tt) then
                realName = tt:match("^%s*(.-)%s*$")
            end
        end)
    end

    -- 5. Scan attributes specifically ignoring metadata/classification/rarity keys
    if not realName then
        pcall(function()
            local IGNORED_ATTR_KEYS = {
                ["rarity"]=true, ["tier"]=true, ["type"]=true, ["category"]=true,
                ["class"]=true, ["slot"]=true, ["id"]=true, ["serial"]=true,
                ["ammo"]=true, ["maxammo"]=true, ["damage"]=true, ["state"]=true,
                ["durability"]=true, ["level"]=true, ["weight"]=true, ["equipped"]=true,
                ["fishweight"]=true,
            }
            for k, val in pairs(tool:GetAttributes()) do
                local kLow = tostring(k):lower()
                if not IGNORED_ATTR_KEYS[kLow] and isValidHumanName(val) then
                    realName = tostring(val):match("^%s*(.-)%s*$")
                    return
                end
            end
        end)
    end

    -- 6. Check StringValue objects inside the Tool (e.g. ItemName, DisplayName, GunName)
    if not realName then
        pcall(function()
            for _, desc in ipairs(tool:GetDescendants()) do
                if desc:IsA("StringValue") then
                    local sVal = desc.Value
                    local sName = desc.Name:lower()
                    if (sName:find("name") or sName:find("display") or sName:find("weapon") or sName:find("item")) and isValidHumanName(sVal) then
                        realName = sVal:match("^%s*(.-)%s*$")
                        return
                    end
                end
            end
        end)
    end

    -- 7. Check child Models, MeshParts, or Parts (often named after the actual weapon, e.g. "Katana", "Remington")
    if not realName then
        pcall(function()
            for _, desc in ipairs(tool:GetChildren()) do
                if (desc:IsA("Model") or desc:IsA("MeshPart") or desc:IsA("BasePart")) and isValidHumanName(desc.Name) then
                    realName = desc.Name
                    return
                end
            end
            for _, desc in ipairs(tool:GetDescendants()) do
                if (desc:IsA("Model") or desc:IsA("MeshPart")) and isValidHumanName(desc.Name) then
                    realName = desc.Name
                    return
                end
            end
        end)
    end

    -- 8. Check animations and sounds (e.g. "Remington_Shoot", "MP5_Reload", "Katana_Swing")
    if not realName then
        pcall(function()
            for _, desc in ipairs(tool:GetDescendants()) do
                if desc:IsA("Animation") or desc:IsA("Sound") then
                    local prefix = desc.Name:match("^([%a%d%s%-]+)_")
                    if isValidHumanName(prefix) then
                        local pLow = prefix:lower()
                        if pLow ~= "idle" and pLow ~= "shoot" and pLow ~= "equip" and pLow ~= "reload" and pLow ~= "fire" and pLow ~= "swing" and pLow ~= "slash" then
                            realName = prefix
                            return
                        end
                    end
                end
            end
        end)
    end

    -- 9. Fallback for Fishing / Catch items:
    -- In BlockSpin, caught fish Tools have Weight or Fish attributes
    if not realName then
        pcall(function()
            local weight = tool:GetAttribute("Weight") or tool:GetAttribute("weight") or tool:GetAttribute("FishWeight")
            local isFish = tool:GetAttribute("Fish") or tool:GetAttribute("Fishing") or tool:GetAttribute("Caught")
            local fishSpecies = tool:GetAttribute("FishType") or tool:GetAttribute("Species") or tool:GetAttribute("FishName")
            if weight or isFish or fishSpecies then
                local fName = (fishSpecies and isValidHumanName(fishSpecies)) and tostring(fishSpecies) or "Fish"
                if type(weight) == "number" and weight > 0 then
                    realName = fName .. " [" .. string.format("%.1f", weight) .. "kg]"
                else
                    realName = fName
                end
            end
        end)
    end

    -- 10. ReplicatedStorage cross-reference (safe map lookup)
    if not realName and tool.Name then
        local rsMap = BuildRSWeaponMap()
        if rsMap then
            local hit = rsMap[tool.Name:lower()]
            if isValidHumanName(hit) then realName = hit end
        end
    end

    -- 11. Check tool type clues as last resort (HealthRestore -> Medkit, Damage -> Weapon)
    if not realName then
        pcall(function()
            local hp = tool:GetAttribute("HealthRestoreAmount") or tool:GetAttribute("HealthRestore")
            local dmg = tool:GetAttribute("Damage") or tool:GetAttribute("BaseDamage")
            local ammo = tool:GetAttribute("MaxAmmo") or tool:GetAttribute("Ammo")
            if type(hp) == "number" and hp > 0 then
                realName = "Medkit"
            elseif (type(dmg) == "number" and dmg > 0) or type(ammo) == "number" then
                realName = "Weapon"
            end
        end)
    end

    -- IF STILL NOT FOUND OR NUMERIC, DO NOT RETURN NUMERIC SERIAL NUMBER!
    if not realName or not isValidHumanName(realName) then
        return nil, nil, nil
    end

    -- Clean formatting:
    realName = realName:gsub("^Tool_", ""):gsub("^Weapon_", ""):gsub("^Item_", ""):gsub("^Gun_", ""):gsub("^Equip_", "")
    realName = realName:gsub("_", " "):match("^%s*(.-)%s*$")

    local lowFinal = realName:lower()
    if lowFinal == "shotgun" or lowFinal == "sawnoff" or lowFinal == "sawn-off" or lowFinal == "sawed off" or lowFinal == "sawedoff" then
        realName = "Sawed-Off"
    elseif lowFinal == "machette" then
        realName = "Machete"
    elseif lowFinal == "ak47" then
        realName = "AK-47"
    else
        realName = CapitalizeName(realName)
    end

    local rarity, color = Util.GetItemRarity(tool, realName)
    return realName, rarity, color
end

function Util.ResolveToolName(tool)
    local name = Util.ResolveToolInfo(tool)
    return name
end

function Util.GetWeaponDetails(tool, isEquipped)
    if not tool then return nil end
    local name, rarity, color = Util.ResolveToolInfo(tool)
    if not name or #name == 0 then return nil end

    return {
        name = name,
        rarity = rarity or "Common",
        color = color or RARITY_COLORS.Common,
        isEquipped = isEquipped,
        damage = Util.GetToolDamage(tool),
    }
end

local _toolInfoCache = setmetatable({}, {__mode = "k"})

function Util.GetToolInfo(tool, isEquipped)
    if not tool then return {display = nil, isEquipped = isEquipped} end
    local cached = _toolInfoCache[tool]
    local now = Tick()
    if cached and cached.isEquipped == isEquipped and (now - (cached.time or 0) < 1.5) then
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
-- CONFIG MANAGER (Save, Load, Reset, Auto-Persistence)
-- ═══════════════════════════════════════════════════
local ConfigManager = {}
local CONFIG_FILE = "phantom_blockspin_config.json"
local HttpService = game:GetService("HttpService")

local function serializeConfigValue(val)
    local t = typeof(val)
    if t == "Color3" then
        return {__type = "Color3", R = val.R, G = val.G, B = val.B}
    elseif t == "EnumItem" then
        return {__type = "EnumItem", EnumType = tostring(val.EnumType), Name = val.Name}
    elseif t == "table" then
        local copy = {}
        for k, v in pairs(val) do
            copy[tostring(k)] = serializeConfigValue(v)
        end
        return copy
    else
        return val
    end
end

local function deserializeConfigValue(val)
    if type(val) == "table" then
        if val.__type == "Color3" and val.R and val.G and val.B then
            return Color3.new(val.R, val.G, val.B)
        elseif val.__type == "EnumItem" and val.EnumType and val.Name then
            local ok, item = pcall(function()
                return Enum[val.EnumType][val.Name]
            end)
            if ok and item then return item end
            return nil
        else
            local res = {}
            for k, v in pairs(val) do
                local numKey = tonumber(k)
                local key = numKey or k
                res[key] = deserializeConfigValue(v)
            end
            return res
        end
    else
        return val
    end
end

function ConfigManager.Save(silent)
    local ok, err = pcall(function()
        local wf = writefile or (getgenv and getgenv().writefile)
        if not wf then
            if not silent then Notify.Send("writefile non supportato dall'executor", C3(255, 80, 80), 3) end
            return
        end
        local serialized = serializeConfigValue(Config)
        local json = HttpService:JSONEncode(serialized)
        wf(CONFIG_FILE, json)
        if not silent then
            Notify.Send("💾 Config salvata con successo!", C3(0, 255, 180), 3)
        end
    end)
    if not ok and not silent then
        Notify.Send("Errore salvataggio config: " .. tostring(err), C3(255, 80, 80), 3)
    end
end

function ConfigManager.Load(silent)
    local ok, err = pcall(function()
        local rf = readfile or (getgenv and getgenv().readfile)
        local isf = isfile or (getgenv and getgenv().isfile)
        if not rf or not isf then return end
        if not isf(CONFIG_FILE) then
            if not silent then Notify.Send("Nessuna config salvata trovata!", C3(255, 200, 50), 3) end
            return
        end
        local content = rf(CONFIG_FILE)
        if not content or #content == 0 then return end
        local raw = HttpService:JSONDecode(content)
        local decoded = deserializeConfigValue(raw)

        local function deepMerge(target, source)
            for k, v in pairs(source) do
                if type(v) == "table" and type(target[k]) == "table" and typeof(v) ~= "Color3" then
                    deepMerge(target[k], v)
                else
                    target[k] = v
                end
            end
        end
        deepMerge(Config, decoded)

        if not silent then
            Notify.Send("📂 Config caricata con successo!", C3(56, 189, 248), 3)
        end
    end)
    if not ok and not silent then
        Notify.Send("Errore caricamento config: " .. tostring(err), C3(255, 80, 80), 3)
    end
end

function ConfigManager.Reset()
    pcall(function()
        local df = delfile or (getgenv and getgenv().delfile)
        local isf = isfile or (getgenv and getgenv().isfile)
        if df and isf and isf(CONFIG_FILE) then
            df(CONFIG_FILE)
        end
        Notify.Send("🔄 Config eliminata! Riavvia lo script per i default.", C3(255, 200, 50), 3)
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
        bb.Size = UDim2.new(0, 220, 0, 120)
        bb.StudsOffset = V3(0, 1.8, 0)
        bb.LightInfluence = 0
        bb.MaxDistance = math.huge
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
        invLbl.Size = UDim2.new(1, 0, 1, -20)
        invLbl.Position = UDim2.new(0, 0, 0, 20)
        invLbl.Font = Enum.Font.GothamBold
        invLbl.RichText = true
        invLbl.TextSize = Config.InventoryESP.TextSize
        invLbl.TextColor3 = C3(255, 255, 255)  -- MUST be white so RichText <font color> tags work
        invLbl.TextStrokeTransparency = 0.2
        invLbl.TextStrokeColor3 = C3(0, 0, 0)
        invLbl.TextXAlignment = Enum.TextXAlignment.Center
        invLbl.TextYAlignment = Enum.TextYAlignment.Top
        invLbl.TextWrapped = true
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
    if dist > (Config.ESP.MaxDistance or 1000) then
        if not d._isOutOfRange then
            ESP.HideAll(d)
            d._isOutOfRange = true
        end
        return
    end
    d._isOutOfRange = false

    -- Color determination with throttled / conditional visibility check (Zero lag)
    local isVisible = false
    if Config.ESP.VisibilityCheck or Config.ESP.Chams then
        local now = Tick()
        if not d._lastVisCheck or (now - d._lastVisCheck > 0.06) then
            d._lastVisCheck = now
            d._cachedVisible = Util.Visible(camPos, rootPos, player)
        end
        isVisible = d._cachedVisible or false
    end

    local col
    if Config.ESP.ShowTeamColor and player.Team then
        col = player.TeamColor.Color
    elseif Config.ESP.VisibilityCheck then
        col = isVisible and Config.ESP.VisibleColor or Config.ESP.NotVisibleColor
    else
        col = Config.ESP.DefaultColor
    end

    -- 1. NATIVE HIGHLIGHT (Chams / Player Highlight - AlwaysOnTop for Xeno)
    if d.Highlight then
        if Config.ESP.Chams and dist <= (Config.ESP.MaxDistance or 1000) then
            if d.Highlight.Parent ~= char then d.Highlight.Parent = char end
            if d.Highlight.Adornee ~= char then d.Highlight.Adornee = char end
            if d.Highlight.DepthMode ~= Enum.HighlightDepthMode.AlwaysOnTop then
                d.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end

            local chamsFill = isVisible and Config.ESP.ChamsVisibleColor or Config.ESP.ChamsHiddenColor
            if d._lastFillCol ~= chamsFill then
                d._lastFillCol = chamsFill
                d.Highlight.FillColor = chamsFill
            end
            if d._lastOutlineCol ~= col then
                d._lastOutlineCol = col
                d.Highlight.OutlineColor = col
            end

            d.Highlight.FillTransparency = Config.ESP.ChamsTransparency or 0.35
            d.Highlight.OutlineTransparency = 0
            if not d.Highlight.Enabled then d.Highlight.Enabled = true end
        else
            if d.Highlight.Enabled then d.Highlight.Enabled = false end
        end
    end

    -- 2. NATIVE SELECTIONBOX (3D Box around player)
    if d.SelectionBox then
        if Config.ESP.Boxes and dist <= (Config.ESP.MaxDistance or 1000) then
            if d.SelectionBox.Parent ~= char then d.SelectionBox.Parent = char end
            if d.SelectionBox.Adornee ~= char then d.SelectionBox.Adornee = char end
            if d._lastBoxCol ~= col then
                d._lastBoxCol = col
                d.SelectionBox.Color3 = col
            end
            d.SelectionBox.LineThickness = 0.035
            if not d.SelectionBox.Visible then d.SelectionBox.Visible = true end
        else
            if d.SelectionBox.Visible then d.SelectionBox.Visible = false end
        end
    end

    -- 3. NATIVE BILLBOARDGUI (Name, Distance, Health, Inventory - Zero frame drop updates)
    if d.Billboard then
        local showGui = Config.ESP.Names or Config.ESP.Distance or Config.ESP.HealthBar or Config.InventoryESP.Enabled
        if showGui then
            local adorneePart = head or root
            if d.Billboard.Parent ~= char then d.Billboard.Parent = char end
            if d.Billboard.Adornee ~= adorneePart then d.Billboard.Adornee = adorneePart end
            d.Billboard.MaxDistance = math.huge
            if not d.Billboard.Enabled then d.Billboard.Enabled = true end

            -- Name & Distance
            if d.NameLabel then
                if Config.ESP.Names or Config.ESP.Distance then
                    local roundedDist = mFloor(dist)
                    if d._lastDist ~= roundedDist or not d._nameSet then
                        d._lastDist = roundedDist
                        d._nameSet = true
                        local txt = ""
                        if Config.ESP.Names then txt = player.DisplayName end
                        if Config.ESP.Distance then
                            txt = txt .. (txt ~= "" and " " or "") .. "[" .. roundedDist .. "m]"
                        end
                        d.NameLabel.Text = txt
                    end
                    if d._lastTextColor ~= Config.ESP.NameColor then
                        d._lastTextColor = Config.ESP.NameColor
                        d.NameLabel.TextColor3 = Config.ESP.NameColor
                    end
                    d.NameLabel.TextSize = Config.ESP.NameSize
                    if not d.NameLabel.Visible then d.NameLabel.Visible = true end
                else
                    if d.NameLabel.Visible then d.NameLabel.Visible = false end
                end
            end

            -- Health Bar & Health Text
            if d.HealthBG and d.HealthFill then
                if Config.ESP.HealthBar then
                    local maxHp = (hum.MaxHealth and hum.MaxHealth > 0) and hum.MaxHealth or 100
                    local curHp = mClamp(hum.Health, 0, maxHp)
                    if d._lastCurHp ~= curHp or d._lastMaxHp ~= maxHp then
                        d._lastCurHp = curHp
                        d._lastMaxHp = maxHp
                        local pct = mClamp(curHp / maxHp, 0, 1)
                        d.HealthFill.Size = UDim2.new(pct, 0, 1, 0)
                        local hpColor = C3(mFloor((1 - pct) * 255), mFloor(pct * 255), 50)
                        d.HealthFill.BackgroundColor3 = hpColor
                        if d.HealthText then
                            d.HealthText.Text = mFloor(curHp) .. " HP"
                            d.HealthText.TextColor3 = hpColor
                        end
                    end
                    if not d.HealthBG.Visible then d.HealthBG.Visible = true end

                    if d.HealthText then
                        local showHp = Config.ESP.HealthText
                        if d.HealthText.Visible ~= showHp then
                            d.HealthText.Visible = showHp
                        end
                    end
                else
                    if d.HealthBG.Visible then d.HealthBG.Visible = false end
                    if d.HealthText and d.HealthText.Visible then d.HealthText.Visible = false end
                end
            end

                        -- Inventory ESP (RichText Colored Weapons by Rarity - Clean, 100% Readable, Zero Broken Images)
            if Config.InventoryESP.Enabled and d.InventoryLabel then
                local now = Tick()
                if not d._lastInvCheck or (now - d._lastInvCheck > 0.5) then
                    d._lastInvCheck = now
                    local formattedItems = {}
                    local itemCount = 0

                    -- Equipped weapon (always first with [E])
                    if Config.InventoryESP.ShowEquipped then
                        for _, c in ipairs(char:GetChildren()) do
                            if c:IsA("Tool") and itemCount < (Config.InventoryESP.MaxItems or 6) then
                                local details = Util.GetWeaponDetails(c, true)
                                if details and details.name then
                                    local r, g, b = math.floor(details.color.R * 255), math.floor(details.color.G * 255), math.floor(details.color.B * 255)
                                    local hex = string.format("#%02X%02X%02X", r, g, b)
                                    local dmgStr = (Config.InventoryESP.ShowDamage and details.damage) and (" [" .. details.damage .. " DMG]") or ""
                                    local str = "<font color=\"#ffbe14\">[E] </font><font color=\"" .. hex .. "\"><b>" .. details.name .. "</b></font>" .. dmgStr
                                    tInsert(formattedItems, str)
                                    itemCount = itemCount + 1
                                end
                            end
                        end
                    end

                    -- Backpack items with smart quantity grouping (e.g. Lockpick x3 instead of duplicates!)
                    if Config.InventoryESP.ShowBackpack then
                        local bp = player:FindFirstChild("Backpack")
                        if bp then
                            local bpCounts = {}
                            local bpOrder = {}
                            local bpDetails = {}

                            for _, c in ipairs(bp:GetChildren()) do
                                if c:IsA("Tool") and itemCount < (Config.InventoryESP.MaxItems or 6) then
                                    local details = Util.GetWeaponDetails(c, false)
                                    if details and details.name then
                                        local n = details.name
                                        if not bpCounts[n] then
                                            bpCounts[n] = 1
                                            tInsert(bpOrder, n)
                                            bpDetails[n] = details
                                        else
                                            bpCounts[n] = bpCounts[n] + 1
                                        end
                                        itemCount = itemCount + 1
                                    end
                                end
                            end

                            for _, n in ipairs(bpOrder) do
                                local count = bpCounts[n]
                                local details = bpDetails[n]
                                local r, g, b = math.floor(details.color.R * 255), math.floor(details.color.G * 255), math.floor(details.color.B * 255)
                                local hex = string.format("#%02X%02X%02X", r, g, b)
                                local qtyStr = (count > 1) and (" x" .. count) or ""
                                local dmgStr = (Config.InventoryESP.ShowDamage and details.damage) and (" [" .. details.damage .. "]") or ""
                                local str = "<font color=\"" .. hex .. "\">" .. details.name .. qtyStr .. "</font>" .. dmgStr
                                tInsert(formattedItems, str)
                            end
                        end
                    end

                    d._lastInvText = (#formattedItems > 0) and tConcat(formattedItems, "  |  ") or ""
                end

                local text = d._lastInvText or ""
                if #text > 0 then
                    if d.InventoryLabel.Text ~= text then
                        d.InventoryLabel.Text = text
                    end
                    d.InventoryLabel.TextSize = Config.InventoryESP.TextSize or 12
                    local yPos = (Config.ESP.HealthBar and (Config.ESP.HealthText and 38 or 26)) or (Config.ESP.Names and 16 or 2)
                    d.InventoryLabel.Position = UDim2.new(0, 0, 0, yPos)
                    d.InventoryLabel.Visible = true
                else
                    d.InventoryLabel.Visible = false
                end
            elseif d.InventoryLabel then
                d.InventoryLabel.Visible = false
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

function Aimbot.GetActiveMode()
    -- Check Strong Aim
    if Config.Aimbot.StrongEnabled then
        if Config.Aimbot.StrongMode == "Always" or (Config.Aimbot.StrongMode == "Toggle" and State.StrongAimToggled) or (Config.Aimbot.StrongMode == "Hold" and State.StrongAimHeld) then
            return "Strong"
        end
    end
    -- Check Soft Aim
    if Config.Aimbot.SoftEnabled then
        if Config.Aimbot.SoftMode == "Always" or (Config.Aimbot.SoftMode == "Toggle" and State.SoftAimToggled) or (Config.Aimbot.SoftMode == "Hold" and State.SoftAimHeld) then
            return "Soft"
        end
    end
    return nil
end

function Aimbot.IsActive()
    return Aimbot.GetActiveMode() ~= nil
end

function Aimbot.FindTarget(customFov, customPart)
    local maxFov = customFov or 180
    local targetBone = customPart or "Head"

    local best, bestVal = nil, mHuge
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local center = V2(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and Util.Alive(p) then
            if not (Config.Aimbot.TeamCheck and Util.IsTeam(p)) then
                local char = p.Character
                local part = char and char:FindFirstChild(targetBone)
                if not part and char then
                    part = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
                end

                if part then
                    local d3 = Util.D3(part.Position, cam.CFrame.Position)
                    if d3 <= 600 then
                        local vp, on = cam:WorldToViewportPoint(part.Position)
                        if on and vp.Z > 0 then
                            local sp = V2(vp.X, vp.Y)
                            local distToCrosshair = Util.D2(sp, center)

                            if distToCrosshair <= maxFov and distToCrosshair < bestVal then
                                if Config.Aimbot.WallCheck then
                                    if Util.Visible(cam.CFrame.Position, part.Position, p) then
                                        best = p; bestVal = distToCrosshair
                                    end
                                else
                                    best = p; bestVal = distToCrosshair
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

function Aimbot.Predict(part, plr)
    local targetPos = part.Position
    -- Calibrate head aim down to hit chin/face center
    if part.Name == "Head" then
        targetPos = targetPos - V3(0, 0.45, 0)
    end

    -- VEHICLE DETECTION: if player is sitting in car/seat, NEVER apply erratic physics prediction!
    local isSitting = false
    if plr and plr.Character then
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Sit then
            isSitting = true
        end
    end

    if isSitting then
        return targetPos
    end

    -- On foot: horizontal-only velocity prediction with strict 2.5 studs clamp (Zero sky tracking)
    local vel = V3(0,0,0)
    pcall(function() vel = part.AssemblyLinearVelocity end)
    if vel.Magnitude < 0.1 then pcall(function() vel = part.Velocity end) end

    local hVel = V3(vel.X, 0, vel.Z)
    if hVel.Magnitude > 30 then
        hVel = hVel.Unit * 30
    end

    local lead = hVel * (Config.Aimbot.PredictionMultiplier or 0.11)
    if lead.Magnitude > 2.5 then
        lead = lead.Unit * 2.5
    end

    return targetPos + lead
end

local _subPixelX = 0
local _subPixelY = 0

function Aimbot.AimAt(worldPos, smooth)
    if not HAS_MOUSEMOVEREL then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local vp, on = cam:WorldToViewportPoint(worldPos)
    if not on or vp.Z <= 0 then return end

    local vpSize = cam.ViewportSize
    local center = V2(vpSize.X / 2, vpSize.Y / 2)
    local delta = V2(vp.X, vp.Y) - center

    local nowTick = Tick()
    local dt = _lastAimTick and (nowTick - _lastAimTick) or (1/120)
    _lastAimTick = nowTick
    local fpsFactor = mClamp(dt / (1/60), 0.1, 2.0)

    local targetSmooth = math.max(smooth or 1.0, 1.0)
    if targetSmooth <= 1.05 then
        -- Strong Lock mode: 1:1 Instant lock onto target with zero lag
        local intX = math.floor(delta.X + 0.5)
        local intY = math.floor(delta.Y + 0.5)
        if intX ~= 0 or intY ~= 0 then
            mousemoverel(intX, intY)
        end
        _subPixelX = 0
        _subPixelY = 0
    else
        -- Soft Aim mode: buttery sub-pixel smoothed movement (no lost fractional pixels)
        local mx = (delta.X / targetSmooth) * fpsFactor
        local my = (delta.Y / targetSmooth) * fpsFactor

        local toMoveX = mx + _subPixelX
        local toMoveY = my + _subPixelY

        local intX = (toMoveX > 0) and math.floor(toMoveX + 0.5) or math.ceil(toMoveX - 0.5)
        local intY = (toMoveY > 0) and math.floor(toMoveY + 0.5) or math.ceil(toMoveY - 0.5)

        _subPixelX = toMoveX - intX
        _subPixelY = toMoveY - intY

        if intX ~= 0 or intY ~= 0 then
            mousemoverel(intX, intY)
        end
    end

    local sp = Util.W2S(worldPos)
    if TargetDot then TargetDot.Position = sp; TargetDot.Visible = true end
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
            local r = Workspace:Raycast(ray.Origin, ray.Direction * Config.Triggerbot.MaxDistance, _sharedRayParams)
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
    if not Config.Player.SpeedEnabled then return end
    pcall(function()
        if not LocalPlayer.Character then return end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Config.Player.WalkSpeed end
    end)
end

function PlayerMods.UpdateJump()
    if not Config.Player.JumpEnabled then return end
    pcall(function()
        if not LocalPlayer.Character then return end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
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
                    if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
                        pcall(function()
                            UserInputService.MouseIconEnabled = true
                            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                        end)
                    end
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
        Scroll.CanvasSize = UDim2.new(0, 0, 0, 2400)
        Scroll.ScrollingEnabled = true
        Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
        Scroll.ElasticBehavior = Enum.ElasticBehavior.Never
        Scroll.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
        Scroll.Parent = ContentHolder

        local pLayout = Instance.new("UIListLayout")
        pLayout.Padding = UDim.new(0, 10)
        pLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pLayout.Parent = Scroll

        pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Scroll.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 60)
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
    -- 1. POPULATE ESP (PULITO, ESSENZIALE & CHAMS XENO)
    -- ──────────────────────────────────────────
    pcall(function()
        tESP:AddSection("✨ Chams (Highlight Attraverso i Muri - Xeno)")
        tESP:AddToggle("Enable Chams", Config.ESP.Chams, function(v)
            Config.ESP.Chams = v
            if not v then
                for _, d in pairs(State.ESPCache) do
                    if d.Highlight then d.Highlight.Enabled = false end
                end
            end
        end)
        tESP:AddSlider("Chams Transparency", 0.0, 1.0, Config.ESP.ChamsTransparency, "", 0.05, function(v)
            Config.ESP.ChamsTransparency = v
        end)
        tESP:AddColorPicker("Visible Color (In Vista)", Config.ESP.ChamsVisibleColor, function(v)
            Config.ESP.ChamsVisibleColor = v
        end)
        tESP:AddColorPicker("Hidden Color (Dietro i Muri)", Config.ESP.ChamsHiddenColor, function(v)
            Config.ESP.ChamsHiddenColor = v
        end)

        tESP:AddSection("📦 Box & Tracers")
        tESP:AddToggle("3D Box ESP", Config.ESP.Boxes, function(v) Config.ESP.Boxes = v end)
        tESP:AddToggle("Tracers (Linee al Bersaglio)", Config.ESP.Tracers, function(v) Config.ESP.Tracers = v end)

        tESP:AddSection("👤 Info Bersaglio (Nomi & Vita)")
        tESP:AddToggle("Show Names", Config.ESP.Names, function(v) Config.ESP.Names = v end)
        tESP:AddToggle("Show Distance [m]", Config.ESP.Distance, function(v) Config.ESP.Distance = v end)
        tESP:AddToggle("Health Bar", Config.ESP.HealthBar, function(v) Config.ESP.HealthBar = v end)
        tESP:AddToggle("Numeric HP", Config.ESP.HealthText, function(v) Config.ESP.HealthText = v end)

        tESP:AddSection("🦴 Scheletro")
        tESP:AddToggle("Enable Skeleton", Config.ESP.Skeleton, function(v) Config.ESP.Skeleton = v end)
        tESP:AddColorPicker("Skeleton Color", Config.ESP.SkeletonColor, function(v) Config.ESP.SkeletonColor = v end)

        tESP:AddSection("⚙️ Filtri & Distanza")
        tESP:AddToggle("Wall Check (Color Swap)", Config.ESP.VisibilityCheck, function(v) Config.ESP.VisibilityCheck = v end)
        tESP:AddToggle("Ignore Teammates", Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)
        tESP:AddSlider("Max Distance", 100, 2000, Config.ESP.MaxDistance, " studs", 50, function(v) Config.ESP.MaxDistance = v end)
    end)

    -- ──────────────────────────────────────────
    -- 2. POPULATE INVENTARIO
    -- ──────────────────────────────────────────
    pcall(function()
        tInv:AddSection("Inventory ESP")
        tInv:AddToggle("Enable Inventory ESP", Config.InventoryESP.Enabled, function(v) Config.InventoryESP.Enabled = v end)
        tInv:AddToggle("Show Equipped Weapon [E]", Config.InventoryESP.ShowEquipped, function(v) Config.InventoryESP.ShowEquipped = v end)
        tInv:AddToggle("Show Backpack Items", Config.InventoryESP.ShowBackpack, function(v) Config.InventoryESP.ShowBackpack = v end)
        tInv:AddToggle("Show Weapon Damage", Config.InventoryESP.ShowDamage, function(v) Config.InventoryESP.ShowDamage = v end)
        tInv:AddSlider("Font Size", 9, 18, Config.InventoryESP.TextSize, "pt", 1, function(v) Config.InventoryESP.TextSize = v end)
        tInv:AddSlider("Max Displayed Items", 1, 8, Config.InventoryESP.MaxItems, "", 1, function(v) Config.InventoryESP.MaxItems = v end)
    end)

    -- ──────────────────────────────────────────
    -- 3. POPULATE AIMBOT (CLEAN & POWERFUL DUAL ENGINE)
    -- ──────────────────────────────────────────
    pcall(function()
        tAim:AddSection("⚡ Strong Aimbot (Potente)")
        tAim:AddToggle("Enable Strong Aimbot", Config.Aimbot.StrongEnabled, function(v) Config.Aimbot.StrongEnabled = v end)
        tAim:AddDropdown("Activation Mode", {"Hold", "Always", "Toggle"}, Config.Aimbot.StrongMode, function(v) Config.Aimbot.StrongMode = v end)
        tAim:AddDropdown("Strong Keybind", safeKeybinds, Config.Aimbot.StrongKeyName, function(v)
            Config.Aimbot.StrongKeyName = v
            local bind = KeybindMap[v]
            if bind then
                Config.Aimbot.StrongKey = bind.Value
                Config.Aimbot.StrongKeyType = bind.Type
                Notify.Send("Strong Aim Key: " .. v, C3(255, 100, 100), 2)
            end
        end)
        tAim:AddDropdown("Target Bone", {"Head", "UpperTorso", "HumanoidRootPart"}, Config.Aimbot.StrongPart, function(v) Config.Aimbot.StrongPart = v end)
        tAim:AddSlider("FOV Radius", 30, 500, Config.Aimbot.StrongFOV, "px", 5, function(v) Config.Aimbot.StrongFOV = v end)

        tAim:AddSection("🎯 Soft Aim (Morbido / Regolabile)")
        tAim:AddToggle("Enable Soft Aim", Config.Aimbot.SoftEnabled, function(v) Config.Aimbot.SoftEnabled = v end)
        tAim:AddDropdown("Activation Mode", {"Hold", "Always", "Toggle"}, Config.Aimbot.SoftMode, function(v) Config.Aimbot.SoftMode = v end)
        tAim:AddDropdown("Soft Keybind", safeKeybinds, Config.Aimbot.SoftKeyName, function(v)
            Config.Aimbot.SoftKeyName = v
            local bind = KeybindMap[v]
            if bind then
                Config.Aimbot.SoftKey = bind.Value
                Config.Aimbot.SoftKeyType = bind.Type
                Notify.Send("Soft Aim Key: " .. v, C3(100, 255, 150), 2)
            end
        end)
        tAim:AddSlider("Smoothness", 1.5, 15, Config.Aimbot.SoftSmooth, "", 0.5, function(v) Config.Aimbot.SoftSmooth = v end)
        tAim:AddSlider("FOV Radius", 30, 400, Config.Aimbot.SoftFOV, "px", 5, function(v) Config.Aimbot.SoftFOV = v end)
        tAim:AddDropdown("Target Bone", {"Head", "UpperTorso", "HumanoidRootPart"}, Config.Aimbot.SoftPart, function(v) Config.Aimbot.SoftPart = v end)

        tAim:AddSection("🚗 Vehicle Fix & Target Settings")
        tAim:AddToggle("Vehicle & Glass Penetration", Config.Aimbot.VehiclePenetration, function(v) Config.Aimbot.VehiclePenetration = v end)
        tAim:AddToggle("Wall Check (Obstacles)", Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end)
        tAim:AddToggle("Ignore Teammates", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
        tAim:AddToggle("Show FOV Circle", Config.Aimbot.ShowFOV, function(v) Config.Aimbot.ShowFOV = v end)
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
        tSettings:AddSection("Performance & Framerate")
        tSettings:AddDropdown("FPS Cap / Unlocker", {"Uncapped (Max FPS)", "240 FPS", "144 FPS", "120 FPS", "60 FPS (Default)"}, "Uncapped (Max FPS)", function(v)
            if v == "Uncapped (Max FPS)" then
                setFPS(0)
                Notify.Send("Framerate Uncapped (Max FPS)", C3(0, 255, 255), 2)
            elseif v == "240 FPS" then
                setFPS(240)
                Notify.Send("Framerate set to 240 FPS", C3(0, 255, 180), 2)
            elseif v == "144 FPS" then
                setFPS(144)
                Notify.Send("Framerate set to 144 FPS", C3(0, 255, 180), 2)
            elseif v == "120 FPS" then
                setFPS(120)
                Notify.Send("Framerate set to 120 FPS", C3(0, 255, 180), 2)
            elseif v == "60 FPS (Default)" then
                setFPS(60)
                Notify.Send("Framerate set to 60 FPS", C3(200, 200, 200), 2)
            end
        end)

        tSettings:AddSection("💾 Config Management")
        tSettings:AddButton("💾 Save Configuration", "Salva tutte le impostazioni correnti", function()
            ConfigManager.Save()
        end)
        tSettings:AddButton("📂 Load Configuration", "Ricarica le impostazioni salvate", function()
            ConfigManager.Load()
        end)
        tSettings:AddButton("🔄 Reset Defaults", "Ripristina la configurazione predefinita", function()
            ConfigManager.Reset()
        end)

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
    pcall(function() ConfigManager.Load(true) end)
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

    -- Strong Aimbot Key
    if matchesBind(input, Config.Aimbot.StrongKey, Config.Aimbot.StrongKeyType) then
        if Config.Aimbot.StrongMode == "Toggle" then
            State.StrongAimToggled = not State.StrongAimToggled
            Notify.Send("Strong Aim: " .. (State.StrongAimToggled and "ON" or "OFF"), State.StrongAimToggled and C3(50, 255, 100) or C3(255, 50, 80), 1.5)
        else
            State.StrongAimHeld = true
        end
    end

    -- Soft Aim Key
    if matchesBind(input, Config.Aimbot.SoftKey, Config.Aimbot.SoftKeyType) then
        if Config.Aimbot.SoftMode == "Toggle" then
            State.SoftAimToggled = not State.SoftAimToggled
            Notify.Send("Soft Aim: " .. (State.SoftAimToggled and "ON" or "OFF"), State.SoftAimToggled and C3(50, 255, 100) or C3(255, 50, 80), 1.5)
        else
            State.SoftAimHeld = true
        end
    end

    -- Triggerbot (v3: custom keybind)
    if matchesBind(input, Config.Triggerbot.ActivationKey, Config.Triggerbot.ActivationKeyType) then
        State.TriggerbotHeld = true
    end
end

local function OnInputEnded(input, _)
    -- Strong Aim release
    if matchesBind(input, Config.Aimbot.StrongKey, Config.Aimbot.StrongKeyType) then
        State.StrongAimHeld = false
        if Config.Aimbot.StrongMode == "Hold" then
            State.CurrentTarget = nil
            if TargetDot then pcall(function() TargetDot.Visible = false end) end
        end
    end

    -- Soft Aim release
    if matchesBind(input, Config.Aimbot.SoftKey, Config.Aimbot.SoftKeyType) then
        State.SoftAimHeld = false
        if Config.Aimbot.SoftMode == "Hold" then
            State.CurrentTarget = nil
            if TargetDot then pcall(function() TargetDot.Visible = false end) end
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

    -- Aimbot FOV Circle (Adapts dynamically to active mode)
    if FOVCircle then
        local activeMode = Aimbot.GetActiveMode()
        local shouldShow = Config.Aimbot.ShowFOV and (Config.Aimbot.StrongEnabled or Config.Aimbot.SoftEnabled)
        if shouldShow then
            local activeRadius = Config.Aimbot.StrongFOV
            if activeMode == "Soft" or (Config.Aimbot.SoftEnabled and not Config.Aimbot.StrongEnabled) then
                activeRadius = Config.Aimbot.SoftFOV
            end
            FOVCircle.Position = Util.Center()
            FOVCircle.Radius = activeRadius
            FOVCircle.Color = Config.Aimbot.FOVColor
            FOVCircle.Transparency = Config.Aimbot.FOVTransparency
            FOVCircle.NumSides = 64
            FOVCircle.Thickness = 1
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

    -- Aimbot (Strong Lock & Soft Aim)
    local activeMode = Aimbot.GetActiveMode()
    if activeMode then
        local targetPart = (activeMode == "Strong") and Config.Aimbot.StrongPart or Config.Aimbot.SoftPart
        local targetFOV = (activeMode == "Strong") and Config.Aimbot.StrongFOV or Config.Aimbot.SoftFOV
        local smoothVal = (activeMode == "Strong") and (Config.Aimbot.StrongSmooth or 1.0) or (Config.Aimbot.SoftSmooth or 6.0)

        local target = Aimbot.FindTarget(targetFOV, targetPart)
        if target and target.Character then
            local part = target.Character:FindFirstChild(targetPart) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("UpperTorso")
            if part then
                local predictedPos = Aimbot.Predict(part, target)
                Aimbot.AimAt(predictedPos, smoothVal)
            end
        else
            if TargetDot then pcall(function() TargetDot.Visible = false end) end
        end
    else
        if TargetDot then pcall(function() TargetDot.Visible = false end) end
    end

    -- Triggerbot
    pcall(Triggerbot.Process)

    -- v3: Player mods per-frame
    PlayerMods.UpdateSpeed()
    PlayerMods.UpdateJump()
    PlayerMods.Noclip()
    PlayerMods.UpdateFly()

    -- v3: Kill tracking (Throttled to 10Hz to eliminate frame drops)
    local now = Tick()
    if not _lastKillCheck or (now - _lastKillCheck > 0.1) then
        _lastKillCheck = now
        pcall(trackKills)
    end

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

    setFPS(0)
    Notify.Send("PRV SERVICE v12.0 Uncapped FPS Loaded!", C3(56, 189, 248), 4)
    Notify.Send("Press K to open/close menu", C3(200, 200, 200), 5)
    Notify.Send("Settings > Save Configuration per salvare!", C3(0, 255, 180), 6)
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
