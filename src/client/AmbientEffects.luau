local Workspace = game:GetService("Workspace")

local FLICKER_VARIANCE = 0.6
local MIN_BRIGHTNESS = 0.2
local POINT_LIGHT_TIMEOUT = 5

local AmbientEffects = {}

local function flicker(light)
	local baseBrightness = light.Brightness
	task.spawn(function()
		while light.Parent do
			local variance = (math.random() - 0.5) * FLICKER_VARIANCE
			light.Brightness = math.max(baseBrightness + variance, MIN_BRIGHTNESS)
			task.wait(math.random(2, 6) / 10)
		end
	end)
end

local function tryFlicker(holder)
	local light = holder:FindFirstChildOfClass("PointLight") or holder:WaitForChild("PointLight", POINT_LIGHT_TIMEOUT)
	if light then
		flicker(light)
	end
end

function AmbientEffects.init()
	local map = Workspace:WaitForChild("Map")
	local lights = map:WaitForChild("Lights")

	for _, holder in ipairs(lights:GetChildren()) do
		tryFlicker(holder)
	end
	lights.ChildAdded:Connect(tryFlicker)
end

return AmbientEffects
