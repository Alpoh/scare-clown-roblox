local SoundService = game:GetService("SoundService")

local DEFAULT_MUSIC_VOLUME = 0.5

local AudioController = {}

local ambient
local sting
local musicVolume = DEFAULT_MUSIC_VOLUME

function AudioController.init()
	ambient = SoundService:WaitForChild("AmbientMusic")
	sting = SoundService:WaitForChild("CatchSting")
	ambient.Volume = musicVolume
	ambient:Play()
end

function AudioController.setMusicVolume(volume)
	musicVolume = math.clamp(volume, 0, 1)
	if ambient then
		ambient.Volume = musicVolume
	end
end

function AudioController.getMusicVolume()
	return musicVolume
end

function AudioController.playCatchSting()
	if sting then
		sting:Play()
	end
end

return AudioController
