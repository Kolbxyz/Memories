------ // Script made by Kolbxyz \\ ------

---- Services & Instances ----
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local marketplaceService = game:GetService("MarketplaceService")
local userService = game:GetService("UserService")

--- Instances
local player = players.LocalPlayer
local character = player.character or player.CharacterAdded:Wait()
local playerGui = player.PlayerGui

-- GUIs
local mainGui = playerGui:WaitForChild("MainGui")
local mainFrame = mainGui:WaitForChild("MainFrame")
local sideButtons = mainGui:WaitForChild("sideButtons")

--\Frames
local favoritesFrame = mainFrame:WaitForChild("FavoritesFrame")
local feedbackFrame = mainFrame:WaitForChild("FeedbackFrame")
local readFrame = mainFrame:WaitForChild("ReadFrame")
local updateFrame = mainFrame:WaitForChild("UpdateFrame")
local upperScreen = mainFrame:WaitForChild("UpperScreen")
local writeFrame = mainFrame:WaitForChild("WriteFrame")
local editFrame = mainFrame:WaitForChild("editFrame")
local profileFrame = mainFrame:WaitForChild("profileFrame")
local settingsFrame = mainFrame:WaitForChild("settingsFrame")

--\Buttons
local writeButton = mainFrame:WaitForChild("Write")
local favoritesButton = mainFrame:WaitForChild("Favorites")
local updatesButton = mainFrame:WaitForChild("Updates")

--\\Side Buttons
local sideButtonsContainer = sideButtons:WaitForChild("container")
local feedbackButton = sideButtonsContainer:WaitForChild("Feedback")
local profileButton = sideButtonsContainer:WaitForChild("profile")
local settingsButton = sideButtonsContainer:WaitForChild("settings")

--\Others
--\\favorites
local favoritesContainer = favoritesFrame:WaitForChild("Container")
local favoriteFrameTemplate = favoritesContainer:WaitForChild("Example")
local recommendationContainer = favoritesFrame:WaitForChild("Recents")
local recommentationTemplate = recommendationContainer:WaitForChild("Example")

--\\write
local writeFrameFilterButton = writeFrame:WaitForChild("Filter")
local writeFrameConfirmButton = writeFrame:WaitForChild("Confirm")
local writeFrameContent = writeFrame:waitForChild("InputText")

--\\read
local readFrameContainer = readFrame:WaitForChild("Likers")
local readFrameTemplate = readFrameContainer:WaitForChild("Example")

--\\admin
local adminButton = sideButtonsContainer:WaitForChild("admin")
local adminFrame = mainFrame:WaitForChild("adminFrame")

local adminEditBox = adminFrame.edit
local adminDeleteBox = adminFrame.delete
local adminEditButton = adminFrame.performEdit
local adminDeleteButton = adminFrame.performDelete

--\Network
local remotes = replicatedStorage:WaitForChild("Remotes")

local Modules = script.Parent.Parent:WaitForChild("Modules")

--// Modules
local _Guis = Modules:WaitForChild("Guis")
--\\

---- Variables ----
adminEditButton.MouseButton1Click:Connect(function()
	local arguments = string.split(adminEditBox.ContentText," ")
	remotes.edit:FireServer(arguments[4], arguments[3], arguments[2], arguments[5])
	adminEditBox.Text = ""
end)
adminDeleteButton.MouseButton1Click:Connect(function()
	
end)

------ // Script made by Kolbxyz \\ ------