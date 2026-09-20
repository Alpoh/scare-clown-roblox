local DEFAULT_STATS = {
	RoundsPlayed = 0,
	TimesCaught = 0,
	TimesAsClown = 0,
	RoundsWon = 0,
	MaxSurvivalTime = 0,
	FastestCatch = 999,
	BestWinStreak = 0,
	CurrentWinStreak = 0,
}

local PlayerStats = {}

function PlayerStats.withDefaults(data)
	local result = table.clone(DEFAULT_STATS)
	if data then
		for key in pairs(DEFAULT_STATS) do
			if type(data[key]) == "number" then
				result[key] = data[key]
			end
		end
	end
	return result
end

function PlayerStats.increment(stats, key)
	local result = table.clone(stats)
	result[key] = (result[key] or 0) + 1
	return result
end

function PlayerStats.recordSurvivalTime(stats, survivedSeconds)
	local result = table.clone(stats)
	result.MaxSurvivalTime = math.max(result.MaxSurvivalTime or 0, survivedSeconds)
	return result
end

function PlayerStats.recordCatchTime(stats, catchSeconds)
	local result = table.clone(stats)
	result.FastestCatch = math.min(result.FastestCatch or 999, catchSeconds)
	return result
end

function PlayerStats.recordWin(stats)
	local result = table.clone(stats)
	result.RoundsWon = (result.RoundsWon or 0) + 1
	result.CurrentWinStreak = (result.CurrentWinStreak or 0) + 1
	result.BestWinStreak = math.max(result.BestWinStreak or 0, result.CurrentWinStreak)
	return result
end

function PlayerStats.resetWinStreak(stats)
	local result = table.clone(stats)
	result.CurrentWinStreak = 0
	return result
end

return PlayerStats
