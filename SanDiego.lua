local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "San Diego Border RP | Full Auto-Farm",
   LoadingTitle = "Завантаження скрипта...",
   LoadingSubtitle = "Full Code Edition",
   ConfigurationSaving = { Enabled = false }
})

-- Сервіси Roblox
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Збережені базові координати
local BuyPos = Vector3.new(6820.7, 18.0, 16.6)
local SellPos = Vector3.new(-79.56, 38.0, 428.46)
local LaunderPos = Vector3.new(6806.9, 16.0, -36.34)
local BankPos = Vector3.new(6820.7, 18.0, 16.6) -- Резервна точка для банку/банкомату

local IsFarming = false
local AutoBank = false

-- Функція точного миттєвого телепорту без збоїв фізики
local function instantTP(targetPos)
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   local hrp = char.HumanoidRootPart

   -- Скидаємо будь-яку швидкість і задаємо позицію
   hrp.AssemblyLinearVelocity = Vector3.zero
   hrp.CFrame = CFrame.new(targetPos)
   
   -- Заморожуємо на 0.15 сек проти відкидання античітом
   hrp.Anchored = true
   task.wait(0.15)
   hrp.Anchored = false
end

-- Взаємодія з промптом або клавішею E
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
   task.wait(1.0)
   VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
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
               -- 1. Зняття / Банкомат (якщо увімкнено)
               if AutoBank and IsFarming then
                  instantTP(BankPos)
                  task.wait(0.4)
                  interact()
                  task.wait(1.2)
               end

               -- 2. Закупівля
               if not IsFarming then break end
               instantTP(BuyPos)
               task.wait(0.4)
               interact()
               task.wait(1.2)

               -- 3. Продаж
               if not IsFarming then break end
               instantTP(SellPos)
               task.wait(0.4)
               interact()
               task.wait(1.2)

               -- 4. Відмивання
               if not IsFarming then break end
               instantTP(LaunderPos)
               task.wait(0.4)
               interact()
               task.wait(1.2)
            end
         end)
      end
   end,
})

FarmTab:CreateToggle({
   Name = "Включити забір грошей (Банк)",
   CurrentValue = false,
   Callback = function(val)
      AutoBank = val
   end,
})

-- ========================================================
-- 2. ВКЛАДКА: НАЛАШТУВАННЯ ТОЧОК (Збереження на місці)
-- ========================================================
local SetupTab = Window:CreateTab("Налаштування Точок", 4483362458)

SetupTab:CreateButton({
   Name = "Записати ПОТОЧНЕ місце як ЗАКУПІВЛЮ",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         BuyPos = LocalPlayer.Character.HumanoidRootPart.Position
         Rayfield:Notify({ Title = "Точка 1", Content = "Закупівлю оновлено!", Duration = 3 })
      end
   end,
})

SetupTab:CreateButton({
   Name = "Записати ПОТОЧНЕ місце як ПРОДАЖ",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         SellPos = LocalPlayer.Character.HumanoidRootPart.Position
         Rayfield:Notify({ Title = "Точка 2", Content = "Продаж оновлено!", Duration = 3 })
      end
   end,
})

SetupTab:CreateButton({
   Name = "Записати ПОТОЧНЕ місце як ВІДМИВАННЯ",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         LaunderPos = LocalPlayer.Character.HumanoidRootPart.Position
         Rayfield:Notify({ Title = "Точка 3", Content = "Відмивання оновлено!", Duration = 3 })
      end
   end,
})

SetupTab:CreateButton({
   Name = "Записати ПОТОЧНЕ місце як БАНК / ЗНІМАННЯ",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         BankPos = LocalPlayer.Character.HumanoidRootPart.Position
         Rayfield:Notify({ Title = "Точка Банку", Content = "Знімання грошей оновлено!", Duration = 3 })
      end
   end,
})

-- ========================================================
-- 3. ВКЛАДКА: СЕРВІС
-- ========================================================
local SettingsTab = Window:CreateTab("Налаштування", 4483362458)
SettingsTab:CreateButton({
   Name = "Вигрузити Скрипт",
   Callback = function()
      IsFarming = false
      Rayfield:Destroy()
   end,
})
