-- DeltaX BeachBall GUI & Functions (compact, mobile+PC, all features)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local dragging, dragInput, dragStart, startPos
local point = nil
local collecting = false
local flying = false
local noCollide = false
local walkSpeed = 16

-- Ограничения на координаты для безопасного телепорта
local minX, maxX = -999999, 999999
local minY, maxY = -999999, 999999
local minZ, maxZ = -999999, 999999

local function safeVector3(pos)
    local x = math.max(math.min(pos.X, maxX), minX)
    local y = math.max(math.min(pos.Y, maxY), minY)
    local z = math.max(math.min(pos.Z, maxZ), minZ)
    return Vector3.new(x, y, z)
end

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "DeltaXBeachBallUI"
gui.Parent = game:GetService("CoreGui")

local dragBtn = Instance.new("TextButton")
dragBtn.Text = "="
dragBtn.Size = UDim2.new(0, 28, 0, 28)
dragBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
dragBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
dragBtn.TextColor3 = Color3.fromRGB(255,255,255)
dragBtn.Parent = gui
dragBtn.ZIndex = 20
dragBtn.AutoButtonColor = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 152, 0, 212)
frame.Position = UDim2.new(0.25, 0, 0.18, 0) -- раздельное положение с "="
frame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
frame.Visible = false
frame.Parent = gui
frame.ZIndex = 19

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 2
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 9)

-- Drag logic for mobile/PC (каждый элемент отдельно)
local function makeDraggable(guiObj)
    guiObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObj.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) and 
           (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(dragBtn)
makeDraggable(frame)

-- Show/hide window (отдельно от "=")
dragBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Button creator (compact buttons)
local function createButton(text, posY)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.87, 0, 0, 20)
    btn.Position = UDim2.new(0.06, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = text
    btn.TextSize = 13
    btn.Font = Enum.Font.Code
    btn.ZIndex = 21
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 1
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 5)
    return btn
end

-- UI Elements
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0.57, 0, 0, 20)
speedBox.Position = UDim2.new(0.07, 0, 1, -27)
speedBox.PlaceholderText = "Скорость"
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
speedBox.Text = ""
speedBox.TextSize = 13
speedBox.Font = Enum.Font.Code
speedBox.ZIndex = 21
local speedCorner = Instance.new("UICorner", speedBox)
speedCorner.CornerRadius = UDim.new(0, 5)

local setSpeedBtn = Instance.new("TextButton", frame)
setSpeedBtn.Size = UDim2.new(0.29, 0, 0, 20)
setSpeedBtn.Position = UDim2.new(0.66, 0, 1, -27)
setSpeedBtn.Text = "Уст."
setSpeedBtn.TextColor3 = Color3.fromRGB(255,255,255)
setSpeedBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
setSpeedBtn.TextSize = 13
setSpeedBtn.Font = Enum.Font.Code
setSpeedBtn.ZIndex = 21
local setSpeedCorner = Instance.new("UICorner", setSpeedBtn)
setSpeedCorner.CornerRadius = UDim.new(0, 5)

local setPointBtn = createButton("Установить точку", 8)
local tpBtn = createButton("Телепорт к точке", 32)
local collectBtn = createButton("Сбор мячей", 56)
local flightBtn = createButton("Полет к мячам", 80)
local npcBtn = createButton("NoPlayerColl", 104)
local supportBtn = createButton("Поддержать автора", 128)

-- @Ew3qs donate link
local supportUrl = "https://www.donationalerts.com/r/Ew3qs"

-- Button toggles
local toggles = {
    collect = false,
    flight = false,
    nocollide = false,
}

-- Сохраняем состояние коллизии карты для восстановления
local lastCollisions = {}

local function setMapCollision(state)
    -- Сохраняем начальные значения при отключении
    if not state then
        lastCollisions = {}
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                lastCollisions[v] = v.CanCollide
                v.CanCollide = false
            end
        end
    else
        -- Восстанавливаем значения
        for part, collide in pairs(lastCollisions) do
            if part and part.Parent then
                part.CanCollide = collide
            end
        end
        lastCollisions = {}
    end
end

-- Установить скорость
setSpeedBtn.MouseButton1Click:Connect(function()
    local val = tonumber(speedBox.Text)
    if val and val > 0 and val <= 400 then
        walkSpeed = val
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = walkSpeed
        end
    else
        speedBox.Text = ""
    end
end)

-- Установить точку
setPointBtn.MouseButton1Click:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        point = safeVector3(hrp.Position)
        setPointBtn.Text = "Точка установлена!"
        task.wait(0.75)
        setPointBtn.Text = "Установить точку"
    end
end)

-- Телепорт к точке
tpBtn.MouseButton1Click:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and point then
        hrp.CFrame = CFrame.new(safeVector3(point))
    end
end)

-- Сбор мячей (toggle, с 1s задержкой и имитацией W)
collectBtn.MouseButton1Click:Connect(function()
    toggles.collect = not toggles.collect
    collectBtn.Text = toggles.collect and "Сбор: ВКЛ" or "Сбор мячей"
    if not toggles.collect then return end
    spawn(function()
        while toggles.collect do
            -- Поиск карты и контейнера
            local map, container
            for _, m in pairs(workspace:GetChildren()) do
                if m:IsA("Model") and m:GetAttribute("MapID") then
                    map = m
                    break
                end
            end
            if map then container = map:FindFirstChild("CoinContainer") end
            if not container then task.wait(1) continue end

            for _, coin in ipairs(container:GetChildren()) do
                if not toggles.collect then break end
                if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                    local cv = coin:FindFirstChild("CoinVisual")
                    if cv and cv.Transparency ~= 1 then
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- Телепорт к мячу
                            hrp.CFrame = CFrame.new(safeVector3(coin.Position))
                            task.wait(1) -- задержка между телепортами
                            -- "проходит вперед" (как W) — симуляция движения вперед
                            local dir2 = hrp.CFrame.LookVector
                            hrp.CFrame = hrp.CFrame + dir2 * 2
                            task.wait(0.2)
                            if point then
                                hrp.CFrame = CFrame.new(safeVector3(point))
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end)

-- Полет к мячам (оптимизированный и с восстановлением коллизии)
flightBtn.MouseButton1Click:Connect(function()
    toggles.flight = not toggles.flight
    flightBtn.Text = toggles.flight and "Полет: ВКЛ" or "Полет к мячам"
    if toggles.flight then
        spawn(function()
            workspace.FallenPartsDestroyHeight = -10000
            setMapCollision(false)
            while toggles.flight do
                -- Поиск ближайшего BeachBall
                local map, container
                for _, m in pairs(workspace:GetChildren()) do
                    if m:IsA("Model") and m:GetAttribute("MapID") then
                        map = m
                        break
                    end
                end
                if map then container = map:FindFirstChild("CoinContainer") end
                if not container then task.wait(1) continue end

                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local found = false
                for _, coin in ipairs(container:GetChildren()) do
                    if not toggles.flight then break end
                    if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                        local cv = coin:FindFirstChild("CoinVisual")
                        if cv and cv.Transparency ~= 1 and hrp then
                            found = true
                            local maxSteps = 100 -- максимум шагов на один мяч
                            local steps = 0
                            local dist = (hrp.Position - coin.Position).Magnitude
                            -- Если очень далеко - делаем пошагово, иначе телепортируемся
                            while toggles.flight and dist > 2 and steps < maxSteps do
                                local dir = (coin.Position - hrp.Position).Unit
                                hrp.CFrame = hrp.CFrame + dir * math.min(walkSpeed * 0.5, dist)
                                steps = steps + 1
                                task.wait(0.05)
                                dist = (hrp.Position - coin.Position).Magnitude
                            end
                            break
                        end
                    end
                end
                if not found then task.wait(1) end
            end
            setMapCollision(true)
        end)
    else
        setMapCollision(true)
    end
end)

-- NoPlayerColl (toggle)
npcBtn.MouseButton1Click:Connect(function()
    toggles.nocollide = not toggles.nocollide
    npcBtn.Text = toggles.nocollide and "NoColl: ВКЛ" or "NoPlayerColl"
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                if part.Name:lower():find("foot") or part.Name:lower():find("leg") then
                    part.CanCollide = true
                else
                    part.CanCollide = not toggles.nocollide
                end
            end
        end
    end
end)

-- Поддержать автора (копировать ссылку)
supportBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(supportUrl)
    else
        speedBox.Text = "Скопировано!"
        task.wait(1)
        speedBox.Text = ""
    end
end)

-- Anti-AFK
pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- Сброс кнопок при скрытии окна
frame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not frame.Visible then
        setPointBtn.Text = "Установить точку"
        collectBtn.Text = "Сбор мячей"
        flightBtn.Text = "Полет к мячам"
        npcBtn.Text = "NoPlayerColl"
    end
end)