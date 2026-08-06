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
local LocalPlayer = Players.LocalPlayer

-- Координати фарму (за потреби можна скоригувати під карту)
local BUY_RINGS_POS = Vector3.new(450, 10, 850)
local SELL_PARKING_POS = Vector3.new(-120, 15, -300)

-- Функція плавного переміщення (Float / Tween)
local function floatTo(targetPos, speed)
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      local hrp = LocalPlayer.Character.HumanoidRootPart
      local distance = (hrp.Position - targetPos).Magnitude
      local duration = distance / (speed or 120)

      local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
      local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
      tween:Play()
      tween.Completed:Wait()
   end
end

-- ========================================================
-- 1. ВКЛАДКА: АВТО-ФАРМ
-- ========================================================
local FarmTab = Window:CreateTab("Авто Фарм", 4483362458)
local FarmRings = false
local FarmSpeed = 120

FarmTab:CreateSlider({
   Name = "Швидкість полету (Float Speed)",
   Range = {50, 250},
   Increment = 10,
   Suffix = " studs/s",
   CurrentValue = 120,
   Flag = "FarmSpeedSlider",
   Callback = function(Value)
      FarmSpeed = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Авто-Фарм Бандитів (Закуп Кільця -> Парковка -> Продаж)",
   CurrentValue = false,
   Callback = function(Value)
      FarmRings = Value
      if Value then
         task.spawn(function()
            while FarmRings do
               -- 1. Ллетимо до закупівлі кілець
               floatTo(BUY_RINGS_POS, FarmSpeed)
               if not FarmRings then break end
               task.wait(0.5)

               -- Спроба купівлі (Взаємодія з промптом / ремоутом)
               for _, obj in pairs(Workspace:GetDescendants()) do
                  if obj:IsA("ProximityPrompt") and (obj.Parent.Name:lower():find("ring") or obj.Parent.Name:lower():find("кольц") or obj.Parent.Name:lower():find("dealer")) then
                     fireproximityprompt(obj)
                  end
               end
               task.wait(1)

               -- 2. Ллетимо на парковку для продажу
               floatTo(SELL_PARKING_POS, FarmSpeed)
               if not FarmRings then break end
               task.wait(0.5)

               -- Спроба продажу
               for _, obj in pairs(Workspace:GetDescendants()) do
                  if obj:IsA("ProximityPrompt") and (obj.Parent.Name:lower():find("sell") or obj.Parent.Name:lower():find("parking") or obj.Parent.Name:lower():find("покуп")) then
                     fireproximityprompt(obj)
                  end
               end
               task.wait(1)
            end
         end)
      end
   end,
})

-- ========================================================
-- 2. ВКЛАДКА: ПЕРСОНАЖ / NOCLIP
-- ========================================================
local PlayerTab = Window:CreateTab("Персонаж", 4483362458)
local NoclipAll = false
local NoclipConnection = nil

PlayerTab:CreateToggle({
   Name = "Повний Noclip (Крізь усі стіни)",
   CurrentValue = false,
   Callback = function(Value)
      NoclipAll = Value
      if Value then
         NoclipConnection = RunService.Stepped:Connect(function()
            if NoclipAll and LocalPlayer.Character then
               for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                  if part:IsA("BasePart") then part.CanCollide = false end
               end
            end
         end)
      else
         if NoclipConnection then NoclipConnection:Disconnect() end
      end
   end,
})

PlayerTab:CreateButton({
   Name = "Прибрати колізію шлагбаумів (Одноразово)",
   Callback = function()
      local count = 0
      for _, obj in pairs(Workspace:GetDescendants()) do
         if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("gate") or name:find("barrier") or name:find("door") or name:find("шлагбаум") or name:find("ворота") then
               obj.CanCollide = false
               count = count + 1
            end
         end
      end
      Rayfield:Notify({ Title = "Noclip", Content = "Вимкнено колізію для " .. tostring(count) .. " об'єктів.", Duration = 3 })
   end,
})

-- ========================================================
-- 3. ВКЛАДКА: ESP / ВІЗУАЛИ
-- ========================================================
local ESPTab = Window:CreateTab("ESP / Візуали", 4483362458)
local PlayerESP = false
local PrinterESP = false

local function getPlayerWantedLevel(plr)
    if plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Wanted") then
        return plr.leaderstats.Wanted.Value
    end
    local dataFolder = plr:FindFirstChild("PlayerData") or plr:FindFirstChild("Stats") or plr:FindFirstChild("Data")
    if dataFolder then
        local wantedVal = dataFolder:FindFirstChild("Wanted") or dataFolder:FindFirstChild("WantedLevel") or dataFolder:FindFirstChild("Stars")
        if wantedVal then return wantedVal.Value end
    end
    if plr.Character then
        local char = plr.Character
        local wantedVal = char:FindFirstChild("Wanted") or char:FindFirstChild("WantedLevel") or char:FindFirstChild("Stars")
        if wantedVal then return wantedVal.Value end
        local attrWanted = char:GetAttribute("Wanted") or char:GetAttribute("WantedLevel") or plr:GetAttribute("Wanted")
        if attrWanted then return attrWanted end
    end
    return 0
end

ESPTab:CreateToggle({
   Name = "ESP Гравців (Нік + Розшук)",
   CurrentValue = false,
   Callback = function(Value)
      PlayerESP = Value
      if Value then
         task.spawn(function()
            while PlayerESP do
               for _, plr in pairs(Players:GetPlayers()) do
                  if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                     local char = plr.Character
                     local head = char.Head

                     if not head:FindFirstChild("PlayerESP_Gui") then
                        local bgui = Instance.new("BillboardGui")
                        bgui.Name = "PlayerESP_Gui"
                        bgui.Adornee = head
                        bgui.Size = UDim2.new(0, 200, 0, 40)
                        bgui.StudsOffset = Vector3.new(0, 2.5, 0)
                        bgui.AlwaysOnTop = true

                        local label = Instance.new("TextLabel")
                        label.Name = "ESPLabel"
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.SourceSansBold
                        label.TextSize = 14
                        label.Parent = bgui
                        bgui.Parent = head
                     end

                     local wantedCount = getPlayerWantedLevel(plr)
                     local label = head.PlayerESP_Gui.ESPLabel
                     if wantedCount > 0 then
                        label.TextColor3 = Color3.fromRGB(255, 60, 60)
                        label.Text = string.format("%s\n[🚨 РОЗШУК: %s]", plr.Name, tostring(wantedCount))
                     else
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.Text = string.format("%s\n[Розшук: 0]", plr.Name)
                     end
                  end
               end
               task.wait(0.5)
            end
         end)
      else
         for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Head:FindFirstChild("PlayerESP_Gui") then
               plr.Character.Head.PlayerESP_Gui:Destroy()
            end
         end
      end
   end,
})

ESPTab:CreateToggle({
   Name = "ESP на Принтери Грошей",
   CurrentValue = false,
   Callback = function(Value)
      PrinterESP = Value
      for _, obj in pairs(Workspace:GetDescendants()) do
         if obj:IsA("Model") and (obj.Name:lower():find("printer") or obj.Name:lower():find("money")) then
            local highlight = obj:FindFirstChild("PrinterHighlight")
            if Value then
               if not highlight then
                  highlight = Instance.new("Highlight")
                  highlight.Name = "PrinterHighlight"
                  highlight.FillColor = Color3.fromRGB(0, 255, 120)
                  highlight.Parent = obj
               end
            else
               if highlight then highlight:Destroy() end
            end
         end
      end
   end,
})

-- ========================================================
-- 4. ВКЛАДКА: БОЙ / БЕЗСМЕРТЯ (GODMODE)
-- ========================================================
local CombatTab = Window:CreateTab("Бой / Безсмертя", 4483362458)
local GodmodeEnabled = false

CombatTab:CreateToggle({
   Name = "Godmode (Безсмертя / Авто-HP)",
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
      else
         if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            hum.MaxHealth = 100
            hum.Health = 100
         end
      end
   end,
})

-- ========================================================
-- 5. ВКЛАДКА: ТЕЛЕПОРТИ (TELEPORTS)
-- ========================================================
local TeleportTab = Window:CreateTab("Телепорти", 4483362458)

TeleportTab:CreateButton({
   Name = "Телепорт: Головний Кордон",
   Callback = function() floatTo(Vector3.new(120, 15, -450), 200) end,
})

TeleportTab:CreateButton({
   Name = "Телепорт: Поліцейський Участок",
   Callback = function() floatTo(Vector3.new(-340, 12, 210), 200) end,
})

TeleportTab:CreateButton({
   Name = "Телепорт: Спавн Бандитів",
   Callback = function() floatTo(Vector3.new(520, 10, 890), 200) end,
})

-- ========================================================
-- 6. ВКЛАДКА: НАЛАШТУВАННЯ
-- ========================================================
local SettingsTab = Window:CreateTab("Налаштування", 4483362458)
SettingsTab:CreateButton({
   Name = "Вигрузити Скрипт",
   Callback = function()
      if NoclipConnection then NoclipConnection:Disconnect() end
      Rayfield:Destroy()
   end,
})
