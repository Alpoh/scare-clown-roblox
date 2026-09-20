local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundState = require(ReplicatedStorage.Shared.RoundState)
local RoundConfig = require(ReplicatedStorage.Shared.RoundConfig)

local RoundManager = {}

local roundStateChangedEvent
local stateChangedBindable = Instance.new("BindableEvent")

RoundManager.StateChanged = stateChangedBindable.Event

local currentState = RoundState.Waiting
local stateDuration = 0
local stateStartClock = 0
local endPlayingRequested = false
local difficultyManager = nil

local function ensureRemote()
	local remote = ReplicatedStorage:FindFirstChild("RoundStateChanged")
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = "RoundStateChanged"
		remote.Parent = ReplicatedStorage
	end
	return remote
end

local function setState(state, duration)
	currentState = state
	stateDuration = duration
	stateStartClock = os.clock()
	roundStateChangedEvent:FireAllClients(state, duration)
	stateChangedBindable:Fire(state, duration)
end

function RoundManager.getState()
	return currentState
end

function RoundManager.endPlayingEarly()
	endPlayingRequested = true
end

function RoundManager.init(DifficultyMgr)
	difficultyManager = DifficultyMgr
	roundStateChangedEvent = ensureRemote()

	Players.PlayerAdded:Connect(function(player)
		local elapsed = os.clock() - stateStartClock
		local remaining = math.max(stateDuration - elapsed, 0)
		roundStateChangedEvent:FireClient(player, currentState, remaining)
	end)

	task.spawn(function()
		while true do
			setState(RoundState.Waiting, RoundConfig.Waiting)
			task.wait(RoundConfig.Waiting)

			setState(RoundState.Starting, RoundConfig.Starting)
			task.wait(RoundConfig.Starting)

			setState(RoundState.Playing, RoundConfig.Playing)
			endPlayingRequested = false
			local elapsed = 0
			while elapsed < RoundConfig.Playing and not endPlayingRequested do
				local step = math.min(1, RoundConfig.Playing - elapsed)
				task.wait(step)
				elapsed += step
			end

			setState(RoundState.Ended, RoundConfig.Ended)
			task.wait(RoundConfig.Ended)

			if difficultyManager then
				difficultyManager.nextRound()
			end
		end
	end)
end

return RoundManager
