-- UI & Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables
local gui = Instance.new("ScreenGui", game.CoreGui)
local toggleButton = Instance.new("TextButton")
local mainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local dragging, dragInput, dragStart, startPos

-- Toggle Button (≡)
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(0, 100, 0, 100)
toggleButton.Text = "≡"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.Parent = gui
UICorner.Parent = toggleButton

-- Main Frame (Menu)
mainFrame.Size = UDim2.new(0, 160, 0, 230)
mainFrame.Position = UDim2.new(0, 140, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Visible = false
mainFrame.Parent = gui
UICorner:Clone().Parent = mainFrame

-- Gradient for Buttons
local function createGradient(button)
    local UIStroke = Instance.new("UIStroke", button)
    UIStroke.Thickness = 2
    local Gradient = Instance.new("UIGradient", UIStroke)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 128)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
    }
end

-- Menu Buttons
local buttons = {}
local buttonNames = {"Начать бег", "Установить точку", "Телепорт к точке", "NoPlayerColl"}
for i, name in ipairs(buttonNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 20)
    btn.Position = UDim2.new(0, 10, 0, 60 + (i - 1) * 22)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = name
    btn.Parent = mainFrame
    createGradient(btn)
    buttons[name] = btn
end

-- Speed Input Field
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -20, 0, 20)
speedBox.Position = UDim2.new(0, 10, 0, 10)
speedBox.PlaceholderText = "Скорость (default 16)"
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
speedBox.Parent = mainFrame
createGradient(speedBox)

-- Speed Button
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(1, -20, 0, 20)
speedButton.Position = UDim2.new(0, 10, 0, 32)
speedButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
speedButton.TextColor3 = Color3.new(1, 1, 1)
speedButton.Text = "Установить скорость"
speedButton.Parent = mainFrame
createGradient(speedButton)

-- Support Button
local supportBtn = Instance.new("TextButton")
supportBtn.Size = UDim2.new(1, -20, 0, 20)
supportBtn.Position = UDim2.new(0, 10, 0, 60 + (#buttonNames) * 22)
supportBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
supportBtn.TextColor3 = Color3.new(1, 1, 1)
supportBtn.Text = "Поддержать автора @Ew3qs"
supportBtn.Parent = mainFrame
createGradient(supportBtn)

-- Dragging Toggle Button
local function makeDraggable(obj)
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(toggleButton)

-- Toggle Menu Visibility
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Action Variables
local targetPoint = nil
local noCollisions = false
local running = false
local walkSpeed = 16

-- NoPlayerColl
buttons["NoPlayerColl"].MouseButton1Click:Connect(function()
    noCollisions = not noCollisions
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide and not v:IsDescendantOf(LocalPlayer.Character) then
            v.CanCollide = not noCollisions
        end
    end
end)

-- Set Point
buttons["Установить точку"].MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        targetPoint = LocalPlayer.Character.HumanoidRootPart.Position
    end
end)

-- Teleport to Point
buttons["Телепорт к точке"].MouseButton1Click:Connect(function()
    if targetPoint then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPoint)
    end
end)

-- Speed Setting
speedButton.MouseButton1Click:Connect(function()
    local value = tonumber(speedBox.Text)
    if value and value > 0 then
        walkSpeed = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeed
        end
    end
end)

-- Copy Support Link
supportBtn.MouseButton1Click:Connect(function()
    setclipboard("https://www.donationalerts.com/r/Ew3qs")
end)

-- Beachball Auto Collect
buttons["Начать бег"].MouseButton1Click:Connect(function()
    running = not running
    if running then
        task.spawn(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = char:WaitForChild("Humanoid")
            local hrp = char:WaitForChild("HumanoidRootPart")
            humanoid.WalkSpeed = walkSpeed
            local map = nil

            for _, m in pairs(workspace:GetDescendants()) do
                if m:IsA("Model") and m:GetAttribute("MapID") then
                    map = m
                    break
                end
            end

            while running do
                if map and map:FindFirstChild("CoinContainer") then
                    local targetCoin = nil
                    local minDist = math.huge
                    for _, coin in ipairs(map.CoinContainer:GetChildren()) do
                        if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                            local cv = coin:FindFirstChild("CoinVisual")
                            if cv and cv.Transparency ~= 1 then
                                local dist = (hrp.Position - coin.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    targetCoin = coin
                                end
                            end
                        end
                    end

                    if targetCoin then
                        local direction = (targetCoin.Position - hrp.Position).Unit
                        while (hrp.Position - targetCoin.Position).Magnitude > 3 and running do
                            local moveDir = direction + Vector3.new(
                                math.random(-10, 10)/50,
                                0,
                                math.random(-10, 10)/50
                            )
                            humanoid:MoveTo(hrp.Position + moveDir * 5)

                            if math.random() < 0.05 then
                                humanoid.Jump = true
                            end
                            task.wait(0.1)
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    end
end)