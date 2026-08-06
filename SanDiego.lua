local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "San Diego Border RP | Instant TP Farm",
   LoadingTitle = "Завантаження...",
   LoadingSubtitle = "Instant Teleport Edition",
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

-- Функція МИТТЄВОГО ТЕЛЕПОРТУ (без польоту)
local function instantTP(targetPos)
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   local hrp = char.HumanoidRootPart

   -- ТЕЛЕПОРТ: Одразу переміщуємо CFrame у потрібну позицію
   hrp.AssemblyLinearVelocity = Vector3.zero
   hrp.CFrame = CFrame.new(targetPos)
   
   -- Короткочасна фіксація (0.1 сек), щоб сервер не відкинув назад
   hrp.Anchored = true
   task.wait(0.1)
   hrp.Anchored = false
end

-- Взаємодія з продавцем (ProximityPrompt або E)
local function interact()
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   
   local targetPrompt = nil
   for _, prompt in pairs(Workspace:GetDescendants()) do
      if prompt:IsA("ProximityPrompt") then
         local dist = (char.HumanoidRootPart.Position - prompt.Parent:GetPivot().Position).Magnitude
         if dist <= 20 then
            targetPrompt = prompt
            break
         end
      end
   end

   if targetPrompt then
      fireproximityprompt(targetPrompt)
   end

   VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
   task.wait(0.8)
   VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- ========================================================
-- 1. ВКЛАДКА: АВТО ФАРМ
-- ========================================================
local FarmTab = Window:CreateTab("Авто Фарм", 4483362458)

FarmTab:CreateToggle({
   Name = "Запустити Миттєвий Авто-Фарм",
   CurrentValue = false,
   Callback = function(val)
      IsFarming = val
      if val then
         task.spawn(function()
            while IsFarming do
               -- 1. Миттєвий телепорт на Закупівлю
               instantTP(BuyPos)
               if not IsFarming then break end
               task.wait(0.3)
               interact()
               task.wait(1.0)

               -- 2. Миттєвий телепорт на Продаж
               instantTP(SellPos)
               if not IsFarming then break end
               task.wait(0.3)
               interact()
               task.wait(1.0)

               -- 3. Миттєвий телепорт на Відмивання
               instantTP(LaunderPos)
               if not IsFarming then break end
               task.wait(0.3)
               interact()
               task.wait(1.0)
            end
         end)
      end
   end
})

-- ========================================================
-- 2. ВКЛАДКА: ОТРЕМАННЯ КООРДИНАТ (F9)
-- ========================================================
local CoordsTab = Window:CreateTab("Координати", 4483362458)

CoordsTab:CreateButton({
   Name = "Вивести поточні координати в F9",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         local pos = LocalPlayer.Character.HumanoidRootPart.Position
         local formattedPos = string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
         print("--- ТЕПЕРЕШНІ КООРДИНАТИ ---")
         print(formattedPos)
         Rayfield:Notify({ Title = "Координати у F9", Content = formattedPos, Duration = 4 })
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
