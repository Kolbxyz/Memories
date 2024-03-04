local players = game:GetService("Players")
local player = players.LocalPlayer
local playerGui = player.PlayerGui
local mainGui = playerGui:WaitForChild("MainGui")
local sideButtons = mainGui:WaitForChild("sideButtons")

local module = {}

module.themes = {
	{
		["name"] = "Classic",
		["price"] = false,
		["config"] = {
			SIDE_BUTTONS_CORNER_RADIUS = 100,
			BUTTONS_STROKE = true,
			BUTTONS_BACKGROUND = true,
			BUTTONS_BLUR = true,
			BUTTONS_BACKGROUND_COLOR = Color3.fromRGB(22, 22, 22),
			
			FRAMES_BACKGROUND = true,
			FRAMES_BACKGROUND_COLOR = Color3.fromRGB(39, 39, 39),
			
			GLOBAL_CORNER_RADIUS = nil,
		}
	},
	{
		["name"] = "Modern",
		["price"] = true,
		["config"] = {
			SIDE_BUTTONS_CORNER_RADIUS = 15,
			BUTTONS_STROKE = false,
			BUTTONS_BACKGROUND = false,
			BUTTONS_BLUR = false,
			BUTTONS_BACKGROUND_COLOR = Color3.fromRGB(15, 15, 15),

			FRAMES_BACKGROUND = false,
			FRAMES_BACKGROUND_COLOR = Color3.fromRGB(18, 18, 18),

			GLOBAL_CORNER_RADIUS = nil,
		}
	}
}

function module.applyConfig(configs)
	local config = configs.config
	local success, error = pcall(function()
		for _, button in pairs(sideButtons.container:GetChildren()) do
			if not button:IsA("TextButton") then continue end
			button.UICorner.CornerRadius = UDim.new(0, config.SIDE_BUTTONS_CORNER_RADIUS or 100)
		end
	
		for _, button in pairs(mainGui:GetDescendants()) do
			if not button:IsA("TextButton") then continue end
			
			if button:FindFirstChild("Pattern") then
				button.Pattern.Visible = config.BUTTONS_BACKGROUND
			end
			
			if button:FindFirstChildWhichIsA("UIStroke") then
				button:FindFirstChildWhichIsA("UIStroke").Enabled = config.BUTTONS_STROKE or true
			end
			
			if button:FindFirstChild("Blur") then
				button.Blur.Visible = config.BUTTONS_BLUR or true
			end
			
			button.BackgroundColor3 = config.BUTTONS_BACKGROUND_COLOR-- or Color3.fromRGB(22,22,22)
		end
	
		for _, frame in pairs(mainGui.MainFrame:GetChildren()) do
			if not frame:IsA("Frame") then continue end
			
			if frame:FindFirstChild("Pattern") then
				frame:WaitForChild("Pattern", 2).Visible = config.FRAMES_BACKGROUND or true
			end
			
			frame.BackgroundColor3 = config.FRAMES_BACKGROUND_COLOR or Color3.fromRGB(39,39,39)
		end
			
		for _, thing in pairs(mainGui:GetDescendants()) do
			if not config.GLOBAL_CORNER_RADIUS then break end
			if thing:FindFirstChildWhichIsA("UICorner") then thing:FindFirstChildWhichIsA("UICorner").CornerRadius = UDim.new(0, config.GLOBAL_CORNER_RADIUS) end
		end
	end)
	if not success and error then warn(error) end
end

return module