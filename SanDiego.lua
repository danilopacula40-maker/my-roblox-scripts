local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "San Diego Border RP | Fixed Hub",
   LoadingTitle = "Завантаження скрипта...",
   LoadingSubtitle = "by ya_gay",
   ConfigurationSaving = { Enabled = false }
})

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Змінні точок
local BuyPos = Vector3.new(6820.7, 18.0, 16.6)
local SellPos = Vector3.new(-79.56, 38.0, 428.46)
local LaunderPos = Vector3.new(6806.9, 16.0, -36.34)

local IsFarming = false
local FlySpeed = 100
local NoclipConn = nil

-- Noclip (проходження крізь стіни під час польоту)
local function enableNoclip(state)
   if state then
      NoclipConn = RunService.Stepped:Connect(function()
         if LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
               if v:IsA("BasePart") then
                  v.CanCollide = false
               end
            end
         end
      end)
   else
      if NoclipConn then
         NoclipConn:Disconnect()
         NoclipConn = nil
      end
   end
end

-- Надійна функція перельоту через CFrame Step
local function moveToPos(targetPos)
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   local hrp = char.HumanoidRootPart

   enableNoclip(true)

   while IsFarming and (hrp.Position - targetPos).Magnitude > 4 do
      local direction = (targetPos - hrp.Position).Unit
      local distance = (hrp.Position - targetPos).Magnitude
      local step = math.min(distance, FlySpeed * 0.03)
      
      hrp.CFrame = CFrame.new(hrp.Position + direction * step)
      task.wait(0.01)
   end

   enableNoclip(false)
end

-- Взаємодія з промптом
local function interact()
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   
   for _, prompt in pairs(Workspace:GetDescendants()) do
      if prompt:IsA("ProximityPrompt") then
         local dist = (char.HumanoidRootPart.Position - prompt.Parent:GetPivot().Position).Magnitude
         if dist <= 25 then
            fireproximityprompt(prompt)
            break
         end
      end
   end

   VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
   task.wait(1.2)
   VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- ========================================================
-- ВКЛАДКА: АВТО-ФАРМ
-- ========================================================
local FarmTab = Window:CreateTab("Авто Фарм", 4483362458)

FarmTab:CreateSlider({
   Name = "Швидкість польоту",
   Range = {30, 250},
   Increment = 10,
   Suffix = " studs/s",
   CurrentValue = 100,
   Callback = function(val) FlySpeed = val end,
})

FarmTab:CreateButton({
   Name = "Зберегти поточні координати як ЗАКУПІВЛЮ",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         BuyPos = LocalPlayer.Character.HumanoidRootPart.Position
         Rayfield:Notify({ Title = "Успіх", Content = "Точку купівлі оновлено!", Duration = 3 })
      end
   end,
})

FarmTab:CreateButton({
   Name = "Зберегти поточні координати як ПРОДАЖ",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         SellPos = LocalPlayer.Character.HumanoidRootPart.Position
         Rayfield:Notify({ Title = "Успіх", Content = "Точку продажу оновлено!", Duration = 3 })
      end
   end,
})

FarmTab:CreateToggle({
   Name = "Старт Авто-Фарму",
   CurrentValue = false,
   Callback = function(val)
      IsFarming = val
      if not val then
         enableNoclip(false)
      else
         task.spawn(function()
            while IsFarming do
               -- 1. Закупівля
               moveToPos(BuyPos)
               if not IsFarming then break end
               task.wait(0.5)
               interact()
               task.wait(1.5)

               -- 2. Продаж
               moveToPos(SellPos)
               if not IsFarming then break end
               task.wait(0.5)
               interact()
               task.wait(1.5)

               -- 3. Відмивання
               moveToPos(LaunderPos)
               if not IsFarming then break end
               task.wait(0.5)
               interact()
               task.wait(1.5)
            end
         end)
      end
   end,
})

-- ========================================================
-- ВКЛАДКА: НАЛАШТУВАННЯ
-- ========================================================
local SettingsTab = Window:CreateTab("Налаштування", 4483362458)
SettingsTab:CreateButton({
   Name = "Вигрузити Скрипт",
   Callback = function()
      IsFarming = false
      enableNoclip(false)
      Rayfield:Destroy()
   end,
})
