local UserInputService = game:GetService("UserInputService")

local UISlider = {}

local function clamp01(value)
	return math.clamp(value, 0, 1)
end

function UISlider.create(parent, config)
	local zIndex = config.zIndex or 1

	local track = Instance.new("Frame")
	track.Name = (config.name or "Slider") .. "Track"
	track.Size = config.size or UDim2.new(0.8, 0, 0, 10)
	track.Position = config.position or UDim2.new(0.1, 0, 0.5, 0)
	track.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	track.BorderSizePixel = 0
	track.ZIndex = zIndex
	track.Parent = parent

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.ZIndex = zIndex + 1
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local handle = Instance.new("Frame")
	handle.Name = "Handle"
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.Size = UDim2.new(0, 18, 0, 18)
	handle.Position = UDim2.new(0, 0, 0.5, 0)
	handle.BackgroundColor3 = Color3.fromRGB(240, 195, 45)
	handle.BorderSizePixel = 0
	handle.ZIndex = zIndex + 2
	handle.Parent = track

	local handleCorner = Instance.new("UICorner")
	handleCorner.CornerRadius = UDim.new(1, 0)
	handleCorner.Parent = handle

	local value = clamp01(config.initial or 0)
	local dragging = false

	local function applyValue(newValue)
		value = clamp01(newValue)
		fill.Size = UDim2.new(value, 0, 1, 0)
		handle.Position = UDim2.new(value, 0, 0.5, 0)
		if config.onChanged then
			config.onChanged(value)
		end
	end

	local function valueFromInputX(inputX)
		local absoluteSize = track.AbsoluteSize.X
		if absoluteSize <= 0 then
			return value
		end
		return (inputX - track.AbsolutePosition.X) / absoluteSize
	end

	local function isPointerInput(input)
		return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
	end

	local function beginDrag(input)
		dragging = true
		applyValue(valueFromInputX(input.Position.X))
	end

	track.InputBegan:Connect(function(input)
		if isPointerInput(input) then
			beginDrag(input)
		end
	end)

	handle.InputBegan:Connect(function(input)
		if isPointerInput(input) then
			beginDrag(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			applyValue(valueFromInputX(input.Position.X))
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if isPointerInput(input) then
			dragging = false
		end
	end)

	applyValue(value)

	return {
		track = track,
		setValue = applyValue,
		getValue = function()
			return value
		end,
	}
end

return UISlider
