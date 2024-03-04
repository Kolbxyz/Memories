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

	-- On utilise une table pour stocker le nombre de messages de chaque joueur
	local Users = {}

	-- On boucle sur les données pour compter les messages
	for _, Content in pairs(Data) do
		local userId = tonumber(Content.ID)
		local username = Players:GetNameFromUserIdAsync(userId)

		if not Users[username] then
			Users[username] = 0
		end

		-- Compter les messages
		Users[username] = Users[username] + #Content.data
	end

	-- On trie la table en fonction du nombre de messages
	local SortedUsers = {}
	for Username, Count in pairs(Users) do
		table.insert(SortedUsers, {Username = Username, Count = Count})
	end
	table.sort(SortedUsers, function(a, b)
		return a.Count > b.Count
	end)

	-- Mettre à jour le podium
	local podiums = Leaderboard.Podium
	local gold, silver, bronze = podiums.Gold, podiums.Silver, podiums.Bronze
	for i, v in ipairs(SortedUsers) do
		local u = v.Username
		if i == 1 then
			gold.R15.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(Players:GetUserIdFromNameAsync(u)))
			gold.R15.Humanoid.Animator:LoadAnimation(gold.R15.Idle):Play()
			gold.R15.BillboardGui.username.Text = u
		elseif i == 2 then
			silver.R15.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(Players:GetUserIdFromNameAsync(u)))
			silver.R15.Humanoid.Animator:LoadAnimation(silver.R15.Idle):Play()
			silver.R15.BillboardGui.username.Text = u
		elseif i == 3 then
			bronze.R15.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(Players:GetUserIdFromNameAsync(u)))
			bronze.R15.Humanoid.Animator:LoadAnimation(bronze.R15.Idle):Play()
			bronze.R15.BillboardGui.username.Text = u
		end
	end

	-- Mettre à jour l'affichage en créant ou en réutilisant des clones de l'exemple
	local count = 0
	for i, User in ipairs(SortedUsers) do
		if count < 25 then count += 1 else break end
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

	-- Cacher les clones restants qui ne sont plus nécessaires
	for _, Clone in ipairs(Container:GetChildren()) do
		if Clone:IsA("Frame") and Clone ~= Example and not Users[Clone.Name] then
			Clone.Visible = false
		end
	end
end

Refresh() -- On appelle la fonction Refresh() pour mettre à jour l'affichage au chargement du script