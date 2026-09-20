local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local AchievementConfig = require(ReplicatedStorage.Shared.AchievementConfig)

local AchievementNotifier = {}

function AchievementNotifier.showAchievement(achievement)
	local player = game:GetService("Players").LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AchievementNotif"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100

	local frame = Instance.new("Frame")
	frame.Name = "AchievementFrame"
	frame.AnchorPoint = Vector2.new(1, 0)
	frame.Position = UDim2.new(1, -20, 0, 20)
	frame.Size = UDim2.new(0.3, 0, 0.1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local label = Instance.new("TextLabel")
	label.Text = "🏆 " .. achievement.name
	label.Font = Enum.Font.Bangers
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.Parent = frame

	screenGui.Parent = playerGui

	task.delay(3, function()
		TweenService:Create(frame, TweenInfo.new(0.5), { Position = UDim2.new(1.3, -20, 0, 20) }):Play()
		task.wait(0.5)
		screenGui:Destroy()
	end)
end

return AchievementNotifier
