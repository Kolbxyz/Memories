local replicatedStorage = game:GetService("ReplicatedStorage")
local remote = replicatedStorage.Remotes.notify

function notify(title, content)
	local newNotification = script.Parent.template:Clone()
	local size = newNotification.Size
	newNotification.Size = UDim2.new()
	newNotification.Parent, newNotification.Visible = script.Parent, true
	newNotification.title.Text = title; newNotification.content.Text = content
	workspace.Sounds.notification:Play()
	game:GetService("TweenService"):Create(newNotification, TweenInfo.new(.4), {Size=size}):Play()
	game:GetService("TweenService"):Create(newNotification, TweenInfo.new(.4), {GroupTransparency=0}):Play()
	task.wait(5)
	game:GetService("TweenService"):Create(newNotification, TweenInfo.new(.4), {Size=UDim2.new()}):Play()
	game:GetService("TweenService"):Create(newNotification, TweenInfo.new(.4), {GroupTransparency=1}):Play()
	task.wait(.4)
	newNotification:Destroy()
end

remote.OnClientEvent:Connect(notify)
replicatedStorage.Remotes.clientNotify.Event:Connect(notify)