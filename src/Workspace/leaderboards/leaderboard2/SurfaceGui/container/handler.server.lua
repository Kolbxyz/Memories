-- On stocke les objets utilisés dans des variables locales pour éviter de les rechercher à chaque fois
local ServerScriptService = game:GetService("ServerScriptService")
local MainModule = require(ServerScriptService.Modules.Main)
local Players = game:GetService("Players")

local Leaderboard = script.Parent.Parent.Parent
local Container = Leaderboard.SurfaceGui.container
local Example = Container.example

function Refresh()
	-- On récupère les données depuis le module Main
	local Data = MainModule.GetData()

	-- On utilise une table pour stocker le nombre de likes de chaque joueur
	local Users = {}

	-- On boucle sur les données pour compter les likes
	for _, Content in pairs(Data) do
		for _, Message in pairs(Content.data) do
			local likeCount = #Message.Likes
			pcall(function()
				local playerName = Players:GetNameFromUserIdAsync(tonumber(Content.ID))
				if not Users[playerName] then
					Users[playerName] = likeCount
				else 
					Users[playerName] = Users[playerName] + likeCount
				end
			end)
		end
	end

	-- On trie la table en fonction du nombre de likes
	local SortedUsers = {}
	for Username, Count in pairs(Users) do
		table.insert(SortedUsers, {Username = Username, Count = Count})
	end
	table.sort(SortedUsers, function(a, b)
		return a.Count > b.Count
	end)

	local s, e = pcall(function()
		local podiums = script.Parent.Parent.Parent.Podium
		local gold, silver, bronze = podiums.Gold, podiums.Silver, podiums.Bronze
		local c = 0
		for i, v in ipairs(SortedUsers) do
			local u = v.Username
			if c == 0 then
				gold.R15.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(Players:GetUserIdFromNameAsync(u)))
				gold.R15.Humanoid.Animator:LoadAnimation(gold.R15.Idle):Play()
				gold.R15.BillboardGui.username.Text = u
			elseif c == 1 then
				silver.R15.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(Players:GetUserIdFromNameAsync(u)))
				silver.R15.Humanoid.Animator:LoadAnimation(silver.R15.Idle):Play()
				silver.R15.BillboardGui.username.Text = u
			elseif c == 2 then
				bronze.R15.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(Players:GetUserIdFromNameAsync(u)))
				bronze.R15.Humanoid.Animator:LoadAnimation(bronze.R15.Idle):Play()
				bronze.R15.BillboardGui.username.Text = u
			else
				break
			end
			c = c + 1
		end
	end)

	-- On met à jour l'affichage en créant ou en réutilisant des clones de l'exemple
	local count = 0
	for i, User in ipairs(SortedUsers) do
		if count >= 25 then break else count = count + 1 end
		local Clone = Container:FindFirstChild(User.Username)
		if not Clone then
			Clone = Example:Clone()
			Clone.Name = User.Username
			Clone.Parent = Container
		end
		Clone.value.Text = User.Count
		Clone.name.Text = User.Username
		Clone.image.Image = Players:GetUserThumbnailAsync(
			Players:GetUserIdFromNameAsync(User.Username),
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420)
		Clone.LayoutOrder = i
		Clone.Visible = true
		
		Clone.rank.Text = string.format("#%d", i)
		if i == 1 then
			Clone.rank.TextColor3 = Color3.new(1, 1, 0)
		elseif i == 2 then
			Clone.rank.TextColor3 = Color3.new(0.709804, 0.709804, 0.709804)
		elseif i == 3 then
			Clone.rank.TextColor3 = Color3.new(0.917647, 0.458824, 0)
		end
	end

	-- On cache les clones restants qui ne sont plus nécessaires
	for _, Clone in ipairs(Container:GetChildren()) do
		if Clone:IsA("Frame") and Clone ~= Example and not Users[Clone.Name] then
			Clone.Visible = false
		end
	end
end

Refresh() -- On appelle la fonction Refresh() pour mettre à jour l'affichage au chargement du script