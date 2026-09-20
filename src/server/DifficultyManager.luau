local DifficultyManager = {}

local roundCount = 0
local currentDifficulty = 1

local DIFFICULTY_THRESHOLDS = {
	{ roundsNeeded = 0, speedMultiplier = 1.0, name = "FÁCIL" },
	{ roundsNeeded = 3, speedMultiplier = 1.1, name = "NORMAL" },
	{ roundsNeeded = 6, speedMultiplier = 1.2, name = "DIFÍCIL" },
	{ roundsNeeded = 9, speedMultiplier = 1.3, name = "MUY DIFÍCIL" },
}

local function updateDifficulty()
	for i, threshold in ipairs(DIFFICULTY_THRESHOLDS) do
		if roundCount >= threshold.roundsNeeded then
			currentDifficulty = i
		end
	end
end

local function getDifficultyLevel()
	return DIFFICULTY_THRESHOLDS[currentDifficulty]
end

local function incrementRoundCount()
	roundCount = roundCount + 1
	updateDifficulty()
end

local function getRoundCount()
	return roundCount
end

local function getSpeedMultiplier()
	return getDifficultyLevel().speedMultiplier
end

local function getDifficultyName()
	return getDifficultyLevel().name
end

function DifficultyManager.init()
	roundCount = 0
	currentDifficulty = 1
end

function DifficultyManager.nextRound()
	incrementRoundCount()
end

function DifficultyManager.getRoundCount()
	return getRoundCount()
end

function DifficultyManager.getSpeedMultiplier()
	return getSpeedMultiplier()
end

function DifficultyManager.getDifficultyName()
	return getDifficultyName()
end

return DifficultyManager
