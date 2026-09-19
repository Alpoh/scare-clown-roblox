local DEFAULT_STATS = {
	RoundsPlayed = 0,
	TimesCaught = 0,
	TimesAsClown = 0,
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

return PlayerStats
