local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local draggingBtn, draggingFrame, dragInputBtn, dragInputFrame, dragStartBtn, dragStartFrame, startPosBtn, startPosFrame
local point = nil
local walkSpeed = 16

local minX, maxX = -999999, 999999
local minY, maxY = -999999, 999999
local minZ, maxZ = -999999, 999999
local function safeVector3(pos)
    local x = math.max(math.min(pos.X, maxX), minX)
    local y = math.max(math.min(pos.Y, maxY), minY)
    local z = math.max(math.min(pos.Z, maxZ), minZ)
    return Vector3.new(x, y, z)
end

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaXBeachBallUI"
gui.Parent = game:GetService("CoreGui")

local dragBtn = Instance.new("TextButton")
dragBtn.Text = "="
dragBtn.Size = UDim2.new(0, 28, 0, 28)
dragBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
dragBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
dragBtn.TextColor3 = Color3.fromRGB(255,255,255)
dragBtn.Parent = gui
dragBtn.ZIndex = 20
dragBtn.AutoButtonColor = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 170, 0, 240)
frame.Position = UDim2.new(0.25, 0, 0.18, 0)
frame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
frame.Visible = false
frame.Parent = gui
frame.ZIndex = 19

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 2
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 9)

dragBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true
        dragStartBtn = input.Position
        startPosBtn = dragBtn.Position
        dragInputBtn = input
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingBtn = false
            end
        end)
    end
end)
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = true
        dragStartFrame = input.Position
        startPosFrame = frame.Position
        dragInputFrame = input
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingFrame = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingBtn and (input == dragInputBtn) and 
       (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartBtn
        dragBtn.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
    end
    if draggingFrame and (input == dragInputFrame) and 
       (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartFrame
        frame.Position = UDim2.new(startPosFrame.X.Scale, startPosFrame.X.Offset + delta.X, startPosFrame.Y.Scale, startPosFrame.Y.Offset + delta.Y)
    end
end)

dragBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local function createButton(text, posY)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.87, 0, 0, 20)
    btn.Position = UDim2.new(0.06, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = text
    btn.TextSize = 13
    btn.Font = Enum.Font.Code
    btn.ZIndex = 21
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 1
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 5)
    return btn
end

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0.57, 0, 0, 20)
speedBox.Position = UDim2.new(0.07, 0, 1, -27)
speedBox.PlaceholderText = "Скорость"
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
speedBox.Text = ""
speedBox.TextSize = 13
speedBox.Font = Enum.Font.Code
speedBox.ZIndex = 21
local speedCorner = Instance.new("UICorner", speedBox)
speedCorner.CornerRadius = UDim.new(0, 5)

local setSpeedBtn = Instance.new("TextButton", frame)
setSpeedBtn.Size = UDim2.new(0.29, 0, 0, 20)
setSpeedBtn.Position = UDim2.new(0.66, 0, 1, -27)
setSpeedBtn.Text = "Уст."
setSpeedBtn.TextColor3 = Color3.fromRGB(255,255,255)
setSpeedBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
setSpeedBtn.TextSize = 13
setSpeedBtn.Font = Enum.Font.Code
setSpeedBtn.ZIndex = 21
local setSpeedCorner = Instance.new("UICorner", setSpeedBtn)
setSpeedCorner.CornerRadius = UDim.new(0, 5)

local setPointBtn = createButton("Установить точку", 8)
local tpBtn = createButton("Телепорт к точке", 32)
local collectBtn = createButton("Сбор мячей", 56)
local flightBtn = createButton("Флай к мячам", 80)
local nearestBtn = createButton("Телепорт к ближайшему мячу", 104)
local npcBtn = createButton("NoPlayerColl", 128)
local supportBtn = createButton("Поддержать автора", 152)

local supportUrl = "https://www.donationalerts.com/r/Ew3qs"

local toggles = {
    collect = false,
    flight = false,
    nocollide = false,
}

local lastCollisions = {}
local lastGravity = Workspace.Gravity

local function setMapCollision(state)
    if not state then
        lastCollisions = {}
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                lastCollisions[v] = v.CanCollide
                v.CanCollide = false
            end
        end
    else
        for part, collide in pairs(lastCollisions) do
            if part and part.Parent then
                part.CanCollide = collide
            end
        end
        lastCollisions = {}
    end
end

local function setGravity(state)
    if not state then
        lastGravity = Workspace.Gravity
        Workspace.Gravity = 0
    else
        Workspace.Gravity = lastGravity
    end
end

setSpeedBtn.MouseButton1Click:Connect(function()
    local val = tonumber(speedBox.Text)
    if val and val > 0 and val <= 400 then
        walkSpeed = val
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = walkSpeed
        end
    else
        speedBox.Text = ""
    end
end)

setPointBtn.MouseButton1Click:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        point = safeVector3(hrp.Position)
        setPointBtn.Text = "Точка установлена!"
        task.wait(0.75)
        setPointBtn.Text = "Установить точку"
    end
end)

tpBtn.MouseButton1Click:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and point then
        hrp.CFrame = CFrame.new(safeVector3(point))
    end
end)

-- Ограничение на кнопку "Телепорт к ближайшему мячу" — раз в 4 секунды
local canTpNearest = true
nearestBtn.MouseButton1Click:Connect(function()
    if not canTpNearest then return end
    canTpNearest = false
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local nearest, minDist
    local map, container
    for _, m in pairs(workspace:GetChildren()) do
        if m:IsA("Model") and m:GetAttribute("MapID") then
            map = m
            break
        end
    end
    if map then container = map:FindFirstChild("CoinContainer") end
    if not container then canTpNearest = true return end
    for _, coin in ipairs(container:GetChildren()) do
        if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
            local cv = coin:FindFirstChild("CoinVisual")
            if cv and cv.Transparency ~= 1 then
                local dist = (hrp.Position - coin.Position).Magnitude
                if not minDist or dist < minDist then
                    minDist = dist
                    nearest = coin
                end
            end
        end
    end
    if nearest then
        hrp.CFrame = CFrame.new(safeVector3(nearest.Position))
    end
    task.spawn(function()
        task.wait(4)
        canTpNearest = true
    end)
end)

-- Сбор мячей с задержкой 0.1 сек после каждого телепорта
collectBtn.MouseButton1Click:Connect(function()
    toggles.collect = not toggles.collect
    collectBtn.Text = toggles.collect and "Сбор: ВКЛ" or "Сбор мячей"
    if not toggles.collect then return end
    spawn(function()
        while toggles.collect do
            local map, container
            for _, m in pairs(workspace:GetChildren()) do
                if m:IsA("Model") and m:GetAttribute("MapID") then
                    map = m
                    break
                end
            end
            if map then container = map:FindFirstChild("CoinContainer") end
            if not container then task.wait(1) continue end

            local coins = {}
            for _, coin in ipairs(container:GetChildren()) do
                if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                    local cv = coin:FindFirstChild("CoinVisual")
                    if cv and cv.Transparency ~= 1 then
                        table.insert(coins, coin)
                    end
                end
            end

            for _, coin in ipairs(coins) do
                if not toggles.collect then break end
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(safeVector3(coin.Position))
                    task.wait(0.1) -- 0.1 секунда после сбора мяча
                end
            end
            task.wait(1)
        end
    end)
end)

-- ФУНКЦИЮ ПОЛЁТА НЕ ТРОГАЮ, ЛОГИКА ПОЛЁТА ОСТАЁТСЯ:
flightBtn.MouseButton1Click:Connect(function()
    toggles.flight = not toggles.flight
    flightBtn.Text = toggles.flight and "Флай: ВКЛ" or "Флай к мячам"
    if toggles.flight then
        spawn(function()
            Workspace.FallenPartsDestroyHeight = -10000
            setMapCollision(false)
            setGravity(false)
            while toggles.flight do
                local map, container
                for _, m in pairs(workspace:GetChildren()) do
                    if m:IsA("Model") and m:GetAttribute("MapID") then
                        map = m
                        break
                    end
                end
                if map then container = map:FindFirstChild("CoinContainer") end
                if not container then task.wait(1) continue end

                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then task.wait(0.2) continue end

                local nearest, minDist
                for _, coin in ipairs(container:GetChildren()) do
                    if coin:IsA("Part") and coin.Name == "Coin_Server" and coin:GetAttribute("CoinID") == "BeachBall" then
                        local cv = coin:FindFirstChild("CoinVisual")
                        if cv and cv.Transparency ~= 1 then
                            local dist = (hrp.Position - coin.Position).Magnitude
                            if not minDist or dist < minDist then
                                minDist = dist
                                nearest = coin
                            end
                        end
                    end
                end

                if nearest then
                    local targetPos = nearest.Position
                    local flySpeed = walkSpeed * 2
                    local bodyVel = hrp:FindFirstChild("DeltaXFlyBV") or Instance.new("BodyVelocity")
                    bodyVel.Name = "DeltaXFlyBV"
                    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bodyVel.Parent = hrp

                    while toggles.flight and nearest.Parent and (hrp.Position - targetPos).Magnitude > 2 do
                        local dir = (targetPos - hrp.Position).Unit
                        bodyVel.Velocity = dir * flySpeed
                        hrp.CFrame = CFrame.new(hrp.Position, targetPos)
                        task.wait()
                    end
                    if bodyVel then bodyVel:Destroy() end
                else
                    task.wait(1)
                end
            end
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("DeltaXFlyBV")
                if bv then bv:Destroy() end
            end
            setMapCollision(true)
            setGravity(true)
        end)
    else
        setMapCollision(true)
        setGravity(true)
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("DeltaXFlyBV")
            if bv then bv:Destroy() end
        end
    end
end)

npcBtn.MouseButton1Click:Connect(function()
    toggles.nocollide = not toggles.nocollide
    npcBtn.Text = toggles.nocollide and "NoColl: ВКЛ" or "NoPlayerColl"
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                if part.Name:lower():find("foot") or part.Name:lower():find("leg") then
                    part.CanCollide = true
                else
                    part.CanCollide = not toggles.nocollide
                end
            end
        end
    end
end)

supportBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(supportUrl)
    else
        speedBox.Text = "Скопировано!"
        task.wait(1)
        speedBox.Text = ""
    end
end)

pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

frame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not frame.Visible then
        setPointBtn.Text = "Установить точку"
        collectBtn.Text = "Сбор мячей"
        flightBtn.Text = "Флай к мячам"
        npcBtn.Text = "NoPlayerColl"
    end
end)