local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RoundState = require(ReplicatedStorage.Shared.RoundState)

local RESULT_TEXT = {
	Clown = "EL CLOWN GANO",
	Survivors = "LOS SOBREVIVIENTES ESCAPARON",
}

local ResultScreen = {}

function ResultScreen.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ResultScreen"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 20
	screenGui.Enabled = false
	screenGui.Parent = playerGui

	local root = Instance.new("CanvasGroup")
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.GroupTransparency = 0
	root.Parent = screenGui

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(5, 3, 4)
	backdrop.BackgroundTransparency = 0.15
	backdrop.BorderSizePixel = 0
	backdrop.Parent = root

	local resultLabel = Instance.new("TextLabel")
	resultLabel.Name = "ResultLabel"
	resultLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	resultLabel.Position = UDim2.new(0.5, 0, 0.45, 0)
	resultLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
	resultLabel.BackgroundTransparency = 1
	resultLabel.Font = Enum.Font.Bangers
	resultLabel.TextScaled = true
	resultLabel.TextColor3 = Color3.fromRGB(240, 195, 45)
	resultLabel.TextStrokeColor3 = Color3.fromRGB(120, 5, 10)
	resultLabel.TextStrokeTransparency = 0
	resultLabel.Text = ""
	resultLabel.Parent = root

	local roundResultRemote = ReplicatedStorage:WaitForChild("RoundResult")
	local roundStateChangedRemote = ReplicatedStorage:WaitForChild("RoundStateChanged")

	local function show(winner)
		resultLabel.Text = RESULT_TEXT[winner] or tostring(winner)
		root.GroupTransparency = 1
		screenGui.Enabled = true
		TweenService:Create(root, TweenInfo.new(0.4, Enum.EasingStyle.Quad), { GroupTransparency = 0 }):Play()
	end

	local function hide()
		local fadeOut = TweenService:Create(root, TweenInfo.new(0.4, Enum.EasingStyle.Quad), { GroupTransparency = 1 })
		fadeOut:Play()
		fadeOut.Completed:Wait()
		screenGui.Enabled = false
	end

	roundResultRemote.OnClientEvent:Connect(show)

	roundStateChangedRemote.OnClientEvent:Connect(function(state)
		if state ~= RoundState.Ended and screenGui.Enabled then
			hide()
		end
	end)
end

return ResultScreen
