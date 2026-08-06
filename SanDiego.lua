local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "San Diego Border RP | Auto-Farm Hub",
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

-- Точні координати з ваших скріншотів
local BUY_POS = Vector3.new(6820.7, 20.15, 16.6)      -- 1. Закупівля кілець
local SELL_POS = Vector3.new(-79.56, 40.24, 428.46)   -- 2. Скупник (Продаж)
local LAUNDER_POS = Vector3.new(6806.9, 17.44, -36.34) -- 3. Відмивання грошей (Launder Cash)

-- Функція плавної левітації/перельоту
local function floatTo(targetPos, speed)
   if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
   local hrp = LocalPlayer.Character.HumanoidRootPart
   local distance = (hrp.Position - targetPos).Magnitude
   local duration = distance / (speed or 120)

   local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
   local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
   tween:Play()
   tween.Completed:Wait()
end

-- Автоматична взаємодія з підказками (E / ProximityPrompt)
local function interactWithVendor()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      local myPos = LocalPlayer.Character.HumanoidRootPart.Position
      for _, obj in pairs(Workspace:GetDescendants()) do
         if obj:IsA("ProximityPrompt") then
            local promptPos = obj.Parent:GetPivot().Position
            if (myPos - promptPos).Magnitude <= 20 then
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

FarmTab:CreateToggle({
   Name = "Повний Авто-Фарм (Закуп -> Продаж -> Відмивання)",
   CurrentValue = false,
   Callback = function(Value)
      FarmRings = Value
      if Value then
         task.spawn(function()
            while FarmRings do
               -- 1. Ллетимо на закупівлю
               floatTo(BUY_POS, FarmSpeed)
               if not FarmRings then break end
               task.wait(0.5)
               interactWithVendor()
               task.wait(1.5)

               -- 2. Ллетимо на продаж
               floatTo(SELL_POS, FarmSpeed)
               if not FarmRings then break end
               task.wait(0.5)
               interactWithVendor()
               task.wait(1.5)

               -- 3. Ллетимо на відмивання грошей
               floatTo(LAUNDER_POS, FarmSpeed)
               if not FarmRings then break end
               task.wait(0.5)
               interactWithVendor()
               task.wait(2.0)
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
   Name = "Телепорт: Закупівля кілець",
   Callback = function() floatTo(BUY_POS, FarmSpeed) end,
})

TeleportTab:CreateButton({
   Name = "Телепорт: Скупник (Продаж)",
   Callback = function() floatTo(SELL_POS, FarmSpeed) end,
})

TeleportTab:CreateButton({
   Name = "Телепорт: Пральні машини (Відмивання)",
   Callback = function() floatTo(LAUNDER_POS, FarmSpeed) end,
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
