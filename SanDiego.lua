local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "San Diego Border RP | Ultimate Hub",
   LoadingTitle = "Завантаження скрипта...",
   LoadingSubtitle = "by ya_gay",
   ConfigurationSaving = { Enabled = false }
})

-- Сервіси Roblox
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Змінні для координат
local BuyPos = nil
local SellPos = nil
local SavedCFrame = nil

-- Функція перельоту (Float)
local function floatTo(targetPos, speed)
   if not targetPos or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
   local hrp = LocalPlayer.Character.HumanoidRootPart
   local distance = (hrp.Position - targetPos).Magnitude
   local duration = distance / (speed or 120)

   local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
   local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
   tween:Play()
   tween.Completed:Wait()
end

-- Взаємодія з промптами та клавішею E
local function interactWithVendor()
   for _, obj in pairs(Workspace:GetDescendants()) do
      if obj:IsA("ProximityPrompt") then
         if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Parent:GetPivot().Position).Magnitude
            if dist < 20 then
               fireproximityprompt(obj)
            end
         end
      end
   end
   
   VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
   task.wait(0.1)
   VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- ========================================================
-- 1. ВКЛАДКА: АВТО-ФАРМ
-- ========================================================
local FarmTab = Window:CreateTab("Авто Фарм", 4483362458)
local FarmRings = false
local FarmSpeed = 120

FarmTab:CreateSlider({
   Name = "Швидкість польоту",
   Range = {50, 300},
   Increment = 10,
   Suffix = " studs/s",
   CurrentValue = 120,
   Callback = function(Value) FarmSpeed = Value end,
})

FarmTab:CreateButton({
   Name = "1. Зберегти точку КУПІВЛІ кілець",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         BuyPos = LocalPlayer.Character.HumanoidRootPart.Position
         Rayfield:Notify({ Title = "Фарм", Content = "Точку купівлі збережено!", Duration = 3 })
      end
   end,
})

FarmTab:CreateButton({
   Name = "2. Зберегти точку ПРОДАЖУ кілець",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         SellPos = LocalPlayer.Character.HumanoidRootPart.Position
         Rayfield:Notify({ Title = "Фарм", Content = "Точку продажу збережено!", Duration = 3 })
      end
   end,
})

FarmTab:CreateToggle({
   Name = "Старт Авто-Фарму (Купівля -> Переліт -> Продаж)",
   CurrentValue = false,
   Callback = function(Value)
      FarmRings = Value
      if Value then
         if not BuyPos or not SellPos then
            Rayfield:Notify({ Title = "Помилка", Content = "Спочатку збережіть обидві точки!", Duration = 4 })
            FarmRings = false
            return
         end

         task.spawn(function()
            while FarmRings do
               -- Ллетимо на купівлю
               floatTo(BuyPos, FarmSpeed)
               if not FarmRings then break end
               task.wait(0.5)
               interactWithVendor()
               task.wait(1.5)

               -- Ллетимо на продаж
               floatTo(SellPos, FarmSpeed)
               if not FarmRings then break end
               task.wait(0.5)
               interactWithVendor()
               task.wait(1.5)
            end
         end)
      end
   end,
})

-- ========================================================
-- 2. ВКЛАДКА: ТЕЛЕПОРТИ
-- ========================================================
local TeleportTab = Window:CreateTab("Телепорти", 4483362458)

TeleportTab:CreateButton({
   Name = "Зберегти поточну позицію",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
         Rayfield:Notify({ Title = "Телепорт", Content = "Позицію збережено!", Duration = 2 })
      end
   end,
})

TeleportTab:CreateButton({
   Name = "Телепорт до збереженої позиції",
   Callback = function()
      if SavedCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         floatTo(SavedCFrame.Position, FarmSpeed)
      end
   end,
})

TeleportTab:CreateButton({
   Name = "Телепорт: Головний Кордон",
   Callback = function() floatTo(Vector3.new(120, 15, -450), FarmSpeed) end,
})

TeleportTab:CreateButton({
   Name = "Телепорт: Поліцейський Участок",
   Callback = function() floatTo(Vector3.new(-340, 12, 210), FarmSpeed) end,
})

TeleportTab:CreateButton({
   Name = "Телепорт: Спавн Бандитів",
   Callback = function() floatTo(Vector3.new(520, 10, 890), FarmSpeed) end,
})

-- ========================================================
-- 3. ВКЛАДКА: БОЙ / БЕЗСМЕРТЯ
-- ========================================================
local CombatTab = Window:CreateTab("Бой / Безсмертя", 4483362458)
local GodmodeEnabled = false

CombatTab:CreateToggle({
   Name = "Godmode (Безсмертя)",
   CurrentValue = false,
   Callback = function(Value)
      GodmodeEnabled = Value
      if Value then
         task.spawn(function()
            while GodmodeEnabled do
               if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                  local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                  hum.MaxHealth = 999999
                  hum.Health = 999999
               end
               task.wait(0.1)
            end
         end)
      end
   end,
})

-- ========================================================
-- 4. ВКЛАДКА: НАЛАШТУВАННЯ
-- ========================================================
local SettingsTab = Window:CreateTab("Налаштування", 4483362458)
SettingsTab:CreateButton({
   Name = "Вигрузити Скрипт",
   Callback = function() Rayfield:Destroy() end,
})
