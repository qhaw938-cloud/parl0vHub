
-- Matcha | ULTIMATE RED ESP
-- English Names | 15000 Studs | Tracers
-- F = Enable | L = Disable

local env = (type(getgenv) == "function" and getgenv()) or _G

if type(env.parl0vHubCleanup) == "function" then
    pcall(env.parl0vHubCleanup)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local MAX_DISTANCE = 15000
local SCAN_INTERVAL = 3
local RED = Color3.fromRGB(255, 0, 0)

-- Arabic internal names -> English display names
local names = {
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

local state = {
    alive = true,
    enabled = true,
    items = {},
    connections = {},
    gui = nil,
    status = nil
}

local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getPart(obj)
    if obj:IsA("BasePart") then
        return obj
    end

    if obj:IsA("Model") then
        return obj.PrimaryPart
            or obj:FindFirstChildWhichIsA("BasePart", true)
    end

    return nil
end

local function getEnglishName(name)
    if names[name] then
        return names[name]
    end

    local lower = string.lower(name)

    if string.find(lower, "dhab", 1, true)
        or string.find(lower, "dhabb", 1, true)
        or string.find(lower, "lizard", 1, true)
        or string.find(lower, "ضب", 1, true) then

        if string.find(lower, "ضب", 1, true) then
            return "Unknown Dhab"
        end

        return name
    end

    return nil
end

local function removeItem(obj)
    local item = state.items[obj]
    if not item then return end

    if item.highlight then
        item.highlight:Destroy()
    end

    if item.billboard then
        item.billboard:Destroy()
    end

    if item.line then
        pcall(function()
            item.line:Remove()
        end)
    end

    state.items[obj] = nil
end

local function createGui()
    local playerGui = player:WaitForChild("PlayerGui")

    local old = playerGui:FindFirstChild("MatchaStatusUI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MatchaStatusUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromOffset(280, 55)
    label.Position = UDim2.fromOffset(15, 15)
    label.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    label.BackgroundTransparency = 0.2
    label.BorderColor3 = RED
    label.BorderSizePixel = 2
    label.TextColor3 = RED
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.Text = "MATCHA ESP | ON\nScanning..."
    label.Parent = gui

    state.gui = gui
    state.status = label
end

local function addItem(obj, englishName)
    if state.items[obj] then return end

    local part = getPart(obj)
    if not part then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "MatchaRedHighlight"
    highlight.Adornee = obj
    highlight.FillColor = RED
    highlight.OutlineColor = RED
    highlight.FillTransparency = 0.45
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = state.gui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MatchaESPLabel"
    billboard.Adornee = part
    billboard.Size = UDim2.fromOffset(200, 55)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = MAX_DISTANCE
    billboard.Parent = state.gui

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.TextColor3 = RED
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextStrokeTransparency = 0
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Text = englishName
    text.Parent = billboard

    local line = nil

    if type(Drawing) == "table"
        and type(Drawing.new) == "function" then

        local ok, result = pcall(function()
            return Drawing.new("Line")
        end)

        if ok then
            line = result
            line.Color = RED
            line.Thickness = 2
            line.Visible = false
        end
    end

    state.items[obj] = {
        part = part,
        highlight = highlight,
        billboard = billboard,
        text = text,
        line = line,
        name = englishName
    }
end

local function scan()
    if not state.enabled then return end

    local root = getRoot()
    if not root then return end

    local found = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if not state.alive or not state.enabled then
            return
        end

        if obj:IsA("Model") or obj:IsA("BasePart") then
            local englishName = getEnglishName(obj.Name)

            if englishName then
                local part = getPart(obj)

                if part then
                    local distance =
                        (root.Position - part.Position).Magnitude

                    if distance <= MAX_DISTANCE then
                        found[obj] = true
                        addItem(obj, englishName)
                    end
                end
            end
        end
    end

    for obj in pairs(state.items) do
        if not found[obj] or not obj:IsDescendantOf(workspace) then
            removeItem(obj)
        end
    end
end

local function update()
    if not state.enabled then return end

    local root = getRoot()
    local camera = workspace.CurrentCamera

    if not root or not camera then return end

    local count = 0

    for obj, item in pairs(state.items) do
        local part = item.part

        if not part or not part:IsDescendantOf(workspace) then
            removeItem(obj)
        else
            local distance =
                (root.Position - part.Position).Magnitude

            local visible = distance <= MAX_DISTANCE

            item.highlight.Enabled = visible
            item.billboard.Enabled = visible

            if visible then
                count = count + 1

                item.text.Text = string.format(
                    "%s\n[%d studs]",
                    item.name,
                    math.floor(distance)
                )
            end

            if item.line then
                local pos, onScreen =
                    camera:WorldToViewportPoint(part.Position)

                item.line.Visible =
                    visible and onScreen and pos.Z > 0

                if item.line.Visible then
                    item.line.From = Vector2.new(
                        camera.ViewportSize.X / 2,
                        camera.ViewportSize.Y
                    )

                    item.line.To = Vector2.new(pos.X, pos.Y)
                end
            end
        end
    end

    if state.status then
        state.status.Text = string.format(
            "MATCHA ESP | ON\nFound: %d | Range: 15000",
            count
        )
    end
end

local function setEnabled(value)
    state.enabled = value

    if not value then
        for obj in pairs(state.items) do
            removeItem(obj)
        end

        if state.status then
            state.status.Text = "MATCHA ESP | OFF\nPress F to enable"
        end
    else
        if state.status then
            state.status.Text = "MATCHA ESP | ON\nScanning..."
        end

        task.spawn(scan)
    end
end

local function cleanup()
    if not state.alive then return end

    state.alive = false
    state.enabled = false

    for _, connection in ipairs(state.connections) do
        connection:Disconnect()
    end

    for obj in pairs(state.items) do
        removeItem(obj)
    end

    if state.gui then
        state.gui:Destroy()
    end
end

env.parl0vHubCleanup = cleanup

createGui()

table.insert(
    state.connections,
    RunService.RenderStepped:Connect(update)
)

table.insert(
    state.connections,
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end

        if input.KeyCode == Enum.KeyCode.F then
            setEnabled(true)
        elseif input.KeyCode == Enum.KeyCode.L then
            setEnabled(false)
        end
    end)
)

task.spawn(function()
    while state.alive do
        if state.enabled then
            local ok, err = pcall(scan)

            if not ok then
                warn("[Matcha ESP] Scan error:", err)
            end
        end

        task.wait(SCAN_INTERVAL)
    end
end)

print("[Matcha] ESP Loaded | F = ON | L = OFF")
