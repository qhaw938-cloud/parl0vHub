-- parl0v Hub | rare dhab detector | L toggles ON/OFF
-- Client-side detection only. No auto-hunt, selling or invulnerability.
local env = (type(getgenv) == 'function' and getgenv()) or _G
if env.parl0vHubCleanup then pcall(env.parl0vHubCleanup) end
local rareNames = {
 'أبو الضبان','ضب التبر','الضب الألماسي','أسطورة البر','الضب العملاق الأسطوري',
 'ضب الياقوت','ضب الزمرد','ضب الكهرمان','ضب الفيروز','ضب المعادن',
 'الضب النجمي','الضب الأزرق النادر','الضب البنفسجي المشع','ضب الميثيك الأرجواني',
 'الضب الناري','ضب الفانوس','الضب المشع','الضب الكريستالي',
 'ضب الكهوف النادر','ضب الحجر النادر'
}
local state = {enabled=false, alive=true, seen={}, connections={}}
local function log(message) print('[parl0v Hub] '..message) end
local function matches(name)
 if type(name) ~= 'string' then return false end
 for _,rare in ipairs(rareNames) do
  if string.find(name,rare,1,true) then return true end
 end
 return false
end
local function scan()
 if not state.enabled then return end
 local ok, descendants = pcall(function() return game:GetDescendants() end)
 if not ok then log('Cannot scan game objects') return end
 local found = {}
 for _,obj in ipairs(descendants) do
  local okName,name = pcall(function() return obj.Name end)
  if okName and matches(name) then
   found[name] = true
   if not state.seen[name] then log('RARE FOUND: '..name) end
  end
 end
 state.seen = found
end
local function toggle()
 state.enabled = not state.enabled
 if state.enabled then
  log('ON - rare detection started (L to stop)')
  scan()
 else
  log('OFF - rare detection stopped (L to start)')
  state.seen = {}
 end
end
local function cleanup()
 state.alive = false
 state.enabled = false
 for _,conn in ipairs(state.connections) do pcall(function() conn:Disconnect() end) end
 log('Unloaded')
end
env.parl0vHubCleanup = cleanup
env.parl0vToggle = toggle
local ok, input = pcall(function() return game:GetService('UserInputService') end)
if ok and input and input.InputBegan then
 local connected, conn = pcall(function()
  return input.InputBegan:Connect(function(key,processed)
   if processed then return end
   if key.KeyCode == Enum.KeyCode.L then toggle() end
  end)
 end)
 if connected then table.insert(state.connections,conn) else log('Keyboard hook unavailable') end
else
 log('Keyboard input unavailable; use parl0vToggle() manually')
end
local taskLib = task
if taskLib and taskLib.spawn and taskLib.wait then
 taskLib.spawn(function()
  while state.alive do
   taskLib.wait(3)
   if state.enabled then scan() end
  end
 end)
else
 log('Background scanning unavailable in this runtime')
end
log('Loaded. Press L to toggle rare detection. Initially OFF.')
