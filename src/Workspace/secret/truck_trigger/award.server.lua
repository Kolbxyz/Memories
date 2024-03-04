local badgeService = game:GetService("BadgeService")

script.Parent.Touched:Connect(function(p)
	if game:GetService("Players"):GetPlayerFromCharacter(p.Parent) then
		p = game:GetService("Players"):GetPlayerFromCharacter(p.Parent)
		badgeService:AwardBadge(p.UserId, 2143077538)
	end
end)