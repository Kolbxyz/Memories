script.Parent.ClickDetector.MouseClick:Connect(function(p)
	script.Parent.Color = Color3.new(0,1,0)
	game:GetService("BadgeService"):AwardBadge(p.UserId, 2143235600)
end)