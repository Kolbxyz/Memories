local children = workspace:WaitForChild("Clones")
local table = children:GetChildren()

children.ChildAdded:Connect(function(child)
	table = children:GetChildren()
	child:WaitForChild("ProximityPrompt").TriggerEnded:Connect(function()
		game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("MainGui").MainFrame.loadingText.Visible = true
	end)
end)