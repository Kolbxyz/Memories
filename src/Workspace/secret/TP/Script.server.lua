script.Parent.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") then
		if game:GetService("Players"):GetPlayerFromCharacter(hit.Parent) then
			hit.Parent:MoveTo(Vector3.new())
			game:GetService("BadgeService"):AwardBadge(game:GetService("Players"):GetPlayerFromCharacter(hit.Parent).UserId, 2143077549)
		end
	end
end)