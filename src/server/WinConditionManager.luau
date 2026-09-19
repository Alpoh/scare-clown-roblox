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

function WinConditionManager.init(RoundManager, RoleManager, CatchManager)
	roundResultRemote = ensureRemote()

	RoundManager.StateChanged:Connect(function(state)
		if state == RoundState.Playing then
			decided = false
			caughtCount = 0
			local clown = RoleManager.getClown()
			local totalPlayers = #Players:GetPlayers()
			survivorCount = clown and math.max(totalPlayers - 1, 0) or totalPlayers
		elseif state == RoundState.Ended then
			declareResult("Survivors")
		end
	end)

	CatchManager.PlayerCaught:Connect(function()
		caughtCount += 1
		if survivorCount > 0 and caughtCount >= survivorCount then
			declareResult("Clown")
			RoundManager.endPlayingEarly()
		end
	end)
end

return WinConditionManager
