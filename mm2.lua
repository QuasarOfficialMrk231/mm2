local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")

local screenGui = Instance.new("ScreenGui", game.CoreGui)
local dragFrame = Instance.new("Frame", screenGui)
dragFrame.Size = UDim2.new(0, 200, 0, 30)
dragFrame.Position = UDim2.new(0, 100, 0, 100)
dragFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dragFrame.Active = true
dragFrame.Draggable = true

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 150)
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
toggleButton.TextSize = 18
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

local setPointButton = Instance.new("TextButton", mainFrame)
setPointButton.Size = UDim2.new(1, -20, 0, 30)
setPointButton.Position = UDim2.new(0, 10, 0, 10)
setPointButton.Text = "Установить точку"

local teleportButton = Instance.new("TextButton", mainFrame)
teleportButton.Size = UDim2.new(1, -20, 0, 30)
teleportButton.Position = UDim2.new(0, 10, 0, 50)
teleportButton.Text = "Телепорт к точке"

local collectButton = Instance.new("TextButton", mainFrame)
collectButton.Size = UDim2.new(1, -20, 0, 30)
collectButton.Position = UDim2.new(0, 10, 0, 90)
collectButton.Text = "Сбор мячей"

local noCollButton = Instance.new("TextButton", mainFrame)
noCollButton.Size = UDim2.new(1, -20, 0, 30)
noCollButton.Position = UDim2.new(0, 10, 0, 130)
noCollButton.Text = "NoPlayerColl"

local setSpeedBox = Instance.new("TextBox", mainFrame)
setSpeedBox.Size = UDim2.new(1, -20, 0, 30)
setSpeedBox.Position = UDim2.new(0, 10, 0, 170)
setSpeedBox.PlaceholderText = "Скорость"

local setSpeedButton = Instance.new("TextButton", mainFrame)
setSpeedButton.Size = UDim2.new(1, -20, 0, 30)
setSpeedButton.Position = UDim2.new(0, 10, 0, 210)
setSpeedButton.Text = "Установить скорость"

local supportButton = Instance.new("TextButton", mainFrame)
supportButton.Size = UDim2.new(1, -20, 0, 30)
supportButton.Position = UDim2.new(0, 10, 0, 250)
supportButton.Text = "Поддержать автора"

local savedPoint = nil
local noCollEnabled = false

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
    if noCollEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.CanCollide = false
            end
        end
    else
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.CanCollide = true
            end
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

local collecting = false
collectButton.MouseButton1Click:Connect(function()
    collecting = not collecting
    if collecting then
        spawn(function()
            while collecting do
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
                                    wait(0.1)
                                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
                                    wait(0.1)
                                    if savedPoint then
                                        hrp.CFrame = savedPoint
                                    end
                                end
                            end
                        end
                    end
                end
                wait(0.5)
            end
        end)
    end
end)