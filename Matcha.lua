--[[
    Matcha Hub ESP | Dhab Hunt + Deira Locator (FIXED)
    Game: PlaceId 82347957379349 (Dhab Hunting)
    
    Controls:
    - F2: Toggle Dhab/NPC ESP
    - F3: Toggle Deira Beacon
]]

--=========================================================
--  SERVICES
--=========================================================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UIS        = game:GetService("UserInputService")

-- Wait for Player & Character
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.5)
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera

-- Safe Instance Creator (Fix for "index nil with new")
local function create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if properties.Parent then
        inst.Parent = properties.Parent
    end
    return inst
end

--=========================================================
--  CONFIG
--=========================================================
local Config = {
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
local DhabNames = {
    ["أبو الضبان"] = "Abu Al-Dhabban",
    ["أسطورة البر"] = "Desert Legend",
    ["الضب الألماسي"] = "Diamond Dhab",
    ["الضب الأزرق النادر"] = "Rare Blue Dhab",
    ["ضب التبر"] = "Gold Dhab",
    ["ضب الكهرمان"] = "Amber Dhab",
    ["ضب الياقوت"] = "Ruby Dhab",
    ["ضب البتر النادر"] = "Rare Batr Dhab",
    ["ضب الجلمود"] = "Boulder Dhab",
    ["ضب الحمى"] = "Fever Dhab",
    ["الضب الفيروزي"] = "Turquoise Dhab",
    ["الضب الصحراوي العادي"] = "Common Desert Dhab",
    ["الضب الأخضر"] = "Green Dhab",
    ["ضب الحزم"] = "Hazm Dhab",
    ["ضب الشيح"] = "Wormwood Dhab",
    ["ضب الغبار"] = "Dust Dhab",
    ["ضب الأرطى"] = "Arta Dhab",
    ["الضب النادر"] = "Rare Dhab",
    ["الضب الأزرق"] = "Blue Dhab",
    ["الضب الوردي"] = "Pink Dhab",
    ["الضب السريع"] = "Speed Dhab",
    ["الضب المخفي"] = "Hidden Dhab",
    ["الضب الصخري"] = "Rock Dhab",
    ["ضب الزمرد"] = "Emerald Dhab",
    ["الضب العملاق الأسطوري"] = "Legendary Giant Dhab",
    ["الضب النجمي"] = "Star Dhab",
    ["الضب البنفسجي المشع"] = "Radioactive Purple Dhab",
    ["الضب الناري"] = "Fire Dhab",
    ["ضب الفانوس"] = "Lantern Dhab",
    ["الضب المشع"] = "Radioactive Dhab",
    ["الضب الكريستالي"] = "Crystal Dhab",
    ["ضب الكهوف النادر"] = "Rare Cave Dhab",
    ["ضب الحجر النادر"] = "Rare Stone Dhab"
}

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
--  DHAB HUNT ESP
--=========================================================
local dhabEspData = {}

local function clearDhabVisuals(model)
    local data = dhabEspData[model]
    if not data then return end
    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end
    if data.tracer then pcall(function() data.tracer:Remove() end) end
    dhabEspData[model] = nil
end

local function createDhabVisuals(model)
    if dhabEspData[model] then return end
    local root = getRoot(model)
    if not root then return end

    local data = {}
    if Config.Dhab.ShowHighlight then
        data.highlight = create("Highlight", {
            FillColor = Config.Dhab.HighlightFill,
            OutlineColor = Config.Dhab.Color,
            FillTransparency = 0.55,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            Parent = model
        })
    end

    if Config.Dhab.ShowName or Config.Dhab.ShowDistance then
        local bb = create("BillboardGui", {
            Name = "Matcha_BB",
            Size = UDim2.new(0, 160, 0, 42),
            StudsOffset = Vector3.new(0, 3, 0),
            AlwaysOnTop = true,
            Adornee = root,
            Parent = root
        })
        
        local lbl = create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Config.Dhab.TextColor,
            TextStrokeTransparency = 0,
            Text = model.Name,
            Parent = bb
        })
        data.billboard = bb
        data.label = lbl
    end

    if Config.Dhab.ShowTracers and Drawing and Drawing.new then
        pcall(function()
            local t = Drawing.new("Line")
            t.Thickness = 1.5
            t.Color = Config.Dhab.TracerColor
            t.Transparency = 0.8
            t.Visible = false
            data.tracer = t
        end)
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
--  DEIRA LOCATOR
--=========================================================
local deiraTarget = nil
local deiraBeam   = nil
local deiraHL     = nil
local hudGui, hudLabel, arrow

local function buildDeiraHUD()
    if hudGui then return end
    local parent = (gethui and gethui()) or (game:GetService("CoreGui"):FindFirstChild("RobloxGui")) or LocalPlayer:FindFirstChild("PlayerGui")
    
    hudGui = create("ScreenGui", {
        Name = "DeiraHUD",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = parent
    })
    
    hudLabel = create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 15),
        Size = UDim2.new(0, 300, 0, 35),
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Color3.new(0, 0, 0),
        TextColor3 = Color3.new(1, 0, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Visible = false,
        Parent = hudGui
    })
    
    arrow = create("TextLabel", {
        Size = UDim2.new(0, 40, 0, 40),
        BackgroundTransparency = 1,
        Text = "➤",
        TextColor3 = Color3.new(1, 0, 0),
        TextSize = 35,
        Visible = false,
        Parent = hudGui
    })
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
            deiraHL = create("Highlight", {
                FillColor = Config.Deira.Color,
                DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
                Parent = deiraTarget
            })
        end
    end
end

--=========================================================
--  LOOPS
--=========================================================
task.spawn(function()
    while task.wait(Config.Dhab.ScanInterval) do pcall(scanDhab) end
end)

task.spawn(function()
    while task.wait(Config.Deira.ScanInterval) do pcall(scanDeira) end
end)

RunService.RenderStepped:Connect(function()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    local char = LocalPlayer.Character
    local myRoot = char and getRoot(char)
    
    -- Dhab Update
    if Config.Dhab.Enabled then
        for model, data in pairs(dhabEspData) do
            local root = getRoot(model)
            if root then
                local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
                local inRange = dist <= Config.Dhab.MaxDistance
                if data.billboard then 
                    data.billboard.Enabled = inRange
                    if data.label then 
                        local displayName = DhabNames[model.Name] or model.Name
                        data.label.Text = string.format("%s [%d]", displayName, math.floor(dist)) 
                    end
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
        
        if Config.Deira.ShowBeam then
            if not deiraBeam then
                deiraBeam = create("Part", {
                    Anchored = true, CanCollide = false, Transparency = 0.5,
                    Material = Enum.Material.Neon, Color = Config.Deira.Color,
                    Size = Vector3.new(Config.Deira.BeamSize, Config.Deira.BeamHeight, Config.Deira.BeamSize),
                    Parent = Workspace
                })
            end
            deiraBeam.Position = pos + Vector3.new(0, Config.Deira.BeamHeight/2, 0)
        end
        
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
