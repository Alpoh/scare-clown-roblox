local SoundService = game:GetService("SoundService")

local AMBIENT_VOLUME = 0.5

local AudioController = {}

local ambient
local sting
local musicEnabled = true

function AudioController.init()
	ambient = SoundService:WaitForChild("AmbientMusic")
	sting = SoundService:WaitForChild("CatchSting")
	ambient.Volume = musicEnabled and AMBIENT_VOLUME or 0
	ambient:Play()
end

function AudioController.setMusicEnabled(enabled)
	musicEnabled = enabled
	if ambient then
		ambient.Volume = enabled and AMBIENT_VOLUME or 0
	end
end

function AudioController.playCatchSting()
	if sting then
		sting:Play()
	end
end

return AudioController
