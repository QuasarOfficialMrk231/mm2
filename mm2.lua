--[[
    MM2 Randomized Ball Collector Script for Delta X (Mobile)
    Repository: QuasarOfficialMrk231/mm2
    File: main.lua
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
local HumanoidRootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")

local collected = 0
local MAX_COLLECT = 40

-- Function to make a random movement/jitter
local function randomMovement()
    local duration = math.random(1,2)
    local endTime = tick() + duration

    while tick() < endTime do
        local randomVec = Vector3.new(
            math.random(-3,3),
            0,
            math.random(-3,3)
        )
        Humanoid:MoveTo(HumanoidRootPart.Position + randomVec)
        if math.random() < 0.2 then
            Humanoid.Jump = true
        end
        RunService.Heartbeat:Wait()
    end
end

-- Function to move towards a ball with random detours
local function moveToBall(ball)
    local ballPos = ball.Position
    local pathNodes = {}

    -- Create random detour points
    local detourCount = math.random(1,3)
    for i = 1, detourCount do
        local offset = Vector3.new(
            math.random(-10,10),
            0,
            math.random(-10,10)
        )
        table.insert(pathNodes, ballPos + offset)
    end
    table.insert(pathNodes, ballPos)  -- Final target is the ball

    -- Move through all path nodes
    for _,point in ipairs(pathNodes) do
        Humanoid:MoveTo(point)
        local reached = false
        local conn
        conn = Humanoid.MoveToFinished:Connect(function(success)
            reached = true
        end)

        -- Occasionally jump while moving
        if math.random() < 0.3 then
            Humanoid.Jump = true
        end

        while not reached do
            RunService.Heartbeat:Wait()
        end
        conn:Disconnect()
    end
end

-- Main loop
spawn(function()
    while collected < MAX_COLLECT do
        local ballsFolder = Workspace:FindFirstChild("BeachBalls") or Workspace:FindFirstChild("Coins")
        if not ballsFolder then
            wait(1)
            continue
        end

        local balls = ballsFolder:GetChildren()
        local nearest = nil
        local shortest = math.huge

        for _,ball in ipairs(balls) do
            if ball:IsA("BasePart") then
                local dist = (HumanoidRootPart.Position - ball.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = ball
                end
            end
        end

        if nearest then
            -- Random chance to "be weird" and make a large detour path
            if math.random() < 0.5 then
                moveToBall(nearest)
            else
                Humanoid:MoveTo(nearest.Position)
                Humanoid.MoveToFinished:Wait()
            end

            collected = collected + 1
            wait(0.3)
            randomMovement()
        else
            wait(1)
        end
    end
    print("Собрано 40 мячиков. Жду новый раунд.")
end)

print("Human-like Ball Collector Script запущен.")
