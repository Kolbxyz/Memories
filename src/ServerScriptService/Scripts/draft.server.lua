local main = script.Parent.Parent.Modules.Main
local players = game:GetService("Players")
local datastores = game:GetService("DataStoreService")
--local datastore = datastores:GetDataStore("DATA")
local remotes = game:GetService("ReplicatedStorage").Remotes

remotes.exportDraft.OnServerEvent:Connect(function(player, draft)
	require(game:GetService("ServerScriptService"):WaitForChild("Modules", 1).Main).saveDraft(player, draft)
end)

players.PlayerAdded:Connect(function(player)
	require(game:GetService("ServerScriptService"):WaitForChild("Modules", 1).Main).fixDraft(player)
end)