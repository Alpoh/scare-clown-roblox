local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local STATE_LABELS = {
	Waiting = "Esperando jugadores",
	Starting = "¡Prepárate!",
	Playing = "Ronda en curso",
	Ended = "Ronda terminada",
}

local RoundHud = {}

function RoundHud.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RoundHud"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1
	screenGui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Name = "StateLabel"
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.new(0.5, 0, 0.02, 0)
	label.Size = UDim2.new(0.5, 0, 0.06, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSansBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Text = ""
	label.Parent = screenGui

	local remote = ReplicatedStorage:WaitForChild("RoundStateChanged")

	local currentState = "Waiting"
	local remainingAtReceive = 0
	local receivedAt = os.clock()

	remote.OnClientEvent:Connect(function(state, duration)
		currentState = state
		remainingAtReceive = duration
		receivedAt = os.clock()
	end)

	task.spawn(function()
		while true do
			local elapsed = os.clock() - receivedAt
			local remaining = math.max(math.ceil(remainingAtReceive - elapsed), 0)
			local text = STATE_LABELS[currentState] or currentState
			label.Text = string.format("%s (%ds)", text, remaining)
			task.wait(0.2)
		end
	end)
end

return RoundHud
