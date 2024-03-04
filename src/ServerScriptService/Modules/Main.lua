------ // Script made by Kolbxyz \\ ------

---- Services & Instances ----
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TextService = game:GetService("TextService")
local BadgeService = game:GetService("BadgeService")
local HttpService = game:GetService("HttpService")
local MarketPlaceService = game:GetService("MarketplaceService")

local Rongo = require(ServerScriptService.Modules.Rongo)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

--// Remotes
local Refresh = Remotes:WaitForChild("Refresh")
local New = Remotes:WaitForChild("New")
--\\

---- Variables ----
local CREDENTIALS = require(script.Parent.Credentials)
local MESSAGES_LIMIT = 50

local clientMessages = Rongo.new("data-pehuz", CREDENTIALS.CLIENT_MESSAGES)
local clientUsers = Rongo.new("data-pehuz", CREDENTIALS.CLIENT_USERS)
--local clientFeedbacks = Rongo.new("data-pehuz", CREDENTIALS.CLIENT_FEEDBACKS)

local ClusterMessages = clientMessages:GetCluster("Cluster0")
local DatabaseMessages = ClusterMessages:GetDatabase("Memories")

local ClusterUsers = clientUsers:GetCluster("Cluster0")
local DatabaseUsers = ClusterUsers:GetDatabase("Memories")

--local ClusterFeedbacks = clientFeedbacks:GetCluster("Cluster0")
--local DatabaseFeedbacks = ClusterFeedbacks:GetDatabase("Memories")

local messagesData = DatabaseMessages:GetCollection("messages")
local usersData = DatabaseUsers:GetCollection("users")
--local feedbacksData = DatabaseFeedbacks:GetCollection("feedbacks")

local likeTriggers = {}

local SERVER = {}
local MESSAGE_WEBHOOK = CREDENTIALS.MESSAGE_WEBHOOK
local FEEDBACK_WEBHOOK = CREDENTIALS.FEEDBACK_WEBHOOK

--local DataStore = DataStoreService:GetDataStore("DATA")

---- Functions ----
function SERVER.filterTable(table)
	if not table then warn("no table provided!"); return {} end
	table["_id"] = nil
	table["_id__baas_transaction"] = nil
	return table
end

function SERVER.fixDraft(player)
	local s, e = pcall(function()
		if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, 116779341) then
			local userData = SERVER:getUserData(player)
			userData.messagesCount = 9999
			userData = SERVER.filterTable(userData)
			usersData:ReplaceOne({ID=tostring(player.UserId)}, userData, true)
		end
	end) if not s then warn(e) end
	local draft = SERVER:getUserData(player)["draft"]
	if draft and draft ~= {} then
		draft = SERVER.filterTable(draft)
		Remotes.fixDraft:FireClient(player, draft)
	end
end

function SERVER.calculatePlaytime(player: Player, joinTime: number)
	local userData = SERVER:getUserData(player)
	if userData.playtime then
		userData.playtime += DateTime.now().UnixTimestamp - joinTime
	else
		userData.playtime = DateTime.now().UnixTimestamp - joinTime
	end
	
	usersData:ReplaceOne({ID=tostring(player.UserId)}, userData, true)
end

function SERVER.isFirstTime(player)
	local data = SERVER:getUserData(player)
	if not data.hasVisited then
		SERVER.firstTime(player)
	end
end

function SERVER.firstTime(player)
	local userData = SERVER:getUserData(player)
	Remotes.firstTime:FireClient(player)
	userData.hasVisited = DateTime.now().UnixTimestamp
	usersData:ReplaceOne({ID=tostring(player.UserId)}, userData, true)
end

function SERVER.saveDraft(player, draft)
	warn("Saving draft...")
	if not draft or draft == {} then return end
	local userData = SERVER:getUserData(player)
	userData.draft = draft
	userData = SERVER.filterTable(userData)
	usersData:ReplaceOne({ID=tostring(player.UserId)}, userData, true)
end

function SERVER.GetData()
--	DataStore:SetAsync("_database", game:GetService("DataStoreService"):GetDataStore("DATA"):GetAsync("database"))
	Remotes.ResetCooldown:FireAllClients(6)
	local result
	local success,data = pcall(function()
		result = messagesData:FindMany()
	end)
--	warn(result)
	if not success then warn(data) end
	return result or {}
end

function SERVER:getUserData(player)
	if not player then warn("invalid player! Can't get their data!") return end
	if typeof(player) ~= "number" then
		player = player.UserId
	else
		player = player
	end
	Remotes.ResetCooldown:FireAllClients(6)
	local result
	local s,e = pcall(function()
		---[[CHANGE BELOW TO MODIFY DEFAULT USER DATA]]
		result = usersData:FindOne({ID=tostring(player)}) or {messagesCount=1;draft={};ID=tostring(player);hasVisited=false;playtime=0}
		result = SERVER.filterTable(result)
		-- DateTime.now():FormatUniversalTime("MM/YY","en-us")
	end)
	if not s and e then warn(e) end
	
	return result
end

function SERVER.Refresh()
	for _, child in pairs(workspace.Clones:GetChildren()) do
		child:Destroy()
	end

	local Data = SERVER.GetData()

	-- Flatten the data into a linear table
	local flatData = {}
	for i, v in pairs(Data) do
		for j, w in pairs(v.data) do
			table.insert(flatData, {v = v, w = w, index = i, subIndex = j})
		end
	end

	-- Randomize the order of messages
	for i = #flatData, 2, -1 do
		local j = math.random(i)
		flatData[i], flatData[j] = flatData[j], flatData[i]
	end

	local count = 0

	-- Display only {MESSAGES_LIMIT} messages
	for _, entry in ipairs(flatData) do
		if count >= MESSAGES_LIMIT then
			break
		end

		local v = entry.v -- all messages of the user
		local w = entry.w -- message content
		local i = entry.index -- user ID
		local j = entry.subIndex -- message ID

		task.wait(.5)

		SERVER.renderMessage(v,i,j,w)

		count += 1
	end
end

function SERVER.renderMessage(v, i, j, w)
	local Clone = ServerStorage.Parts:WaitForChild("SoulPart"):Clone()
	Clone.Parent, Clone.Name, Clone.Position = workspace.Clones, Players:GetNameFromUserIdAsync(tonumber(v.ID)) or "Unknown", Vector3.new(w["x"], w["y"], w["z"])
	Clone.Fire.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))),
	}
	Clone.ProximityPrompt.ActionText = w["title"]
	Clone.ProximityPrompt.ObjectText = Players:GetNameFromUserIdAsync(v.ID) or "Unknown"

	if DateTime.now().UnixTimestamp - w["Timestamp"] <= 18000 then
		Clone.BillboardGui.IsNew.Visible = true
	end

	Clone:WaitForChild("ProximityPrompt").TriggerEnded:Connect(function(Player)
		local Data = SERVER.GetData()
		Remotes.ReadContent:FireClient(Player, Data[i]["data"][j], v.ID, Data, j)
	end)
end

function SERVER.processReceipt(receiptInfo)
	if receiptInfo["ProductId"] == 1342051457 then
		local userData = SERVER:getUserData(Players:GetPlayerByUserId(receiptInfo["PlayerId"]))
		
		userData["messagesCount"] += 1
		userData = SERVER.filterTable(userData)
		usersData:ReplaceOne({ID=tostring(Players:GetPlayerByUserId(receiptInfo["PlayerId"]))}, userData, true)
	end
end

function SERVER.Filter(Player, String)
--	print(TextService:FilterStringAsync(String, Player.UserId))
	return TextService:FilterStringAsync(String, Player.UserId):GetChatForUserAsync(Player.UserId) or "Error when filtering!"
end


--[[Change settings
function SERVER.updateSetting(player, settingName, value)
	local userData = SERVER:getUserData(player)
	print(
		userData, userData["settings"]
	)
	if not settingName then Remotes.sendSettings:FireClient(player, userData["settings"] or {}) end
	
	if not userData["settings"] then userData["settings"] = {} end
	if not userData["settings"][settingName] then userData["settings"][settingName] = {} end
	if userData["settings"][settingName] ~= nil then
		userData["settings"][settingName] = value
		
		print("Successfully updated!")
	end
	
	DataStore:SetAsync("userData-"..player.UserId, userData)
end]]

function SERVER.delete(player, dataIndex)
	if player and dataIndex then
		local playerId = tostring(player.UserId) or 0
		local data = SERVER.GetData()
		if data then
			local playerData
			for i, v in pairs(data) do
				if v.ID == tostring(player.UserId) then
					playerData=v
				end
			end
			if playerData then
				if playerData.data[dataIndex] then
					table.remove(playerData.data, dataIndex)
					playerData = SERVER.filterTable(playerData)
					Remotes.notify:FireClient(player, "Deleting message...", "Your message is being deleted...")
					messagesData:ReplaceOne({["ID"]=tostring(playerId)}, playerData, true)
					
					SERVER.Refresh()
					Remotes.notify:FireClient(player, "Message deleted!", "Your message has been deleted!")
				end
			end
		end
	end
end

function SERVER.edit(Player, Content, title, index, forcePlayer, notifications)
	print(string.format("Sending \"%s\"", Content))

--	if forcePlayer and Player.UserId == game.CreatorId then Player = forcePlayer end

	if title == "" then title = string.format("Message from %s", Player.Name) end
	title = string.sub(title, 1, 30)

	local Head = Player.Character:WaitForChild("Head")
	local x, y, z
	x,y,z = x or Head.Position.X, y or Head.Position.Y, z or Head.Position.Z
	local CurrentData = SERVER.GetData()
	
	local playerData
	for i,v in pairs(CurrentData) do
		if v.ID == tostring(Player.UserId) then
			playerData = v
		end
	end

	local s, e = pcall(function()
		if not MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, 74708875) and #Content > 500 then return end

		Content = SERVER.Filter(Player, Content)
		
		if not playerData.data then
			playerData.data = {}
		end
		
		playerData = SERVER.filterTable(playerData)

		playerData.data[index].Content=Content
		playerData.data[index].title = title
		playerData.data[index].Timestamp = DateTime.now().UnixTimestamp
		playerData.data[index].Likes = {}
		playerData.data[index].hasNotifications = notifications or true

		messagesData:ReplaceOne({ID=tostring(Player.UserId)}, playerData)
		local GuildedMessage = {
			["embeds"] = {
				{
					title= string.format("Edited message | %s (@%s) | %s", Player.DisplayName, Player.Name, title or string.format("Message from %s", Player.Name)),
					avatar_url = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
					description = string.format("`%s`", Content),
					color = 3066993,
					footer = {
						text = DateTime.now():FormatUniversalTime("LLL", "en-us")
					}
				}
			}
		}	
		GuildedMessage = HttpService:JSONEncode(GuildedMessage)
		HttpService:PostAsync(MESSAGE_WEBHOOK, GuildedMessage)
	end)
	--	warn(CurrentData)
	if not s and e then warn(e) end
	Remotes.notify:FireClient(Player, "Message edited!", "Your message has been edited!")
	SERVER.Refresh()
end

function SERVER.New(Player, Content, title, notifications)
	print(Content)
	
	if title == "" then title = string.format("Message from %s", Player.Name) end
	title = SERVER.Filter(Player, title)
	title = string.sub(title, 1, 30)
	
	local Head = Player.Character:WaitForChild("Head")
	local x, y, z
	x,y,z = x or Head.Position.X, y or Head.Position.Y, z or Head.Position.Z
	local CurrentData = SERVER.GetData()
	
	local userData = SERVER:getUserData(Player)
	--	print(userData["messagesCount"], #CurrentData[tostring(Player.UserId)]) --DEBUG
	--	pcall(function()warn(CurrentData[tostring(Player.UserId)] and userData["messagesCount"] >= #CurrentData[tostring(Player.UserId)])end)
	local playerData = {ID=tostring(Player.UserId);data={}}
	for i,v in pairs(CurrentData) do
		if v.ID == tostring(Player.UserId) then
			playerData = v
		end
	end
--	warn(userData.messagesCount)
	if playerData and userData["messagesCount"] <= #playerData.data then
		Remotes.notify:FireClient(Player, "Cannot send!", "You can't send more message!")
		MarketPlaceService:PromptProductPurchase(Player, 1342051457)
		return
	end
	
	local s, e = pcall(function()
		if not MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, 74708875) and #Content > 500 then warn("Message must be shorter than 500 characters!") return end
		
		Content = SERVER.Filter(Player, Content)

--		if not CurrentData then
--			CurrentData[tostring(Player.UserId)] = {}
--		end
		
		playerData = SERVER.filterTable(playerData)
		table.insert(playerData.data,{["title"]=title;["Content"]=Content;["x"]=x;["y"]=y;["z"]=z;["Timestamp"]=DateTime.now().UnixTimestamp;["Likes"]={};hasNotifications=notifications})
		
		SERVER.saveDraft(Player, {content='',title=''})
		
		messagesData:ReplaceOne({["ID"]=tostring(Player.UserId)},playerData,true)
		local GuildedMessage = {
			["embeds"] = {
				{
					title= string.format("New message | %s (@%s) | %s", Player.DisplayName, Player.Name, title or string.format("Message from %s", Player.Name)),
					avatar_url = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
					description = string.format("`%s`", Content),
					color = 3066993,
					footer = {
						text = DateTime.now():FormatUniversalTime("LLL", "en-us")
					}
				}
			}
		}	
		HttpService:PostAsync(MESSAGE_WEBHOOK, HttpService:JSONEncode(GuildedMessage))
	end)
--	warn(CurrentData)
	if not s and e then warn(e) end
	BadgeService:AwardBadge(Player.UserId, 2143077577)
	
	SERVER.getUserData()
	
	Remotes.notify:FireClient(Player, "Message sent!", "Your message has been sent! Check your profile to read it!")
	SERVER.Refresh()
end

function SERVER.Like(Player, author, dataIndex)
	if likeTriggers[Player.UserId] then
		if DateTime.now().UnixTimestamp - likeTriggers[Player.UserId] < 5 then
			Remotes.notify:FireClient(Player, "Slow down", string.format("Please wait %d seconds before liking messages again.", 15-(DateTime.now().UnixTimestamp-likeTriggers[Player.UserId])))
			return
		end
	else
		likeTriggers[Player.UserId] = DateTime.now().UnixTimestamp
	end
	Remotes.ResetCooldown:FireClient(Player, 6)
	local Data = SERVER.GetData()

	local playerData = {data={}}
	for _, v in pairs(Data) do
		if v.ID == tostring(author) then
			playerData = v
		end
	end
--	print(playerData, dataIndex)
	if not table.find(playerData.data[dataIndex]["Likes"], Player.Name) then
--		warn(playerData)
		table.insert(playerData.data[dataIndex]["Likes"], Player.Name)
		playerData = SERVER.filterTable(playerData)
		messagesData:ReplaceOne({["ID"]=tostring(author)}, playerData)
		Remotes.notify:FireClient(Player, "Message liked!", "This message has been added to your favourites!")
		local LikedCount = 0
		for _, playerMessages in pairs(Data) do
			for _, message in pairs(playerMessages.data) do
				if table.find(message["Likes"], Player.Name) then
					LikedCount += 1
				end
			end
		end
		if LikedCount >= 50 then
			BadgeService:AwardBadge(Player.UserId, 2128117978)
		elseif LikedCount >= 30 then
			BadgeService:AwardBadge(Player.UserId, 2128117974)
		elseif LikedCount >= 20 then
			BadgeService:AwardBadge(Player.UserId, 2128117973)
		elseif LikedCount >= 10 then
			BadgeService:AwardBadge(Player.UserId, 2128117971)
		elseif LikedCount >= 5 then
			BadgeService:AwardBadge(Player.UserId, 2128117967)
		end
		if playerData.data[dataIndex]["hasNotifications"] then
			if Player.UserId == tonumber(author) then return end
			if #playerData.data[dataIndex]["Likes"] > 25 then --> disable when more than 25 likes
				return
			end
			
			local OCUserNotification = require(ServerScriptService.Modules.OpenCloud.V2.UserNotification)
			local recipientPlayerID = tonumber(author)

			local formattedLikeCount = {int64Value = #playerData.data[dataIndex]["Likes"] or 0}

			local userNotification = {
				payload = {
					messageId = "d79acfb8-679a-9840-a230-8ee743dd3dd2",
					type = "MOMENT",
					parameters = {
						["count"] = formattedLikeCount,
					}
				}
			}

			local result = OCUserNotification.createUserNotification(recipientPlayerID, userNotification)

			if result.statusCode ~= 200 then
				print(result.statusCode)
				print(result.error.code)
				print(result.error.message)
			end
		end
	else
		table.remove(playerData.data[dataIndex]["Likes"], table.find(playerData.data[dataIndex]["Likes"], Player.Name))
		playerData = SERVER.filterTable(playerData)
		messagesData:ReplaceOne({["ID"]=tostring(author)}, playerData)
		Remotes.notify:FireClient(Player, "Message removed from your favourites!", "This message has been removed from your favourites.")
	end
	task.wait(15)
	likeTriggers[Player.UserId] = nil
end

function SERVER.GetLiked(Player, userId)
	userId = userId or Player.UserId
	local playerName = Players:GetNameFromUserIdAsync(tonumber(userId))
	local Data = SERVER.GetData() or {}
	local Favorites = {}
	for index, Content in pairs(Data) do
--		warn(Content)
		for mIndex, message in pairs(Content.data) do
			if not message["Likes"] then continue end
			if table.find(message["Likes"], playerName) then
				table.insert(Favorites, message)
				Favorites[#Favorites]["author"] = Content.ID or 1
			end
		end
	end
	return Favorites, Data
end

function SERVER.SendFeedback(Player, Content)
	if Content == "" then
		return
	end
	local GuildedMessage = {
		["embeds"] = {
			{
				title = string.format("New feedback| %s (@%s)", Player.DisplayName, Player.Name),
				avatar_url = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
				description = string.format("`%s`", Content),
				color = 3447003,
				footer = {
					text = DateTime.now():FormatUniversalTime("LLL", "en-us")
				}
			}
		}
	}	
	GuildedMessage = HttpService:JSONEncode(GuildedMessage)
	HttpService:PostAsync(FEEDBACK_WEBHOOK, GuildedMessage)
	Remotes.notify:FireClient(Player, "Feedback sent!", "Thank you for your feedback!")
end

function SERVER.Report(Player, author, content)
	local GuildedMessage = {
		["embeds"] = {
			{
				title = string.format("Message report | %s (@%s)", Player.DisplayName, Player.Name),
				avatar_url = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
				description = string.format("`%s`\nfrom:%s", content, author),
				color = 15548997,
				footer = {
					text = DateTime.now():FormatUniversalTime("LLL", "en-us")
				}
			}
		}
	}	
	GuildedMessage = HttpService:JSONEncode(GuildedMessage)
	HttpService:PostAsync(FEEDBACK_WEBHOOK, GuildedMessage)
	Remotes.notify:FireClient(Player, "Message reported!", "Thanks for reporting this message.")
end
--- // Core \\ ---
return SERVER

------ // Script made by Kolbxyz \\ ------