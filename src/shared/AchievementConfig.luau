local AchievementConfig = {
	FirstWin = { name = "PRIMER TRIUNFO", condition = "RoundsWon >= 1" },
	FiveWins = { name = "5 VICTORIAS", condition = "RoundsWon >= 5" },
	TenWins = { name = "10 VICTORIAS", condition = "RoundsWon >= 10" },
	Streak5 = { name = "RACHA DE 5", condition = "BestWinStreak >= 5" },
	QuickCatch = { name = "CAPTURA RÁPIDA", condition = "FastestCatch <= 15" },
	Survivor = { name = "SUPERVIVIENTE", condition = "MaxSurvivalTime >= 60" },
	Epic = { name = "ÉPICO", condition = "MaxSurvivalTime >= 120" },
}

local function checkAchievements(stats)
	local unlocked = {}
	for id, achievement in pairs(AchievementConfig) do
		local condition = achievement.condition
		local nameParts = {}
		for word in condition:gmatch("%w+") do
			table.insert(nameParts, word)
		end

		if loadstring("return function(stats) return " .. condition .. " end")()(stats) then
			table.insert(unlocked, { id = id, name = achievement.name })
		end
	end
	return unlocked
end

return {
	AchievementConfig = AchievementConfig,
	checkAchievements = checkAchievements,
}
