-----// Script made by @Kolbxyz \\-----

----// Services & Instances \\----
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--//Instances
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

----// Variables \\----
local Modules = ServerScriptService:WaitForChild("Modules")

--// Modules
local DialogsManagerModule = Modules:WaitForChild("DialogsManager")
--\\

----// Connectors \\----
require(DialogsManagerModule).HandleDialogs()
Remotes.ShowProximityPrompt.OnServerEvent:Connect(function()
	for _, v in pairs(workspace.NPCs:GetChildren()) do
		if not v:FindFirstChild("Dialog") or not v:FindFirstChild("Dialog"):FindFirstChild("ProximityPrompt") then return end
		v.Dialog.ProximityPrompt.Enabled = true --not v.Dialog.ProximityPrompt.Enabled
	end
end)

-----// Script made by @Kolbxyz \\-----