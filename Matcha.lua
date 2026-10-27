--[[
    Matcha Hub | parl0vHub
    Script: Auto Buy Tycoon (FIXED FOR MATCHA)
    Features: Auto Buy, ESP (Highlights, Labels)
    Status: Auto-run enabled
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local Config = {
    AutoBuy = true,
    ESP = {
        Enabled = true,
        Color = Color3.fromRGB(255, 0, 0), -- Red
        Highlight = true,
        Labels = true
    },
    Branding = "Matcha Hub | parl0vHub"
}

-- Safe Notification Function (Fix for SetCore error)
local function Notify(title, text)
    task.spawn(function()
        local success = false
        local retryCount = 0
        while not success and retryCount < 10 do
            success = pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = tostring(title or "Notification"),
                    Text = tostring(text or ""),
                    Duration = 5
                })
            end)
            if not success then
                task.wait(1)
                retryCount = retryCount + 1
            end
        end
    end)
end

Notify(Config.Branding, "Script Loaded Successfully!")

-- Helper: Find Tycoon Buttons
local function getTycoonButtons()
    local buttons = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                if (obj.Name:lower():find("button") or obj:FindFirstChild("TouchInterest")) and obj.Transparency < 1 and obj.CanTouch then
                    table.insert(buttons, obj)
                end
            end
        end)
    end
    return buttons
end

-- ESP Implementation
local function createESP(part)
    if not part or not part:IsA("BasePart") then return end
    
    -- Highlight
    if Config.ESP.Highlight and not part:FindFirstChild("MatchaHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MatchaHighlight"
        highlight.FillColor = Config.ESP.Color
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.Parent = part
    end

    -- BillboardGui (Label)
    if Config.ESP.Labels and not part:FindFirstChild("MatchaLabel") then
        local bgui = Instance.new("BillboardGui")
        bgui.Name = "MatchaLabel"
        bgui.Size = UDim2.new(0, 100, 0, 50)
        bgui.Adornee = part
        bgui.AlwaysOnTop = true
        bgui.ExtentsOffset = Vector3.new(0, 3, 0)
        
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = tostring(part.Name)
        label.TextColor3 = Config.ESP.Color
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Parent = bgui
        bgui.Parent = part
    end
end

-- Auto Buy Logic
task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoBuy then
            local buttons = getTycoonButtons()
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                for _, button in pairs(buttons) do
                    if firetouchinterest then
                        firetouchinterest(rootPart, button, 0)
                        task.wait()
                        firetouchinterest(rootPart, button, 1)
                    end
                    
                    if Config.ESP.Enabled then
                        createESP(button)
                    end
                end
            end
        end
    end
end)

local brandingText = tostring(Config.Branding or "Matcha Hub")
print("[" .. brandingText .. "] Auto Buy System Active.")
