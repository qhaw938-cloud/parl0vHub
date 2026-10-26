
-- parl0v Hub | Dhab Hunting
-- F = Start | L = Stop | RightShift = Menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local old = guiParent:FindFirstChild("parl0vHub")
if old then old:Destroy() end

local running = false
local espEnabled = true
local rareOnly = true
local minPrice = 100000
local range = 15000
local markers = {}
local lastAlert = {}
local connections = {}

local rareNames = {
    "rare", "legendary", "mythic", "diamond",
    "gold", "ruby", "emerald", "amber",
    "sapphire", "crystal", "giant",
    "hidden", "pink", "blue", "rock",
    "star", "radioactive", "fire",
    "ابو الضبان", "أبو الضبان",
    "النادر", "الاسطوري", "الأسطوري",
    "الالماسي", "الألماسي",
    "التبر", "الياقوت", "الزمرد",
    "الكهرمان", "الفيروز", "المشع",
    "الكريستالي", "الوردي", "المخفي"
}

local function character()
    return player.Character
end

local function root()
    local c = character()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function position(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        return obj:GetPivot().Position
    end
end

local function isRare(name)
    local lower = string.lower(name)
    for _, word in ipairs(rareNames) do
        if string.find(lower, word, 1, true) then
            return true
        end
    end
    return false
end

local function getPrice(obj)
    for _, key in ipairs({"Price", "Value", "Worth", "SellPrice"}) do
        local value = obj:GetAttribute(key)
        if type(value) == "number" then
            return value
        end

        local child = obj:FindFirstChild(key)
        if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then
            return child.Value
        end
    end
    return nil
end

local function isDhab(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then
        return false
    end

    if obj:IsDescendantOf(character() or player) then
        return false
    end

    local name = string.lower(obj.Name)
    local words = {
        "dhab", "lizard", "ضب", "ضبان",
        "rare", "mythic", "legendary"
    }

    for _, word in ipairs(words) do
        if string.find(name, word, 1, true) then
            return true
        end
    end

    return isRare(obj.Name)
end

local function eligible(obj)
    if not isDhab(obj) then return false end

    local price = getPrice(obj)
    if price and price >= minPrice then
        return true
    end

    if rareOnly then
        return isRare(obj.Name)
    end

    return true
end

local gui = Instance.new("ScreenGui")
gui.Name = "parl0vHub"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(310, 345)
frame.Position = UDim2.new(0.5, -155, 0.5, -172)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(220, 45, 55)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "parl0v Hub | DHAB"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.Parent = frame

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(10, 48)
status.Size = UDim2.new(1, -20, 0, 26)
status.BackgroundTransparency = 1
status.Text = "Status: STOPPED"
status.TextColor3 = Color3.fromRGB(255, 100, 100)
status.Font = Enum.Font.GothamBold
status.TextSize = 13
status.Parent = frame

local function button(text, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -24, 0, 35)
    b.Position = UDim2.fromOffset(12, y)
    b.BackgroundColor3 = Color3.fromRGB(43, 43, 54)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 13
    b.Text = text
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function setRunning(value)
    running = value
    status.Text = value and "Status: RUNNING" or "Status: STOPPED"
    status.TextColor3 = value
        and Color3.fromRGB(80, 255, 130)
        or Color3.fromRGB(255, 100, 100)
end

button("START AUTO SEARCH [F]", 82, function()
    setRunning(true)
end)

button("STOP AUTO SEARCH [L]", 122, function()
    setRunning(false)
end)

local espButton
espButton = button("RARE ESP: ON", 162, function()
    espEnabled = not espEnabled
    espButton.Text = "RARE ESP: " .. (espEnabled and "ON" or "OFF")
end)

local filterButton
filterButton = button("RARE ONLY: ON", 202, function()
    rareOnly = not rareOnly
    filterButton.Text = "RARE ONLY: " .. (rareOnly and "ON" or "OFF")
end)

local countLabel = Instance.new("TextLabel")
countLabel.Position = UDim2.fromOffset(12, 248)
countLabel.Size = UDim2.new(1, -24, 0, 25)
countLabel.BackgroundTransparency = 1
countLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
countLabel.Text = "Targets: 0"
countLabel.TextSize = 14
countLabel.Font = Enum.Font.Gotham
countLabel.Parent = frame

local info = Instance.new("TextLabel")
info.Position = UDim2.fromOffset(12, 285)
info.Size = UDim2.new(1, -24, 0, 45)
info.BackgroundTransparency = 1
info.TextWrapped = true
info.Text = "F Start | L Stop | RightShift Menu"
info.TextColor3 = Color3.fromRGB(170, 170, 180)
info.Font = Enum.Font.Gotham
info.TextSize = 12
info.Parent = frame

local function clearMarker(obj)
    local marker = markers[obj]
    if marker then
        marker:Destroy()
        markers[obj] = nil
    end
end

local function addMarker(obj)
    if markers[obj] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "parl0vESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.55
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = obj
    highlight.Parent = gui

    markers[obj] = highlight
end

local function getTargets()
    local found = {}
    local r = root()
    if not r then return found end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if eligible(obj) then
            local pos = position(obj)
            if pos and (r.Position - pos).Magnitude <= range then
                table.insert(found, obj)
            end
        end
    end

    return found
end

local function notifyRare(obj)
    if lastAlert[obj] then return end
    lastAlert[obj] = true

    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Rare Dhab Found!",
            Text = obj.Name,
            Duration = 5
        })
    end)
end

local currentTarget = nil

local function update()
    local targets = getTargets()
    local active = {}

    for _, obj in ipairs(targets) do
        active[obj] = true
        if espEnabled then
            addMarker(obj)
        end
        if isRare(obj.Name) then
            notifyRare(obj)
        end
    end

    for obj in pairs(markers) do
        if not active[obj] or not espEnabled or not obj.Parent then
            clearMarker(obj)
        end
    end

    countLabel.Text = "Targets: " .. #targets

    if not running then return end

    local r = root()
    local c = character()
    local humanoid = c and c:FindFirstChildOfClass("Humanoid")
    if not r or not humanoid then return end

    local nearest, bestDistance = nil, math.huge

    for _, obj in ipairs(targets) do
        local pos = position(obj)
        if pos then
            local distance = (r.Position - pos).Magnitude
            if distance < bestDistance then
                bestDistance = distance
                nearest = obj
            end
        end
    end

    currentTarget = nearest

    if nearest then
        local pos = position(nearest)
        if pos and bestDistance > 12 then
            humanoid:MoveTo(pos)
        end
    end
end

table.insert(connections, UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.F then
        setRunning(true)
    elseif input.KeyCode == Enum.KeyCode.L then
        setRunning(false)
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end))

task.spawn(function()
    while gui.Parent do
        pcall(update)
        task.wait(1.5)
    end
end)

print("parl0v Hub loaded successfully")
