script.Parent.ProximityPrompt.TriggerEnded:Connect(function(Player)
	game:GetService("BadgeService"):AwardBadge(Player.UserId, 2129511313)
end)