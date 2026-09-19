local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundState = require(ReplicatedStorage.Shared.RoundState)

local SpawnManager = {}

local function getMap()
	return Workspace:WaitForChild("Map")
end

local function getGate()
	return getMap():WaitForChild("LobbyGate")
end

local function getPlayAreaSpawnPoints()
	return getMap():WaitForChild("PlayAreaSpawns"):GetChildren()
end

local function setGateOpen(isOpen)
	local gate = getGate()
	gate.CanCollide = not isOpen
	gate.Transparency = isOpen and 0.85 or 0.3
end

local function sendPlayersToPlayArea()
	local spawnPoints = getPlayAreaSpawnPoints()
	if #spawnPoints == 0 then
		return
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local point = spawnPoints[math.random(1, #spawnPoints)]
			character:PivotTo(point.CFrame + Vector3.new(0, 3, 0))
		end
	end
end

local function sendPlayersToLobby()
	for _, player in ipairs(Players:GetPlayers()) do
		player:LoadCharacter()
	end
end

local function applyState(state)
	if state == RoundState.Playing then
		setGateOpen(true)
		sendPlayersToPlayArea()
	elseif state == RoundState.Waiting then
		setGateOpen(false)
		sendPlayersToLobby()
	elseif state == RoundState.Ended then
		setGateOpen(false)
	end
end

function SpawnManager.init(RoundManager)
	applyState(RoundManager.getState())

	RoundManager.StateChanged:Connect(function(state)
		applyState(state)
	end)
end

return SpawnManager
