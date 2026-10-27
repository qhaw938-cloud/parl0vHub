--[[
    Matcha Hub | parl0vHub
    Script: Pure Auto Walk
    Features: Auto Walk Only
    Status: Auto-run enabled
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Branding = "Matcha Hub | parl0vHub"

print("[" .. Branding .. "] Pure Auto Walk Active.")

-- وظيفة للبحث عن أقرب زر للمشي نحوه
local function getClosestButton()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local closestButton = nil
    local shortestDistance = math.huge

    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                -- البحث عن الأزرار المتاحة
                if (obj.Name:lower():find("button") or obj:FindFirstChild("TouchInterest")) and obj.Transparency < 1 and obj.CanTouch then
                    local distance = (rootPart.Position - obj.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestButton = obj
                    end
                end
            end
        end)
    end
    return closestButton
end

-- منطق المشي التلقائي الصافي
task.spawn(function()
    while task.wait(0.5) do
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            local target = getClosestButton()
            if target then
                humanoid:MoveTo(target.Position)
            end
        end
    end
end)
