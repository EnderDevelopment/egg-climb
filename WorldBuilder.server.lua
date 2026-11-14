local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local tower = Instance.new("Folder")
tower.Name = "EggClimbWorld"
tower.Parent = workspace

local remotes = ReplicatedStorage:FindFirstChild("EggClimbRemotes") or Instance.new("Folder")
remotes.Name = "EggClimbRemotes"
remotes.Parent = ReplicatedStorage

local function part(name, size, position, color, material, parent)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.Position = position
	object.Color = color
	object.Material = material or Enum.Material.SmoothPlastic
	object.Anchored = true
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent or tower
	return object
end

local function label(adornee, text, color)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Sign"
	gui.Adornee = adornee
	gui.Size = UDim2.fromOffset(220, 55)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = adornee
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0.35
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.TextScaled = true
	textLabel.Parent = gui
end

local function studdedPlatform(name, center, size, color)
	local base = part(name, size, center, color, Enum.Material.Plastic)
	local rows = math.max(2, math.floor(size.X / 3))
	local columns = math.max(2, math.floor(size.Z / 3))
	for x = 1, rows do
		for z = 1, columns do
			local px = center.X - size.X / 2 + (x - 0.5) * size.X / rows
			local pz = center.Z - size.Z / 2 + (z - 0.5) * size.Z / columns
			local stud = part("Stud", Vector3.new(0.65, 0.18, 0.65), Vector3.new(px, center.Y + size.Y / 2 + 0.09, pz), color, Enum.Material.Plastic)
			stud.Shape = Enum.PartType.Cylinder
			stud.Orientation = Vector3.new(0, 0, 0)
		end
	end
	return base
end

local function checkpoint(floor, position)
	local pad = part("Checkpoint_" .. floor, Vector3.new(10, 0.35, 10), position, Color3.fromRGB(255, 214, 64), Enum.Material.Neon)
	pad:SetAttribute("Floor", floor)
	pad.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = character and Players:GetPlayerFromCharacter(character)
		if player then
			player:SetAttribute("ReachedFloor", math.max(player:GetAttribute("ReachedFloor") or 0, floor))
		end
	end)
end

local function hazard(floor, position, rotation)
	local bar = part("Hazard_" .. floor, Vector3.new(2, 1.2, 12), position, Color3.fromRGB(255, 74, 86), Enum.Material.Neon)
	bar.Orientation = Vector3.new(0, rotation, 0)
	bar.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.Health = 0 end
	end)
end

Lighting.ClockTime = 14
Lighting.Brightness = 2.2
Lighting.Ambient = Color3.fromRGB(130, 145, 175)
Lighting.OutdoorAmbient = Color3.fromRGB(180, 195, 220)

local lobby = studdedPlatform("Lobby", Vector3.new(0, 0, 0), Vector3.new(58, 2, 48), Color3.fromRGB(92, 183, 255))
label(lobby, "EGG CLIMB!", Color3.fromRGB(255, 241, 132))
local spawn = Instance.new("SpawnLocation")
spawn.Name = "EggClimbSpawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, 1.6, 0)
spawn.Transparency = 1
spawn.CanCollide = false
spawn.Anchored = true
spawn.Neutral = true
spawn.Parent = tower

local floorHeight = 8
local floorCount = 30
for floor = 1, floorCount do
	local y = floor * floorHeight
	local x = math.sin(floor * 1.7) * 15
	local z = math.cos(floor * 1.25) * 9
	local width = floor % 3 == 0 and 18 or 14
	local depth = floor % 4 == 0 and 16 or 12
	local platform = studdedPlatform("Floor_" .. floor, Vector3.new(x, y, z), Vector3.new(width, 1.2, depth), floor % 2 == 0 and Color3.fromRGB(117, 220, 164) or Color3.fromRGB(111, 172, 255))
	platform:SetAttribute("Floor", floor)
	local lowerX = math.sin((floor - 1) * 1.7) * 15
	local lowerZ = math.cos((floor - 1) * 1.25) * 9
	local bridge = part("Bridge_" .. floor, Vector3.new(4, 0.65, 8), Vector3.new((x + lowerX) / 2, y - 3.1, (z + lowerZ) / 2), Color3.fromRGB(255, 190, 92), Enum.Material.WoodPlanks)
	bridge.Orientation = Vector3.new(0, math.deg(math.atan2(x - lowerX, z - lowerZ)), 0)
	if floor % 5 == 0 then checkpoint(floor, Vector3.new(x, y + 1, z)) end
	if floor > 2 and floor % 4 == 1 then hazard(floor, Vector3.new(x, y + 1.2, z), floor % 2 == 0 and 25 or -25) end
end

local summit = studdedPlatform("Summit", Vector3.new(0, floorCount * floorHeight + 8, 0), Vector3.new(28, 2, 24), Color3.fromRGB(255, 216, 76))
local finish = part("FinishPad", Vector3.new(12, 0.5, 12), summit.Position + Vector3.new(0, 1.3, 0), Color3.fromRGB(255, 247, 177), Enum.Material.Neon)
finish:SetAttribute("Finish", true)
label(finish, "SUMMIT!", Color3.fromRGB(255, 255, 255))
local finishRemote = remotes:FindFirstChild("FinishTouch") or Instance.new("BindableEvent")
finishRemote.Name = "FinishTouch"
finishRemote.Parent = remotes
finish.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = character and Players:GetPlayerFromCharacter(character)
	if player then finishRemote:Fire(player) end
end)

local sign = part("RulesSign", Vector3.new(12, 5, 0.5), Vector3.new(0, 4, -17), Color3.fromRGB(37, 48, 74), Enum.Material.SmoothPlastic)
local surface = Instance.new("SurfaceGui")
surface.Face = Enum.NormalId.Front
surface.Parent = sign
local rules = Instance.new("TextLabel")
rules.Size = UDim2.fromScale(1, 1)
rules.BackgroundTransparency = 1
rules.Text = "CLIMB HIGH\nTOUCH GOLD\nUNLOCK EGGS"
rules.TextColor3 = Color3.fromRGB(255, 244, 166)
rules.Font = Enum.Font.GothamBold
rules.TextScaled = true
rules.Parent = surface

workspace.FallenPartsDestroyHeight = -40
