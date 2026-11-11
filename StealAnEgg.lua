
-- STEAL AN EGG
-- ServerScriptService > EggSystemServer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:FindFirstChild("EggAction")
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "EggAction"
    remote.Parent = ReplicatedStorage
end

local eggsFolder = workspace:WaitForChild("Eggs")
local eventsFolder = workspace:WaitForChild("Events")

local cooldowns = {}

local function getPart(object)
    if object:IsA("BasePart") then
        return object
    end

    if object:IsA("Model") then
        return object.PrimaryPart
            or object:FindFirstChildWhichIsA("BasePart", true)
    end
end

local function distance(player, object)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local part = getPart(object)

    if not root or not part then
        return math.huge
    end

    return (root.Position - part.Position).Magnitude
end

Players.PlayerAdded:Connect(function(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player

    local eggs = Instance.new("IntValue")
    eggs.Name = "Eggs"
    eggs.Parent = stats

    local points = Instance.new("IntValue")
    points.Name = "EventPoints"
    points.Parent = stats

    player:SetAttribute("AFKMode", false)
end)

remote.OnServerEvent:Connect(function(player, action, target)
    if action == "AFK" then
        if typeof(target) == "boolean" then
            player:SetAttribute("AFKMode", target)
        end
        return
    end

    if player:GetAttribute("AFKMode") then
        return
    end

    local now = os.clock()
    cooldowns[player] = cooldowns[player] or {}

    if now - (cooldowns[player][action] or 0) < 1 then
        return
    end

    if action == "Steal" then
        if typeof(target) ~= "Instance" then return end
        if not target:IsDescendantOf(eggsFolder) then return end
        if distance(player, target) > 18 then return end
        if target:GetAttribute("Stolen") then return end

        target:SetAttribute("Stolen", true)

        local stats = player:FindFirstChild("leaderstats")
        local eggs = stats and stats:FindFirstChild("Eggs")

        if eggs then
            eggs.Value += 1
        end

        target:Destroy()

    elseif action == "JoinEvent" then
        if typeof(target) ~= "Instance" then return end
        if not target:IsDescendantOf(eventsFolder) then return end
        if distance(player, target) > 18 then return end

        local stats = player:FindFirstChild("leaderstats")
        local points = stats and stats:FindFirstChild("EventPoints")

        if points then
            points.Value += 1
        end
    end

    cooldowns[player][action] = now
end)

Players.PlayerRemoving:Connect(function(player)
    cooldowns[player] = nil
end)
