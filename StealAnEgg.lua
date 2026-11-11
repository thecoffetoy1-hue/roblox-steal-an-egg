

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Config = {
    EggFinder = true,
    AFKMode = false,
    AutoEvent = true
}

local old = game:GetService("CoreGui"):FindFirstChild("EggFinderGUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "EggFinderGUI"
gui.ResetOnSpawn = false

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

if not gui.Parent then
    gui.Parent = Player:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 260)
frame.Position = UDim2.new(0.5, -130, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.Text = "STEAL AN EGG"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundColor3 = Color3.fromRGB(100,60,200)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 35)
status.Position = UDim2.fromOffset(10, 48)
status.Text = "Ready to scan"
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1
status.Parent = frame

local function makeButton(text, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -30, 0, 36)
    b.Position = UDim2.fromOffset(15, y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(75,60,130)
    b.Parent = frame

    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 8)

    b.MouseButton1Click:Connect(callback)
    return b
end

local highlights = {}

local function scanEggs()
    local count = 0
    local nearestDistance = math.huge
    local nearestName = "None"

    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and
            string.find(string.lower(obj.Name), "egg") then

            local part = obj.PrimaryPart or
                obj:FindFirstChildWhichIsA("BasePart")

            if part then
                count += 1

                if Config.EggFinder then
                    if not highlights[obj] then
                        local h = Instance.new("Highlight")
                        h.FillColor = Color3.fromRGB(255, 210, 0)
                        h.OutlineColor = Color3.new(1,1,1)
                        h.Adornee = obj
                        h.Parent = gui
                        highlights[obj] = h
                    end
                end

                if root then
                    local distance =
                        (root.Position - part.Position).Magnitude

                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestName = obj.Name
                    end
                end
            end
        end
    end

    status.Text = "Eggs: " .. count ..
        " | Nearest: " .. nearestName

    return count
end

makeButton("SCAN EGGS", 95, scanEggs)

makeButton("EGG FINDER: ON", 138, function()
    Config.EggFinder = not Config.EggFinder
    scanEggs()
end)

makeButton("AFK MODE: OFF", 181, function()
    Config.AFKMode = not Config.AFKMode
end)

makeButton("SCAN EVENTS", 224, function()
    local count = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), "event") then
            count += 1
            print("Event found:", obj:GetFullName())
        end
    end

    status.Text = "Events found: " .. count
end)

print("STEAL AN EGG GUI LOADED")
