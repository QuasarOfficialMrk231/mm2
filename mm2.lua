local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local dragging, dragInput, dragStart, startPos
local selectedPoint = nil
local collecting = false
local flight = false
local WalkSpeed = 16

-- UI Creation
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local DragButton = Instance.new("TextButton", ScreenGui)
local MainFrame = Instance.new("Frame", ScreenGui)
local UIStroke = Instance.new("UIStroke", MainFrame)
local UICorner = Instance.new("UICorner", MainFrame)

-- DragButton properties
DragButton.Text = "="
DragButton.Size = UDim2.new(0, 30, 0, 30)
DragButton.Position = UDim2.new(0.1, 0, 0.1, 0)
DragButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
DragButton.TextColor3 = Color3.fromRGB(255,255,255)
DragButton.ZIndex = 2

-- MainFrame properties
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0.1, 40, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.ZIndex = 1

UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 2
UICorner.CornerRadius = UDim.new(0, 10)

-- Functions to make draggable
local function makeDraggable(gui)
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

makeDraggable(DragButton)
makeDraggable(MainFrame)

-- Toggle MainFrame visibility
DragButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

-- Buttons
local function createButton(text, posY)
	local btn = Instance.new("TextButton", MainFrame)
	btn.Size = UDim2.new(0.8, 0, 0, 25)
	btn.Position = UDim2.new(0.1, 0, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	local stroke = Instance.new("UIStroke", btn)
	stroke.Color = Color3.fromRGB(0, 170, 255)
	stroke.Thickness = 1
	return btn
end

local SetPointBtn = createButton("Установить точку", 10)
local TeleportToPointBtn = createButton("Телепорт к точке", 40)
local CollectBallsBtn = createButton("Сбор мячей", 70)
local NoPlayerCollBtn = createButton("NoPlayerColl", 100)
local FlightBtn = createButton("Полет к мячам", 130)

-- Input Field for WalkSpeed
local SpeedBox = Instance.new("TextBox", MainFrame)
SpeedBox.Size = UDim2.new(0.6, 0, 0, 20)
SpeedBox.Position = UDim2.new(0.1, 0, 1, -25)
SpeedBox.PlaceholderText = "Скорость"
SpeedBox.TextColor3 = Color3.fromRGB(255,255,255)
SpeedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)

local SetSpeedBtn = Instance.new("TextButton", MainFrame)
SetSpeedBtn.Size = UDim2.new(0.3, 0, 0, 20)
SetSpeedBtn.Position = UDim2.new(0.7, 0, 1, -25)
SetSpeedBtn.Text = "Уст."
SetSpeedBtn.TextColor3 = Color3.fromRGB(255,255,255)
SetSpeedBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)

-- Functions
SetPointBtn.MouseButton1Click:Connect(function()
	selectedPoint = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
end)

TeleportToPointBtn.MouseButton1Click:Connect(function()
	if selectedPoint then
		player.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(selectedPoint)
	end
end)

NoPlayerCollBtn.MouseButton1Click:Connect(function()
	local state = not NoPlayerCollBtn.Active
	NoPlayerCollBtn.Active = state
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.CanCollide then
			v.CanCollide = not state
		end
	end
end)

SetSpeedBtn.MouseButton1Click:Connect(function()
	local val = tonumber(SpeedBox.Text)
	if val then
		WalkSpeed = val
	end
end)

FlightBtn.MouseButton1Click:Connect(function()
	flight = not flight
	if flight then
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	else
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
	end
end)

-- Ball Collection Logic
CollectBallsBtn.MouseButton1Click:Connect(function()
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
				if not map then task.wait(0.5) continue end

				local container = map:FindFirstChild("CoinContainer")
				if not container then task.wait(0.5) continue end

				for _, coin in ipairs(container:GetChildren()) do
					if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
						local cv = coin:FindFirstChild("CoinVisual")
						if cv and cv.Transparency ~= 1 then
							local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
							if hrp then
								local dir = (coin.Position - hrp.Position).Unit
								for i = 1, 3 do
									hrp.CFrame = hrp.CFrame + dir
									task.wait(0.05)
								end
								if selectedPoint then
									hrp.CFrame = CFrame.new(selectedPoint)
								end
							end
							task.wait(0.5)
						end
					end
				end
				task.wait(1)
			end
		end)
	end
end)

-- Anti-Idle
pcall(function()
	local VirtualUser = game:GetService("VirtualUser")
	player.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end)