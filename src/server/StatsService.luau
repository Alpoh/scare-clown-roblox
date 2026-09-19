local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundState = require(ReplicatedStorage.Shared.RoundState)
local PlayerStats = require(ReplicatedStorage.Shared.PlayerStats)
local Promise = require(ReplicatedStorage.Packages.Promise)

local STORE_NAME = "PlayerStats_v1"
local RETRY_ATTEMPTS = 3
local RETRY_DELAY_SECONDS = 2

local StatsService = {}

local dataStore = DataStoreService:GetDataStore(STORE_NAME)
local cache = {}

local function attemptAsync(fn, attemptsLeft)
	return Promise.new(function(resolve, reject)
		local ok, result = pcall(fn)
		if ok then
			resolve(result)
		else
			reject(result)
		end
	end):catch(function(err)
		if attemptsLeft <= 1 then
			return Promise.reject(err)
		end
		return Promise.delay(RETRY_DELAY_SECONDS):andThen(function()
			return attemptAsync(fn, attemptsLeft - 1)
		end)
	end)
end

local function loadStats(userId)
	return attemptAsync(function()
		return dataStore:GetAsync("Player_" .. userId)
	end, RETRY_ATTEMPTS)
end

local function saveStats(userId, stats)
	return attemptAsync(function()
		dataStore:SetAsync("Player_" .. userId, stats)
		return true
	end, RETRY_ATTEMPTS)
end

local function getCached(player)
	return cache[player.UserId]
end

local function updateCached(player, key)
	local current = getCached(player)
	if not current then
		return
	end
	cache[player.UserId] = PlayerStats.increment(current, key)
end

function StatsService.getStats(player)
	return getCached(player)
end

local function onPlayerAdded(player)
	loadStats(player.UserId)
		:andThen(function(data)
			cache[player.UserId] = PlayerStats.withDefaults(data)
		end)
		:catch(function()
			cache[player.UserId] = PlayerStats.withDefaults(nil)
		end)
end

local function flushPlayer(player)
	local stats = getCached(player)
	if not stats then
		return Promise.resolve(true)
	end
	return saveStats(player.UserId, stats)
end

local function onPlayerRemoving(player)
	flushPlayer(player):catch(function() end)
	cache[player.UserId] = nil
end

function StatsService.init(RoundManager, RoleManager, CatchManager)
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	RoundManager.StateChanged:Connect(function(state)
		if state == RoundState.Playing then
			for _, player in ipairs(Players:GetPlayers()) do
				updateCached(player, "RoundsPlayed")
			end
		end
	end)

	RoleManager.RoleAssigned:Connect(function(clown)
		if clown then
			updateCached(clown, "TimesAsClown")
		end
	end)

	CatchManager.PlayerCaught:Connect(function(victim)
		updateCached(victim, "TimesCaught")
	end)

	game:BindToClose(function()
		local promises = {}
		for _, player in ipairs(Players:GetPlayers()) do
			table.insert(promises, flushPlayer(player))
		end
		Promise.all(promises):catch(function() end):await()
	end)
end

return StatsService
