local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")

local Categories = game:GetChildren()
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UI = script.Parent
local Bar = UI.Bar
local Status = UI.Status
local Percentage = UI.Percentage

local function preloadAsset(asset)
	local success, errorMsg = pcall(function()
		ContentProvider:PreloadAsync({asset})
	end)

	if not success then
		warn(errorMsg)
	end
end

local function updateLoadingStatus(categoryName, assetName, currentIndex, totalCategories)
	Status.Text = string.format("%s: %s, %d / %d", categoryName, assetName, currentIndex, totalCategories)
	Percentage.Text = string.format("%d%%", math.round(currentIndex / totalCategories * 100))
	Bar.Fill.Size = UDim2.new(currentIndex / totalCategories, 0, 1, 0)
end

local function preloadAssetsInCategory(category)
	for i, asset in pairs(category:GetDescendants()) do
		preloadAsset(asset)
		updateLoadingStatus(category.Name, asset.Name, i, #category:GetDescendants())
	end
end

script.Parent.Parent.Parent = PlayerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()

local startTime = os.clock()

for i, category in pairs(Categories) do
	preloadAssetsInCategory(category)
end

while Bar.Fill.Size.X.Scale ~= 1 do task.wait(1) end

task.wait(2)

game:GetService("TweenService"):Create(UI, TweenInfo.new(.5), {Position=UDim2.new(0.5, 0,-0.5, -36)}):Play()
script.Parent.Parent.Parent:WaitForChild("MainGui").Enabled = true
task.wait(.5)
script.Parent:Destroy()