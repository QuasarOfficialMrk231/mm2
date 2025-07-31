-- MM2 Auto Collector GUI Script by QuasarOfficialMrk231

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local collected = 0
local MAX_COLLECT = 40
local savedPoint = nil
local collecting = false

-- UI Elements
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainButton = Instance.new("TextButton")
local Frame = Instance.new("Frame")

MainButton.Text = "≡"
MainButton.Size = UDim2.new(0, 50, 0, 50)
MainButton.Position = UDim2.new(0, 100, 0, 100)
MainButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.Draggable = true
MainButton.Active = true
MainButton.Parent = ScreenGui

Frame.Size = UDim2.new(0, 200, 0, 160)
Frame.Position = UDim2.new(0, 160, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Visible = false
Frame.Parent = ScreenGui

local function createButton(text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Parent = Frame
    btn.MouseButton1Click:Connect(callback)
end

-- Find nearest ball
local function getNearestBall()
    local ballsFolder = Workspace:FindFirstChild("BeachBalls") or Workspace:FindFirstChild("Coins")
    if not ballsFolder then return nil end

    local nearest = nil
    local shortest = math.huge

    for _, ball in ipairs(ballsFolder:GetChildren()) do
        if ball:IsA("BasePart") then
            local dist = (HumanoidRootPart.Position - ball.Position).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = ball
            end
        end
    end

    return nearest
end

-- Pathfinding movement
local pathParams = {
    AgentRadius = 2,
    AgentHeight = 5,
    AgentCanJump = true,
    Costs = {}
}

local function followPath(destination)
    local path = PathfindingService:CreatePath(pathParams)
    local success, msg = pcall(function()
        path:ComputeAsync(HumanoidRootPart.Position, destination)
    end)
    if not success or path.Status ~= Enum.PathStatus.Success then
        return false
    end

    local waypoints = path:GetWaypoints()
    local nextIdx = 2  -- skip start point
    local reachedConn, blockedConn

    reachedConn = Humanoid.MoveToFinished:Connect(function(reached)
        if reached and nextIdx <= #waypoints then
            -- Random jump
            if math.random() < 0.1 then
                Humanoid.Jump = true
            end
            Humanoid:MoveTo(waypoints[nextIdx].Position)
            nextIdx += 1
        else
            reachedConn:Disconnect()
            if blockedConn then blockedConn:Disconnect() end
        end
    end)

    blockedConn = path.Blocked:Connect(function(blockedIdx)
        if blockedIdx >= nextIdx then
            reachedConn:Disconnect()
            blockedConn:Disconnect()
            followPath(destination)
        end
    end)

    if waypoints[nextIdx] then
        Humanoid:MoveTo(waypoints[nextIdx].Position)
    end

    return true
end

local function moveToTargetWithPath(targetPart)
    if not targetPart or not targetPart.Position then return end
    if math.random() < 0.3 then
        -- странный длинный путь
        local offset = Vector3.new(math.random(-15,15), 0, math.random(-15,15))
        followPath(targetPart.Position + offset)
    else
        followPath(targetPart.Position)
    end
end

-- Auto Collecting Logic
local function autoCollect()
    collecting = true
    collected = 0

    while collecting and collected < MAX_COLLECT do
        local ball = getNearestBall()
        if ball then
            moveToTargetWithPath(ball)
            collected += 1
            wait(0.5)
        else
            wait(1)
        end
    end
end

-- UI Buttons
createButton("Начать бег", 10, function()
    if not collecting then
        spawn(autoCollect)
    else
        collecting = false
    end
end)

createButton("Установить точку", 50, function()
    savedPoint = HumanoidRootPart.Position
end)

createButton("Телепорт к точке", 90, function()
    if savedPoint then
        HumanoidRootPart.CFrame = CFrame.new(savedPoint)
    end
end)

createButton("NoPlayerColl", 130, function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

MainButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

print("Script Loaded Successfully!")