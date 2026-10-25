-- parl0v Hub | rare-name scanner | diagnostic/console fallback
-- For testing in Roblox clients. This is NOT automatic hunting, loading, or selling.
-- Replace the old parl0v.lua in your GitHub repository with this file.

local TAG = '[parl0v Hub] '
local function log(s) print(TAG .. s) end
local function warning(s) warn(TAG .. s) end

local ok, Players, World = pcall(function()
    return game:GetService('Players'), game:GetService('Workspace')
end)
if not ok or not World then
    warning('Roblox game services are unavailable. The executor may not be attached to an active game.')
    return
end

local rareNames = {
    'أبو الضبان', 'ضب التبر', 'الضب الألماسي', 'أسطورة البر',
    'الضب العملاق الأسطوري', 'ضب الياقوت', 'ضب الزمرد',
    'ضب الكهرمان', 'ضب الفيروز', 'ضب المعادن', 'الضب النجمي',
    'الضب الأزرق النادر', 'الضب البنفسجي المشع',
    'ضب الميثيك الأرجواني', 'الضب الناري', 'ضب الفانوس',
    'الضب المشع', 'الضب الكريستالي', 'ضب الكهوف النادر',
    'ضب الحجر النادر'
}

local running = true
local foundBefore = setmetatable({}, {__mode = 'k'})
local ui, status, toggleButton
local tickWait = (task and task.wait) or wait
local function rareMatch(name)
    for _, rare in ipairs(rareNames) do
        if string.find(name, rare, 1, true) then return rare end
    end
end

local function stop()
    running = false
    if status then pcall(function() status.Text = 'الكشف متوقف' end) end
    log('Scanner stopped.')
end

-- Exposes a stop function when the executor supports getgenv().
if type(getgenv) == 'function' then
    local envOk, env = pcall(getgenv)
    if envOk and type(env) == 'table' then
        if type(env.parl0vStop) == 'function' then pcall(env.parl0vStop) end
        env.parl0vStop = stop
    end
end

local canCreate = type(Instance) == 'table' and type(Instance.new) == 'function'
if canCreate then
    local made, err = pcall(function()
        local player = Players.LocalPlayer
        if not player then error('LocalPlayer not available') end
        local pg = player:FindFirstChildOfClass('PlayerGui') or player:WaitForChild('PlayerGui', 5)
        if not pg then error('PlayerGui not available') end
        local old = pg:FindFirstChild('parl0vHub')
        if old then old:Destroy() end
        ui = Instance.new('ScreenGui')
        ui.Name = 'parl0vHub'
        ui.ResetOnSpawn = false
        ui.Parent = pg
        local frame = Instance.new('Frame')
        frame.Name = 'Panel'
        frame.Size = UDim2.fromOffset(310, 170)
        frame.Position = UDim2.new(.5, -155, .25, 0)
        frame.BackgroundColor3 = Color3.fromRGB(25, 27, 31)
        frame.Active = true
        frame.Draggable = true
        frame.Parent = ui
        local title = Instance.new('TextLabel')
        title.Size = UDim2.new(1, -16, 0, 34)
        title.Position = UDim2.fromOffset(8, 8)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(255, 216, 98)
        title.Text = 'parl0v Hub | Rare Scanner'
        title.TextSize = 18
        title.Parent = frame
        status = Instance.new('TextLabel')
        status.Size = UDim2.new(1, -16, 0, 50)
        status.Position = UDim2.fromOffset(8, 45)
        status.BackgroundTransparency = 1
        status.TextColor3 = Color3.new(1, 1, 1)
        status.TextWrapped = true
        status.Text = 'جاري فحص الأسماء النادرة...'
        status.TextSize = 14
        status.Parent = frame
        toggleButton = Instance.new('TextButton')
        toggleButton.Size = UDim2.new(1, -24, 0, 38)
        toggleButton.Position = UDim2.fromOffset(12, 112)
        toggleButton.BackgroundColor3 = Color3.fromRGB(145, 83, 45)
        toggleButton.TextColor3 = Color3.new(1, 1, 1)
        toggleButton.Text = 'Stop Everything'
        toggleButton.TextSize = 15
        toggleButton.Parent = frame
        toggleButton.MouseButton1Click:Connect(stop)
    end)
    if made then
        log('UI created. Name-only scanning is running.')
    else
        warning('UI creation failed (' .. tostring(err) .. '). Using output/console mode.')
        if ui then pcall(function() ui:Destroy() end) end
        ui = nil
        status = nil
    end
else
    warning('Instance.new unavailable; using output/console mode (no GUI).')
end

local okTask = (type(tickWait) == 'function')
if not okTask then
    warning('No scheduler/wait available. Cannot scan continuously.')
    return
end

local function scanOnce()
    local descendants = World:GetDescendants()
    local count = 0
    for _, obj in ipairs(descendants) do
        if not running then break end
        if obj:IsA('Model') or obj:IsA('BasePart') then
            local rare = rareMatch(obj.Name)
            if rare then
                count = count + 1
                if not foundBefore[obj] then
                    foundBefore[obj] = true
                    log('RARE NAME FOUND: ' .. rare .. ' [' .. obj:GetFullName() .. ']')
                end
            end
        end
    end
    if status then pcall(function() status.Text = 'مطابقات أسماء النادر: ' .. count end) end
    return count
end

log('Started. Only matches visible Workspace object names; it does not hunt or sell.')
while running do
    local scanned, result = pcall(scanOnce)
    if not scanned then
        warning('Scan failed: ' .. tostring(result))
        break
    end
    tickWait(5)
end
log('Finished.')
