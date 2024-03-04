local module = require(game:GetService("ReplicatedStorage").Modules.BanList)

for i, v in pairs(module) do
	local found = false
	if i == game:GetService("Players").LocalPlayer.UserId then
		found = true
		script.Parent.Enabled = true
		script.Parent.Parent.MainGui:Destroy()
		script.Parent.Parent:WaitForChild("Intro"):Destroy()
		game:GetService("Lighting").UIBlur.Enabled = true
		game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.CLIENT.Enabled = false
		
		script.Parent.Background.Description.Text = v.message
		script.Parent.Background.Item.Text = string.format("<b>item</b>: <i>%s</i>", v.item)
	end
	if not found then
		script.Parent:Destroy()
	end
end

script.Parent.Background.TextButton.MouseButton1Click:Connect(function()
	game:GetService("Players").LocalPlayer:Kick("Thanks for playing, please respect the rules.")
end)