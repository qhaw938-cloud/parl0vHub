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
12 lines hidden
        TracerColor      = Color3.fromRGB(255, 0, 0),
        ToggleKey        = Enum.KeyCode.F2,
    },
    Deira = {
        Keywords         = { "ديره", "دير", "deira", "town", "village", "base", "home" },
        ShowBeam         = true,
34 lines hidden
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
 
4 lines hidden
 
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
27 lines hidden
end
 
--=========================================================
--  DEIRA LOCATOR
--=========================================================
local deiraTarget = nil
local deiraBeam   = nil
2 lines hidden
 
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
16 lines hidden
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
5 lines hidden
 
RunService.RenderStepped:Connect(function()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    local char = LocalPlayer.Character
    local myRoot = char and getRoot(char)
    
    -- Dhab Update
    if Config.Dhab.Enabled then
26 lines hidden
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
18 lines hidden
    end
end)
 
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.Dhab.ToggleKey then
7 lines hidden
 
buildDeiraHUD()
notify("Matcha Hub", "Loaded! F2: Dhab ESP | F3: Deira Beacon")
