--[[ 
    Matcha Hub | parl0v Edition (Dhab Hunting)
    الميزات: تحديد شامل، مسافة 20كم، بدون تعليق، ترجمة أسماء
]]

repeat task.wait() until game:IsLoaded()
local lp = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")

-- 1. قائمة الأسماء (عربي -> إنجليزي)
local DhabNames = {
    ["أبو الضبان"] = "Abu Al-Dhabban", ["أسطورة البر"] = "Desert Legend", ["الضب الألماسي"] = "Diamond Dhab",
    ["الضب الأزرق النادر"] = "Rare Blue Dhab", ["ضب التبر"] = "Gold Dhab", ["ضب الكهرمان"] = "Amber Dhab"
}

-- 2. دالة إنشاء الـ ESP (صناديق حمراء فاقعة)
local function createVisuals(obj)
    local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
    if not root or root:FindFirstChild("MatchaVisual") then return end

    -- إنشاء المربع الأحمر
    local bb = Instance.new("BillboardGui", root)
    bb.Name = "MatchaVisual"
    bb.Size = UDim2.new(5, 0, 5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 20000 -- 20 كم

    local f = Instance.new("Frame", bb)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 0.6
    f.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Instance.new("UIStroke", f).Color = Color3.new(1, 1, 1)

    local t = Instance.new("TextLabel", bb)
    t.Text = (DhabNames[obj.Name] or obj.Name)
    t.Size = UDim2.new(1, 0, 0.5, 0)
    t.Position = UDim2.new(0, 0, -0.7, 0)
    t.TextColor3 = Color3.new(1, 1, 1)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
end

-- 3. حلقة المسح الشامل (كل 3 ثواني)
task.spawn(function()
    while task.wait(3) do
        for _, v in ipairs(workspace:GetDescendants()) do
            -- الضبان والحيوانات
            if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v ~= lp.Character then
                createVisuals(v)
            end
            -- الديره (عمود ضوئي)
            if (v.Name:find("دير") or v.Name:lower():find("deira")) and not v:FindFirstChild("MatchaBeam") then
                local p = Instance.new("Part", v)
                p.Name = "MatchaBeam"
                p.Anchored = true; p.CanCollide = false; p.Transparency = 0.5
                p.Size = Vector3.new(15, 20000, 15); p.Color = Color3.new(1,0,0); p.Material = "Neon"
                p.Position = v:GetPivot().Position + Vector3.new(0, 10000, 0)
            end
        end
    end
end)

-- 4. إشعار التشغيل
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Matcha Hub",
    Text = "مرحباً parl0v! السكربت جاهز ومكشوف بالكامل",
    Duration = 5
})
