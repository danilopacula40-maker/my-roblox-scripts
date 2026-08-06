local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "San Diego Border RP | Full Hold Farm",
   LoadingTitle = "Завантаження...",
   LoadingSubtitle = "Auto-Buy & Sell Fixed",
   ConfigurationSaving = { Enabled = false }
})

-- Сервіси Roblox
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Жорстко закріплені координати
local BuyPos = Vector3.new(6820.7, 18.0, 16.6)
local SellPos = Vector3.new(-79.56, 38.0, 428.46)
local LaunderPos = Vector3.new(6806.9, 16.0, -36.34)

local IsFarming = false

-- Функція миттєвого телепорту
local function instantTP(targetPos)
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   local hrp = char.HumanoidRootPart

   hrp.AssemblyLinearVelocity = Vector3.zero
   hrp.CFrame = CFrame.new(targetPos)
   
   hrp.Anchored = true
   task.wait(0.15)
   hrp.Anchored = false
end

-- Універсальна функція взаємодії (затискає E певну кількість разів)
local function performAction(times, holdDuration)
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   
   for i = 1, (times or 1) do
      if not IsFarming then break end
      
      -- Шукаємо найближчий ProximityPrompt
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

      -- Затискаємо клавішу E
      VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
      task.wait(holdDuration or 1.2)
      VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

      task.wait(0.4) -- Пауза між повторами
   end
end

-- ========================================================
-- 1. ВКЛАДКА: АВТО ФАРМ
-- ========================================================
local FarmTab = Window:CreateTab("Авто Фарм", 4483362458)

FarmTab:CreateToggle({
   Name = "Запустити Повний Авто-Фарм",
   CurrentValue = false,
   Callback = function(val)
      IsFarming = val
      if val then
         task.spawn(function()
            while IsFarming do
               -- 1. ТП на закупівлю (Купуємо 5 кілець)
               instantTP(BuyPos)
               if not IsFarming then break end
               task.wait(0.5)
               performAction(5, 1.2) -- Цикл на 5 покупок по 1.2 сек затискання E
               task.wait(0.5)

               -- 2. ТП на продаж (Затискаємо кілька разів, щоб точно все здати і отримати гроші)
               instantTP(SellPos)
               if not IsFarming then break end
               task.wait(0.5)
               performAction(5, 1.2) -- 5 спроб продажу
               task.wait(0.5)

               -- 3. ТП на відмивання (Затискаємо відмивання грошей)
               instantTP(LaunderPos)
               if not IsFarming then break end
               task.wait(0.5)
               performAction(3, 1.5) -- 3 спроби відмивання
               task.wait(1.0)
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
