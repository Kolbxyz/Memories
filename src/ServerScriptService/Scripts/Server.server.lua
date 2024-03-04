------ // Script made by Kolbxyz \\ ------

---- Services & Instances ----
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local marketPlaceService = game:GetService("MarketplaceService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Modules = ServerScriptService:WaitForChild("Modules")

--// Modules
local _Main = Modules:WaitForChild("Main")
--\\

---- Variables ----
--local DataStore = DataStoreService:GetDataStore("DATA")

---- Connectors ----
--\\Remote events
Remotes.New.OnServerEvent:Connect(require(_Main).New)
Remotes.edit.OnServerEvent:Connect(require(_Main).edit)
--Remotes.Refresh.OnServerEvent:Connect(require(_Main).Refresh)
Remotes.Like.OnServerEvent:Connect(require(_Main).Like)
Remotes.Feedback.OnServerEvent:Connect(require(_Main).SendFeedback)
Remotes.ReportMessage.OnServerEvent:Connect(require(_Main).Report)
Remotes.delete.OnServerEvent:Connect(require(_Main).delete)

Remotes.getMessagesCount.OnServerInvoke = function(player)
	local messagesCount = require(_Main):getUserData(player)["messagesCount"]
	local data = require(_Main).GetData()
	
	local count = 0
	for i, v in pairs(data) do
		if v.ID == tostring(player.UserId) then
			for _, _ in pairs(v.data) do
				count += 1
			end
		end
	end
	
	local remaining = messagesCount - count
	return remaining, messagesCount
end
Remotes.getData.OnServerInvoke = function(player, playerToGet)
	return require(_Main):getUserData(playerToGet)
end

--\\Remote functions
Remotes.GetLiked.OnServerInvoke = require(_Main).GetLiked
Remotes.Filter.OnServerInvoke = require(_Main).Filter

--\\Everything else
marketPlaceService.ProcessReceipt = require(_Main).processReceipt

local l_c
Players.PlayerAdded:Connect(function(player)
	require(_Main).Refresh()
	require(_Main).isFirstTime(player)
	local joinTime = DateTime.now().UnixTimestamp

	local playtime = require(_Main):getUserData(player).playtime
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"

	local playtime_value = Instance.new("NumberValue", leaderstats)
	playtime_value.Name = "Playtime"; playtime_value.Value = playtime

	l_c = Players.PlayerRemoving:Connect(function(player_leaving)
		if player == player_leaving then
			l_c:Disconnect()
			require(_Main).calculatePlaytime(player, joinTime)
		end
	end)

	while task.wait(1) and Players:FindFirstChild(player.Name) do
		playtime_value.Value += 1
	end

end)

------ // Script made by Kolbxyz \\ ------