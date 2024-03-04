game:GetService("ReplicatedStorage").Remotes.userOwnsPass.OnServerInvoke =
	function(trigger, playerId, passId)
		return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(playerId, passId)
	end