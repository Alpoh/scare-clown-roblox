local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

local KICK_MESSAGE = "Este juego esta en pruebas cerradas. Pidele al desarrollador que te agregue como amigo (o amigo de un amigo)."

local AccessControlService = {}

local function collectAllIds(pages)
	local ids = {}
	while true do
		for _, entry in ipairs(pages:GetCurrentPage()) do
			table.insert(ids, entry.Id)
		end
		if pages.IsFinished then
			break
		end
		pages:AdvanceToNextPageAsync()
	end
	return ids
end

local function getFriendIds(userId)
	return Promise.new(function(resolve)
		local ok, result = pcall(function()
			return collectAllIds(Players:GetFriendsAsync(userId))
		end)
		resolve(ok and result or {})
	end)
end

local function buildAllowedSet(ownerUserId)
	return getFriendIds(ownerUserId):andThen(function(directFriends)
		local allowed = { [ownerUserId] = true }
		for _, friendId in ipairs(directFriends) do
			allowed[friendId] = true
		end

		local secondDegreePromises = {}
		for _, friendId in ipairs(directFriends) do
			table.insert(secondDegreePromises, getFriendIds(friendId))
		end

		return Promise.all(secondDegreePromises):andThen(function(secondDegreeLists)
			for _, ids in ipairs(secondDegreeLists) do
				for _, id in ipairs(ids) do
					allowed[id] = true
				end
			end
			return allowed
		end)
	end)
end

local function checkPlayer(player, allowedSet)
	if player.Parent and not allowedSet[player.UserId] then
		player:Kick(KICK_MESSAGE)
	end
end

function AccessControlService.init()
	if game.CreatorType ~= Enum.CreatorType.User then
		return
	end

	local allowedSetPromise = buildAllowedSet(game.CreatorId)

	Players.PlayerAdded:Connect(function(player)
		allowedSetPromise:andThen(function(allowedSet)
			checkPlayer(player, allowedSet)
		end)
	end)
end

return AccessControlService
