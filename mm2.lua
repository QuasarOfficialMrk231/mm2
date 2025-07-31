local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

local dragging, dragInput, dragStart, startPos
local UI = Instance.new("ScreenGui", game.CoreGui)
UI.ResetOnSpawn = false

local FloatingButton = Instance.new("TextButton")
FloatingButton.Text = "="
FloatingButton.Size = UDim2.new(0, 40, 0, 40)
FloatingButton.Position = UDim2.new(0, 100, 0, 100)
FloatingButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.Parent = UI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 220)
MainFrame.Position = UDim2.new(0, 150, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = UI

local FrameDragArea = Instance.new("Frame", MainFrame)
FrameDragArea.Size = UDim2.new(1, 0, 0, 20)
FrameDragArea.BackgroundTransparency = 1

local function makeButton(name, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, position)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    local uiStroke = Instance.new("UIStroke", btn)
    uiStroke.Color = Color3.fromRGB(0, 120, 255)
    uiStroke.Thickness = 1.5
    return btn
end

local SpeedBox = Instance.new("TextBox", MainFrame)
SpeedBox.Size = UDim2.new(1, -20, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 30)
SpeedBox.PlaceholderText = "Speed"
SpeedBox.Text = ""
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UIStroke", SpeedBox).Color = Color3.fromRGB(0, 120, 255)

local SetSpeedBtn = makeButton("Set Speed", 70)
SetSpeedBtn.Parent = MainFrame

local StartFarmBtn = makeButton("Start Farm", 110)
StartFarmBtn.Parent = MainFrame

local SetPointBtn = makeButton("Set Point", 150)
SetPointBtn.Parent = MainFrame

local TPtoPointBtn = makeButton("Teleport to Point", 190)
TPtoPointBtn.Parent = MainFrame

local NoCollideBtn = makeButton("NoPlayerColl", 230)
NoCollideBtn.Parent = MainFrame

local SupportBtn = makeButton("Support Author", 270)
SupportBtn.Parent = MainFrame

-- Dragging Logic
local function enableDrag(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
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

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

enableDrag(FloatingButton)
enableDrag(FrameDragArea)

FloatingButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Functional Variables
local savedPoint = nil
local noCollide = false
local speed = 16
local farming = false

SetSpeedBtn.MouseButton1Click:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then
        speed = val
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
    end
end)

SetPointBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPoint = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

TPtoPointBtn.MouseButton1Click:Connect(function()
    if savedPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = savedPoint
    end
end)

NoCollideBtn.MouseButton1Click:Connect(function()
    noCollide = not noCollide
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not noCollide
                end
            end
        end
    end
end)

SupportBtn.MouseButton1Click:Connect(function()
    setclipboard("https://www.donationalerts.com/r/Ew3qs")
end)

local function farmBalls()
    local char = LocalPlayer.Character
    local map = nil
    farming = not farming
    if farming then
        StartFarmBtn.Text = "Stop Farm"
    else
        StartFarmBtn.Text = "Start Farm"
    end
    game.Workspace.DescendantAdded:Connect(function(m)
        if m:IsA("Model") and m:GetAttribute("MapID") then
            map = m
        end
    end)
    game.Workspace.DescendantRemoving:Connect(function(m)
        if m == map then
            map = nil
        end
    end)
    while farming do
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            char = LocalPlayer.Character
        end
        if map and map:FindFirstChild("CoinContainer") then
            for _, coin in ipairs(map.CoinContainer:GetChildren()) do
                if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                    local cv = coin:FindFirstChild("CoinVisual")
                    if cv and cv.Transparency ~= 1 then
                        char.HumanoidRootPart.CFrame = coin.CFrame
                        wait(0.1)
                        char.Humanoid:Move(Vector3.new(0, 0, -2), false)
                        wait(0.1)
                        if savedPoint then
                            char.HumanoidRootPart.CFrame = savedPoint
                        end
                        wait(0.3)
                    end
                end
            end
        end
        RunService.Stepped:Wait()
    end
end

StartFarmBtn.MouseButton1Click:Connect(farmBalls)