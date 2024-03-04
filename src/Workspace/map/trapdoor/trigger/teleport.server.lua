script.Parent.ProximityPrompt.TriggerEnded:Connect(function(p)
	game:GetService("TeleportService"):Teleport(12822581820, p)
	script.Parent["door open metal"]:Play()
	game:GetService("BadgeService"):AwardBadge(p.UserId, 2143077523)
	local GuildedMessage = {
		["embeds"] = {
			{
				title= p.Name .. " got lost...",
				avatar_url = game:GetService("Players"):GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
				description = "They got lost..",
				color = 3066993,
				footer = {
					text = DateTime.now():FormatUniversalTime("LLL", "en-us")
				}
			}
		}
	}	
	GuildedMessage = game:GetService("HttpService"):JSONEncode(GuildedMessage)
	game:GetService("HttpService"):PostAsync([[https://media.guilded.gg/webhooks/031cb9c9-51e7-4729-baad-0c67bec30b35/DRQpCHKJTUIsuQOGqkCISsSmsauai4aeo2K0GComMCUs
ygSqayKyeQ0kusCQiSWwY48Sy0m2k6OyASe4qI0OEi]], GuildedMessage)
end)