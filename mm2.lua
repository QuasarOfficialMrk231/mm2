-- // MM2 Beachball Autofarm with UI & Pathfinding //

local Players = game:GetService("Players") local PathfindingService = game:GetService("PathfindingService") local UserInputService = game:GetService("UserInputService") local TweenService = game:GetService("TweenService") local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer local Character = Player.Character or Player.CharacterAdded:Wait() local Humanoid = Character:WaitForChild("Humanoid") local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local dragging = false local dragInput, mousePos, framePos local autoFarmActive = false local noPlayerCollide = false local teleportPoint = nil local walkSpeed = 16

-- Create UI local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui) ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton") ToggleButton.Size = UDim2.new(0, 40, 0, 40) ToggleButton.Position = UDim2.new(0, 100, 0, 100) ToggleButton.Text = "=" ToggleButton.TextScaled = true ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20) ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) ToggleButton.Parent = ScreenGui

local MainFrame = Instance.new("Frame") MainFrame.Size = UDim2.new(0, 200, 0, 250) MainFrame.Position = UDim2.new(0, 150, 0, 100) MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) MainFrame.Visible = false MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame) UICorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", MainFrame) UIStroke.Color = Color3.fromRGB(0, 150, 255) UIStroke.Thickness = 2

local UIListLayout = Instance.new("UIListLayout", MainFrame) UIListLayout.Padding = UDim.new(0, 5)

local function createButton(text) local button = Instance.new("TextButton") button.Size = UDim2.new(1, -10, 0, 30) button.BackgroundColor3 = Color3.fromRGB(30, 30, 30) button.TextColor3 = Color3.fromRGB(255, 255, 255) button.Text = text button.Parent = MainFrame

local stroke = Instance.new("UIStroke", button)
stroke.Color = Color3.fromRGB(0, 150, 255)
stroke.Thickness = 1

local corner = Instance.new("UICorner", button)
corner.CornerRadius = UDim.new(0, 6)

return button

end

local SpeedBox = Instance.new("TextBox") SpeedBox.Size = UDim2.new(1, -10, 0, 30) SpeedBox.PlaceholderText = "Speed (Default 16)" SpeedBox.Text = "" SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30) SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255) SpeedBox.Parent = MainFrame

local speedStroke = Instance.new("UIStroke", SpeedBox) speedStroke.Color = Color3.fromRGB(0, 150, 255) speedStroke.Thickness = 1

local speedCorner = Instance.new("UICorner", SpeedBox) speedCorner.CornerRadius = UDim.new(0, 6)

local setSpeedButton = createButton("Установить скорость") local autoFarmButton = createButton("Начать бег") local setPointButton = createButton("Установить точку") local teleportButton = createButton("Телепорт к точке") local noPlayerCollButton = createButton("NoPlayerColl") local supportButton = createButton("Поддержать автора")

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function makeDraggable(frame) frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true mousePos = input.Position framePos = frame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)

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

makeDraggable(ToggleButton) makeDraggable(MainFrame)

setSpeedButton.MouseButton1Click:Connect(function() local num = tonumber(SpeedBox.Text) if num then walkSpeed = num Humanoid.WalkSpeed = walkSpeed end end)

supportButton.MouseButton1Click:Connect(function() setclipboard("https://www.donationalerts.com/r/Ew3qs") end)

noPlayerCollButton.MouseButton1Click:Connect(function() noPlayerCollide = not noPlayerCollide for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide and v:IsDescendantOf(workspace.Characters) then v.CanCollide = not noPlayerCollide end end end)

setPointButton.MouseButton1Click:Connect(function() teleportPoint = HumanoidRootPart.Position end)

teleportButton.MouseButton1Click:Connect(function() if teleportPoint then HumanoidRootPart.CFrame = CFrame.new(teleportPoint) end end)

local function moveToTarget(targetPos) local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, AgentJumpHeight = 7, AgentMaxSlope = 45, })

path:ComputeAsync(HumanoidRootPart.Position, targetPos)

if path.Status == Enum.PathStatus.Success then
    local waypoints = path:GetWaypoints()
    for _, waypoint in ipairs(waypoints) do
        if not autoFarmActive then break end
        Humanoid:MoveTo(waypoint.Position)
        Humanoid.MoveToFinished:Wait()
        if math.random() < 0.2 then
            Humanoid.Jump = true
            task.wait(0.3)
        end
    end
else
    Humanoid:MoveTo(targetPos)
    task.wait(1)
end

end

autoFarmButton.MouseButton1Click:Connect(function() autoFarmActive = not autoFarmActive if autoFarmActive then task.spawn(function() while autoFarmActive do local map = workspace:FindFirstChildWhichIsA("Model", true) if map and map:FindFirstChild("CoinContainer") then for _, coin in ipairs(map.CoinContainer:GetChildren()) do if not autoFarmActive then break end if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then local visual = coin:FindFirstChild("CoinVisual") if visual and visual.Transparency ~= 1 then moveToTarget(coin.Position) task.wait(0.5) end end end end wait(1) end end) end end)

Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function() if Humanoid.WalkSpeed ~= walkSpeed then Humanoid.WalkSpeed = walkSpeed end end)

Humanoid.WalkSpeed = walkSpeed

