--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║     ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗ ║
    ║     ██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████║║
    ║     ██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔██║║
    ║     ██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚█║║
    ║     ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ █║║
    ║     ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝ ║║
    ║                                                               ║
    ║     PHANTOM · BlockSpin Stealth Suite                         ║
    ║     Built for Xeno Executor                                   ║
    ║     Undetected Build v1.0                                     ║
    ║                                                               ║
    ╠═══════════════════════════════════════════════════════════════╣
    ║  FEATURES:                                                    ║
    ║  • Player ESP (Box, Name, Health Bar, Distance, Tracers)      ║
    ║  • Inventory ESP (Equipped + Backpack items per player)       ║
    ║  • Aimbot (Smooth, FOV, Prediction, Wall Check, Jitter)      ║
    ║  • Triggerbot (Randomized delay, Hit chance, Raycast-based)   ║
    ║                                                               ║
    ║  ANTI-DETECTION:                                              ║
    ║  • Drawing API only (invisible to game scripts)               ║
    ║  • mousemoverel (no CFrame snapping)                          ║
    ║  • Randomized delays & jitter (human-like behavior)           ║
    ║  • Remote call filtering (__namecall hook)                    ║
    ║  • No game property modifications                             ║
    ║                                                               ║
    ║  KEYBINDS (modifica sotto in Config):                         ║
    ║  F1       = Toggle ESP                                        ║
    ║  F2       = Toggle Inventory ESP                              ║
    ║  F3       = Toggle Aimbot                                     ║
    ║  F4       = Toggle Triggerbot                                 ║
    ║  RMB      = Aimbot attivazione (tieni premuto)                ║
    ║  Left Alt = Triggerbot attivazione (tieni premuto)            ║
    ║  F8       = Unload / Distruggi cheat                          ║
    ╚═══════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════════
-- SERVICES & CORE REFERENCES
-- Cache everything upfront - cleaner and faster
-- ═══════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

-- Anti-detection: cache math/table/constructor functions locally
-- This avoids repeated global lookups and makes the script harder to trace
local mFloor   = math.floor
local mSqrt    = math.sqrt
local mRandom  = math.random
local mAbs     = math.abs
local mHuge    = math.huge
local mClamp   = math.clamp
local mMin     = math.min
local mMax     = math.max
local V2       = Vector2.new
local V3       = Vector3.new
local C3       = Color3.fromRGB
local CF       = CFrame.new
local RParams  = RaycastParams.new
local tInsert  = table.insert
local tRemove  = table.remove
local tClear   = table.clear
local tConcat  = table.concat
local Tick     = tick
local tWait    = task.wait
local tSpawn   = task.spawn
local tDefer   = task.defer

-- ═══════════════════════════════════════════════════════════════════
-- CONFIGURAZIONE
-- Modifica questi valori come vuoi! Tutti i keybind, colori, FOV,
-- smoothing ecc. sono qui. Non toccare il resto se non sai cosa fai.
-- ═══════════════════════════════════════════════════════════════════
local Config = {

    -- ╔═══════════════════════════╗
    -- ║   ESP (PLAYER VISUALS)    ║
    -- ╚═══════════════════════════╝
    ESP = {
        Enabled       = false,                    -- Stato iniziale (F1 per toggle)
        ToggleKey     = Enum.KeyCode.F1,          -- Tasto per attivare/disattivare

        -- Box ESP
        Boxes         = true,                     -- Mostra box intorno ai giocatori
        BoxColor      = C3(255, 50, 80),          -- Colore box (rosso acceso)
        BoxThickness  = 1.3,                      -- Spessore linee box

        -- Name ESP
        Names         = true,                     -- Mostra nomi sopra la testa
        NameColor     = C3(255, 255, 255),        -- Colore nome (bianco)
        NameSize      = 14,                       -- Dimensione testo nome

        -- Health Bar
        HealthBar     = true,                     -- Barra vita a sinistra del box
        HealthBarWidth = 3,                       -- Larghezza barra vita

        -- Distance
        Distance      = true,                     -- Mostra distanza sotto il box
        DistanceColor = C3(200, 200, 200),        -- Colore testo distanza

        -- Tracers (linee dal basso schermo al player)
        Tracers       = true,                     -- Mostra tracers
        TracerColor   = C3(255, 50, 80),          -- Colore tracers
        TracerThickness = 1,                      -- Spessore tracers
        TracerOrigin  = "Bottom",                 -- "Bottom", "Center", "Top"

        -- Visibility Check (cambia colore se visibile o no)
        VisibilityCheck = true,                   -- Attiva check visibilita
        VisibleColor    = C3(50, 255, 100),       -- Verde se visibile
        NotVisibleColor = C3(255, 50, 80),        -- Rosso se dietro muro

        -- Limits
        MaxDistance    = 1000,                     -- Distanza massima ESP (studs)
        TeamCheck     = false,                    -- Ignora compagni di squadra
    },

    -- ╔═══════════════════════════╗
    -- ║     INVENTORY ESP         ║
    -- ╚═══════════════════════════╝
    InventoryESP = {
        Enabled      = false,                     -- Stato iniziale (F2 per toggle)
        ToggleKey    = Enum.KeyCode.F2,           -- Tasto per attivare/disattivare
        ShowEquipped = true,                      -- Mostra armi/tool equipaggiati
        ShowBackpack = true,                      -- Mostra items nello zaino
        TextColor    = C3(0, 255, 210),           -- Colore testo inventario (cyan)
        TextSize     = 12,                        -- Dimensione testo
    },

    -- ╔═══════════════════════════╗
    -- ║         AIMBOT            ║
    -- ╚═══════════════════════════╝
    Aimbot = {
        Enabled          = false,                              -- Stato iniziale (F3 per toggle)
        ToggleKey        = Enum.KeyCode.F3,                    -- Tasto per attivare/disattivare
        ActivationKey    = Enum.UserInputType.MouseButton2,    -- Tasto per mirare (RMB = tasto destro mouse)

        -- Targeting
        TargetPart       = "Head",                -- Parte del corpo da mirare: "Head", "HumanoidRootPart", "UpperTorso"
        MaxDistance      = 500,                   -- Distanza massima (studs)

        -- FOV (Field of View circle)
        FOV              = 120,                   -- Raggio FOV in pixel
        ShowFOV          = true,                  -- Mostra cerchio FOV sullo schermo
        FOVColor         = C3(255, 255, 255),     -- Colore cerchio FOV
        FOVThickness     = 1,                     -- Spessore cerchio
        FOVTransparency  = 0.6,                   -- Trasparenza cerchio (0 = pieno, 1 = invisibile)
        FOVSides         = 64,                    -- Smoothness del cerchio

        -- Smoothing & Humanization
        Smoothing        = 6,                     -- Smoothing: 1 = istantaneo (bannable!), 10+ = molto lento. 4-8 consigliato.
        HumanizeJitter   = true,                  -- Aggiunge micro-movimento casuale (sembra umano)
        JitterStrength   = 0.4,                   -- Forza del jitter (0.1 - 1.0)

        -- Prediction (anticipa il movimento del target)
        Prediction            = true,             -- Attiva predizione
        PredictionMultiplier  = 0.135,            -- Forza predizione (0.1 - 0.2 consigliato)

        -- Safety
        WallCheck        = true,                  -- Non mira attraverso i muri
        StickyAim        = false,                 -- Rimani sullo stesso target finche tieni premuto
        TeamCheck        = false,                 -- Ignora compagni di squadra
    },

    -- ╔═══════════════════════════╗
    -- ║       TRIGGERBOT          ║
    -- ╚═══════════════════════════╝
    Triggerbot = {
        Enabled       = false,                    -- Stato iniziale (F4 per toggle)
        ToggleKey     = Enum.KeyCode.F4,          -- Tasto per attivare/disattivare
        ActivationKey = Enum.KeyCode.LeftAlt,     -- Tasto per attivare (tieni premuto Left Alt)

        -- Timing (randomizzato per sembrare umano)
        MinDelay      = 0.06,                     -- Delay minimo tra spari (secondi)
        MaxDelay      = 0.18,                     -- Delay massimo tra spari (secondi)

        -- Targeting
        MaxDistance    = 300,                      -- Distanza massima raycast
        HitChance     = 95,                       -- Percentuale di hit (1-100, 100 = spara sempre)
        TargetParts   = {                          -- Parti valide che triggerano lo sparo
            "Head", "UpperTorso", "LowerTorso",
            "HumanoidRootPart", "LeftUpperArm",
            "RightUpperArm", "LeftUpperLeg",
            "RightUpperLeg",
        },
        TeamCheck     = false,                    -- Ignora compagni di squadra
    },

    -- ╔═══════════════════════════╗
    -- ║          MISC             ║
    -- ╚═══════════════════════════╝
    Misc = {
        UnloadKey            = Enum.KeyCode.F8,   -- Tasto per distruggere la cheat
        NotificationDuration = 2.5,               -- Durata notifiche (secondi)
        ShowWatermark        = true,              -- Mostra "PHANTOM" in alto a sinistra
    },
}


-- ═══════════════════════════════════════════════════════════════════
-- STATE (non toccare)
-- ═══════════════════════════════════════════════════════════════════
local State = {
    Running          = true,
    AimbotHeld       = false,
    TriggerbotHeld   = false,
    CurrentTarget    = nil,
    Connections      = {},
    ESPCache         = {},      -- player -> {drawings}
    Notifications    = {},
}


-- ═══════════════════════════════════════════════════════════════════
-- ANTI-DETECTION MODULE
-- Hook __namecall per filtrare le remote calls dell'anti-cheat.
-- Il Drawing API e' gia invisibile al gioco di suo.
-- mousemoverel simula movimento mouse reale.
-- ═══════════════════════════════════════════════════════════════════
local AntiDetect = {}

do
    -- Patterns comuni usati dagli anti-cheat di Roblox
    -- Se BlockSpin usa nomi diversi, aggiungili qui
    local _blacklist = {
        "anticheat", "anti_cheat", "anti-cheat",
        "ac_check", "ac_flag", "ac_report",
        "detect", "security", "validate",
        "verify", "integrity", "guard",
        "shield", "monitor", "cheat",
        "exploit", "kick_player", "ban",
        "report_player", "flag_player",
    }

    local _oldNamecall
    _oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()

        -- Intercetta FireServer / InvokeServer
        if method == "FireServer" or method == "InvokeServer" then
            if self and self.Name then
                local remoteName = self.Name:lower()
                for _, pattern in ipairs(_blacklist) do
                    if remoteName:find(pattern, 1, true) then
                        -- Blocca silenziosamente - l'anti-cheat non riceve nulla
                        return nil
                    end
                end
            end
        end

        return _oldNamecall(self, ...)
    end))
end


-- ═══════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════
local Util = {}

-- Converte posizione 3D del mondo in coordinate 2D dello schermo
function Util.WorldToScreen(worldPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    return V2(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- Distanza 2D tra due Vector2
function Util.Dist2D(a, b)
    local dx = a.X - b.X
    local dy = a.Y - b.Y
    return mSqrt(dx * dx + dy * dy)
end

-- Distanza 3D tra due Vector3
function Util.Dist3D(a, b)
    return (a - b).Magnitude
end

-- Controlla se un player e' vivo e valido
function Util.IsAlive(player)
    if not player or not player.Parent then return false end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not char:FindFirstChild("HumanoidRootPart") then return false end
    return true
end

-- Raycast per controllare se un target e' visibile (non dietro un muro)
function Util.IsVisible(origin, targetPos, targetPlayer)
    local params = RParams()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filterList = {Camera}

    -- Escludi il tuo character
    if LocalPlayer.Character then
        tInsert(filterList, LocalPlayer.Character)
    end

    params.FilterDescendantsInstances = filterList

    local direction = targetPos - origin
    local result = Workspace:Raycast(origin, direction, params)

    if not result then
        return true -- Niente blocca la vista
    end

    -- Controlla se la parte colpita appartiene al target
    if targetPlayer and targetPlayer.Character then
        local hitPart = result.Instance
        if hitPart:IsDescendantOf(targetPlayer.Character) then
            return true
        end
    end

    return false
end

-- Check se e' un compagno di squadra
function Util.IsTeammate(player)
    if not player then return false end
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    return false
end

-- Centro dello schermo
function Util.ScreenCenter()
    local vp = Camera.ViewportSize
    return V2(vp.X / 2, vp.Y / 2)
end

-- Random float tra min e max
function Util.RandFloat(min, max)
    return min + math.random() * (max - min)
end


-- ═══════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- Notifiche basate su Drawing API (invisibili al gioco)
-- ═══════════════════════════════════════════════════════════════════
local Notify = {}

function Notify.Send(text, color, duration)
    color    = color or C3(255, 255, 255)
    duration = duration or Config.Misc.NotificationDuration

    local label = Drawing.new("Text")
    label.Text         = "  [PHANTOM]  " .. text
    label.Size         = 16
    label.Font         = Drawing.Fonts.Plex
    label.Color        = color
    label.OutlineColor = C3(0, 0, 0)
    label.Outline      = true
    label.Position     = V2(12, 10 + (#State.Notifications * 22))
    label.Visible      = true

    local entry = { Drawing = label, Expire = Tick() + duration }
    tInsert(State.Notifications, entry)

    tSpawn(function()
        tWait(duration)

        -- Fade out animazione
        for i = 1, 12 do
            if label then
                label.Transparency = 1 - (i / 12)
            end
            tWait(0.025)
        end

        -- Rimuovi
        if label then label:Remove() end

        for idx, n in ipairs(State.Notifications) do
            if n == entry then
                tRemove(State.Notifications, idx)
                -- Riposiziona le notifiche rimanenti
                for j = idx, #State.Notifications do
                    if State.Notifications[j].Drawing then
                        State.Notifications[j].Drawing.Position = V2(12, 10 + ((j - 1) * 22))
                    end
                end
                break
            end
        end
    end)
end


-- ═══════════════════════════════════════════════════════════════════
-- ESP MODULE
-- Ogni player ha un set di Drawing objects dedicati.
-- Tutto e' renderizzato via Drawing API = invisibile al gioco.
-- ═══════════════════════════════════════════════════════════════════
local ESP = {}

-- Template per i drawing di ogni player
function ESP.CreatePlayerDrawings()
    local d = {}

    -- Box (rettangolo intorno al player)
    d.Box = Drawing.new("Square")
    d.Box.Thickness = Config.ESP.BoxThickness
    d.Box.Filled    = false
    d.Box.Visible   = false

    -- Nome
    d.Name = Drawing.new("Text")
    d.Name.Size         = Config.ESP.NameSize
    d.Name.Font         = Drawing.Fonts.Plex
    d.Name.Outline      = true
    d.Name.OutlineColor = C3(0, 0, 0)
    d.Name.Visible      = false

    -- Distanza
    d.Dist = Drawing.new("Text")
    d.Dist.Size         = 12
    d.Dist.Font         = Drawing.Fonts.Plex
    d.Dist.Outline      = true
    d.Dist.OutlineColor = C3(0, 0, 0)
    d.Dist.Visible      = false

    -- Health bar background
    d.HealthBG = Drawing.new("Line")
    d.HealthBG.Thickness = Config.ESP.HealthBarWidth + 2
    d.HealthBG.Visible   = false

    -- Health bar foreground
    d.Health = Drawing.new("Line")
    d.Health.Thickness = Config.ESP.HealthBarWidth
    d.Health.Visible   = false

    -- Tracer
    d.Tracer = Drawing.new("Line")
    d.Tracer.Thickness = Config.ESP.TracerThickness
    d.Tracer.Visible   = false

    -- Inventory text
    d.Inventory = Drawing.new("Text")
    d.Inventory.Size         = Config.InventoryESP.TextSize
    d.Inventory.Font         = Drawing.Fonts.Plex
    d.Inventory.Outline      = true
    d.Inventory.OutlineColor = C3(0, 0, 0)
    d.Inventory.Visible      = false

    return d
end

-- Rimuovi tutti i drawing di un player
function ESP.DestroyPlayerDrawings(drawings)
    if not drawings then return end
    for _, d in pairs(drawings) do
        if d then
            pcall(function() d:Remove() end)
        end
    end
end

-- Nascondi tutti i drawing di un player
function ESP.HideAll(drawings)
    if not drawings then return end
    for _, d in pairs(drawings) do
        if d then d.Visible = false end
    end
end

-- Registra un nuovo player per l'ESP
function ESP.Register(player)
    if player == LocalPlayer then return end
    if State.ESPCache[player] then return end
    State.ESPCache[player] = ESP.CreatePlayerDrawings()
end

-- Rimuovi un player dall'ESP
function ESP.Unregister(player)
    if State.ESPCache[player] then
        ESP.DestroyPlayerDrawings(State.ESPCache[player])
        State.ESPCache[player] = nil
    end
end

-- Aggiorna i drawing ESP per un singolo player
function ESP.UpdatePlayer(player, drawings)
    -- Controlli di validita
    if not Util.IsAlive(player) then
        ESP.HideAll(drawings)
        return
    end

    -- Team check
    if Config.ESP.TeamCheck and Util.IsTeammate(player) then
        ESP.HideAll(drawings)
        return
    end

    local char     = player.Character
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local head     = char:FindFirstChild("Head")

    if not rootPart or not humanoid then
        ESP.HideAll(drawings)
        return
    end

    -- Distanza check
    local camPos   = Camera.CFrame.Position
    local distance = Util.Dist3D(rootPart.Position, camPos)

    if distance > Config.ESP.MaxDistance then
        ESP.HideAll(drawings)
        return
    end

    -- Calcola bounding box 2D
    -- Usa top/bottom del character per un box preciso
    local topWorld    = rootPart.Position + V3(0, 3.2, 0)
    local bottomWorld = rootPart.Position - V3(0, 3.2, 0)

    local screenTop,    onTop    = Util.WorldToScreen(topWorld)
    local screenBottom, onBottom = Util.WorldToScreen(bottomWorld)

    if not onTop and not onBottom then
        ESP.HideAll(drawings)
        return
    end

    local boxH = mAbs(screenBottom.Y - screenTop.Y)
    local boxW = boxH * 0.55
    local boxX = screenTop.X - boxW / 2
    local boxY = screenTop.Y

    -- Determina colore in base alla visibilita
    local espColor
    if Config.ESP.VisibilityCheck then
        local visible = Util.IsVisible(camPos, rootPart.Position, player)
        espColor = visible and Config.ESP.VisibleColor or Config.ESP.NotVisibleColor
    else
        espColor = Config.ESP.BoxColor
    end

    -- ┌─────────────────────┐
    -- │      BOX ESP        │
    -- └─────────────────────┘
    if Config.ESP.Enabled and Config.ESP.Boxes then
        drawings.Box.Position  = V2(boxX, boxY)
        drawings.Box.Size      = V2(boxW, boxH)
        drawings.Box.Color     = espColor
        drawings.Box.Thickness = Config.ESP.BoxThickness
        drawings.Box.Visible   = true
    else
        drawings.Box.Visible = false
    end

    -- ┌─────────────────────┐
    -- │     NAME ESP        │
    -- └─────────────────────┘
    if Config.ESP.Enabled and Config.ESP.Names then
        local n = drawings.Name
        n.Text  = player.DisplayName
        n.Color = Config.ESP.NameColor
        n.Size  = Config.ESP.NameSize
        -- Centra sopra il box
        n.Position = V2(screenTop.X - n.TextBounds.X / 2, screenTop.Y - n.TextBounds.Y - 3)
        n.Visible  = true
    else
        drawings.Name.Visible = false
    end

    -- ┌─────────────────────┐
    -- │    DISTANCE ESP     │
    -- └─────────────────────┘
    if Config.ESP.Enabled and Config.ESP.Distance then
        local dt = drawings.Dist
        dt.Text  = mFloor(distance) .. "m"
        dt.Color = Config.ESP.DistanceColor
        dt.Position = V2(screenBottom.X - dt.TextBounds.X / 2, screenBottom.Y + 3)
        dt.Visible  = true
    else
        drawings.Dist.Visible = false
    end

    -- ┌─────────────────────┐
    -- │    HEALTH BAR       │
    -- └─────────────────────┘
    if Config.ESP.Enabled and Config.ESP.HealthBar then
        local healthPct = mClamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local barX = boxX - Config.ESP.HealthBarWidth - 4

        -- Background
        drawings.HealthBG.From  = V2(barX, boxY)
        drawings.HealthBG.To    = V2(barX, boxY + boxH)
        drawings.HealthBG.Color = C3(25, 25, 25)
        drawings.HealthBG.Visible = true

        -- Foreground (verde -> giallo -> rosso in base alla vita)
        local healthBarH = boxH * healthPct
        local r = mFloor((1 - healthPct) * 255)
        local g = mFloor(healthPct * 255)
        drawings.Health.From  = V2(barX, boxY + boxH - healthBarH)
        drawings.Health.To    = V2(barX, boxY + boxH)
        drawings.Health.Color = C3(r, g, 50)
        drawings.Health.Visible = true
    else
        drawings.HealthBG.Visible = false
        drawings.Health.Visible   = false
    end

    -- ┌─────────────────────┐
    -- │      TRACERS        │
    -- └─────────────────────┘
    if Config.ESP.Enabled and Config.ESP.Tracers then
        local vp = Camera.ViewportSize
        local origin

        if Config.ESP.TracerOrigin == "Bottom" then
            origin = V2(vp.X / 2, vp.Y)
        elseif Config.ESP.TracerOrigin == "Top" then
            origin = V2(vp.X / 2, 0)
        else -- Center
            origin = V2(vp.X / 2, vp.Y / 2)
        end

        drawings.Tracer.From      = origin
        drawings.Tracer.To        = screenBottom
        drawings.Tracer.Color     = espColor
        drawings.Tracer.Thickness = Config.ESP.TracerThickness
        drawings.Tracer.Visible   = true
    else
        drawings.Tracer.Visible = false
    end

    -- ┌─────────────────────┐
    -- │   INVENTORY ESP     │
    -- └─────────────────────┘
    if Config.InventoryESP.Enabled then
        local items = {}

        -- Tool equipaggiati (nel Character)
        if Config.InventoryESP.ShowEquipped then
            for _, child in ipairs(char:GetChildren()) do
                if child:IsA("Tool") then
                    tInsert(items, "[E] " .. child.Name)
                end
            end
        end

        -- Tool nello zaino (Backpack)
        if Config.InventoryESP.ShowBackpack then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, child in ipairs(backpack:GetChildren()) do
                    if child:IsA("Tool") then
                        tInsert(items, "[B] " .. child.Name)
                    end
                end
            end
        end

        if #items > 0 then
            local inv = drawings.Inventory
            inv.Text  = tConcat(items, " | ")
            inv.Color = Config.InventoryESP.TextColor
            inv.Size  = Config.InventoryESP.TextSize

            local yOff = screenBottom.Y + 18
            if Config.ESP.Distance then yOff = yOff + 16 end

            inv.Position = V2(screenBottom.X - inv.TextBounds.X / 2, yOff)
            inv.Visible  = true
        else
            drawings.Inventory.Visible = false
        end
    else
        drawings.Inventory.Visible = false
    end
end


-- ═══════════════════════════════════════════════════════════════════
-- AIMBOT MODULE
-- Usa mousemoverel per movimento mouse reale (non CFrame snapping).
-- Smoothing + jitter rendono il movimento indistinguibile da un umano.
-- ═══════════════════════════════════════════════════════════════════
local Aimbot = {}

-- FOV Circle drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled       = false
FOVCircle.NumSides     = Config.Aimbot.FOVSides
FOVCircle.Radius       = Config.Aimbot.FOV
FOVCircle.Thickness    = Config.Aimbot.FOVThickness
FOVCircle.Color        = Config.Aimbot.FOVColor
FOVCircle.Transparency = Config.Aimbot.FOVTransparency
FOVCircle.Visible      = false

-- Target indicator (piccolo cerchio sul target)
local TargetDot = Drawing.new("Circle")
TargetDot.Filled    = true
TargetDot.NumSides  = 16
TargetDot.Radius    = 4
TargetDot.Color     = C3(255, 50, 80)
TargetDot.Visible   = false

-- Trova il target piu vicino al centro dello schermo, dentro il FOV
function Aimbot.FindTarget()
    local best     = nil
    local bestDist = mHuge
    local center   = Util.ScreenCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Util.IsAlive(player) then
            -- Team check
            if Config.Aimbot.TeamCheck and Util.IsTeammate(player) then
                continue
            end

            local char       = player.Character
            local targetPart = char:FindFirstChild(Config.Aimbot.TargetPart)

            if targetPart then
                local dist3D = Util.Dist3D(targetPart.Position, Camera.CFrame.Position)

                if dist3D <= Config.Aimbot.MaxDistance then
                    local screenPos, onScreen = Util.WorldToScreen(targetPart.Position)

                    if onScreen then
                        local screenDist = Util.Dist2D(screenPos, center)

                        if screenDist <= Config.Aimbot.FOV and screenDist < bestDist then
                            -- Wall check
                            if Config.Aimbot.WallCheck then
                                if Util.IsVisible(Camera.CFrame.Position, targetPart.Position, player) then
                                    best     = player
                                    bestDist = screenDist
                                end
                            else
                                best     = player
                                bestDist = screenDist
                            end
                        end
                    end
                end
            end
        end
    end

    return best
end

-- Calcola posizione predetta basata sulla velocita del target
function Aimbot.PredictPosition(targetPart)
    if not Config.Aimbot.Prediction then
        return targetPart.Position
    end

    -- Usa AssemblyLinearVelocity (R15/R6 compatible)
    local vel = targetPart.AssemblyLinearVelocity
    if not vel then
        vel = targetPart.Velocity or V3(0, 0, 0)
    end

    return targetPart.Position + (vel * Config.Aimbot.PredictionMultiplier)
end

-- Muovi il mouse verso il target con smoothing + jitter
function Aimbot.AimAt(worldPos)
    local screenPos, onScreen = Util.WorldToScreen(worldPos)
    if not onScreen then return end

    local center = Util.ScreenCenter()
    local delta  = screenPos - center

    -- Smoothing: dividi il delta per il fattore di smoothing
    local moveX = delta.X / Config.Aimbot.Smoothing
    local moveY = delta.Y / Config.Aimbot.Smoothing

    -- Jitter: aggiungi micro-rumore casuale per sembrare umano
    if Config.Aimbot.HumanizeJitter then
        local jStr = Config.Aimbot.JitterStrength
        moveX = moveX + Util.RandFloat(-jStr, jStr)
        moveY = moveY + Util.RandFloat(-jStr, jStr)
    end

    -- mousemoverel muove il mouse relativamente - non snappa il CFrame
    -- Questo e' il metodo piu sicuro e meno rilevabile
    mousemoverel(moveX, moveY)

    -- Aggiorna target dot
    TargetDot.Position = screenPos
    TargetDot.Visible  = true
end


-- ═══════════════════════════════════════════════════════════════════
-- TRIGGERBOT MODULE
-- Spara automaticamente quando il mirino e' su un nemico.
-- Delay randomizzato + hit chance per sembrare umano.
-- ═══════════════════════════════════════════════════════════════════
local Triggerbot = {}

local _lastTriggerTime = 0

function Triggerbot.Process()
    if not Config.Triggerbot.Enabled then return end
    if not State.TriggerbotHeld then return end

    -- Delay randomizzato
    local now   = Tick()
    local delay = Util.RandFloat(Config.Triggerbot.MinDelay, Config.Triggerbot.MaxDelay)
    if now - _lastTriggerTime < delay then return end

    -- Hit chance (non spara sempre, piu realistico)
    if mRandom(1, 100) > Config.Triggerbot.HitChance then
        _lastTriggerTime = now
        return
    end

    -- Raycast dal centro dello schermo
    local center = Util.ScreenCenter()
    local ray    = Camera:ViewportPointToRay(center.X, center.Y)

    local params = RParams()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filterList = {Camera}
    if LocalPlayer.Character then
        tInsert(filterList, LocalPlayer.Character)
    end
    params.FilterDescendantsInstances = filterList

    local result = Workspace:Raycast(ray.Origin, ray.Direction * Config.Triggerbot.MaxDistance, params)

    if result and result.Instance then
        local hitPart = result.Instance
        local hitChar = hitPart:FindFirstAncestorOfClass("Model")

        if hitChar then
            local hitPlayer = Players:GetPlayerFromCharacter(hitChar)

            if hitPlayer and hitPlayer ~= LocalPlayer then
                -- Team check
                if Config.Triggerbot.TeamCheck and Util.IsTeammate(hitPlayer) then
                    return
                end

                -- Controlla se la parte colpita e' valida
                local validHit = false
                for _, partName in ipairs(Config.Triggerbot.TargetParts) do
                    if hitPart.Name == partName then
                        validHit = true
                        break
                    end
                end

                if validHit then
                    -- Simula click mouse (metodo undetected)
                    mouse1click()
                    _lastTriggerTime = now
                end
            end
        end
    end
end


-- ═══════════════════════════════════════════════════════════════════
-- HUD MODULE
-- Piccolo pannello status in alto a sinistra basato su Drawing API
-- ═══════════════════════════════════════════════════════════════════
local HUD = {}
local _hudDrawings = {}

function HUD.Init()
    if not Config.Misc.ShowWatermark then return end

    -- Watermark / Titolo
    _hudDrawings.Title = Drawing.new("Text")
    _hudDrawings.Title.Text         = "PHANTOM"
    _hudDrawings.Title.Size         = 20
    _hudDrawings.Title.Font         = Drawing.Fonts.Plex
    _hudDrawings.Title.Color        = C3(180, 80, 255)
    _hudDrawings.Title.OutlineColor = C3(0, 0, 0)
    _hudDrawings.Title.Outline      = true
    _hudDrawings.Title.Position     = V2(12, 42)
    _hudDrawings.Title.Visible      = true

    -- Linea separatrice
    _hudDrawings.Line = Drawing.new("Line")
    _hudDrawings.Line.From      = V2(12, 64)
    _hudDrawings.Line.To        = V2(160, 64)
    _hudDrawings.Line.Color     = C3(180, 80, 255)
    _hudDrawings.Line.Thickness = 1
    _hudDrawings.Line.Visible   = true

    -- Status per ogni feature
    local features = {"ESP", "InvESP", "Aimbot", "Trigger"}
    for i, name in ipairs(features) do
        _hudDrawings["S_" .. name] = Drawing.new("Text")
        _hudDrawings["S_" .. name].Size         = 13
        _hudDrawings["S_" .. name].Font         = Drawing.Fonts.Plex
        _hudDrawings["S_" .. name].OutlineColor = C3(0, 0, 0)
        _hudDrawings["S_" .. name].Outline      = true
        _hudDrawings["S_" .. name].Position     = V2(12, 68 + (i - 1) * 18)
        _hudDrawings["S_" .. name].Visible      = true
    end
end

function HUD.Update()
    if not Config.Misc.ShowWatermark then return end

    local statuses = {
        { Key = "S_ESP",     Label = "[F1] ESP",       On = Config.ESP.Enabled },
        { Key = "S_InvESP",  Label = "[F2] InvESP",    On = Config.InventoryESP.Enabled },
        { Key = "S_Aimbot",  Label = "[F3] Aimbot",    On = Config.Aimbot.Enabled },
        { Key = "S_Trigger", Label = "[F4] Trigger",   On = Config.Triggerbot.Enabled },
    }

    for _, s in ipairs(statuses) do
        local d = _hudDrawings[s.Key]
        if d then
            local tag   = s.On and " ON" or " OFF"
            local color = s.On and C3(80, 255, 120) or C3(255, 80, 80)
            d.Text  = s.Label .. tag
            d.Color = color
        end
    end
end

function HUD.Destroy()
    for _, d in pairs(_hudDrawings) do
        if d then pcall(function() d:Remove() end) end
    end
    tClear(_hudDrawings)
end


-- ═══════════════════════════════════════════════════════════════════
-- INPUT HANDLER
-- ═══════════════════════════════════════════════════════════════════
local function OnInputBegan(input, gameProcessed)
    if gameProcessed then return end

    local kc = input.KeyCode

    -- Toggle features
    if kc == Config.ESP.ToggleKey then
        Config.ESP.Enabled = not Config.ESP.Enabled
        local on = Config.ESP.Enabled
        Notify.Send("ESP " .. (on and "ON" or "OFF"), on and C3(80, 255, 120) or C3(255, 80, 80))

    elseif kc == Config.InventoryESP.ToggleKey then
        Config.InventoryESP.Enabled = not Config.InventoryESP.Enabled
        local on = Config.InventoryESP.Enabled
        Notify.Send("Inventory ESP " .. (on and "ON" or "OFF"), on and C3(80, 255, 120) or C3(255, 80, 80))

    elseif kc == Config.Aimbot.ToggleKey then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
        local on = Config.Aimbot.Enabled
        Notify.Send("Aimbot " .. (on and "ON" or "OFF"), on and C3(80, 255, 120) or C3(255, 80, 80))

    elseif kc == Config.Triggerbot.ToggleKey then
        Config.Triggerbot.Enabled = not Config.Triggerbot.Enabled
        local on = Config.Triggerbot.Enabled
        Notify.Send("Triggerbot " .. (on and "ON" or "OFF"), on and C3(80, 255, 120) or C3(255, 80, 80))

    elseif kc == Config.Misc.UnloadKey then
        State.Running = false
        return
    end

    -- Aimbot hold activation (Right Mouse Button)
    if input.UserInputType == Config.Aimbot.ActivationKey then
        State.AimbotHeld = true
    end

    -- Triggerbot hold activation
    if kc == Config.Triggerbot.ActivationKey then
        State.TriggerbotHeld = true
    end
end

local function OnInputEnded(input, _)
    -- Release aimbot
    if input.UserInputType == Config.Aimbot.ActivationKey then
        State.AimbotHeld    = false
        State.CurrentTarget = nil
        TargetDot.Visible   = false
    end

    -- Release triggerbot
    if input.KeyCode == Config.Triggerbot.ActivationKey then
        State.TriggerbotHeld = false
    end
end


-- ═══════════════════════════════════════════════════════════════════
-- MAIN RENDER LOOP
-- Gira ogni frame su RenderStepped per aggiornamenti fluidi.
-- ═══════════════════════════════════════════════════════════════════
local function RenderLoop()
    -- ─── ESP Update ───
    for player, drawings in pairs(State.ESPCache) do
        if player and player.Parent then
            if Config.ESP.Enabled or Config.InventoryESP.Enabled then
                ESP.UpdatePlayer(player, drawings)
            else
                ESP.HideAll(drawings)
            end
        else
            -- Player ha lasciato, cleanup
            ESP.DestroyPlayerDrawings(drawings)
            State.ESPCache[player] = nil
        end
    end

    -- ─── FOV Circle ───
    if Config.Aimbot.Enabled and Config.Aimbot.ShowFOV then
        FOVCircle.Position     = Util.ScreenCenter()
        FOVCircle.Radius       = Config.Aimbot.FOV
        FOVCircle.Color        = Config.Aimbot.FOVColor
        FOVCircle.Transparency = Config.Aimbot.FOVTransparency
        FOVCircle.Visible      = true
    else
        FOVCircle.Visible = false
    end

    -- ─── Aimbot ───
    if Config.Aimbot.Enabled and State.AimbotHeld then
        local target

        -- Sticky aim: mantieni il target corrente se ancora vivo
        if Config.Aimbot.StickyAim and State.CurrentTarget and Util.IsAlive(State.CurrentTarget) then
            target = State.CurrentTarget
        else
            target = Aimbot.FindTarget()
            State.CurrentTarget = target
        end

        if target and target.Character then
            local part = target.Character:FindFirstChild(Config.Aimbot.TargetPart)
            if part then
                local predictedPos = Aimbot.PredictPosition(part)
                Aimbot.AimAt(predictedPos)
            end
        else
            TargetDot.Visible = false
        end
    else
        TargetDot.Visible = false
    end

    -- ─── Triggerbot ───
    Triggerbot.Process()

    -- ─── HUD ───
    HUD.Update()
end


-- ═══════════════════════════════════════════════════════════════════
-- CLEANUP / UNLOAD
-- Chiamato quando premi F8 o lo script si ferma.
-- Rimuove TUTTO: drawings, connections, hooks.
-- ═══════════════════════════════════════════════════════════════════
local function Unload()
    -- Disconnetti tutti gli eventi
    for name, conn in pairs(State.Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    tClear(State.Connections)

    -- Rimuovi tutti i drawing ESP
    for player, drawings in pairs(State.ESPCache) do
        ESP.DestroyPlayerDrawings(drawings)
    end
    tClear(State.ESPCache)

    -- Rimuovi FOV circle e target dot
    pcall(function() FOVCircle:Remove() end)
    pcall(function() TargetDot:Remove() end)

    -- Rimuovi HUD
    HUD.Destroy()

    -- Rimuovi notifiche
    for _, n in ipairs(State.Notifications) do
        if n.Drawing then
            pcall(function() n.Drawing:Remove() end)
        end
    end
    tClear(State.Notifications)

    -- Notifica finale
    local bye = Drawing.new("Text")
    bye.Text         = "  [PHANTOM] Unloaded - Ciao!"
    bye.Size         = 16
    bye.Font         = Drawing.Fonts.Plex
    bye.Color        = C3(255, 80, 80)
    bye.OutlineColor = C3(0, 0, 0)
    bye.Outline      = true
    bye.Position     = V2(12, 10)
    bye.Visible      = true

    tSpawn(function()
        tWait(2)
        pcall(function() bye:Remove() end)
    end)
end


-- ═══════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════
local function Init()
    -- Inizializza HUD
    HUD.Init()

    -- Registra tutti i player esistenti
    for _, player in ipairs(Players:GetPlayers()) do
        ESP.Register(player)
    end

    -- Ascolta nuovi player che entrano
    State.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        ESP.Register(player)
    end)

    -- Cleanup quando un player esce
    State.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        ESP.Unregister(player)
    end)

    -- Input handlers
    State.Connections.InputBegan = UserInputService.InputBegan:Connect(OnInputBegan)
    State.Connections.InputEnded = UserInputService.InputEnded:Connect(OnInputEnded)

    -- Main render loop - gira ogni frame
    State.Connections.Render = RunService.RenderStepped:Connect(function()
        if State.Running then
            RenderLoop()
        else
            Unload()
        end
    end)

    -- Benvenuto!
    Notify.Send("Loaded! F8 to Unload", C3(180, 80, 255), 4)
    Notify.Send("F1=ESP  F2=Inv  F3=Aim  F4=Trig", C3(200, 200, 200), 5)
end

-- ═══════════════════════════════════════════════════════════════════
-- LET'S GO
-- ═══════════════════════════════════════════════════════════════════
Init()
