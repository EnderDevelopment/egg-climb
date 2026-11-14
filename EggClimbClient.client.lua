local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("EggClimbRemotes")
local progressEvent = remotes:WaitForChild("ProgressUpdate")
local equipEvent = remotes:WaitForChild("EquipCosmetic")

local gui = Instance.new("ScreenGui")
gui.Name = "EggClimbHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function text(parent, value, size, color, font)
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Text = value
	item.TextColor3 = color
	item.TextSize = size
	item.Font = font or Enum.Font.GothamBold
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.Parent = parent
	return item
end

local panel = Instance.new("Frame")
panel.Name = "ProgressPanel"
panel.Size = UDim2.fromOffset(285, 92)
panel.Position = UDim2.fromOffset(18, 18)
panel.BackgroundColor3 = Color3.fromRGB(36, 45, 71)
panel.BackgroundTransparency = 0.08
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local title = text(panel, "EGG CLIMB!", 20, Color3.fromRGB(255, 230, 108), Enum.Font.GothamBlack)
title.Position = UDim2.fromOffset(14, 9)
title.Size = UDim2.fromOffset(170, 25)
local stats = text(panel, "WINS  0     COINS  0", 14, Color3.fromRGB(235, 240, 255))
stats.Position = UDim2.fromOffset(14, 37)
stats.Size = UDim2.fromOffset(250, 22)
local track = Instance.new("Frame")
track.Size = UDim2.fromOffset(255, 8)
track.Position = UDim2.fromOffset(14, 70)
track.BackgroundColor3 = Color3.fromRGB(74, 86, 116)
track.Parent = panel
Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = Color3.fromRGB(112, 229, 166)
fill.Parent = track
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local shop = Instance.new("Frame")
shop.Name = "Unlocks"
shop.Size = UDim2.fromOffset(205, 224)
shop.AnchorPoint = Vector2.new(1, 0)
shop.Position = UDim2.new(1, -18, 0, 18)
shop.BackgroundColor3 = Color3.fromRGB(36, 45, 71)
shop.BackgroundTransparency = 0.08
shop.Parent = gui
Instance.new("UICorner", shop).CornerRadius = UDim.new(0, 14)
local shopTitle = text(shop, "UNLOCKS", 17, Color3.fromRGB(255, 230, 108), Enum.Font.GothamBlack)
shopTitle.Position = UDim2.fromOffset(14, 10)
shopTitle.Size = UDim2.fromOffset(170, 22)
local function button(y, caption, kind, name, required)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(177, 34)
	button.Position = UDim2.fromOffset(14, y)
	button.BackgroundColor3 = Color3.fromRGB(57, 70, 101)
	button.TextColor3 = Color3.fromRGB(245, 247, 255)
	button.Text = caption .. "  • " .. required .. " wins"
	button.TextSize = 12
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = true
	button.Parent = shop
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
	button.Activated:Connect(function() equipEvent:FireServer(kind, name) end)
	return button
end
button(42, "Classic shell", "Shell", "Classic", 0)
button(82, "Berry shell", "Shell", "Berry", 1)
button(122, "Rainbow trail", "Trail", "Rainbow", 2)
button(162, "Starlight trail", "Trail", "Starlight", 5)

local toast = text(gui, "", 24, Color3.fromRGB(255, 246, 168), Enum.Font.GothamBlack)
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0.18, 0)
toast.Size = UDim2.fromOffset(600, 42)
toast.TextXAlignment = Enum.TextXAlignment.Center
toast.TextTransparency = 1
toast.TextStrokeTransparency = 1

local function showToast(message)
	toast.Text = message
	TweenService:Create(toast, TweenInfo.new(0.25), {TextTransparency = 0, TextStrokeTransparency = 0.35}):Play()
	task.delay(3, function()
		TweenService:Create(toast, TweenInfo.new(0.4), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	end)
end

progressEvent.OnClientEvent:Connect(function(data)
	if data.Toast then showToast(data.Toast) end
	if data.Wins then
		stats.Text = string.format("WINS  %d     COINS  %d", data.Wins, data.Coins or 0)
		local floor = data.Floor or 0
		fill.Size = UDim2.fromScale(math.clamp(floor / 30, 0, 1), 1)
	end
end)

local function refreshFromAttributes()
	local wins = player:GetAttribute("Wins") or 0
	local coins = player:GetAttribute("Coins") or 0
	local floor = player:GetAttribute("ReachedFloor") or 0
	stats.Text = string.format("WINS  %d     COINS  %d", wins, coins)
	fill.Size = UDim2.fromScale(math.clamp(floor / 30, 0, 1), 1)
end
player.AttributeChanged:Connect(refreshFromAttributes)
refreshFromAttributes()
