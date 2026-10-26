--[[
    Matcha Hub ESP | Dhab Hunt + Deira Locator
    Game: PlaceId 82347957379349 (Dhab Hunting)
    
    Features:
    - Auto-run on inject (No GUI buttons required)
    - Dhab ESP: Highlights, Billboard (Name/Dist), Red Tracers
    - Deira Locator: Glowing Beacon, Edge Arrow, Distance HUD
    - Optimized for Matcha Executor
    
    Controls:
    - F2: Toggle Dhab/NPC ESP
    - F3: Toggle Deira Beacon
]]

--=========================================================
--  SERVICES & CONSTANTS
--=========================================================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UIS        = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

--=========================================================
--  CONFIG
--=========================================================
local Config = {
    -- Dhab Hunt ESP
    Dhab = {
        Enabled          = true,
        ShowNPCs         = true,
        ShowPlayers      = false,
        TeamCheck        = true,
        ShowHighlight    = true,
        ShowName         = true,
        ShowDistance     = true,
        ShowTracers      = true,
        MaxDistance      = 5000,
        ScanInterval     = 0.5,
        TracerOriginY    = 0.92,
        Color            = Color3.fromRGB(255, 0, 0),
        HighlightFill    = Color3.fromRGB(255, 0, 0),
        TextColor        = Color3.fromRGB(255, 70, 70),
        TracerColor      = Color3.fromRGB(255, 0, 0),
        ToggleKey        = Enum.KeyCode.F2,
    },
    
    -- Deira Locator
    Deira = {
        Keywords         = { "ديره", "دير", "deira", "town", "village", "base", "home" },
        ShowBeam         = true,
        ShowHighlight    = true,
        ShowHUD          = true,
        ShowEdgeArrow    = true,
        BeamHeight       = 400,
        BeamSize         = 5,
        Color            = Color3.fromRGB(255, 0, 0),
        ScanInterval     = 1,
        ToggleKey        = Enum.KeyCode.F3,
    }
}

--=========================================================
--  UTILITY
--=========================================================
local function notify(title, msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = msg,
            Duration = 5
        })
    end)
end

local function getRoot(model)
    return model:FindFirstChild("HumanoidRootPart") 
        or model:FindFirstChild("UpperTorso") 
        or model:FindFirstChild("Torso") 
        or model.PrimaryPart
end

local function isAlive(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

--=========================================================
--  DHAB HUNT ESP LOGIC
--=========================================================
local dhabEspData = {} -- [model] = { visuals }

local function clearDhabVisuals(model)
    local data = dhabEspData[model]
    if not data then return end
    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end
    if data.tracer then data.tracer:Remove() end
    dhabEspData[model] = nil
end

local function createDhabVisuals(model)
    if dhabEspData[model] then return end
    local root = getRoot(model)
    if not root then return end

    local data = {}
    if Config.Dhab.ShowHighlight then
        local hl = Instance.new("Highlight")
        hl.FillColor = Config.Dhab.HighlightFill
        hl.OutlineColor = Config.Dhab.Color
        hl.FillTransparency = 0.55
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = model
        data.highlight = hl
    end

    if Config.Dhab.ShowName or Config.Dhab.ShowDistance then
        local bb = Instance.new("BillboardGui", root)
        bb.Name = "Matcha_BB"
        bb.Size = UDim2.new(0, 160, 0, 42)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        
        local lbl = Instance.new("TextLabel", bb)
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Config.Dhab.TextColor
        lbl.TextStrokeTransparency = 0
        lbl.Text = model.Name
        data.billboard = bb
        data.label = lbl
    end

    if Config.Dhab.ShowTracers and Drawing then
        local t = Drawing.new("Line")
        t.Thickness = 1.5
        t.Color = Config.Dhab.TracerColor
        t.Transparency = 0.8
        t.Visible = false
        data.tracer = t
    end

    dhabEspData[model] = data
end

local function scanDhab()
    local seen = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character and isAlive(obj) and getRoot(obj) then
            local player = Players:GetPlayerFromCharacter(obj)
            local valid = false
            if player then
                if Config.Dhab.ShowPlayers and not (Config.Dhab.TeamCheck and player.Team == LocalPlayer.Team) then
                    valid = true
                end
            elseif Config.Dhab.ShowNPCs then
                valid = true
            end
            
            if valid then
                seen[obj] = true
                createDhabVisuals(obj)
            end
        end
    end
    for model in pairs(dhabEspData) do
        if not seen[model] or not model.Parent or not isAlive(model) then
            clearDhabVisuals(model)
        end
    end
end

--=========================================================
--  DEIRA LOCATOR LOGIC
--=========================================================
local deiraTarget = nil
local deiraBeam   = nil
local deiraHL     = nil
local hudGui, hudLabel, arrow

local function buildDeiraHUD()
    if hudGui then return end
    hudGui = Instance.new("ScreenGui", (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"))
    hudGui.Name = "DeiraHUD"
    hudGui.ResetOnSpawn = false
    hudGui.IgnoreGuiInset = true
    
    hudLabel = Instance.new("TextLabel", hudGui)
    hudLabel.AnchorPoint = Vector2.new(0.5, 0)
    hudLabel.Position = UDim2.new(0.5, 0, 0, 15)
    hudLabel.Size = UDim2.new(0, 300, 0, 35)
    hudLabel.BackgroundTransparency = 0.5
    hudLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    hudLabel.TextColor3 = Color3.new(1, 0, 0)
    hudLabel.Font = Enum.Font.GothamBold
    hudLabel.TextSize = 16
    hudLabel.Visible = false
    
    arrow = Instance.new("TextLabel", hudGui)
    arrow.Size = UDim2.new(0, 40, 0, 40)
    arrow.BackgroundTransparency = 1
    arrow.Text = "➤"
    arrow.TextColor3 = Color3.new(1, 0, 0)
    arrow.TextSize = 35
    arrow.Visible = false
end

local function scanDeira()
    local best = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Parent then
            local name = obj.Name:lower()
            for _, kw in ipairs(Config.Deira.Keywords) do
                if name:find(kw:lower(), 1, true) then
                    best = obj
                    break
                end
            end
        end
        if best then break end
    end
    
    if best ~= deiraTarget then
        if deiraBeam then deiraBeam:Destroy() deiraBeam = nil end
        if deiraHL then deiraHL:Destroy() deiraHL = nil end
        deiraTarget = best
        if deiraTarget and Config.Deira.ShowHighlight then
            deiraHL = Instance.new("Highlight", deiraTarget)
            deiraHL.FillColor = Config.Deira.Color
            deiraHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end

--=========================================================
--  CORE LOOPS
--=========================================================
task.spawn(function()
    while task.wait(Config.Dhab.ScanInterval) do pcall(scanDhab) end
end)

task.spawn(function()
    while task.wait(Config.Deira.ScanInterval) do pcall(scanDeira) end
end)

RunService.RenderStepped:Connect(function()
    local cam = Workspace.CurrentCamera
    local viewport = cam.ViewportSize
    local myRoot = LocalPlayer.Character and getRoot(LocalPlayer.Character)
    
    -- Dhab Update
    if Config.Dhab.Enabled then
        for model, data in pairs(dhabEspData) do
            local root = getRoot(model)
            if root then
                local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
                local inRange = dist <= Config.Dhab.MaxDistance
                if data.billboard then 
                    data.billboard.Enabled = inRange
                    if data.label then data.label.Text = string.format("%s [%d]", model.Name, math.floor(dist)) end
                end
                if data.highlight then data.highlight.Enabled = inRange end
                if data.tracer then
                    local screenPos, onScreen = cam:WorldToViewportPoint(root.Position)
                    if inRange and onScreen then
                        data.tracer.From = Vector2.new(viewport.X / 2, viewport.Y * Config.Dhab.TracerOriginY)
                        data.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        data.tracer.Visible = true
                    else
                        data.tracer.Visible = false
                    end
                end
            end
        end
    end

    -- Deira Update
    if deiraTarget and deiraTarget.Parent then
        local pos = (deiraTarget:IsA("BasePart") and deiraTarget.Position) or deiraTarget:GetPivot().Position
        local dist = myRoot and (myRoot.Position - pos).Magnitude or 0
        
        -- Beam
        if Config.Deira.ShowBeam then
            if not deiraBeam then
                deiraBeam = Instance.new("Part", Workspace)
                deiraBeam.Anchored = true; deiraBeam.CanCollide = false; deiraBeam.Transparency = 0.5
                deiraBeam.Material = Enum.Material.Neon; deiraBeam.Color = Config.Deira.Color
                deiraBeam.Size = Vector3.new(Config.Deira.BeamSize, Config.Deira.BeamHeight, Config.Deira.BeamSize)
            end
            deiraBeam.Position = pos + Vector3.new(0, Config.Deira.BeamHeight/2, 0)
        end
        
        -- HUD & Arrow
        if Config.Deira.ShowHUD and hudLabel then
            hudLabel.Visible = true
            hudLabel.Text = string.format("DEIRA: %d studs", math.floor(dist))
        end
        
        if Config.Deira.ShowEdgeArrow and arrow then
            local screenPos, onScreen = cam:WorldToViewportPoint(pos)
            if onScreen then
                arrow.Visible = true
                arrow.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
                arrow.Rotation = 90
            else
                local center = Vector2.new(viewport.X/2, viewport.Y/2)
                local dir = (Vector2.new(screenPos.X, screenPos.Y) - center).Unit
                if screenPos.Z < 0 then dir = -dir end
                local radius = math.min(viewport.X, viewport.Y) / 2 - 50
                arrow.Visible = true
                arrow.Position = UDim2.fromOffset(center.X + dir.X * radius, center.Y + dir.Y * radius)
                arrow.Rotation = math.deg(math.atan2(dir.Y, dir.X))
            end
        end
    end
end)

--=========================================================
--  INPUT
--=========================================================
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.Dhab.ToggleKey then
        Config.Dhab.Enabled = not Config.Dhab.Enabled
        notify("Dhab ESP", Config.Dhab.Enabled and "Enabled" or "Disabled")
    elseif input.KeyCode == Config.Deira.ToggleKey then
        Config.Deira.ShowBeam = not Config.Deira.ShowBeam
        notify("Deira Beacon", Config.Deira.ShowBeam and "Enabled" or "Disabled")
    end
end)

buildDeiraHUD()
notify("Matcha Hub", "Loaded! F2: Dhab ESP | F3: Deira Beacon")
