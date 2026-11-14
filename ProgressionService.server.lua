local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local store = DataStoreService:GetDataStore("EggClimbProgress_v1")
local remotes = ReplicatedStorage:WaitForChild("EggClimbRemotes")
local finishTouch = remotes:WaitForChild("FinishTouch")
local progressEvent = remotes:FindFirstChild("ProgressUpdate") or Instance.new("RemoteEvent")
progressEvent.Name = "ProgressUpdate"
progressEvent.Parent = remotes

local defaults = {Wins = 0, Coins = 0, BestFloor = 0}
local finishDebounce = {}

local function copyDefaults(data)
	local result = {}
	for key, value in pairs(defaults) do result[key] = tonumber(data and data[key]) or value end
	return result
end

local function save(player)
	local data = {
		Wins = player:GetAttribute("Wins") or 0,
		Coins = player:GetAttribute("Coins") or 0,
		BestFloor = player:GetAttribute("BestFloor") or 0,
	}
	local success, errorMessage = pcall(function() store:SetAsync("Player_" .. player.UserId, data) end)
	if not success then warn("EGG CLIMB save failed: " .. errorMessage) end
end

local function update(player)
	progressEvent:FireClient(player, {
		Wins = player:GetAttribute("Wins") or 0,
		Coins = player:GetAttribute("Coins") or 0,
		Floor = player:GetAttribute("ReachedFloor") or 0,
		BestFloor = player:GetAttribute("BestFloor") or 0,
	})
end

local function spawnAtCheckpoint(player, character)
	local root = character:WaitForChild("HumanoidRootPart", 5)
	if not root then return end
	local floor = player:GetAttribute("ReachedFloor") or 0
	if floor > 0 then
		local checkpoint = workspace.EggClimbWorld:FindFirstChild("Checkpoint_" .. floor)
		if checkpoint then root.CFrame = checkpoint.CFrame + Vector3.new(0, 4, 0) end
	end
end

Players.PlayerAdded:Connect(function(player)
	local loaded
	pcall(function() loaded = store:GetAsync("Player_" .. player.UserId) end)
	local data = copyDefaults(loaded)
	for key, value in pairs(data) do player:SetAttribute(key, value) end
	player:SetAttribute("ReachedFloor", 0)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = data.Wins
	wins.Parent = leaderstats
	player:GetAttributeChangedSignal("Wins"):Connect(function() wins.Value = player:GetAttribute("Wins") or 0 end)
	player.CharacterAdded:Connect(function(character) spawnAtCheckpoint(player, character) end)
	player:GetAttributeChangedSignal("ReachedFloor"):Connect(function()
		local floor = player:GetAttribute("ReachedFloor") or 0
		if floor > (player:GetAttribute("BestFloor") or 0) then player:SetAttribute("BestFloor", floor) end
		update(player)
	end)
	update(player)
end)

Players.PlayerRemoving:Connect(function(player)
	save(player)
	finishDebounce[player] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do save(player) end
end)

finishTouch.Event:Connect(function(player)
	if finishDebounce[player] then return end
	finishDebounce[player] = true
	player:SetAttribute("Wins", (player:GetAttribute("Wins") or 0) + 1)
	player:SetAttribute("Coins", (player:GetAttribute("Coins") or 0) + 100)
	player:SetAttribute("ReachedFloor", 0)
	update(player)
	progressEvent:FireClient(player, {Toast = "SUMMIT REACHED! +1 WIN  +100 COINS"})
	task.delay(4, function() finishDebounce[player] = nil end)
end)
