-- Matcha | ULTIMATE RED ESP (English Version | 15,000m | Auto)
local env = (type(getgenv) == "function" and getgenv()) or _G
if type(env.parl0vHubCleanup) == "function" then
    pcall(env.parl0vHubCleanup)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

-- Settings
local maxDistance = 15000 -- Maximum search distance in studs
local targetNames = {
    ["أبو الضبان"] = true, ["أسطورة البر"] = true, ["الضب الألماسي"] = true,
    ["الضب الأزرق النادر"] = true, ["ضب التبر"] = true, ["ضب الكهرمان"] = true,
    ["ضب الياقوت"] = true, ["ضب البتر النادر"] = true, ["ضب الجلمود"] = true,
    ["ضب الحمى"] = true, ["الضب الفيروزي"] = true, ["الضب الصحراوي العادي"] = true,
    ["الضب الأخضر"] = true, ["ضب الحزم"] = true, ["ضب الشيح"] = true, ["ضب الغبار"] = true,
    ["ضب الأرطى"] = true,
}

local state = { alive = true, espItems = {}, count = 0, gui = nil, label = nil }

local function safe(fn) local ok, res = pcall(fn) return ok and res or nil end
local function destroyIfExists(instance) if instance then safe(function() instance:Destroy() end) end end

-- Create English Status UI
local function createStatusGui()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    destroyIfExists(state.gui)
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MatchaStatusUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    state.gui = gui
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 250, 0, 35)
    label.Position = UDim2.new(0, 15, 0, 15)
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.BackgroundTransparency = 0.5
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Text = "Matcha: Initializing..."
    label.BorderSizePixel = 2
    label.BorderColor3 = Color3.fromRGB(255, 0, 0)
    label.Parent = gui
    state.label = label
end

local function applyEsp(obj, name)
    if state.espItems[obj] then return end
    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj)
    if not part then return end
    
    -- 1. Red Highlight
    local h = Instance.new("Highlight")
    h.FillColor = Color3.fromRGB(255, 0, 0)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.FillTransparency = 0.4
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
    
    -- 2. Billboard Label (Name + Distance)
    local b = Instance.new("BillboardGui")
    b.Size = UDim2.new(0, 180, 0, 50)
    b.AlwaysOnTop = true
    b.Parent = part
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundTransparency = 1
    t.Text = name
    t.TextColor3 = Color3.fromRGB(255, 0, 0)
    t.TextStrokeTransparency = 0
    t.TextScaled = true
    t.Font = Enum.Font.GothamBold
    t.Parent = b
    
    -- 3. Red Tracers
    local line = nil
    if type(Drawing) ~= "nil" then
        line = Drawing.new("Line")
        line.Color = Color3.fromRGB(255, 0, 0)
        line.Thickness = 2
        line.Transparency = 1
        line.Visible = false
    end
    
    state.espItems[obj] = {h = h, b = b, label = t, line = line, part = part, name = name}
end

local function updateEsp()
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for obj, items in pairs(state.espItems) do
        if items.part and items.part.Parent then
            local dist = math.floor((root.Position - items.part.Position).Magnitude)
            
            -- Update Label Text
            if items.label then
                items.label.Text = items.name .. "\n[" .. tostring(dist) .. "m]"
            end

            -- Update Tracers
            if items.line then
                local pos, onScreen = Camera:WorldToViewportPoint(items.part.Position)
                if onScreen and dist <= maxDistance then
                    items.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    items.line.To = Vector2.new(pos.X, pos.Y)
                    items.line.Visible = true
                else
                    items.line.Visible = false
                end
            end
            
            -- Toggle visibility based on distance
            if items.h then items.h.Enabled = (dist <= maxDistance) end
            if items.b then items.b.Enabled = (dist <= maxDistance) end
        end
    end
end

local function isTarget(name)
    if type(name) ~= "string" then return false end
    if targetNames[name] then return true end
    if string.find(name, "ضب") then return true end -- Auto-detect any animal containing "ضب"
    return false
end

local function scan()
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local descendants = safe(function() return workspace:GetDescendants() end)
    if not descendants then return end
    
    local currentFound = {}
    local count = 0
    for _, obj in ipairs(descendants) do
        local objName = safe(function() return obj.Name end)
        if isTarget(objName) then
            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj)
            if part then
                local dist = (root.Position - part.Position).Magnitude
                if dist <= maxDistance then
                    currentFound[obj] = true
                    count = count + 1
                    applyEsp(obj, objName)
                end
            end
        end
    end
    
    -- Update Status Label
    if state.label then 
        state.label.Text = "Matcha: Searching... (" .. tostring(count) .. " found)" 
        state.label.BackgroundColor3 = count > 0 and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 0, 0)
    end

    -- Cleanup missing objects
    for oldObj, items in pairs(state.espItems) do
        if not currentFound[oldObj] or not oldObj.Parent then
            destroyIfExists(items.h)
            destroyIfExists(items.b)
            if items.line then items.line:Remove() end
            state.espItems[oldObj] = nil
        end
    end
end

-- Cleanup on re-run
env.parl0vHubCleanup = function() 
    state.alive = false 
    destroyIfExists(state.gui)
    for _, items in pairs(state.espItems) do
        if items.line then items.line:Remove() end
    end
end

-- Main Loop
task.spawn(function()
    print("[Matcha] Script Started - English Version")
    safe(createStatusGui)
    while state.alive do
        scan()
        task.wait(3)
    end
end)

-- Frame Update for smooth tracers
RunService.RenderStepped:Connect(function()
    if state.alive then updateEsp() end
end)
