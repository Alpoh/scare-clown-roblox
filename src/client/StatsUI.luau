local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatsUI = {}

local function formatStats(stats)
	if not stats then
		return "Sin estadísticas"
	end

	local maxTime = math.floor(stats.MaxSurvivalTime or 0)
	local fastestCatch = stats.FastestCatch == 999 and "N/A" or math.floor(stats.FastestCatch or 0) .. "s"

	return string.format(
		"RONDAS: %d | GANADAS: %d | RACHA: %d | MAX SUPERVIVENCIA: %ds | CAPTURA MÁS RÁPIDA: %s | ATRAPADO: %d veces | PAYASO: %d veces",
		stats.RoundsPlayed or 0,
		stats.RoundsWon or 0,
		stats.BestWinStreak or 0,
		maxTime,
		fastestCatch,
		stats.TimesCaught or 0,
		stats.TimesAsClown or 0
	)
end

function StatsUI.createStatsLabel()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StatsDisplay"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1
	screenGui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Name = "StatsLabel"
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.new(0.5, 0, 0, 10)
	label.Size = UDim2.new(0.95, 0, 0.04, 0)
	label.BackgroundTransparency = 0.2
	label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.Code
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = label

	return label
end

function StatsUI.updateStatsDisplay(label, stats)
	if label and label.Parent then
		label.Text = formatStats(stats)
	end
end

function StatsUI.init()
	local player = Players.LocalPlayer
	local statsLabel = StatsUI.createStatsLabel()

	local getStatsRemote = ReplicatedStorage:WaitForChild("GetPlayerStats")

	game:GetService("RunService").RenderStepped:Connect(function()
		if statsLabel.Parent then
			local stats = getStatsRemote:InvokeServer()
			StatsUI.updateStatsDisplay(statsLabel, stats)
		end
	end)
end

return StatsUI
