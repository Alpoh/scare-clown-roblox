local PowerUpConfig = {
	Speed = {
		name = "VELOCIDAD",
		duration = 15,
		color = Color3.fromRGB(255, 200, 0),
		speedMultiplier = 1.5,
	},
	Shield = {
		name = "ESCUDO",
		duration = 20,
		color = Color3.fromRGB(0, 150, 255),
		invulnerability = true,
	},
	NightVision = {
		name = "VISIÓN",
		duration = 10,
		color = Color3.fromRGB(50, 255, 50),
		brightnessBuff = true,
	},
}

local function getRandomPowerUp()
	local types = {}
	for name, _ in pairs(PowerUpConfig) do
		table.insert(types, name)
	end
	return types[math.random(#types)]
end

local function getPowerUp(name)
	return PowerUpConfig[name]
end

return {
	PowerUpConfig = PowerUpConfig,
	getRandomPowerUp = getRandomPowerUp,
	getPowerUp = getPowerUp,
}
