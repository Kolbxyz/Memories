local marketPlaceService = game:GetService("MarketplaceService")

local frame = script.Parent
local container = frame.container
local gamepasses = {
	74708875;
	116349961;
	116779341;
}

local example = container.example

for index, passId in pairs(gamepasses) do
	local passInfo = marketPlaceService:GetProductInfo(passId, Enum.InfoType.GamePass)
	local clone = example:Clone()
	clone.Parent, clone.Name, clone.image.Image, clone.name.Text, clone.price.Text, clone.Visible = container, "clone",
		"rbxassetid://"..passInfo.IconImageAssetId, passInfo.Name, passInfo.PriceInRobux, true
	clone.description.Text = passInfo['Description']
	if marketPlaceService:UserOwnsGamePassAsync(game:GetService("Players").LocalPlayer.UserId, passId) then clone.buy.Text = "Owned"; clone.buy.BackgroundColor3 = Color3.new(0.47451, 0.47451, 0.356863); clone.buy.UIStroke.Color=Color3.new(0.231373, 0.188235, 0.14902) end
	clone.buy.MouseButton1Click:Connect(function()
		marketPlaceService:PromptGamePassPurchase(game:GetService("Players").LocalPlayer, passId)
	end)
end