local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

-- Двигаемый значок "="
local DragButton = Instance.new("TextButton")
DragButton.Size = UDim2.new(0, 30, 0, 30)
DragButton.Position = UDim2.new(0, 50, 0, 50)
DragButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
DragButton.Text = "="
DragButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DragButton.BorderColor3 = Color3.fromRGB(0, 120, 255)
DragButton.Parent = ScreenGui

-- Плавающее окно
local FloatingFrame = Instance.new("Frame")
FloatingFrame.Size = UDim2.new(0, 180, 0, 220)
FloatingFrame.Position = UDim2.new(0, 90, 0, 50)
FloatingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingFrame.BorderColor3 = Color3.fromRGB(0, 120, 255)
FloatingFrame.Visible = false
FloatingFrame.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout", FloatingFrame)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 140, 0, 25)
SpeedInput.Text = "16"
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.PlaceholderText = "Скорость"
SpeedInput.ClearTextOnFocus = false
SpeedInput.Parent = FloatingFrame

local SetSpeedButton = Instance.new("TextButton")
SetSpeedButton.Size = UDim2.new(0, 140, 0, 25)
SetSpeedButton.Text = "Установить скорость"
SetSpeedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SetSpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SetSpeedButton.Parent = FloatingFrame

local NoPlayerCollButton = Instance.new("TextButton")
NoPlayerCollButton.Size = UDim2.new(0, 140, 0, 25)
NoPlayerCollButton.Text = "NoPlayerColl (Off)"
NoPlayerCollButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
NoPlayerCollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NoPlayerCollButton.Parent = FloatingFrame

local FlyToBallsButton = Instance.new("TextButton")
FlyToBallsButton.Size = UDim2.new(0, 140, 0, 25)
FlyToBallsButton.Text = "Полет к мячам (Off)"
FlyToBallsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlyToBallsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyToBallsButton.Parent = FloatingFrame

local CollectBallsButton = Instance.new("TextButton")
CollectBallsButton.Size = UDim2.new(0, 140, 0, 25)
CollectBallsButton.Text = "Сбор мячей (Off)"
CollectBallsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CollectBallsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CollectBallsButton.Parent = FloatingFrame

local SetPointButton = Instance.new("TextButton")
SetPointButton.Size = UDim2.new(0, 140, 0, 25)
SetPointButton.Text = "Установить точку"
SetPointButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SetPointButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SetPointButton.Parent = FloatingFrame

local SupportButton = Instance.new("TextButton")
SupportButton.Size = UDim2.new(0, 140, 0, 25)
SupportButton.Text = "Поддержать автора"
SupportButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SupportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SupportButton.Parent = FloatingFrame

-- Перетаскивание значка и окна
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
	local delta = input.Position - dragStart
	DragButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

DragButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = DragButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateDrag(input)
	end
end)

DragButton.MouseButton1Click:Connect(function()
	FloatingFrame.Visible = not FloatingFrame.Visible
end)

-- Логика кнопок
local NoPlayerCollActive = false
local FlyToBallsActive = false
local CollectBallsActive = false
local savedPoint = nil

SetSpeedButton.MouseButton1Click:Connect(function()
	local speed = tonumber(SpeedInput.Text)
	if speed then
		Character.Humanoid.WalkSpeed = speed
	end
end)

NoPlayerCollButton.MouseButton1Click:Connect(function()
	NoPlayerCollActive = not NoPlayerCollActive
	if NoPlayerCollActive then
		for _, part in pairs(Character:GetChildren()) do
			if part:IsA("BasePart") and not part.Name:lower():match("leg") then
				part.CanCollide = false
			end
		end
		NoPlayerCollButton.Text = "NoPlayerColl (On)"
	else
		for _, part in pairs(Character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
		NoPlayerCollButton.Text = "NoPlayerColl (Off)"
	end
end)

FlyToBallsButton.MouseButton1Click:Connect(function()
	FlyToBallsActive = not FlyToBallsActive
	FlyToBallsButton.Text = FlyToBallsActive and "Полет к мячам (On)" or "Полет к мячам (Off)"
end)

CollectBallsButton.MouseButton1Click:Connect(function()
	CollectBallsActive = not CollectBallsActive
	CollectBallsButton.Text = CollectBallsActive and "Сбор мячей (On)" or "Сбор мячей (Off)"
end)

SetPointButton.MouseButton1Click:Connect(function()
	savedPoint = HumanoidRootPart.CFrame
end)

SupportButton.MouseButton1Click:Connect(function()
	setclipboard("https://www.donationalerts.com/r/Ew3qs")
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
	if FlyToBallsActive then
		local map = workspace:FindFirstChildWhichIsA("Model", true, function(m) return m:GetAttribute("MapID") ~= nil end)
		if map and map:FindFirstChild("CoinContainer") then
			for _, coin in ipairs(map.CoinContainer:GetChildren()) do
				if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
					local cv = coin:FindFirstChild("CoinVisual")
					if cv and cv.Transparency ~= 1 then
						local direction = (coin.Position - HumanoidRootPart.Position).Unit
						HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + direction * 1.5
						break
					end
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		if CollectBallsActive and savedPoint then
			local map = workspace:FindFirstChildWhichIsA("Model", true, function(m) return m:GetAttribute("MapID") ~= nil end)
			if map and map:FindFirstChild("CoinContainer") then
				for _, coin in ipairs(map.CoinContainer:GetChildren()) do
					if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
						local cv = coin:FindFirstChild("CoinVisual")
						if cv and cv.Transparency ~= 1 then
							HumanoidRootPart.CFrame = coin.CFrame
							task.wait(0.1)
							HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
							task.wait(0.1)
							HumanoidRootPart.CFrame = savedPoint
							task.wait(0.2)
						end
					end
				end
			end
		end
		task.wait(0.1)
	end
end)