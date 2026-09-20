local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PowerUpConfig = require(ReplicatedStorage.Shared.PowerUpConfig)

local PowerUpService = {}

local activePowerUps = {}

local function getRandomSpawnPosition(mazeId)
	local maxAttempts = 10
	for _ = 1, maxAttempts do
		local x = math.random(-45, 45)
		local z = math.random(-45, 45)
		return Vector3.new(x, 2, z)
	end
	return Vector3.new(0, 2, 0)
end

local function createPowerUpPart(powerUpType, position)
	local config = PowerUpConfig.getPowerUp(powerUpType)
	local part = Instance.new("Part")
	part.Name = "PowerUp_" .. powerUpType
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Size = Vector3.new(2, 2, 2)
	part.CanCollide = false
	part.CFrame = CFrame.new(position)
	part.BrickColor = BrickColor.new(config.color)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = Workspace
	return part
end

local function applyPowerUp(player, powerUpType)
	local config = PowerUpConfig.getPowerUp(powerUpType)

	if not activePowerUps[player.UserId] then
		activePowerUps[player.UserId] = {}
	end

	activePowerUps[player.UserId][powerUpType] = true

	if powerUpType == "Speed" then
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = humanoid.WalkSpeed * config.speedMultiplier
			end
		end
	end

	task.delay(config.duration, function()
		if activePowerUps[player.UserId] then
			activePowerUps[player.UserId][powerUpType] = nil
		end

		if powerUpType == "Speed" then
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = humanoid.WalkSpeed / config.speedMultiplier
				end
			end
		end
	end)
end

local function spawnPowerUpInMaze(mazeId)
	local powerUpType = PowerUpConfig.getRandomPowerUp()
	local position = getRandomSpawnPosition(mazeId)
	local part = createPowerUpPart(powerUpType, position)

	local touched = false
	part.Touched:Connect(function(hit)
		if touched then return end

		local character = hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then return end

		local player = Players:GetPlayerFromCharacter(character)
		if player then
			touched = true
			applyPowerUp(player, powerUpType)
			part:Destroy()
		end
	end)

	task.delay(30, function()
		if part.Parent then
			part:Destroy()
		end
	end)
end

function PowerUpService.spawnPowerUpsForMaze(mazeId)
	local config = game.Workspace.Map:FindFirstChild(mazeId)
	if not config then return end

	task.delay(5, function() spawnPowerUpInMaze(mazeId) end)
	task.delay(15, function() spawnPowerUpInMaze(mazeId) end)
end

function PowerUpService.hasPowerUp(player, powerUpType)
	return activePowerUps[player.UserId] and activePowerUps[player.UserId][powerUpType] or false
end

function PowerUpService.clearPowerUps(player)
	activePowerUps[player.UserId] = nil
end

return PowerUpService
