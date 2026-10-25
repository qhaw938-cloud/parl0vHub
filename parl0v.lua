-- parl0v Hub | rare-only name scanner with START / STOP controls
-- This script DOES NOT automatically hunt, move vehicles, pick up or sell.
local TAG = '[parl0v Hub] '
local function log(msg) print(TAG .. msg) end
local function warnLog(msg) warn(TAG .. msg) end
local env = _G
if type(getgenv) == 'function' then
    local ok, result = pcall(getgenv)
    if ok and type(result) == 'table' then env = result end
end
if type(env.parl0vShutdown) == 'function' then pcall(env.parl0vShutdown) end
local active, alive, matches = false, true, 0
local seen = setmetatable({}, {__mode='k'})
local ui, statusLabel, startButton, stopButton
local rareNames = {
    'أبو الضبان','ضب التبر','الضب الألماسي','أسطورة البر',
    'الضب العملاق الأسطوري','ضب الياقوت','ضب الزمرد','ضب الكهرمان',
    'ضب الفيروز','ضب المعادن','الضب النجمي','الضب الأزرق النادر',
    'الضب البنفسجي المشع','ضب الميثيك الأرجواني','الضب الناري',
    'ضب الفانوس','الضب المشع','الضب الكريستالي',
    'ضب الكهوف النادر','ضب الحجر النادر'
}
local function refresh()
    if statusLabel then
        pcall(function()
            statusLabel.Text = (active and 'RUNNING' or 'STOPPED') .. ' | Rare names: ' .. matches
        end)
    end
end
local function start()
    if not alive then return end
    active = true
    refresh()
    log('START: rare-name scanner enabled (not auto-hunt).')
end
local function stop()
    active = false
    refresh()
    log('STOP: rare-name scanner paused.')
end
local function shutdown()
    alive = false
    active = false
    if ui then pcall(function() ui:Destroy() end) end
end
env.parl0vStart = start
env.parl0vStop = stop
env.parl0vShutdown = shutdown
local okWorld, world = pcall(function() return game:GetService('Workspace') end)
if not okWorld or not world then
    warnLog('Workspace unavailable. Join the game before running this script.')
    return
end
local newInstance = nil
pcall(function() newInstance = Instance and Instance.new end)
if type(newInstance) == 'function' then
    local made, err = pcall(function()
        local players = game:GetService('Players')
        local player = players.LocalPlayer
        local guiParent = player and (player:FindFirstChildOfClass('PlayerGui') or player:WaitForChild('PlayerGui', 5))
        if not guiParent then error('PlayerGui unavailable') end
        local old = guiParent:FindFirstChild('parl0vHub')
        if old then old:Destroy() end
        ui = newInstance('ScreenGui')
        ui.Name = 'parl0vHub'
        ui.ResetOnSpawn = false
        ui.Parent = guiParent
        local frame = newInstance('Frame')
        frame.Size = UDim2.fromOffset(300, 168)
        frame.Position = UDim2.new(.5, -150, .3, 0)
        frame.BackgroundColor3 = Color3.fromRGB(27, 29, 35)
        frame.Active = true
        frame.Draggable = true
        frame.Parent = ui
        local function label(text, y, height)
            local l = newInstance('TextLabel')
            l.BackgroundTransparency = 1
            l.Position = UDim2.fromOffset(12, y)
            l.Size = UDim2.new(1, -24, 0, height)
            l.TextColor3 = Color3.fromRGB(240, 220, 165)
            l.TextSize = 16
            l.Text = text
            l.Parent = frame
            return l
        end
        label('parl0v Hub | Rare Scanner', 9, 29)
        statusLabel = label('STOPPED | Rare names: 0', 43, 28)
        local function button(title, x, color, action)
            local b = newInstance('TextButton')
            b.Size = UDim2.fromOffset(130, 44)
            b.Position = UDim2.fromOffset(x, 95)
            b.BackgroundColor3 = color
            b.TextColor3 = Color3.new(1, 1, 1)
            b.TextSize = 18
            b.Text = title
            b.Parent = frame
            b.MouseButton1Click:Connect(action)
            return b
        end
        startButton = button('START', 12, Color3.fromRGB(36, 132, 79), start)
        stopButton = button('STOP', 158, Color3.fromRGB(164, 58, 58), stop)
    end)
    if not made then
        warnLog('GUI could not be created: ' .. tostring(err))
        if ui then pcall(function() ui:Destroy() end) end
        ui, statusLabel = nil, nil
    end
else
    warnLog('Instance.new unavailable: cannot display on-screen buttons in this runtime.')
end
log('Ready (STOPPED). To start: parl0vStart() | To stop: parl0vStop()')
local pause = task and task.wait or wait
if type(pause) ~= 'function' then
    warnLog('No scheduler available; scanner cannot run.')
    return
end
local function matchRare(name)
    for _, rare in ipairs(rareNames) do
        if string.find(name, rare, 1, true) then return rare end
    end
end
while alive do
    if active then
        local ok, err = pcall(function()
            local count = 0
            for _, obj in ipairs(world:GetDescendants()) do
                if not active or not alive then break end
                if obj:IsA('Model') or obj:IsA('BasePart') then
                    local rare = matchRare(obj.Name)
                    if rare then
                        count = count + 1
                        if not seen[obj] then
                            seen[obj] = true
                            log('RARE NAME FOUND: ' .. rare .. ' | ' .. obj:GetFullName())
                        end
                    end
                end
            end
            matches = count
            refresh()
        end)
        if not ok then warnLog('Scan error: ' .. tostring(err)) end
    end
    pause(3)
end
log('Shutdown complete.')
