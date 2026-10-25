-- parl0v Hub | Roblox client prototype | Delta
-- Visible-name detection only. No unverified server remotes are invoked.
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local names = {'أبو الضبان','ضب التبر','الضب الألماسي','أسطورة البر','الضب العملاق الأسطوري','ضب الياقوت','ضب الزمرد','ضب الكهرمان','ضب الفيروز','ضب المعادن','الضب النجمي','الضب الأزرق النادر','الضب البنفسجي المشع','ضب الميثيك الأرجواني','الضب الناري','ضب الفانوس','الضب المشع','الضب الكريستالي','ضب الكهوف النادر','ضب الحجر النادر'}
local enabled, tags, seen = false, {}, {}
local hasInstance, createInstance = pcall(function() return Instance.new end)
if not hasInstance or type(createInstance) ~= 'function' then
 warn('[parl0v Hub] Roblox Instance.new not available. Join the game and use a compatible Roblox runtime.')
 return
end
local old = game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui'):FindFirstChild('parl0vHub')
if old then old:Destroy() end
local gui = Instance.new('ScreenGui')
gui.Name = 'parl0vHub'; gui.ResetOnSpawn = false
pcall(function() gui.Parent = game:GetService('CoreGui') end)
if not gui.Parent then gui.Parent = player:WaitForChild('PlayerGui') end
if not gui.Parent then warn('[parl0v Hub] Could not attach UI'); return end
local frame = Instance.new('Frame',gui); frame.Size=UDim2.fromOffset(290,210); frame.Position=UDim2.new(.5,-145,.25,0); frame.BackgroundColor3=Color3.fromRGB(24,26,32); frame.Active=true; frame.Draggable=true
Instance.new('UICorner',frame).CornerRadius=UDim.new(0,12)
local function label(text,y,h)
 local l=Instance.new('TextLabel',frame);l.Size=UDim2.new(1,-20,0,h or 32);l.Position=UDim2.fromOffset(10,y);l.BackgroundTransparency=1;l.TextColor3=Color3.new(1,1,1);l.Font=Enum.Font.GothamBold;l.TextSize=14;l.TextWrapped=true;l.Text=text;return l
end
label('parl0v Hub | Rare Dhab Scanner',10,30)
local status=label('جاهز - كشف الأسماء النادرة فقط',48,44)
local function button(text,y,callback)
 local b=Instance.new('TextButton',frame);b.Size=UDim2.new(1,-24,0,36);b.Position=UDim2.fromOffset(12,y);b.BackgroundColor3=Color3.fromRGB(56,92,115);b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=14;b.Text=text;Instance.new('UICorner',b).CornerRadius=UDim.new(0,8);b.MouseButton1Click:Connect(callback)
end
local function clearTags()
 for obj,tag in pairs(tags) do pcall(function()tag:Destroy()end);tags[obj]=nil end
end
local function getRare(obj)
 for _,name in ipairs(names) do if string.find(obj.Name,name,1,true) then return name end end
end
local function scan()
 if not enabled then return end
 local count=0
 for _,obj in ipairs(workspace:GetDescendants()) do
  if obj:IsA('Model') or obj:IsA('BasePart') then
   local rare=getRare(obj)
   if rare then
    local part=obj:IsA('BasePart') and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA('BasePart',true)
    if part then
     count=count+1
     if not tags[obj] then
      local bill=Instance.new('BillboardGui');bill.Name='parl0vRareESP';bill.Size=UDim2.fromOffset(190,36);bill.StudsOffsetWorldSpace=Vector3.new(0,3,0);bill.AlwaysOnTop=true;bill.Adornee=part;bill.Parent=gui
      local t=Instance.new('TextLabel',bill);t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.TextColor3=Color3.fromRGB(255,215,75);t.TextStrokeTransparency=0;t.TextScaled=true;t.Text='★ '..rare
      tags[obj]=bill
      if not seen[obj] then seen[obj]=true; pcall(function()game:GetService('StarterGui'):SetCore('SendNotification',{Title='Rare Dhab Alert',Text=rare,Duration=5})end) end
     end
    end
   end
  end
 end
 status.Text='الضبان النادرة المكتشفة: '..count..' | ESP يعمل'
end
button('تشغيل / إيقاف كشف النادر',105,function()
 enabled=not enabled
 if enabled then status.Text='جاري البحث عن الضبان النادرة...' else clearTags();status.Text='الكشف متوقف' end
end)
button('Stop Everything | إيقاف الكل',151,function()enabled=false;clearTags();status.Text='تم إيقاف كل وظائف النسخة التجريبية' end)
task.spawn(function()while gui.Parent do if enabled then pcall(scan) end task.wait(3) end end)
-- This prototype does not automate shooting, truck loading or selling.
