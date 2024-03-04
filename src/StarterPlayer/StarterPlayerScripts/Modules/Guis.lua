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

--\\read
local readFrameContainer = readFrame:WaitForChild("Likers")
local readFrameTemplate = readFrameContainer:WaitForChild("Example")

--\Network
local remotes = replicatedStorage:WaitForChild("Remotes")


---- Variables ----
local _Guis = {}

local lastFeedbackCooldown = 0 --> cooldown for the player before they can send a feedback again
local hasInfiniteTextGamePass --> Tells if the player has or not the gamepass
pcall(function()
	hasInfiniteTextGamePass = marketplaceService:UserOwnsGamePassAsync(player.UserId, 74708875)
end)

local VIPPassId = 116349961

---- Functions ----
function _Guis.timestampToDHMS(s)
	local days = math.floor(s/86400)
	local hours = math.floor((s%86400)/3600)
	local minutes = math.floor((s%3600)/60)
	local seconds = s%60

	local timeString = ""
	if days > 0 then
		timeString = timeString .. days .. "d "
	end
	if hours > 0 then
		timeString = timeString .. hours .. "h "
	end
	if minutes > 0 then
		timeString = timeString .. minutes .. "m "
	end
	if seconds > 0 or timeString == "" then
		timeString = timeString .. seconds .. "s"
	end

	return timeString .. " ago"
end

function _Guis.manageDisplayedFrameAndButtons(frame, button)
	--[[Below is a big reusable block]]
	for _, child in pairs(mainFrame:GetChildren()) do
		if child:IsA("Frame") and child ~= frame then
			child.Visible = false
		elseif child ~= button.Value and child:FindFirstChild("idleText") and child:IsA("TextButton") then
			child.textBox.Text = child.idleText.Value
		end
	end
	for _, child in pairs(sideButtons.container:GetChildren()) do
		if child ~= button.Value and child:FindFirstChild("idleText") and child:IsA("TextButton") then
			child.textBox.Text = child.idleText.Value
		end
	end
	if button.Value then button.Value.textBox.Text = button.Value.textBox.Text == "Close" and button.Value.idleText.Value or "Close" end
	
	frame.Position = UDim2.new(0.5, 0,-1, 0)
	frame.Visible = not frame.Visible

	if not frame.Visible then
		Lighting.UIBlur.Enabled = false
	else
		Lighting.UIBlur.Enabled = true
	end
	tweenService:Create(frame, TweenInfo.new(.2), {Position=UDim2.new(0.5, 0,0.44, 0)}):Play()
	--[[Above is a big reusable block]]
	mainFrame.loadingText.Visible = false
end

function _Guis.editFrameFunctions(index, content)
	--[[Below is a big reusable block]]
	local frame = editFrame local button = frame:WaitForChild("buttonLocation")
	_Guis.manageDisplayedFrameAndButtons(frame, button)
	if not frame.Visible then return end
	--[[Top is a big reusable block]]
	local filterConnection, confirmConnection, inputChangedConnection, CloseConnection
	if frame.Visible and index and content then
		frame.InputText.Text = content["Content"]
		frame.title.Text = content["title"]
		filterConnection = frame.Filter.MouseButton1Click:Connect(function()
			_Guis.filterContent(frame.InputText.ContentText, "edit")
		end)
		inputChangedConnection = frame.InputText:GetPropertyChangedSignal("Text"):Connect(function()
			frame.Confirm.Visible = false
			frame.Filter.Visible = true
			frame.InputText.TextScaled = false
			frame.InputText.TextScaled = not frame.InputText.TextFits
			if #frame.InputText.Text>500 and not hasInfiniteTextGamePass then marketplaceService:PromptGamePassPurchase(player,74708875)end
			frame.InputText.Text = hasInfiniteTextGamePass and
				string.sub(frame.InputText.Text, 1, 3000) or string.sub(frame.InputText.Text, 1, 500)
			frame._CurrentSize.Text = hasInfiniteTextGamePass and
				string.format("%d/3000", #frame.InputText.ContentText) or string.format("%d/500", #frame.InputText.ContentText)
			workspace.Sounds.Char:Play()
		end)
		confirmConnection = frame.Confirm.MouseButton1Click:Connect(function()
			remotes.edit:FireServer(frame.InputText.ContentText, frame.title.ContentText, index, editFrame.Notifications.notifs.Value.Value)
			frame.Filter.Text = "Message edited!"
			task.wait(1)
			frame.Filter.Text = "Filter"
			frame.Visible = false; Lighting.UIBlur.Enabled = false
			filterConnection:Disconnect(); confirmConnection:Disconnect(); inputChangedConnection:Disconnect(); CloseConnection:Disconnect()
		end)
		CloseConnection = frame.Buttons.close.MouseButton1Click:Connect(function()
			CloseConnection:Disconnect()
			frame.Visible = false; Lighting.UIBlur.Enabled = false
		end)
	end
end
function _Guis.profileFrameFunctions(playerId)
	--[[Below is a big reusable block]]
	local frame = profileFrame local button = frame:WaitForChild("buttonLocation")
	_Guis.manageDisplayedFrameAndButtons(frame, button)
	if not frame.Visible then warn("!!") return end
	--[[Top is a big reusable block]]
	
	for _, child in pairs(profileFrame.messagesList:GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "Example" then child:Destroy() end
	end
	
	local s, e = pcall(function()
	playerId = tonumber(playerId) or players:GetUserIdFromNameAsync(playerId)
	frame.Title.Text = string.format("%s's profile" ,players:GetNameFromUserIdAsync(playerId))
	frame._playerImage.Image = 	players:GetUserThumbnailAsync(playerId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	frame._playerName.Text = string.format("%s (@%s)", userService:GetUserInfosByUserIdsAsync({playerId})[1].DisplayName,
		players:GetNameFromUserIdAsync(playerId))
		frame.tags.VIPtag.Visible = remotes.userOwnsPass:InvokeServer(playerId, VIPPassId)
	end)
	if not s and e then frame.BANNED.Visible = true else frame.BANNED.Visible = false end
	frame._stats.Text = "loading data..."
	frame.tags.DevTag.Visible = playerId == game.CreatorId
	local Liked, FullData = remotes.GetLiked:InvokeServer(playerId)
	local LikedCount = 0
	for _, _ in pairs(Liked) do
		LikedCount += 1
	end

	local messagesSent = {}

	for i, v in pairs(FullData) do
		if v.ID == tostring(playerId) then messagesSent = v.data; messagesSent.author = playerId end
	end
	
	local userData = remotes.getData:InvokeServer(playerId)
	local playtime = userData.playtime or 0
	
	frame._stats.TextScaled = false; frame._stats.TextScaled = not frame._stats.TextFits
	frame._stats.Text = string.format("%d message(s) liked · %d message(s) sent · %d minutes", LikedCount, #messagesSent, playtime/60)
	for index, messageContent in pairs(messagesSent) do
		if typeof(index) == "string" then continue end
--		print(messageContent)
		local Clone = profileFrame.messagesList.Example:Clone()
		Clone.Parent,Clone.Visible,Clone._title.Text,Clone.Name=profileFrame.messagesList,true,messageContent["title"],messageContent["title"]
		Clone.teleport.MouseButton1Click:Connect(function()
			profileFrame.Visible = false; Lighting.UIBlur.Enabled = false
			character:MoveTo(Vector3.new(messageContent.x, messageContent.y, messageContent.z))
			_Guis.ReadContent(messageContent, tostring(messagesSent.author), FullData, index)
		end)
	end
end

function _Guis.writeFrameToggle()
	--[[Below is a big reusable block]]
	local frame = writeFrame local button = frame:WaitForChild("buttonLocation")
	_Guis.manageDisplayedFrameAndButtons(frame, button)
	--[[Top is a big reusable block]]
end
function _Guis.shopFrameToggle()
	--[[Below is a big reusable block]]
	local frame = mainFrame.shopFrame local button = frame:WaitForChild("buttonLocation")
	_Guis.manageDisplayedFrameAndButtons(frame, button)
	--[[Top is a big reusable block]]
end
function _Guis.feedbackFrameFunctions()
	--[[Below is a big reusable block]]
	local frame = feedbackFrame local button = frame:WaitForChild("buttonLocation")
	_Guis.manageDisplayedFrameAndButtons(frame, button)
	--[[Top is a big reusable block]]
end
function _Guis.updateFrameFunctions()
	--[[Below is a big reusable block]]
	local frame = updateFrame
	local button = frame:WaitForChild("buttonLocation")
	_Guis.manageDisplayedFrameAndButtons(frame, button)
	--[[Top is a big reusable block]]
	for _, child in pairs(frame:WaitForChild("Archives"):GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "Example" then
			child:Destroy()
		end
	end
	local UpdatesList = require(replicatedStorage.Modules.Updates)
	frame.Content.Text = UpdatesList[1]["Content"] or "Unknown error when the game was trying to load change log, please try again."
	frame.title.Text = "📅 "..UpdatesList[1]["Date"]
	pcall(function()
		for _, UpdateData in pairs(UpdatesList) do
			local Clone = frame.Archives:WaitForChild("Example"):Clone()
			Clone.Parent, Clone.Name, Clone._Date.Text = frame:WaitForChild("Archives"), UpdateData["Date"], UpdateData["Date"]
			Clone.Visible = true
			Clone.Display.MouseButton1Click:Connect(function()
				frame.Content.Text = UpdateData["Content"]
				frame.title.Text = "📅 "..UpdateData["Date"]
			end)
		end
	end)
end
function _Guis.favoritesFrameToggle()
	--[[Below is a big reusable block]]
	local frame = favoritesFrame
	local button = frame:WaitForChild("buttonLocation")
	_Guis.manageDisplayedFrameAndButtons(frame, button)
	--[[Top is a big reusable block]]
	
	if favoritesFrame.Visible then _Guis.RefreshLiked() end
end

function _Guis.filterContent(Content, target)
	local frame = target == "write" and writeFrame or editFrame
	
	frame.Filter.Visible, frame.Confirm.Visible = true, false
	
	local filterResult = remotes.Filter:InvokeServer(Content, player.UserId)
	
	if frame:WaitForChild("InputText").Text ~= filterResult then
		local txt = frame:WaitForChild("InputText").Text
			~= "⚠ Your message has been filtered and can't be send. Please, fix what may be inapropriate. ⛔" and
			frame:WaitForChild("InputText").Text or nil
		frame:WaitForChild("InputText").Text = "⚠ Your message has been filtered and can't be send. Please, fix what may be inapropriate. ⛔"
		frame:WaitForChild("InputText").Selectable = false
		task.wait(2)
		if txt then frame:WaitForChild("InputText").Text = txt end
		frame:WaitForChild("InputText").Selectable = true
	else
		warn("Content filtered, nothing wrong!")
		frame.Filter.Visible, frame.Confirm.Visible = false, true
	end
	return filterResult
end
function _Guis.NewComment(Content, title)
--	warn(Content, title)
	if #writeFrame.InputText.Text > 5 then
		remotes:WaitForChild("New"):FireServer(Content, title, writeFrame.Buttons.notifs.Value.Value)
	else
		remotes.clientNotify:Fire("Can't sent message!", "Your message must be at least 5 characters long!")
	end
	writeFrame.InputText.Text = ""; writeFrame.title.Text = ""
	_Guis.writeFrameToggle()
end

local likeButtonConnection
local closeButtonConnection
local reportButtonConnection
local deleteButtonConnection
local editButtonConnection
local deleteConfirmYesButton, deleteConfirmNoButton
local profileButtonConnection
local profileButtonConnection2
function _Guis.ReadContent(Content, author, FullData, dataIndex)
	if likeButtonConnection then likeButtonConnection:Disconnect() end
	if closeButtonConnection then closeButtonConnection:Disconnect() end
	if reportButtonConnection then reportButtonConnection:Disconnect() end
	if profileButtonConnection2 then profileButtonConnection2:Disconnect() end
	if deleteButtonConnection then deleteButtonConnection:Disconnect() end
	if editButtonConnection then editButtonConnection:Disconnect() end
	if profileButtonConnection then profileButtonConnection:Disconnect() end
	if deleteConfirmYesButton then deleteConfirmYesButton:Disconnect() end
	if deleteConfirmNoButton then deleteConfirmNoButton:Disconnect() end
	
	readFrame.Content.Text = "Loading..."
	readFrame.Info.Text = "Loading..."
	readFrame.Title.Text = "Loading..."
	readFrame.Likes.Text = "0"

	_Guis.manageDisplayedFrameAndButtons(readFrame, readFrame.buttonLocation)
	readFrame.Visible = true
	Lighting.UIBlur.Enabled = true
	tweenService:Create(readFrame, TweenInfo.new(0.5), {Position=UDim2.new(0.5, 0,0.44, 0)}):Play()
--	readFrame.Expand.profile.Text = string.format("· %s's profile ·", players:GetNameFromUserIdAsync(tonumber(author)))
	
	profileButtonConnection2 = readFrame.ProfileButton.MouseButton1Click:Connect(function()
		_Guis.profileFrameFunctions(tonumber(author))
		profileButtonConnection2:Disconnect()
	end)
	
	workspace.Sounds.opening:Play()
	
	if author == tostring(player.UserId) then
		readFrame.Buttons.EditButton.Visible = true
		readFrame.Buttons.DeleteButton.Visible = true
		readFrame.Buttons.ReportButton.Visible = false
		editButtonConnection = readFrame.Buttons.EditButton.MouseButton1Click:Connect(function()
			editButtonConnection:Disconnect()
			readFrame.Position = UDim2.new(0.5, 0,-1, 0)
			readFrame.Visible = false
			_Guis.editFrameFunctions(dataIndex, Content)
		end)
		
		deleteButtonConnection = readFrame.Buttons.DeleteButton.MouseButton1Click:Connect(function()
			readFrame.deleteConfirm.Visible = true
			deleteConfirmYesButton = readFrame.deleteConfirm.Yes.MouseButton1Click:Connect(function()
				deleteButtonConnection:Disconnect()
				deleteConfirmYesButton:Disconnect()
				deleteConfirmNoButton:Disconnect()
				readFrame.Position = UDim2.new(0.5, 0,-1, 0)
				readFrame.deleteConfirm.Visible = false
				readFrame.Visible = false; Lighting.UIBlur.Enabled = false
				remotes.delete:FireServer(dataIndex)
			end)
			
			deleteConfirmNoButton = readFrame.deleteConfirm.No.MouseButton1Click:Connect(function()
				deleteConfirmNoButton:Disconnect()
				deleteConfirmYesButton:Disconnect()
				readFrame.deleteConfirm.Visible = false
			end)
		end)
	else
		readFrame.Buttons.EditButton.Visible = false
		readFrame.Buttons.DeleteButton.Visible = false
		readFrame.Buttons.ReportButton.Visible = true
	end
	closeButtonConnection = readFrame.CloseButton.MouseButton1Click:Connect(function()
		closeButtonConnection:Disconnect()
		readFrame.Visible = false; Lighting.UIBlur.Enabled = false
	end)
	local playerData = nil
	for i,v in pairs(FullData) do
		if v.ID == author then
			playerData = v
			break
		end
	end
	
	local s, e = pcall(function()
		readFrame.Content.MaxVisibleGraphemes = 0
		coroutine.wrap(function()
			for i, char in pairs(string.split(Content["Content"], "")) do
				task.wait()
				readFrame.Content.MaxVisibleGraphemes += 4
				if char == "." then task.wait(.2) end
			end
		end)()

		readFrame.Content.Text = string.format("%s", Content["Content"])
		readFrame.Title.Text = Content["title"]
--		readFrame.Content.TextScaled = false
--		readFrame.Content.TextScaled = not readFrame.Content.TextFits
		
		coroutine.wrap(function()
			readFrame.Info.Text = string.format("<b>%s</b>", players:GetNameFromUserIdAsync(tonumber(author)))
				.. " · " ..
				string.format("%s · %s", _Guis.timestampToDHMS(DateTime.now().UnixTimestamp - Content["Timestamp"]),
					DateTime.fromUnixTimestamp(Content["Timestamp"]):FormatUniversalTime("LLL","en-us"))
		end)()
		
		readFrame.Title.vipTag.Enabled = remotes.userOwnsPass:InvokeServer(tonumber(author), VIPPassId) or false
	end)
	
	if not s and e then print(e) end
	
	readFrame.LikeButton.ImageColor3=table.find(Content["Likes"], player.Name) and Color3.new(1, 0.666667, 1) or Color3.new(0.690196, 0.690196, 0.690196)
	readFrame.Likes.Text = #Content["Likes"] > 0 and #Content["Likes"] or "0"
	for _, child in pairs(readFrameContainer:GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "Example" then
			child:Destroy()
		end
	end
	for i, PlayerName in pairs(Content["Likes"]) do
		local userId = 1
		pcall(function()
			userId = tostring(players:GetUserIdFromNameAsync(PlayerName))
		end)
		local Clone = readFrameTemplate:Clone()
		Clone.Visible, Clone.Parent, Clone.Name, Clone._PlayerImage.Image, Clone._PlayerName.Text = true, readFrameContainer, PlayerName,
			players:GetUserThumbnailAsync(userId,
			Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420), PlayerName
		Clone.Profile.Text = playerData and "Profile" or "No profile found"
		Clone.Profile.BackgroundColor3 = playerData and Clone.Profile.BackgroundColor3 or Color3.new(0.666667, 0, 0)
		--Clone.BackgroundTransparency = playerData and 0 or 0.8
		profileButtonConnection = Clone.Profile.MouseButton1Click:Connect(function()
			if playerData then
				_Guis.profileFrameFunctions(userId)
				profileButtonConnection:Disconnect()
			end
		end)
	end
	likeButtonConnection = readFrame.LikeButton.MouseButton1Click:Connect(function()
		local count = tonumber(readFrame.Likes.Text)
		readFrame.Likes.Text = readFrame.LikeButton.ImageColor3 == Color3.new(1, 0.666667, 1) and count - 1 or count + 1
		readFrame.LikeButton.ImageColor3=readFrame.LikeButton.ImageColor3==
			Color3.new(0.690196, 0.690196, 0.690196) and Color3.new(1, 0.666667, 1) or Color3.new(0.690196, 0.690196, 0.690196)
		remotes.Like:FireServer(author, dataIndex)
	end)
	reportButtonConnection = readFrame.ReportConfirm.Yes.MouseButton1Click:Connect(function()
		readFrame.ReportConfirm.Visible = false
		remotes.ReportMessage:FireServer(author, Content["Content"])
		readFrame.ReportDone.Visible = true
		wait(5)
		readFrame.ReportDone.Visible = false
	end)
	
end

local RefreshConnection
function _Guis.RefreshLiked()
	local Liked, FullData = remotes.GetLiked:InvokeServer()
	coroutine.wrap(function()
	local LikedCount = 0
		for _, _ in pairs(Liked) do
			LikedCount += 1
		end
		favoritesFrame.Count.Text = string.format("You liked %d messages, keep going!", LikedCount)
		
		--[[
		for _, child in pairs(favoritesContainer:GetChildren()) do
			if child:IsA("Frame") and child.Name ~= "Example" then
				child:Destroy()
			end
		end]]
		
		if #favoritesContainer:GetChildren() <= 4 then
--			print("Refreshing favorites")
			for index, data in pairs(Liked) do
				local Clone
				local s, e = pcall(function()
					
					Clone = favoriteFrameTemplate:Clone()
					Clone._title.Text = "Loading..."
					Clone._author.Text = "Loading..."
					
					Clone.Parent, Clone.Visible= favoritesContainer, true
					
					coroutine.wrap(function()
						Clone._playerImage.Image = players:GetUserThumbnailAsync(tonumber(Liked[index]["author"]),
							Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
						local username = players:GetNameFromUserIdAsync(tonumber(Liked[index]["author"]))
						Clone._author.Text, Clone.Name = username, username
						Clone:FindFirstChild("profile").MouseButton1Click:Connect(function()
							_Guis.profileFrameFunctions(username)
						end)
					end)()

					Clone._title.Text = Liked[index]["title"]
					
					Clone:FindFirstChild("teleport").MouseButton1Click:Connect(function()
						favoritesFrame.Visible = false; Lighting.UIBlur.Enabled = false
						character:MoveTo(Vector3.new(data.x, data.y, data.z))
						print(index)
						_Guis.ReadContent(Liked[index], tostring(Liked[index]["author"]), FullData, index)
					end)
				end)
				if not s then warn(e) end
			end
		end
	end)()
	
	for _, child in pairs(recommendationContainer:GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "Example" then
			child:Destroy()
		end
	end
	
	local navigationIndex = 0
	for index, data in pairs(FullData) do
		for index2, value in pairs(data.data) do
			local Clone
			if table.find(value["Likes"], player.Name) then continue end
			navigationIndex += 1
			local s, e = pcall(function()
				local username = players:GetNameFromUserIdAsync(tonumber(data.ID))
				Clone = recommentationTemplate:Clone()
				Clone.Parent, Clone.Name, Clone._PlayerName.Text, Clone.Visible = recommendationContainer, tonumber(data.ID), username, true
				Clone._PlayerImage.Image = players:GetUserThumbnailAsync(tonumber(data.ID),
					Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
				Clone._title.Text = value["title"]
				Clone:FindFirstChild("teleport").MouseButton1Click:Connect(function()
					favoritesFrame.Visible = false; Lighting.UIBlur.Enabled = false
					character:MoveTo(Vector3.new(value.x, value.y, value.z))
--					print(index)
					_Guis.ReadContent(value, data.ID, FullData, index2)
				end)
			end)
			if not s then warn(e) end
			if navigationIndex >= 5 then break end
		end
		if navigationIndex >= 5 then break end
	end
end

function _Guis.ChatMessage(Data, Color, font, FontSize, pName)
	print(pName)
	if pName ~= player.Name then
		print("CLIENT: Cross message traffic detected, displaying current content to the client's chat, please wait...")
		local Text = Data["Data"]
		Text, Color, font, FontSize = Text or "", Color or Color3.new(), font or Enum.Font.SourceSansBold, FontSize or Enum.FontSize.Size24
		game:GetService("StarterGui"):SetCore( 
			"ChatMakeSystemMessage",  { 
				Text = Text, 
				Color = Color,
				Font = font,
				FontSize = FontSize
		}
		)
	else
		print("CLIENT: Cross message traffic detected, message cannot be displayed; reason: sender can't receive the message.")
	end
end

function _Guis.SubmitFeedback()
	feedbackFrame.Visible, feedbackButton.textBox.Text = false, "Feedback" ; Lighting.UIBlur.Enabled = false
	if DateTime.now().UnixTimestamp >= lastFeedbackCooldown then
		remotes.Feedback:FireServer(feedbackFrame.InputText.ContentText or "Default text.")
		lastFeedbackCooldown = DateTime.now().UnixTimestamp + 60
		local content = {["name"]=player.Name;["content"]=feedbackFrame.InputText.ContentText or "Default text"}
	end
end

function _Guis.ManageAnimations(child)
	if child:IsA("TextButton") or child:IsA("ImageButton") then
		local Size = child.Size
		local cornerRadius = nil
		local cornerRadiusTween = nil
		local canTween = true

		child.MouseEnter:Connect(function()
			if not canTween then return end
			canTween = false
			if child:GetAttribute("hovering") then
				tweenService:Create(child, TweenInfo.new(.2), {Size=child:GetAttribute("hovering")}):Play()
			end
			
			if child:FindFirstChildWhichIsA("UIGradient", true) then
				coroutine.wrap(function()
					local UIGradient = child:FindFirstChild("UIGradient", true)
					for c = 1, 90 do
						if UIGradient.Rotation >= 360 then
							UIGradient.Rotation = 0
						end
						UIGradient.Rotation += 4
						task.wait()
					end
				end)()
			else
			end
			
			workspace.Sounds.Hover:Play()
--[[			if child:FindFirstChild("Blur") then
				tweenService:Create(child:FindFirstChild("Blur"), TweenInfo.new(.5), {ImageTransparency=0}):Play()
			end]]
			local uiCorner = child:FindFirstChildWhichIsA("UICorner")
			if uiCorner then
				if not cornerRadius then
					cornerRadius = uiCorner.CornerRadius
				end
				if cornerRadiusTween then
					cornerRadiusTween:Cancel()
				end
				cornerRadiusTween = tweenService:Create(uiCorner, TweenInfo.new(.13, Enum.EasingStyle.Quad), {CornerRadius = UDim.new(0.5,0)})
				cornerRadiusTween:Play()
				if child:FindFirstChild("Pattern") then
					tweenService:Create(child:FindFirstChild("Pattern").UICorner, TweenInfo.new(.1), {CornerRadius = UDim.new(0.5,0)}):Play()
				end
			end
			canTween = true
			local leaveConnection
			leaveConnection = child.MouseLeave:Connect(function()
				leaveConnection:Disconnect()
				if not canTween then return end
				if child:GetAttribute("normal") then
					tweenService:Create(child, TweenInfo.new(.2), {Size=child:GetAttribute("normal")}):Play()
					if cornerRadius then
						if not uiCorner then
							uiCorner = child:FindFirstChildWhichIsA("UICorner")
						end
						if uiCorner and uiCorner.CornerRadius ~= cornerRadius then
							if cornerRadiusTween then
								cornerRadiusTween:Cancel()
							end
							cornerRadiusTween = tweenService:Create(uiCorner, TweenInfo.new(.5, Enum.EasingStyle.Quad), {CornerRadius = cornerRadius})
							cornerRadiusTween:Play()
							if child:FindFirstChild("Pattern") then
								tweenService:Create(child:FindFirstChild("Pattern").UICorner, TweenInfo.new(.1), {CornerRadius = cornerRadius}):Play()
							end
						end
					end
				end
				if child:FindFirstChild("Blur") then
					local tweenLeave = tweenService:Create(child:FindFirstChild("Blur"), TweenInfo.new(.5), {ImageTransparency=1})
					tweenLeave:Play()
					tweenLeave:Destroy()
				end
			end)
		end)


		child.MouseButton1Click:Connect(function()
			workspace.Sounds.Click:Play()
		end)
--[[		child.MouseButton1Down:Connect(function()
			if child:GetAttribute("down") then
				tweenService:Create(child, TweenInfo.new(.1), {Size=child:GetAttribute("down")}):Play()
			end
		end)
		child.MouseButton1Up:Connect(function()
			if child:GetAttribute("normal") then
				tweenService:Create(child, TweenInfo.new(.1), {Size=child:GetAttribute("normal")}):Play()
			end
		end)]]
	end
end

--- // Core \\ ---
return _Guis

------ // Script made by Kolbxyz \\ ------