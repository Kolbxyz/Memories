-----// Script made by @Kolbxyz \\-----

----// Services & Instances \\----
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--//Instances
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

----// Variables \\----
local DialogsManager = {}
DialogsManager.v = {}

----// Functions \\----
function DialogsManager.HandleDialogs()
	local Dialogs = require(ReplicatedStorage.Modules.Dialogs)
	for NPC, Table in pairs(Dialogs) do
		Table["NPC"].Dialog.ProximityPrompt.ObjectText = Table["Name"] == "_player" and "" or Table["Name"]
		Table["NPC"].Dialog.ProximityPrompt.ActionText = Table["Action"]
		
		Table["NPC"].Dialog.ProximityPrompt.TriggerEnded:Connect(function(p)
--			Table["NPC"].Dialog.ProximityPrompt.Enabled = false -- server-side lock
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(Table.NPC.Dialog.Position.X, hrp.Position.Y, Table.NPC.Dialog.Position.Z))
			if Table["IsQuest"] then -- Or quest finished

			else
				Remotes.RandomDialog:FireClient(p,Table["Dialogs"], Table["Name"], Table["NPC"])
			end
		end)
	end
end

	return DialogsManager
-----// Script made by @Kolbxyz \\-----