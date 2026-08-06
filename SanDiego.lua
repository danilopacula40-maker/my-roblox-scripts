local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "San Diego Border RP | Strict Instant TP",
   LoadingTitle = "Завантаження...",
   LoadingSubtitle = "No-Fly Instant Edition",
   ConfigurationSaving = { Enabled = false }
})

-- Сервіси Roblox
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Точні координати (за потреби оновлюйте тут)
local BuyPos = Vector3.new(6820.7, 18.0, 16.6)
local SellPos = Vector3.new(-79.56, 38.0, 428.46)
local LaunderPos = Vector3.new(6806.9, 16.0, -36.34)

local IsFarming = false

-- Абсолютно жорсткий миттєвий телепорт (виключає будь-який політ)
local function instantTP(targetPos)
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   local hrp = char.HumanoidRootPart
   local hum = char:FindFirstChildOfClass("Humanoid")

   -- Зупиняємо будь-яку фізику, щоб персонаж не летів
   if hum then hum.PlatformStand = true end
   hrp.AssemblyLinearVelocity = Vector3.zero
   hrp.AssemblyAngularVelocity = Vector3.zero

   -- Миттєвий перенос
   char:PivotTo(CFrame.new(targetPos))

   -- Заморожуємо на мілісекунду від античіту
   hrp.Anchored = true
   task.wait(0.1)
   hrp.Anchored = false
   if hum then hum.PlatformStand = false end
end

-- Універсальна взаємодія (затискає E потрібну кількість разів)
local function performAction(times, holdDuration)
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   
   for i = 1, (times or 1) do
      if not IsFarming then break end
      
      local targetPrompt = nil
      for _, prompt in pairs(Workspace:GetDescendants()) do
         if prompt:IsA("ProximityPrompt") then
            local dist = (char.HumanoidRootPart.Position - prompt.Parent:GetPivot().Position).Magnitude
            if dist <= 30 then
               targetPrompt = prompt
               break
            end
         end
      end

      if targetPrompt then
         fireproximityprompt(targetPrompt)
      end

      VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
      task.wait(holdDuration or 1.2)
      VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

      task.wait(0.3)
   end
end

-- ========================================================
-- 1. ВКЛАДКА: АВТО ФАРМ
-- ========================================================
local FarmTab = Window:CreateTab("Авто Фарм", 4483362458)

FarmTab:CreateToggle({
   Name = "Запустити Миттєвий Телепорт-Фарм",
   CurrentValue = false,
   Callback = function(val)
      IsFarming = val
      if val then
         task.spawn(function()
            while IsFarming do
               -- 1. ТП на закупівлю (Купуємо 5 кілець)
               instantTP(BuyPos)
               if not IsFarming then break end
               task.wait(0.3)
               performAction(5, 1.2)
               task.wait(0.3)

               -- 2. ТП на продаж (Здаємо кільця та отримуємо гроші)
               instantTP(SellPos)
               if not IsFarming then break end
               task.wait(0.3)
               performAction(5, 1.2)
               task.wait(0.3)

               -- 3. ТП на відмивання
               instantTP(LaunderPos)
               if not IsFarming then break end
               task.wait(0.3)
               performAction(3, 1.5)
               task.wait(0.5)
            end
         end)
      end
   end
})

-- ========================================================
-- 2. ВКЛАДКА: КООРДИНАТИ (F9)
-- ========================================================
local CoordsTab = Window:CreateTab("Координати", 4483362458)

CoordsTab:CreateButton({
   Name = "Вивести координати в F9",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         local pos = LocalPlayer.Character.HumanoidRootPart.Position
         local formattedPos = string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
         print("--- ПОТОЧНІ КООРДИНАТИ ---")
         print(formattedPos)
         Rayfield:Notify({ Title = "Консоль (F9)", Content = formattedPos, Duration = 4 })
      end
   end
})

-- ========================================================
-- 3. ВКЛАДКА: НАЛАШТУВАННЯ
-- ========================================================
local SettingsTab = Window:CreateTab("Налаштування", 4483362458)
SettingsTab:CreateButton({
   Name = "Вигрузити Скрипт",
   Callback = function()
      IsFarming = false
      Rayfield:Destroy()
   end
})
