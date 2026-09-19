local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundState = require(ReplicatedStorage.Shared.RoundState)

local CatchManager = {}

local playerCaughtBindable = Instance.new("BindableEvent")
CatchManager.PlayerCaught = playerCaughtBindable.Event

local caughtRemote
local getRoundState
local touchConnection
local caughtPlayers = {}

local function ensureRemote()
	local remote = ReplicatedStorage:FindFirstChild("PlayerCaught")
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = "PlayerCaught"
		remote.Parent = ReplicatedStorage
	end
	return remote
end

local function getPlayerFromPart(part)
	local character = part:FindFirstAncestorOfClass("Model")
	if not character then
		return nil
	end
	return Players:GetPlayerFromCharacter(character)
end

local function freezeCharacter(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
	end
end

local function onClownTouched(clown, hit)
	if getRoundState() ~= RoundState.Playing then
		return
	end
	local victim = getPlayerFromPart(hit)
	if not victim or victim == clown or caughtPlayers[victim] then
		return
	end
	caughtPlayers[victim] = true
	if victim.Character then
		freezeCharacter(victim.Character)
	end
	caughtRemote:FireAllClients(victim)
	playerCaughtBindable:Fire(victim)
end

local function connectClownTouch(clown)
	if touchConnection then
		touchConnection:Disconnect()
		touchConnection = nil
	end
	if not clown or not clown.Character then
		return
	end
	local rootPart = clown.Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end
	touchConnection = rootPart.Touched:Connect(function(hit)
		onClownTouched(clown, hit)
	end)
end

function CatchManager.isCaught(player)
	return caughtPlayers[player] == true
end

function CatchManager.init(RoundManager, RoleManager)
	caughtRemote = ensureRemote()
	getRoundState = RoundManager.getState

	RoleManager.RoleAssigned:Connect(connectClownTouch)

	RoundManager.StateChanged:Connect(function(state)
		if state == RoundState.Waiting then
			caughtPlayers = {}
		end
	end)
end

return CatchManager
