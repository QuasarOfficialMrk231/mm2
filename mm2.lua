-- GUI Setup

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")

local screenGui = Instance.new("ScreenGui", game.CoreGui)

local dragFrame = Instance.new("Frame", screenGui)
dragFrame.Size = UDim2.new(0, 100, 0, 20)
dragFrame.Position = UDim2.new(0, 100, 0, 100)
dragFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dragFrame.Active = true
dragFrame.Draggable = true

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 120, 0, 180)
mainFrame.Position = UDim2.new(0, 100, 0, 130)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true

local UIStroke = Instance.new("UIStroke", mainFrame)
UIStroke.Color = Color3.fromRGB(0, 100, 255)
UIStroke.Thickness = 2

local toggleButton = Instance.new("TextButton", dragFrame)
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.Text = "="
toggleButton.TextSize = 14
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Buttons
local function createButton(text, posY)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(1, -10, 0, 20)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.Text = text
    btn.TextSize = 12
    return btn
end

local setPointButton = createButton("Установить точку", 10)
local teleportButton = createButton("Телепорт к точке", 35)
local collectButton = createButton("Сбор мячей", 60)
local flyCollectButton = createButton("Полет к мячам", 85)
local noCollButton = createButton("NoPlayerColl", 110)

local setSpeedBox = Instance.new("TextBox", mainFrame)
setSpeedBox.Size = UDim2.new(1, -10, 0, 20)
setSpeedBox.Position = UDim2.new(0, 5, 0, 135)
setSpeedBox.PlaceholderText = "Скорость"
setSpeedBox.TextSize = 12

local setSpeedButton = createButton("Установить скорость", 160)
local supportButton = createButton("Поддержать автора", 185)

-- Functionalities

local savedPoint = nil
local noCollEnabled = false
local flyingToBalls = false

setPointButton.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedPoint = player.Character.HumanoidRootPart.CFrame
    end
end)

teleportButton.MouseButton1Click:Connect(function()
    if savedPoint and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = savedPoint
    end
end)

noCollButton.MouseButton1Click:Connect(function()
    noCollEnabled = not noCollEnabled
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            v.Character.HumanoidRootPart.CanCollide = not noCollEnabled
        end
    end
end)

setSpeedButton.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = tonumber(setSpeedBox.Text)
    end
end)

supportButton.MouseButton1Click:Connect(function()
    setclipboard("https://www.donationalerts.com/r/Ew3qs")
end)

collectButton.MouseButton1Click:Connect(function()
    spawn(function()
        while true do
            local map = nil
            for _, m in pairs(workspace:GetChildren()) do
                if m:IsA("Model") and m:GetAttribute("MapID") then
                    map = m
                    break
                end
            end
            if map and map:FindFirstChild("CoinContainer") then
                for _, coin in ipairs(map.CoinContainer:GetChildren()) do
                    if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                        local cv = coin:FindFirstChild("CoinVisual")
                        if cv and cv.Transparency ~= 1 then
                            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = coin.CFrame
                                wait(0.3)
                                hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
                                wait(0.3)
                                if savedPoint then
                                    hrp.CFrame = savedPoint
                                end
                            end
                        end
                    end
                end
            end
            wait(1)
        end
    end)
end)

flyCollectButton.MouseButton1Click:Connect(function()
    flyingToBalls = not flyingToBalls
    if flyingToBalls then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = false
            end
        end
        spawn(function()
            while flyingToBalls do
                local map = nil
                for _, m in pairs(workspace:GetChildren()) do
                    if m:IsA("Model") and m:GetAttribute("MapID") then
                        map = m
                        break
                    end
                end
                if map and map:FindFirstChild("CoinContainer") then
                    for _, coin in ipairs(map.CoinContainer:GetChildren()) do
                        if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                            local cv = coin:FindFirstChild("CoinVisual")
                            if cv and cv.Transparency ~= 1 then
                                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local direction = (coin.Position - hrp.Position).Unit
                                    hrp.CFrame = hrp.CFrame + direction * 1.5 -- fly speed
                                end
                            end
                        end
                    end
                end
                wait(0.05)
            end
        end)
    else
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = true
            end
        end
    end
end)