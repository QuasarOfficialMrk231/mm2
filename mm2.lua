local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local dragging = false
local dragInput, mousePos, framePos
local autoFarmActive = false
local noPlayerCollideActive = false
local teleportPoint = nil
local walkSpeed = 16

-- UI Creation
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(0, 100, 0, 100)
ToggleButton.Text = "="
ToggleButton.TextScaled = true
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 270)
MainFrame.Position = UDim2.new(0, 150, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 150, 255)
UIStroke.Thickness = 2

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createButton(text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text

    local stroke = Instance.new("UIStroke", button)
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 1

    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 6)

    button.Parent = MainFrame
    return button
end

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, -10, 0, 30)
SpeedBox.PlaceholderText = "Speed (Default 16)"
SpeedBox.Text = ""
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Parent = MainFrame

local speedStroke = Instance.new("UIStroke", SpeedBox)
speedStroke.Color = Color3.fromRGB(0, 150, 255)
speedStroke.Thickness = 1

local speedCorner = Instance.new("UICorner", SpeedBox)
speedCorner.CornerRadius = UDim.new(0, 6)

local setSpeedButton = createButton("Установить скорость")
local autoFarmButton = createButton("Начать полет")
local setPointButton = createButton("Установить точку")
local teleportButton = createButton("Телепорт к точке")
local noPlayerCollButton = createButton("NoPlayerColl")
local supportButton = createButton("Поддержать автора")

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local function makeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(ToggleButton)
makeDraggable(MainFrame)

setSpeedButton.MouseButton1Click:Connect(function()
    local num = tonumber(SpeedBox.Text)
    if num then
        walkSpeed = num
    end
end)

supportButton.MouseButton1Click:Connect(function()
    setclipboard("https://www.donationalerts.com/r/Ew3qs")
end)

noPlayerCollButton.MouseButton1Click:Connect(function()
    noPlayerCollideActive = not noPlayerCollideActive
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide and v:IsDescendantOf(workspace.Characters) then
            v.CanCollide = not noPlayerCollideActive
        end
    end
end)

setPointButton.MouseButton1Click:Connect(function()
    teleportPoint = HumanoidRootPart.Position
end)

teleportButton.MouseButton1Click:Connect(function()
    if teleportPoint then
        HumanoidRootPart.CFrame = CFrame.new(teleportPoint)
    end
end)

autoFarmButton.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    if autoFarmActive then
        task.spawn(function()
            while autoFarmActive do
                local map = workspace:FindFirstChildWhichIsA("Model", true)
                if map and map:FindFirstChild("CoinContainer") then
                    for _, coin in ipairs(map.CoinContainer:GetChildren()) do
                        if not autoFarmActive then break end
                        if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                            local visual = coin:FindFirstChild("CoinVisual")
                            if visual and visual.Transparency ~= 1 then
                                local goal = {}
                                goal.CFrame = coin.CFrame + Vector3.new(0, 3, 0)

                                local tweenInfo = TweenInfo.new((HumanoidRootPart.Position - coin.Position).Magnitude / walkSpeed, Enum.EasingStyle.Linear)
                                local tween = TweenService:Create(HumanoidRootPart, tweenInfo, goal)
                                tween:Play()

                                tween.Completed:Wait()
                                task.wait(0.5 + math.random() * 1.5) -- Рандомные паузы
                                if math.random() < 0.3 then
                                    Character.Humanoid.Jump = true
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)