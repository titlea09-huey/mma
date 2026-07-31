local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local lockedTarget = nil
local isLocked = false
local fovRadius = 150

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleUIButton = Instance.new("TextButton")
local LockButton = Instance.new("TextButton")
local IncFOVButton = Instance.new("TextButton")
local DecFOVButton = Instance.new("TextButton")
local FOVText = Instance.new("TextLabel")
local FOVCircle = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Name = "LockonGuiContinuous"
ScreenGui.Parent = game:GetService("CoreGui")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundTransparency = 1
MainFrame.Size = UDim2.new(1, 0, 1, 0)

ToggleUIButton.Parent = ScreenGui
ToggleUIButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleUIButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
ToggleUIButton.Position = UDim2.new(0, 10, 0, 10)
ToggleUIButton.Size = UDim2.new(0, 40, 0, 30)
ToggleUIButton.Font = Enum.Font.SourceSansBold
ToggleUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleUIButton.TextSize = 14
ToggleUIButton.Text = "UI"

LockButton.Parent = MainFrame
LockButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LockButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
LockButton.Position = UDim2.new(0, 10, 0, 50)
LockButton.Size = UDim2.new(0, 200, 0, 35)
LockButton.Font = Enum.Font.SourceSansBold
LockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LockButton.TextSize = 16
LockButton.Text = "LOCK: OFF"

DecFOVButton.Parent = MainFrame
DecFOVButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
DecFOVButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
DecFOVButton.Position = UDim2.new(0, 10, 0, 90)
DecFOVButton.Size = UDim2.new(0, 50, 0, 30)
DecFOVButton.Font = Enum.Font.SourceSansBold
DecFOVButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DecFOVButton.TextSize = 16
DecFOVButton.Text = "-"

FOVText.Parent = MainFrame
FOVText.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FOVText.BackgroundTransparency = 0.5
FOVText.Position = UDim2.new(0, 62, 0, 90)
FOVText.Size = UDim2.new(0, 76, 0, 30)
FOVText.Font = Enum.Font.SourceSansBold
FOVText.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVText.TextSize = 14
FOVText.Text = tostring(fovRadius)

IncFOVButton.Parent = MainFrame
IncFOVButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IncFOVButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
IncFOVButton.Position = UDim2.new(0, 140, 0, 90)
IncFOVButton.Size = UDim2.new(0, 50, 0, 30)
IncFOVButton.Font = Enum.Font.SourceSansBold
IncFOVButton.TextColor3 = Color3.fromRGB(255, 255, 255)
IncFOVButton.TextSize = 16
IncFOVButton.Text = "+"

FOVCircle.Parent = MainFrame
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FOVCircle

UIStroke.Parent = FOVCircle
UIStroke.Color = Color3.fromRGB(0, 255, 0)
UIStroke.Thickness = 2
UIStroke.Transparency = 0

local function updateFOVSize()
    FOVCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    FOVText.Text = tostring(fovRadius)
end

IncFOVButton.MouseButton1Click:Connect(function()
    if fovRadius < 500 then
        fovRadius = fovRadius + 25
        updateFOVSize()
    end
end)

DecFOVButton.MouseButton1Click:Connect(function()
    if fovRadius > 50 then
        fovRadius = fovRadius - 25
        updateFOVSize()
    end
end)

local uiVisible = true
ToggleUIButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
    ToggleUIButton.TextColor3 = uiVisible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
end)

local function isVisible(targetPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ignoreList = {LocalPlayer.Character}
    if LocalPlayer.Character then
        table.insert(ignoreList, LocalPlayer.Character)
    end
    rayParams.FilterDescendantsInstances = ignoreList

    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local result = workspace:Raycast(origin, direction, rayParams)

    if result then
        local hit = result.Instance
        if hit:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    return true
end

local function getClosestPlayerInFOV()
    local closestTarget = nil
    local shortestDistance = math.huge
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen and isVisible(rootPart) then
                    local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (screenPos - mousePos).Magnitude
                    if distance <= fovRadius and distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = rootPart
                    end
                end
            end
        end
    end
    return closestTarget
end

LockButton.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    if isLocked then
        lockedTarget = getClosestPlayerInFOV()
        if lockedTarget then
            LockButton.Text = "LOCK: ON"
            LockButton.TextColor3 = Color3.fromRGB(0, 255, 0)
            UIStroke.Color = Color3.fromRGB(0, 255, 0)
        else
            LockButton.Text = "LOCK: AUTO"
            LockButton.TextColor3 = Color3.fromRGB(255, 165, 0)
            UIStroke.Color = Color3.fromRGB(255, 165, 0)
        end
    else
        lockedTarget = nil
        LockButton.Text = "LOCK: OFF"
        LockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        UIStroke.Color = Color3.fromRGB(0, 255, 0)
    end
end)

RunService.RenderStepped:Connect(function()
    if isLocked then
        local isValidTarget = false
        if lockedTarget and lockedTarget.Parent then
            local humanoid = lockedTarget.Parent:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(lockedTarget.Position)
                if onScreen and isVisible(lockedTarget) then
                    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    if distance <= fovRadius then
                        isValidTarget = true
                    end
                end
            end
        end

        if not isValidTarget then
            lockedTarget = getClosestPlayerInFOV()
        end

        if lockedTarget and lockedTarget.Parent then
            -- ใช้ CFrame.new ผสมกับ LookVector เพื่อให้หมุนตามจอและทิศทางที่เราหันไปได้สมูทขึ้น
            local targetPos = lockedTarget.Position
            local currentCamCFrame = Camera.CFrame
            Camera.CFrame = CFrame.new(currentCamCFrame.Position, targetPos)
            
            LockButton.Text = "LOCK: ON"
            LockButton.TextColor3 = Color3.fromRGB(0, 255, 0)
            UIStroke.Color = Color3.fromRGB(0, 255, 0)
        else
            LockButton.Text = "LOCK: AUTO"
            LockButton.TextColor3 = Color3.fromRGB(255, 165, 0)
            UIStroke.Color = Color3.fromRGB(255, 165, 0)
        end
    end
end)
