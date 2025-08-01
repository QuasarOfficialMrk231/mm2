-- // Инициализация
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local dragFrame = Instance.new("Frame", ScreenGui)
dragFrame.Size = UDim2.new(0, 200, 0, 250)
dragFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
dragFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dragFrame.Active = true
dragFrame.Draggable = true

local toggleButton = Instance.new("TextButton", ScreenGui)
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(0, 0, 0, 100)
toggleButton.Text = "="
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextSize = 20

local isGuiVisible = true
toggleButton.MouseButton1Click:Connect(function()
    isGuiVisible = not isGuiVisible
    dragFrame.Visible = isGuiVisible
end)

-- // Кнопки GUI
local function CreateButton(name, posY)
    local btn = Instance.new("TextButton", dragFrame)
    btn.Size = UDim2.new(1, -10, 0, 25)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextSize = 12
    return btn
end

local speedInput = Instance.new("TextBox", dragFrame)
speedInput.Size = UDim2.new(1, -10, 0, 25)
speedInput.Position = UDim2.new(0, 5, 0, 5)
speedInput.PlaceholderText = "Введите скорость"
speedInput.TextSize = 12

local setSpeedBtn = CreateButton("Установить скорость", 35)
local noPlayerCollBtn = CreateButton("NoPlayerColl", 65)
local flyToBallsBtn = CreateButton("Полет к мячам", 95)
local collectBallsBtn = CreateButton("Сбор мячей", 125)
local setPointBtn = CreateButton("Установить точку", 155)
local teleportToPointBtn = CreateButton("Телепорт к точке", 185)
local supportBtn = CreateButton("Поддержать @Ew3qs", 215)

-- // Переменные состояния
local flySpeed = 50
local noPlayerCollActive = false
local flyToBallsActive = false
local collectBallsActive = false
local savedPoint = nil

-- // Установить скорость
setSpeedBtn.MouseButton1Click:Connect(function()
    local val = tonumber(speedInput.Text)
    if val then
        flySpeed = val
    end
end)

-- // NoPlayerColl Toggle
noPlayerCollBtn.MouseButton1Click:Connect(function()
    noPlayerCollActive = not noPlayerCollActive
    for _, v in pairs(Character:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "LeftFoot" and v.Name ~= "RightFoot" then
            v.CanCollide = not noPlayerCollActive
        end
    end
end)

-- // Установить точку
setPointBtn.MouseButton1Click:Connect(function()
    if HumanoidRootPart then
        savedPoint = HumanoidRootPart.CFrame
    end
end)

-- // Телепорт к точке
teleportToPointBtn.MouseButton1Click:Connect(function()
    if savedPoint then
        HumanoidRootPart.CFrame = savedPoint
    end
end)

-- // Поддержка автора
supportBtn.MouseButton1Click:Connect(function()
    setclipboard("https://www.donationalerts.com/r/Ew3qs")
end)

-- // Fly To Balls Toggle
flyToBallsBtn.MouseButton1Click:Connect(function()
    flyToBallsActive = not flyToBallsActive
end)

-- // Collect Balls Toggle
collectBallsBtn.MouseButton1Click:Connect(function()
    collectBallsActive = not collectBallsActive
end)

-- // Поиск мячей
local function findNearestBall()
    local map = nil
    for _, m in pairs(workspace:GetDescendants()) do
        if m:IsA("Model") and m:GetAttribute("MapID") then
            map = m
            break
        end
    end
    if not map then return nil end

    local CoinContainer = map:FindFirstChild("CoinContainer")
    if not CoinContainer then return nil end

    for _, coin in ipairs(CoinContainer:GetChildren()) do
        if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
            local cv = coin:FindFirstChild("CoinVisual")
            if cv and cv.Transparency ~= 1 then
                return coin
            end
        end
    end
    return nil
end

-- // Полет к мячам цикл
RunService.RenderStepped:Connect(function()
    if flyToBallsActive then
        local ball = findNearestBall()
        if ball and HumanoidRootPart then
            local direction = (ball.Position - HumanoidRootPart.Position).Unit
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + direction * (flySpeed * RunService.RenderStepped:Wait())
        end
    end
end)

-- // Сбор мячей цикл
RunService.RenderStepped:Connect(function()
    if collectBallsActive then
        local ball = findNearestBall()
        if ball and savedPoint and HumanoidRootPart then
            HumanoidRootPart.CFrame = ball.CFrame
            task.wait(0.5)
            for i = 1, 3 do
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -1)
                task.wait(0.1)
            end
            HumanoidRootPart.CFrame = savedPoint
            task.wait(1)
        end
    end
end)

-- // Anti-Idle
local vu = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)