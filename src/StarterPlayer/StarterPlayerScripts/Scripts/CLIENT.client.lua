------ // Script made by Kolbxyz \\ ------

---- Services & Instances ----
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local marketplaceService = game:GetService("MarketplaceService")
local userService = game:GetService("UserService")
local Lighting = game:GetService("Lighting")

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
local writeFrame = mainFrame:WaitForChild("WriteFrame")
local editFrame = mainFrame:WaitForChild("editFrame")
local profileFrame = mainFrame:WaitForChild("profileFrame")

--\Buttons
local writeButton = mainFrame:WaitForChild("Write")

--\\Side Buttons
local sideButtonsContainer = sideButtons:WaitForChild("container")
local feedbackButton = sideButtonsContainer:WaitForChild("Feedback")
local profileButton = sideButtonsContainer:WaitForChild("profile")
local favoritesButton = sideButtonsContainer:WaitForChild("Favorites")
local updatesButton = sideButtonsContainer:WaitForChild("Updates")

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

--\Network
local remotes = replicatedStorage:WaitForChild("Remotes")

local Modules = script.Parent.Parent:WaitForChild("Modules")

--// Modules
local _Guis = Modules:WaitForChild("Guis")
--\\

---- Variables ----
local hasInfiniteTextGamePass
pcall(function()
	hasInfiniteTextGamePass = marketplaceService:UserOwnsGamePassAsync(player.UserId, 74708875)
end)

local draftTable = nil

---- Functions ----

function saveDraft()
	draftTable = {content=writeFrame.InputText.Text ~= "" and writeFrame.InputText.Text or "nil";
		title=writeFrame.title.Text ~= "" and writeFrame.title.Text or ""}
	remotes.exportDraft:FireServer(draftTable)
	print("Saving draft...")
end

---- Connectors ----
--\\Single actions
Lighting:WaitForChild("UIBlur"):GetPropertyChangedSignal("Enabled"):Connect(function()
	sideButtons.Visible = not Lighting.UIBlur.Enabled
	local tween = tweenService:Create(workspace.CurrentCamera, TweenInfo.new(.5), {FieldOfView=Lighting.UIBlur.Enabled and 50 or 70})
	tween:Play(); tween:Destroy()
end)
playerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

for i, button in pairs(sideButtonsContainer:GetChildren()) do
	if not button:IsA('TextButton') then continue end
	button.TextScaled = false
	button.TextScaled = not button.TextFits
	
	button.MouseEnter:Connect(function()
		button:FindFirstChild("Stroke").Enabled = true
	end)
	button.MouseLeave:Connect(function()
		button:FindFirstChild("Stroke").Enabled = false
	end)
end

if hasInfiniteTextGamePass then writeFrame.Pass.Visible = false
else
	writeFrame.Pass.PromptPurchase.MouseButton1Click:Connect(function() marketplaceService:PromptGamePassPurchase(player, 74708875) end) end

--\\Property signal
writeFrameContent:GetPropertyChangedSignal("Text"):Connect(function()
	writeFrameConfirmButton.Visible = false
	writeFrameFilterButton.Visible = true
	writeFrame.InputText.TextScaled = not writeFrame.InputText.TextFits
	if #writeFrameContent.Text > 500 and not hasInfiniteTextGamePass then marketplaceService:PromptGamePassPurchase(player, 74708875) end
	writeFrameContent.Text = hasInfiniteTextGamePass and
		string.sub(writeFrameContent.Text, 1, 3000) or string.sub(writeFrameContent.Text, 1, 500)
	writeFrame._CurrentSize.Text = hasInfiniteTextGamePass and
		string.format("%d/3000", #writeFrameContent.Text) or string.format("%d/500", #writeFrameContent.Text)
	workspace.Sounds.Char:Play()
end)
feedbackFrame.InputText:GetPropertyChangedSignal("Text"):Connect(function()
	if #feedbackFrame.InputText.Text == 0 then
		feedbackFrame.Confirm.Text = "Close"
	else
		feedbackFrame.Confirm.Text = "Submit"
	end
	feedbackFrame.InputText.Text = string.sub(feedbackFrame.InputText.Text, 1, 1900)
	feedbackFrame._CurrentSize.Text = string.format("%d/1900", #feedbackFrame.InputText.Text)
end)
writeFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if writeFrame.Visible then
		local remaining, total = remotes.getMessagesCount:InvokeServer()
		writeFrame.messagesCount.Text = string.format("%s / %d · Messages you can write", remaining, total)
	end
end)


--\\Mouse button
feedbackFrame.Confirm.MouseButton1Click:Connect(require(_Guis).SubmitFeedback)
writeButton.MouseButton1Click:Connect(require(_Guis).writeFrameToggle)
favoritesButton.MouseButton1Click:Connect(require(_Guis).favoritesFrameToggle)
updatesButton.MouseButton1Click:Connect(require(_Guis).updateFrameFunctions)
sideButtonsContainer.Feedback.MouseButton1Click:Connect(require(_Guis).feedbackFrameFunctions)
favoritesFrame.Close.MouseButton1Click:Connect(require(_Guis).favoritesFrameToggle)
updateFrame.Close.MouseButton1Click:Connect(require(_Guis).updateFrameFunctions)
mainFrame.shopFrame.Close.MouseButton1Click:Connect(require(_Guis).shopFrameToggle)

readFrame.Buttons.ReportButton.MouseButton1Click:Connect(function()
	readFrame.ReportConfirm.Visible = not readFrame.ReportConfirm.Visible
end)
readFrame.ReportConfirm.No.MouseButton1Click:Connect(function()
	readFrame.ReportConfirm.Visible = false
end)
profileFrame.Close.MouseButton1Click:Connect(function()
	profileFrame.Visible = false; Lighting.UIBlur.Enabled = false --require(_Guis).profileFrameFunctions(player.UserId)
end)
sideButtonsContainer.profile.MouseButton1Click:Connect(function()
	require(_Guis).profileFrameFunctions(player.UserId)
end)

sideButtonsContainer.shop.MouseButton1Click:Connect(require(_Guis).shopFrameToggle)

sideButtons.expand.MouseButton1Click:Connect(function()
	if sideButtons.expand.Rotation == 0 then
		tweenService:Create(sideButtons, TweenInfo.new(.5), {AnchorPoint=Vector2.new(1, 0.5)}):Play()
		tweenService:Create(sideButtons.expand, TweenInfo.new(.5), {Rotation=180}):Play()
	elseif sideButtons.expand.Rotation == 180 then
		tweenService:Create(sideButtons, TweenInfo.new(.5), {AnchorPoint=Vector2.new(0, 0.5)}):Play()
		tweenService:Create(sideButtons.expand, TweenInfo.new(.5), {Rotation=0}):Play()
	end
end)
writeFrameConfirmButton.MouseButton1Click:Connect(function()
	require(_Guis).NewComment(writeFrame.InputText.ContentText, writeFrame.title.ContentText)
end)
writeFrameFilterButton.MouseButton1Click:Connect(function()
	require(_Guis).filterContent(writeFrame.InputText.ContentText, "write")
end)

--\\Everything else
marketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, PassId, IsSuccess)
	hasInfiniteTextGamePass = marketplaceService:UserOwnsGamePassAsync(player.UserId, 74708875)
	writeFrame.Pass.Visible = false
end)

--\\Remotes
remotes.ReadContent.OnClientEvent:Connect(require(_Guis).ReadContent)
remotes.ChatMessage.OnClientEvent:Connect(require(_Guis).ChatMessage)
remotes.RandomDialog.OnClientEvent:Connect(require(Modules.Dialogs).HandleDialog)

remotes.fixDraft.OnClientEvent:Connect(function(draft)
	writeFrame.InputText.Text = draft.content or ""; writeFrame.title.Text = draft.title or ""
end)

writeFrame.InputText.FocusLost:Connect(saveDraft); writeFrame.title.FocusLost:Connect(saveDraft)

------ // Script made by Kolbxyz \\ ------