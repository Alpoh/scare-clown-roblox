local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundState = require(ReplicatedStorage.Shared.RoundState)
local ListUtils = require(ReplicatedStorage.Shared.ListUtils)

local SpawnManager = {}

local CLOWN_SPAWN_DELAY = 3

local function getMap()
	return Workspace:WaitForChild("Map")
end

local function getGate()
	return getMap():WaitForChild("LobbyGate")
end

local function getMazeSpawnZone(mazeId)
	local maze = getMap():FindFirstChild(mazeId)
	if maze then
		return maze:FindFirstChild("SpawnZone")
	end
	return nil
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

local function spawnSurvivorsInMaze(mazeId, RoleManager)
	local spawnZone = getMazeSpawnZone(mazeId)
	if not spawnZone then
		return
	end

	local clown = RoleManager and RoleManager.getClown()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character and player ~= clown then
			local offsetX = math.random(-7, 7)
			local offsetZ = math.random(-7, 7)
			local spawnPos = spawnZone.Position + Vector3.new(offsetX, 3, offsetZ)
			character:PivotTo(CFrame.new(spawnPos))
		end
	end
end

local function spawnClownInMaze(mazeId, RoleManager)
	task.delay(CLOWN_SPAWN_DELAY, function()
		local spawnZone = getMazeSpawnZone(mazeId)
		if not spawnZone then
			return
		end

		local clown = RoleManager and RoleManager.getClown()
		if clown and clown.Character then
			local offsetX = math.random(-7, 7)
			local offsetZ = math.random(-7, 7)
			local spawnPos = spawnZone.Position + Vector3.new(offsetX, 3, offsetZ)
			clown.Character:PivotTo(CFrame.new(spawnPos))
		end
	end)
end

local function sendPlayersToPlayArea(RoleManager, MazeVotingService)
	if not MazeVotingService then
		return
	end

	local winningMaze = MazeVotingService.tallyVotes()
	spawnSurvivorsInMaze(winningMaze, RoleManager)
	spawnClownInMaze(winningMaze, RoleManager)
end

local function sendPlayersToLobby()
	for _, player in ipairs(Players:GetPlayers()) do
		player:LoadCharacter()
	end
end

local function applyState(state, RoleManager, MazeVotingService)
	if state == RoundState.Playing then
		setGateOpen(true)
		sendPlayersToPlayArea(RoleManager, MazeVotingService)
	elseif state == RoundState.Waiting then
		setGateOpen(false)
		sendPlayersToLobby()
		if MazeVotingService then
			MazeVotingService.resetForNewRound()
		end
	elseif state == RoundState.Ended then
		setGateOpen(false)
	end
end

function SpawnManager.init(RoundManager, RoleManager, MazeVotingService)
	applyState(RoundManager.getState(), RoleManager, MazeVotingService)

	RoundManager.StateChanged:Connect(function(state)
		applyState(state, RoleManager, MazeVotingService)
	end)
end

return SpawnManager
