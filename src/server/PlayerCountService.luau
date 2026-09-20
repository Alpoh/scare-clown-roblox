local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundState = require(ReplicatedStorage.Shared.RoundState)

local PlayerCountService = {}

local PLAYER_COUNT_ZONES = {
	{ count = 2, name = "PlayerCount2Zone", position = Vector3.new(-110, 1, -15) },
	{ count = 3, name = "PlayerCount3Zone", position = Vector3.new(-110, 1, 0) },
	{ count = 4, name = "PlayerCount4Zone", position = Vector3.new(-110, 1, 15) },
}

local ZONE_SIZE = Vector3.new(15, 1, 15)
local COUNTDOWN_DURATION = 30
local MIN_PLAYERS_TO_START = 2

local zoneCounter = {}
local countdownActive = false

local function createPlayerCountZones()
	local Map = Workspace:FindFirstChild("Map")
	if not Map then
		return
	end

	for _, zoneData in ipairs(PLAYER_COUNT_ZONES) do
		local existingZone = Map:FindFirstChild(zoneData.name)
		if existingZone then
			existingZone:Destroy()
		end

		local zone = Instance.new("Part")
		zone.Name = zoneData.name
		zone.Shape = Enum.PartType.Block
		zone.Material = Enum.Material.Neon
		zone.Size = ZONE_SIZE
		zone.Position = zoneData.position
		zone.TopSurface = Enum.SurfaceType.Smooth
		zone.BottomSurface = Enum.SurfaceType.Smooth
		zone.CanCollide = false
		zone.Transparency = 0.3
		zone.Color = Color3.fromRGB(100, 200, 255)
		zone.Parent = Map

		local textLabel = Instance.new("Part")
		textLabel.Name = "CountLabel"
		textLabel.Shape = Enum.PartType.Block
		textLabel.Material = Enum.Material.SmoothPlastic
		textLabel.Size = Vector3.new(10, 2, 1)
		textLabel.Position = zoneData.position + Vector3.new(0, ZONE_SIZE.Y / 2 + 2, 0)
		textLabel.CanCollide = false
		textLabel.TopSurface = Enum.SurfaceType.Smooth
		textLabel.BottomSurface = Enum.SurfaceType.Smooth
		textLabel.Color = Color3.fromRGB(0, 0, 0)
		textLabel.Parent = zone

		local textGui = Instance.new("SurfaceGui")
		textGui.Face = Enum.NormalId.Top
		textGui.Parent = textLabel

		local textPart = Instance.new("TextLabel")
		textPart.Name = "Label"
		textPart.Text = tostring(zoneData.count) .. " JUGADORES"
		textPart.Font = Enum.Font.Bangers
		textPart.TextScaled = true
		textPart.TextColor3 = Color3.fromRGB(255, 255, 255)
		textPart.BackgroundTransparency = 1
		textPart.Size = UDim2.new(1, 0, 1, 0)
		textPart.Parent = textGui

		zoneCounter[zone] = { count = zoneData.count, players = {} }
	end
end

local function getPlayersInZone(zone)
	local players = {}
	local zonePos = zone.Position
	local zoneSize = zone.Size / 2

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local charPos = player.Character.HumanoidRootPart.Position
			local diff = (charPos - zonePos).Magnitude
			if diff < math.max(zoneSize.X, zoneSize.Z) then
				table.insert(players, player)
			end
		end
	end

	return players
end

local function getMostPopulatedZone()
	local maxZone = nil
	local maxCount = 0

	for zone, data in pairs(zoneCounter) do
		local players = getPlayersInZone(zone)
		if #players > maxCount and #players >= MIN_PLAYERS_TO_START then
			maxCount = #players
			maxZone = zone
			data.players = players
		end
	end

	return maxZone, maxCount
end

local function updateZoneCounters()
	for zone, data in pairs(zoneCounter) do
		local players = getPlayersInZone(zone)
		data.players = players
		local label = zone:FindFirstChild("CountLabel")
		if label then
			local gui = label:FindFirstChildOfClass("SurfaceGui")
			if gui then
				local textPart = gui:FindFirstChild("Label")
				if textPart then
					textPart.Text = tostring(data.count) .. " JUGADORES\n(" .. tostring(#players) .. " aquí)"
				end
			end
		end
	end
end

local function startCountdown()
	if countdownActive then
		return
	end

	countdownActive = true
	local initialMostPopulated, initialCount = getMostPopulatedZone()

	if not initialMostPopulated or initialCount == 0 then
		countdownActive = false
		return
	end

	for i = COUNTDOWN_DURATION, 1, -1 do
		updateZoneCounters()
		task.wait(1)
		local mostPopulated, count = getMostPopulatedZone()
		if not mostPopulated or count == 0 then
			countdownActive = false
			return
		end
	end

	local selectedZone, selectedCount = getMostPopulatedZone()
	if selectedZone and selectedCount >= MIN_PLAYERS_TO_START then
		print("Jugadores seleccionados: " .. selectedCount)
	end

	countdownActive = false
end

function PlayerCountService.init(RoundManager)
	createPlayerCountZones()

	local lobbyConnectionActive = false

	RoundManager.StateChanged:Connect(function(state)
		if state == RoundState.Waiting then
			if not lobbyConnectionActive then
				lobbyConnectionActive = true
				task.spawn(function()
					while RoundManager.getState() == RoundState.Waiting do
						updateZoneCounters()
						task.wait(0.5)
					end
					lobbyConnectionActive = false
				end)
				startCountdown()
			end
		end
	end)
end

return PlayerCountService
