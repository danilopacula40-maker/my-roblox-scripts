local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "San Diego Border RP | Auto-Farm",
   LoadingTitle = "Завантаження...",
   LoadingSubtitle = "by ya_gay",
   ConfigurationSaving = { Enabled = false }
})

-- Сервіси Roblox
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Збережені координати з ваших скріншотів
local BuyPos = Vector3.new(6820.7, 20.15, 16.6)
local SellPos = Vector3.new(-79.56, 40.24, 428.46)
local LaunderPos = Vector3.new(6806.9, 16.0, -36.34)

local IsFarming = false
local FlySpeed = 100
local NoclipConn = nil

-- Функція Noclip (проходження крізь стіни під час руху)
local function enableNoclip(state)
   if state then
      if not NoclipConn then
         NoclipConn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
               for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                  if v:IsA("BasePart") then
                     v.CanCollide = false
                  end
               end
            end
         end)
      end
   else
      if NoclipConn then
         NoclipConn:Disconnect()
         NoclipConn = nil
      end
   end
end

-- Надійна функція перельоту строго до вказаних координат
local function moveToPos(targetPos)
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   local hrp = char.HumanoidRootPart

   enableNoclip(true)

   while IsFarming and (hrp.Position - targetPos).Magnitude > 4 do
      if not IsFarming then break end

      local currentPos = hrp.Position
      local distance = (currentPos - targetPos).Magnitude
      local step = math.min(distance, FlySpeed * 0.02)
      
      local nextPos = currentPos + (targetPos - currentPos).Unit * step
      hrp.CFrame = CFrame.lookAt(nextPos, targetPos)
      
      task.wait(0.01)
   end

   -- Гасимо інерцію після прильоту або зупинки
   if hrp then
      hrp.AssemblyLinearVelocity = Vector3.zero
   end
   enableNoclip(false)
end

-- Автоматична взаємодія з ProximityPrompt або клавішею E
local function interact()
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   
   local targetPrompt = nil
   for _, prompt in pairs(Workspace:GetDescendants()) do
      if prompt:IsA("ProximityPrompt") then
         local dist = (char.HumanoidRootPart.Position - prompt.Parent:GetPivot().Position).Magnitude
         if dist <= 25 then
            targetPrompt = prompt
            break
         end
      end
   end

   if targetPrompt then
      fireproximityprompt(targetPrompt)
   end

   VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
   task.wait(1.2)
   VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- ========================================================
-- 1. ВКЛАДКА: АВТО ФАРМ
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

FarmTab:CreateToggle({
   Name = "Запустити Авто-Фарм",
   CurrentValue = false,
   Callback = function(val)
      IsFarming = val
      if not val then
         enableNoclip(false)
         if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
         end
      else
         task.spawn(function()
            while IsFarming do
               -- 1. Точка закупівлі
               moveToPos(BuyPos)
               if not IsFarming then break end
               task.wait(0.5)
               interact()
               task.wait(1.5)

               -- 2. Точка продажу
               moveToPos(SellPos)
               if not IsFarming then break end
               task.wait(0.5)
               interact()
               task.wait(1.5)

               -- 3. Точка відмивання
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

-- Кнопки оновлення координат у разі потреби
FarmTab:CreateButton({
   Name = "Оновити точку ЗАКУПІВЛІ (поточна позиція)",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         BuyPos = LocalPlayer.Character.HumanoidRootPart.Position
         Rayfield:Notify({ Title = "Успіх", Content = "Точку купівлі оновлено!", Duration = 3 })
      end
   end,
})

FarmTab:CreateButton({
   Name = "Оновити точку ПРОДАЖУ (поточна позиція)",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         SellPos = LocalPlayer.Character.HumanoidRootPart.Position
         Rayfield:Notify({ Title = "Успіх", Content = "Точку продажу оновлено!", Duration = 3 })
      end
   end,
})

-- ========================================================
-- 2. ВКЛАДКА: ТЕЛЕПОРТИ
-- ========================================================
local TeleportTab = Window:CreateTab("Телепорти", 4483362458)

TeleportTab:CreateButton({
   Name = "Політ до закупівлі",
   Callback = function()
      IsFarming = true
      moveToPos(BuyPos)
      IsFarming = false
   end,
})

TeleportTab:CreateButton({
   Name = "Політ до продажу",
   Callback = function()
      IsFarming = true
      moveToPos(SellPos)
      IsFarming = false
   end,
})

-- ========================================================
-- 3. ВКЛАДКА: НАЛАШТУВАННЯ
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
