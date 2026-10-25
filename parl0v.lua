-- parl0v Hub | rare names + visible price scanner + control menu
-- L toggles detection. No automated shooting, selling, or invulnerability.
local env = (type(getgenv)=="function" and getgenv()) or _G
if type(env.parl0vHubCleanup)=="function" then pcall(env.parl0vHubCleanup) end

local names = {
"أبو الضبان","ضب التبر","الضب الألماسي","أسطورة البر",
"الضب العملاق الأسطوري","ضب الياقوت","ضب الزمرد","ضب الكهرمان",
"ضب الفيروز","ضب المعادن","الضب النجمي","الضب الأزرق النادر",
"الضب البنفسجي المشع","ضب الميثيك الأرجواني","الضب الناري",
"ضب الفانوس","الضب المشع","الضب الكريستالي","ضب الكهوف النادر",
"ضب الحجر النادر","الضب النادر","الضب الأزرق","الضب الوردي",
"الضب السريع","الضب المخفي","الضب الصخري"
}
local state={enabled=false, alive=true, seen={}, conns={}, priceMin=100000,
    scanNames=true, scanPrices=true, alerts=true, esp=false, gui=nil, labels={}}
local function log(s) print("[parl0v Hub] "..tostring(s)) end
local function safe(f) local ok,result=pcall(f); if ok then return result end end
local function matchName(s)
 if type(s)~="string" then return false end
 for _,n in ipairs(names) do if string.find(s,n,1,true) then return true end end
 return false
end
local function numeric(v)
 if type(v)=="number" then return v end
 if type(v)~="string" then return nil end
 local cleaned=v:gsub("[,%s٬]","")
 local number=tonumber(cleaned:match("%d+%.?%d*"))
 if not number then return nil end
 if v:match("[Kk]") or v:find("ألف",1,true) then number=number*1000 end
 if v:match("[Mm]") or v:find("مليون",1,true) then number=number*1000000 end
 return number
end
local function getPrice(obj)
 -- Only inspect explicitly named price/value fields. No invented valuations.
 local priceKeys={"Price","SellPrice","SellValue","Worth","Value","السعر","القيمة"}
 for _,key in ipairs(priceKeys) do
  local v=safe(function() return obj:GetAttribute(key) end)
  local n=numeric(v)
  if n then return n end
  local child=safe(function() return obj:FindFirstChild(key) end)
  if child then
   local cv=safe(function() return child.Value end)
   n=numeric(cv)
   if n then return n end
   local text=safe(function() return child.Text end)
   n=numeric(text)
   if n then return n end
  end
 end
 return nil
end
local function setStatus(message)
 log(message)
 if state.labels.status then safe(function() state.labels.status.Text=message end) end
end
local function scan()
 if not state.enabled then return end
 local objects=safe(function() return workspace:GetDescendants() end)
 if not objects then setStatus("Workspace scan unavailable"); return end
 local found={}
 for _,obj in ipairs(objects) do
  local name=safe(function() return obj.Name end)
  if type(name)=="string" then
   local named=state.scanNames and matchName(name)
   local price=state.scanPrices and getPrice(obj) or nil
   local expensive=price and price>state.priceMin
   if named or expensive then
    local key=tostring(obj)
    found[key]=true
    if not state.seen[key] and state.alerts then
     setStatus("Found: "..name..(price and (" | "..tostring(price)) or " | price unknown"))
    end
   end
  end
 end
 state.seen=found
end
local function toggle()
 state.enabled=not state.enabled
 state.seen={}
 setStatus(state.enabled and "ON | scanning rare / priced objects" or "OFF | press L")
 if state.enabled then scan() end
end
local function cleanup()
 state.alive=false
 state.enabled=false
 for _,c in ipairs(state.conns) do safe(function() c:Disconnect() end) end
 if state.gui then safe(function() state.gui:Destroy() end) end
 log("Unloaded")
end
env.parl0vHubCleanup=cleanup
env.parl0vToggle=toggle
env.parl0vStart=function() if not state.enabled then toggle() end end
env.parl0vStop=function() if state.enabled then toggle() end end

local uis=safe(function() return game:GetService("UserInputService") end)
if uis then
 local c=safe(function() return uis.InputBegan:Connect(function(input,processed)
  if not processed and input.KeyCode==Enum.KeyCode.L then toggle() end
 end) end)
 if c then table.insert(state.conns,c) end
end

-- Menu is created only when Roblox GUI APIs are available.
local canGui=(type(Instance)=="table" or type(Instance)=="userdata") and
    type(Instance.new)=="function"
if canGui then
 local ok,err=pcall(function()
  local players=game:GetService("Players")
  local player=players.LocalPlayer
  local parent=player:WaitForChild("PlayerGui",5)
  if not parent then return end
  local gui=Instance.new("ScreenGui")
  gui.Name="parl0vHubMenu"
  gui.ResetOnSpawn=false
  gui.Parent=parent
  state.gui=gui
  local panel=Instance.new("Frame")
  panel.Size=UDim2.new(0,310,0,340)
  panel.Position=UDim2.new(0,24,0.5,-170)
  panel.BackgroundColor3=Color3.fromRGB(26,29,37)
  panel.Parent=gui
  local corner=Instance.new("UICorner")
  corner.CornerRadius=UDim.new(0,10)
  corner.Parent=panel
  local layout=Instance.new("UIListLayout")
  layout.Padding=UDim.new(0,5)
  layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
  layout.Parent=panel
  local function label(text,height)
   local x=Instance.new("TextLabel")
   x.Size=UDim2.new(1,-16,0,height or 30)
   x.BackgroundTransparency=1
   x.TextColor3=Color3.new(1,1,1)
   x.Font=Enum.Font.Gotham
   x.TextSize=13
   x.TextWrapped=true
   x.Text=text
   x.Parent=panel
   return x
  end
  local function button(text,callback)
   local b=Instance.new("TextButton")
   b.Size=UDim2.new(1,-18,0,34)
   b.BackgroundColor3=Color3.fromRGB(53,62,82)
   b.TextColor3=Color3.new(1,1,1)
   b.Font=Enum.Font.GothamBold
   b.TextSize=13
   b.Text=text
   b.Parent=panel
   b.MouseButton1Click:Connect(callback)
   return b
  end
  label("parl0v Hub | Rare Scanner",35)
  state.labels.status=label("OFF | Press L to toggle",35)
  button("START / STOP  [L]",toggle)
  button("Rare Names: ON/OFF",function()
   state.scanNames=not state.scanNames
   setStatus("Rare names: "..tostring(state.scanNames))
  end)
  button("Price > 100,000: ON/OFF",function()
   state.scanPrices=not state.scanPrices
   setStatus("Price filter: "..tostring(state.scanPrices))
  end)
  button("Alerts: ON/OFF",function()
   state.alerts=not state.alerts
   setStatus("Alerts: "..tostring(state.alerts))
  end)
  label("Auto Hunt / Sell / Truck: not implemented",30)
  label("Only visible names & explicit prices can be scanned.",35)
  button("CLOSE MENU",function() gui.Enabled=false end)
 end)
 if not ok then log("GUI error: "..tostring(err)) end
else
 log("GUI unavailable: Instance.new missing; use L or parl0vToggle()")
end
if task and type(task.spawn)=="function" and type(task.wait)=="function" then
 task.spawn(function()
  while state.alive do
   task.wait(3)
   if state.enabled then scan() end
  end
 end)
else
 log("Background scan unavailable")
end
log("Loaded | L toggles ON/OFF | starts OFF")
