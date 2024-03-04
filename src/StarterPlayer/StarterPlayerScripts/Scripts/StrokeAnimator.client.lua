------ // Script made by Kolbxyz \\ ------

---- Services & Instances ----
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

--// GUI instances
local MainGui = PlayerGui:WaitForChild("MainGui")
local MainFrame = MainGui:WaitForChild("MainFrame")

---- Variables ----

---- Connectors ----
for _, child in pairs(PlayerGui:GetDescendants()) do
	if child:IsA("UIGradient") then
--[[		coroutine.wrap(function()
			game:GetService("RunService").RenderStepped:Connect(function()
				if not child then return end
				if child.Parent.Parent.Parent.Parent.Name == "Intro" then return end
				if child.Rotation >= 360 then
					child.Rotation = 0
				end
				child.Rotation += 4
			end)
		end)()]]
	else
		require(script.Parent.Parent.Modules.Guis).ManageAnimations(child)
	end
end

PlayerGui.DescendantAdded:Connect(function(child)
	require(script.Parent.Parent.Modules.Guis).ManageAnimations(child)
end)


--[[while task.wait() do
	if not MainGui.Dialog.Visible then return end
	TweenService:Create(MainGui.Dialog.Arrow,TweenInfo.new(0.25), {Position=UDim2.new(0.5,0,1.173,0)}):Play()
	TweenService:Create(MainGui.Dialog.Arrow.UIAspectRatioConstraint,TweenInfo.new(0.25), {AspectRatio=1.2}):Play()
	--	TweenService:Create(MainGui.Dialog._Name,TweenInfo.new(0.25), {Size=UDim2.new(0.227, 0,0.303, 0)}):Play()
	task.wait(.25)
	--	TweenService:Create(MainGui.Dialog._Name,TweenInfo.new(0.25), {Size=UDim2.new(0.227, 0,0.227, 0)}):Play()
	TweenService:Create(MainGui.Dialog.Arrow,TweenInfo.new(0.25), {Position=UDim2.new(0.5,0,1.105,0)}):Play()
	TweenService:Create(MainGui.Dialog.Arrow.UIAspectRatioConstraint,TweenInfo.new(0.25), {AspectRatio=1}):Play()
end]]
------ // Script made by Kolbxyz \\ ------