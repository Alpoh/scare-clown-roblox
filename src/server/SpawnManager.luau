local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundState = require(ReplicatedStorage.Shared.RoundState)
local ListUtils = require(ReplicatedStorage.Shared.ListUtils)

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

local function getClownSpawnPoints()
	return getMap():WaitForChild("ClownSpawns"):GetChildren()
end

local function setGateOpen(isOpen)
	local gate = getGate()
	gate.CanCollide = not isOpen
	gate.Transparency = isOpen and 0.85 or 0.3
end

local function selectSpawnPool(isClown, clownSpawnPoints, survivorSpawnPoints)
	if isClown and #clownSpawnPoints > 0 then
		return clownSpawnPoints
	end
	return survivorSpawnPoints
end

local function sendPlayersToPlayArea(RoleManager)
	local spawnPoints = getPlayAreaSpawnPoints()
	local clownSpawnPoints = getClownSpawnPoints()
	if #spawnPoints == 0 then
		return
	end
	local clown = RoleManager and RoleManager.getClown()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local pool = selectSpawnPool(player == clown, clownSpawnPoints, spawnPoints)
			local point = ListUtils.pickRandom(pool)
			character:PivotTo(point.CFrame + Vector3.new(0, 3, 0))
		end
	end
end

local function sendPlayersToLobby()
	for _, player in ipairs(Players:GetPlayers()) do
		player:LoadCharacter()
	end
end

local function applyState(state, RoleManager)
	if state == RoundState.Playing then
		setGateOpen(true)
		sendPlayersToPlayArea(RoleManager)
	elseif state == RoundState.Waiting then
		setGateOpen(false)
		sendPlayersToLobby()
	elseif state == RoundState.Ended then
		setGateOpen(false)
	end
end

function SpawnManager.init(RoundManager, RoleManager)
	applyState(RoundManager.getState(), RoleManager)

	RoundManager.StateChanged:Connect(function(state)
		applyState(state, RoleManager)
	end)
end

return SpawnManager
