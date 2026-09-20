local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ProximityIndicator = {}

local PROXIMITY_RANGES = {
	{ distance = 10, message = "¡¡CALIENTE!!", color = Color3.fromRGB(255, 0, 0) },
	{ distance = 25, message = "¡CALIENTE!", color = Color3.fromRGB(255, 100, 0) },
	{ distance = 50, message = "TIBIO", color = Color3.fromRGB(255, 255, 0) },
	{ distance = 100, message = "FRÍO", color = Color3.fromRGB(100, 200, 255) },
	{ distance = math.huge, message = "MUY FRÍO", color = Color3.fromRGB(0, 100, 255) },
}

local function getClosestSalvationZone()
	local Map = Workspace:FindFirstChild("Map")
	if not Map then
		return nil
	end

	local closest = nil
	local minDistance = math.huge

	for _, mazeFolder in pairs(Map:GetChildren()) do
		if mazeFolder:IsA("Folder") and mazeFolder.Name:match("Maze") then
			local salvationZone = mazeFolder:FindFirstChild("SpawnZone")
			if salvationZone then
				local distance = (salvationZone.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
				if distance < minDistance then
					minDistance = distance
					closest = salvationZone
				end
			end
		end
	end

	return closest
end

local function createIndicatorUI(playerGui)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ProximityIndicator"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 5
	screenGui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Name = "ProximityLabel"
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.new(0.5, 0, 0.05, 0)
	label.Size = UDim2.new(0.4, 0, 0.08, 0)
	label.BackgroundTransparency = 0.3
	label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.Bangers
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = ""
	label.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	return label
end

local function updateProximity(label, salvationZone, player)
	if not salvationZone or not player.Character then
		return
	end

	local distance = (salvationZone.Position - player.Character.HumanoidRootPart.Position).Magnitude

	for _, range in pairs(PROXIMITY_RANGES) do
		if distance <= range.distance then
			label.Text = range.message
			label.TextColor3 = range.color
			break
		end
	end
end

function ProximityIndicator.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local label = createIndicatorUI(playerGui)

	local updateConnection
	updateConnection = game:GetService("RunService").RenderStepped:Connect(function()
		if not player.Character then
			label.Text = ""
			return
		end

		local salvationZone = getClosestSalvationZone()
		updateProximity(label, salvationZone, player)
	end)

	player.CharacterRemoving:Connect(function()
		label.Text = ""
	end)
end

return ProximityIndicator
