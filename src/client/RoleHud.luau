local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FLASH_DURATION = 4

local RoleHud = {}

function RoleHud.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RoleHud"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 2
	screenGui.Parent = playerGui

	local roleLabel = Instance.new("TextLabel")
	roleLabel.Name = "RoleLabel"
	roleLabel.AnchorPoint = Vector2.new(0.5, 0)
	roleLabel.Position = UDim2.new(0.5, 0, 0.1, 0)
	roleLabel.Size = UDim2.new(0.6, 0, 0.08, 0)
	roleLabel.BackgroundTransparency = 1
	roleLabel.Font = Enum.Font.Bangers
	roleLabel.TextScaled = true
	roleLabel.TextColor3 = Color3.fromRGB(255, 230, 60)
	roleLabel.TextStrokeColor3 = Color3.fromRGB(120, 5, 10)
	roleLabel.TextTransparency = 1
	roleLabel.TextStrokeTransparency = 1
	roleLabel.Text = ""
	roleLabel.Parent = screenGui

	local function flashRole(text)
		roleLabel.Text = text
		roleLabel.TextTransparency = 0
		roleLabel.TextStrokeTransparency = 0
		task.delay(FLASH_DURATION, function()
			roleLabel.TextTransparency = 1
			roleLabel.TextStrokeTransparency = 1
		end)
	end

	local clownAssignedRemote = ReplicatedStorage:WaitForChild("ClownAssigned")
	local playerCaughtRemote = ReplicatedStorage:WaitForChild("PlayerCaught")

	clownAssignedRemote.OnClientEvent:Connect(function(clown)
		if clown == player then
			flashRole("ERES EL CLOWN")
		else
			flashRole("SOBREVIVE DEL CLOWN")
		end
	end)

	playerCaughtRemote.OnClientEvent:Connect(function(victim)
		local victimName = victim and victim.Name or "?"
		flashRole(victimName .. " FUE ATRAPADO")
	end)
end

return RoleHud
