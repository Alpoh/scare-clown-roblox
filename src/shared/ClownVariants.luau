local ClownVariants = {
	Normal = {
		name = "PAYASO NORMAL",
		walkSpeed = 22,
		jumpHeight = 7.2,
		multiplier = 1,
	},
	Fast = {
		name = "PAYASO RÁPIDO",
		walkSpeed = 28,
		jumpHeight = 7.2,
		multiplier = 1.27,
	},
	Jumper = {
		name = "PAYASO SALTADOR",
		walkSpeed = 20,
		jumpHeight = 12,
		multiplier = 1.1,
	},
	Stealth = {
		name = "PAYASO SILENCIOSO",
		walkSpeed = 18,
		jumpHeight = 7.2,
		multiplier = 0.82,
	},
}

local function getRandomVariant()
	local variants = {}
	for name, _ in pairs(ClownVariants) do
		table.insert(variants, name)
	end
	return variants[math.random(#variants)]
end

local function getVariant(name)
	return ClownVariants[name] or ClownVariants.Normal
end

return {
	ClownVariants = ClownVariants,
	getRandomVariant = getRandomVariant,
	getVariant = getVariant,
}
