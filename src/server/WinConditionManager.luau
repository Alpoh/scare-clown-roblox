local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundState = require(ReplicatedStorage.Shared.RoundState)

local WinConditionManager = {}

local roundResultRemote

local survivorCount = 0
local caughtCount = 0
local decided = false

local function ensureRemote()
	local remote = ReplicatedStorage:FindFirstChild("RoundResult")
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = "RoundResult"
		remote.Parent = ReplicatedStorage
	end
	return remote
end

local function declareResult(winner)
	if decided then
		return
	end
	decided = true
	roundResultRemote:FireAllClients(winner)
end

local function computeSurvivorCount(totalPlayers, hasClown)
	if hasClown then
		return math.max(totalPlayers - 1, 0)
	end
	return totalPlayers
end

local function isClownVictory(caughtCount, survivorCount)
	return survivorCount > 0 and caughtCount >= survivorCount
end

function WinConditionManager.init(RoundManager, RoleManager, CatchManager)
	roundResultRemote = ensureRemote()

	RoundManager.StateChanged:Connect(function(state)
		if state == RoundState.Playing then
			decided = false
			caughtCount = 0
			local clown = RoleManager.getClown()
			survivorCount = computeSurvivorCount(#Players:GetPlayers(), clown ~= nil)
		elseif state == RoundState.Ended then
			declareResult("Survivors")
		end
	end)

	CatchManager.PlayerCaught:Connect(function()
		caughtCount += 1
		if isClownVictory(caughtCount, survivorCount) then
			declareResult("Clown")
			RoundManager.endPlayingEarly()
		end
	end)
end

return WinConditionManager
