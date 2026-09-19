local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundState = require(ReplicatedStorage.Shared.RoundState)
local ListUtils = require(ReplicatedStorage.Shared.ListUtils)

local CLOWN_WALK_SPEED = 22
local CLOWN_COLOR = Color3.fromRGB(230, 60, 30)

local RoleManager = {}

local roleAssignedBindable = Instance.new("BindableEvent")
RoleManager.RoleAssigned = roleAssignedBindable.Event

local clownAssignedRemote
local currentClown = nil

local function ensureRemote()
	local remote = ReplicatedStorage:FindFirstChild("ClownAssigned")
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = "ClownAssigned"
		remote.Parent = ReplicatedStorage
	end
	return remote
end

local function applyClownAppearance(clown)
	local character = clown.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = CLOWN_WALK_SPEED
	end
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Color = CLOWN_COLOR
		end
	end
end

local function assignRoles()
	currentClown = ListUtils.pickRandom(Players:GetPlayers())
	if currentClown then
		applyClownAppearance(currentClown)
	end
	clownAssignedRemote:FireAllClients(currentClown)
	roleAssignedBindable:Fire(currentClown)
end

function RoleManager.getClown()
	return currentClown
end

function RoleManager.isClown(player)
	return player ~= nil and player == currentClown
end

function RoleManager.init(RoundManager)
	clownAssignedRemote = ensureRemote()

	RoundManager.StateChanged:Connect(function(state)
		if state == RoundState.Starting then
			assignRoles()
		elseif state == RoundState.Waiting then
			currentClown = nil
		end
	end)
end

return RoleManager
