local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("EggClimbRemotes")
local equip = remotes:FindFirstChild("EquipCosmetic") or Instance.new("RemoteEvent")
equip.Name = "EquipCosmetic"
equip.Parent = remotes
local cosmeticsEvent = remotes:FindFirstChild("CosmeticsUpdate") or Instance.new("RemoteEvent")
cosmeticsEvent.Name = "CosmeticsUpdate"
cosmeticsEvent.Parent = remotes

local shells = {
	Classic = {Color = Color3.fromRGB(255, 248, 218), Wins = 0},
	Berry = {Color = Color3.fromRGB(255, 117, 164), Wins = 1},
	Mint = {Color = Color3.fromRGB(113, 240, 184), Wins = 3},
	Sunset = {Color = Color3.fromRGB(255, 152, 83), Wins = 6},
}
local trails = {
	None = {Color = Color3.new(1, 1, 1), Wins = 0},
	Rainbow = {Color = Color3.fromRGB(255, 220, 75), Wins = 2},
	Starlight = {Color = Color3.fromRGB(158, 211, 255), Wins = 5},
}

local function unlocked(player, catalogue, name)
	local item = catalogue[name]
	return item and (player:GetAttribute("Wins") or 0) >= item.Wins
end

local function makeEgg(character)
	local root = character:WaitForChild("HumanoidRootPart")
	local old = character:FindFirstChild("EggShell")
	if old then old:Destroy() end
	local egg = Instance.new("Part")
	egg.Name = "EggShell"
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(2.5, 3.1, 2.5)
	egg.Color = Color3.fromRGB(255, 248, 218)
	egg.Material = Enum.Material.SmoothPlastic
	egg.CanCollide = false
	egg.Massless = true
	egg.CFrame = root.CFrame * CFrame.new(0, 0.4, 0)
	egg.Parent = character
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = egg
	weld.Parent = egg
	for _, side in ipairs({-1, 1}) do
		local eye = Instance.new("Part")
		eye.Name = "EggEye"
		eye.Shape = Enum.PartType.Ball
		eye.Size = Vector3.new(0.22, 0.3, 0.16)
		eye.Color = Color3.fromRGB(38, 45, 68)
		eye.CanCollide = false
		eye.Massless = true
		eye.CFrame = egg.CFrame * CFrame.new(side * 0.4, 0.35, -1.08)
		eye.Parent = character
		local eyeWeld = Instance.new("WeldConstraint")
		eyeWeld.Part0 = egg
		eyeWeld.Part1 = eye
		eyeWeld.Parent = eye
	end
	return egg
end

local function apply(player, kind, name)
	local catalogue = kind == "Shell" and shells or trails
	if not unlocked(player, catalogue, name) then return end
	player:SetAttribute("Equipped" .. kind, name)
	if kind == "Shell" and player.Character then
		local egg = player.Character:FindFirstChild("EggShell")
		if egg then egg.Color = catalogue[name].Color end
	elseif kind == "Trail" and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local old = root:FindFirstChild("EggTrail")
			if old then old:Destroy() end
			if name ~= "None" then
				local trail = Instance.new("Trail")
				trail.Name = "EggTrail"
				trail.Color = ColorSequence.new(catalogue[name].Color)
				trail.Lifetime = 0.35
				local a0 = Instance.new("Attachment", root)
				local a1 = Instance.new("Attachment", root)
				a0.Position = Vector3.new(-0.7, 0, 0)
				a1.Position = Vector3.new(0.7, 0, 0)
				trail.Attachment0, trail.Attachment1 = a0, a1
				trail.Parent = root
			end
		end
	end
	cosmeticsEvent:FireClient(player, {Shell = player:GetAttribute("EquippedShell") or "Classic", Trail = player:GetAttribute("EquippedTrail") or "None"})
end

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("EquippedShell", "Classic")
	player:SetAttribute("EquippedTrail", "None")
	player.CharacterAdded:Connect(function(character)
		local egg = makeEgg(character)
		egg.Color = shells[player:GetAttribute("EquippedShell") or "Classic"].Color
		task.defer(function() apply(player, "Trail", player:GetAttribute("EquippedTrail") or "None") end)
	end)
end)

equip.OnServerEvent:Connect(function(player, kind, name)
	if (kind == "Shell" or kind == "Trail") and type(name) == "string" then apply(player, kind, name) end
end)
