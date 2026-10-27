--[[
    Matcha Hub | parl0vHub
    Script: Enhanced Auto Walk
    Features: Auto Walk, WalkSpeed Boost
    Status: Auto-run enabled
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Branding = "Matcha Hub | parl0vHub"
local WalkSpeedBoost = 100 -- سرعة عالية لضمان الحركة

print("[" .. Branding .. "] Enhanced Auto Walk Active.")

-- وظيفة مطورة للبحث عن أقرب زر
local function getClosestButton()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local closestButton = nil
    local shortestDistance = math.huge
    local foundCount = 0

    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            -- التحقق من أن الكائن هو جزء وقابل للمس ومرئي
            if obj:IsA("BasePart") and obj.CanTouch and obj.Transparency < 1 then
                -- البحث عن أزرار التايكون بمختلف أنواعها
                if obj.Name:lower():find("button") or obj:FindFirstChild("TouchInterest") or obj:FindFirstChildOfClass("ProximityPrompt") then
                    local distance = (rootPart.Position - obj.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestButton = obj
                    end
                    foundCount = foundCount + 1
                end
            end
        end)
    end
    
    -- إذا لم يجد أزرار سيطبع تحذير في الكونسول
    if foundCount == 0 then
        warn("[" .. Branding .. "] No buttons found! Make sure you are near your Tycoon.")
    end
    
    return closestButton
end

-- منطق المشي التلقائي المطور
task.spawn(function()
    while task.wait(0.2) do -- استجابة سريعة جداً
        pcall(function()
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            if humanoid then
                -- تفعيل زيادة السرعة
                humanoid.WalkSpeed = WalkSpeedBoost
                
                local target = getClosestButton()
                if target then
                    humanoid:MoveTo(target.Position)
                    
                    -- قفز تلقائي إذا علق اللاعب
                    if humanoid.FloorMaterial == Enum.Material.Air then
                        humanoid.Jump = true
                    end
                end
            end
        end)
    end
end)
