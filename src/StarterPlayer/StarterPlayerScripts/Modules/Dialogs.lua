-----// Script made by @Kolbxyz \\-----

----// Services & Instances \\----
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--//Instances
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local MainGui = PlayerGui:WaitForChild("MainGui")
local DialogGUI = MainGui:WaitForChild("Dialog")
local Character = Player.Character or Player.CharacterAdded.wait()
--local Sounds = workspace.Sounds

--/ Modules
local Modules = script.Parent.Parent.Modules

local GUIsModule = Modules:WaitForChild("Guis")
--\

----// Variables \\----
local DialogsModule = {}
DialogsModule.v = {}
local CanUseTeleport = true

----// Functions \\----
function DialogsModule.removeTags(str)
	-- replace line break tags (otherwise grapheme loop will miss those linebreak characters)
	str = str:gsub("<br%s*/>", "\n")
	return (str:gsub("<[^<>]->", ""))
end

function DialogsModule.HandleDialog(AllDialogs, name, npc, BackgroundColor)

	npc.Dialog.ProximityPrompt.Enabled = false

	BackgroundColor = BackgroundColor or Color3.fromRGB(252, 255, 234)

	local interactanim
	pcall(function()
		interactanim = npc.Humanoid.Animator:LoadAnimation(npc.Humanoid.Interact)
		interactanim:Play()
	end)

	local previousCameraType = workspace.CurrentCamera.CameraType
	local previousCameraCFrame = workspace.CurrentCamera.CFrame
	local previousCameraSubject = workspace.CurrentCamera.CameraSubject

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1), {CFrame=npc.Camera.CFrame}):Play()
	--workspace.CurrentCamera.CFrame = npc.Camera.CFrame

	-- Creates variables
	local Click
	local Dialogs = AllDialogs["Random"]
	local ws = Character:FindFirstChildWhichIsA("Humanoid").WalkSpeed
	local jp = Character:FindFirstChildWhichIsA("Humanoid").JumpPower

	-- Avoid the player from moving
	Character:FindFirstChildWhichIsA("Humanoid").WalkSpeed = 0
	Character:FindFirstChildWhichIsA("Humanoid").JumpPower = 0

	-- Displaying the dialog frame and showing the arrow
	DialogGUI.Size = UDim2.new()
	DialogGUI.Visible = true
	DialogGUI.Arrow.Visible = true

	TweenService:Create(DialogGUI, TweenInfo.new(1,Enum.EasingStyle.Exponential), {Size=UDim2.new(0.687, 0,0.203, 0)}):Play()

	-- Creating more variables; pick a random dialog in the list
	local Dialog = math.random(1, #Dialogs)
	local DialogCount = 1

	-- Display the name of the npc; clear the text
	DialogGUI._Name.Text = name == "_player" and Player.DisplayName or name
	DialogGUI._Content.Text = ""

	task.wait(.5)

	-- repeat [numbers of dialogs in the dialog chosen]

	for count = 1, #Dialogs[Dialog] do

		-- Cannot continue
		local CanContinue = false

		-- If no choice is prompted; arrow is not visible and the current dialog is < or = to the total of dialogs
		if DialogGUI.ChoiceFrame.Visible == false and DialogGUI.Arrow.Visible and DialogCount <= #Dialogs[Dialog] then

			-- Hide the arrow
			DialogGUI.Arrow.Visible = false

			-- If the current dialog has choices
			if Dialogs[Dialog][DialogCount]["Choices"] then

				-- Hide all choices
				for _, child in pairs(DialogGUI.ChoiceFrame:GetChildren()) do
					if child:IsA("TextButton") and child.Name ~= "CHOICE" then
						child:Destroy()
					end
				end

				-- Show the choice frame
				DialogGUI.ChoiceFrame.Visible = true
				DialogGUI.ChoiceFrame.Size = UDim2.new()
				TweenService:Create(DialogGUI.ChoiceFrame, TweenInfo.new(1, Enum.EasingStyle.Elastic), {Size=UDim2.new(0.3, 0,0.232, 0)}):Play()

				-- Repeat for the numbers of choices in the dialog
				for name, output in pairs(Dialogs[Dialog][DialogCount]["Choices"]) do

					-- Create a new text button for the choice
					local Clone = DialogGUI.ChoiceFrame.CHOICE:Clone()
					Clone.Name, Clone.Parent, Clone.Visible, Clone.Text = name, DialogGUI.ChoiceFrame, true, name

					-- Show the background when choice is touched by the mouse
					Clone.MouseEnter:Connect(function()
						Clone.Cursor.Visible = true
						Clone.Text = string.format("<font color='rgb(220, 220, 0)'>%s</font>", Clone.Text)
					end)

					-- Hide the background when mouse stops to over the dialog
					Clone.MouseLeave:Connect(function()
						Clone.Cursor.Visible = false
						Clone.Text = Clone.ContentText
					end)

					-- When the choice is chosen by the player
					Clone.MouseButton1Click:Connect(function()
						DialogGUI.Arrow.Visible = false -- Hide the arrow
						task.wait()
						--						Sounds.Sounds.UIClick:Play() -- Play a sound
						DialogGUI._Content.Text = "" -- Clear the text
						--						TweenService:Create(DialogGUI.ChoiceFrame, TweenInfo.new(), {Size=UDim2.new()}):Play() -- Fade in the choice frame
						--						task.wait(.2) -- Wait 200ms
						DialogGUI.ChoiceFrame.Visible = false -- Hide choices
						task.wait(.2) -- Wait 200ms
						--						print(AllDialogs["Answers"][Dialog][DialogCount]) -- Print all answers for this dialog
						--						warn("Start answer")
						--						print(DialogCount, AllDialogs["Answers"][Dialog][DialogCount][tostring(output)])
						warn(output)
						DialogsModule.DisplayDialog(AllDialogs["Answers"][Dialog][DialogCount][tostring(output)]) -- Display the correct answer
						--						warn("wait answer time")
						pcall(function()
							wait(#AllDialogs["Answers"][Dialog][DialogCount][tostring(output)]*0.01+0.2)
						end)
						--						warn("showing arrow")
						DialogGUI.Arrow.Visible = true -- Show the arrow
					end)
				end
			end
			--			warn("Normal content")
			DialogGUI.Arrow.Visible = false -- Hide the arrow
			DialogGUI._Content.Text = "" -- Clear the text
			DialogsModule.DisplayDialog(Dialogs[Dialog][DialogCount]["Content"]) -- Display the correct text content
			task.wait(#Dialogs[Dialog][DialogCount]["Content"]*0.01+0.2) -- Wait [Number of chars] + 500ms
			DialogGUI.Arrow.Visible = true -- Show the arrow

			Click = Player:GetMouse().Button1Down:Connect(function() -- When mouse is clicked
				if not DialogGUI.ChoiceFrame.Visible and DialogGUI.Arrow.Visible then -- If choice frame is hidden and arrow visible
					Click:Disconnect()
					DialogCount+=1
					if DialogGUI.ChoiceFrame.Visible == false and DialogGUI.Arrow.Visible and DialogCount > #Dialogs[Dialog] then
						DialogGUI.Arrow.Visible = false
						DialogGUI._Content.Text = ""
						TweenService:Create(DialogGUI, TweenInfo.new(), {Size=UDim2.new()}):Play()
						task.wait(0.2)
						DialogGUI.Visible = false
						Character:FindFirstChildWhichIsA("Humanoid").WalkSpeed = ws
						Character:FindFirstChildWhichIsA("Humanoid").JumpPower = jp
						Remotes.ShowProximityPrompt:FireServer()

						pcall(function()
							interactanim:Stop()
						end)

						npc.Dialog.ProximityPrompt.Enabled = true

						workspace.CurrentCamera.CameraType = previousCameraType
						workspace.CurrentCamera.CFrame = previousCameraCFrame
						workspace.CurrentCamera.CameraSubject = previousCameraSubject

					end
					--					warn(DialogCount, #Dialogs[Dialog])
					CanContinue = true
				end
			end)

			while not CanContinue do task.wait() end

		end
	end
end

function DialogsModule.DisplayDialog(Content)

	local connection
	local skipped = false
	DialogGUI._Content.Text = Content

	Content = DialogsModule.removeTags(Content)

	assert(Content, "Dialog's content = nil; Function: DialogsModule.DisplayDialog; Script: GUIs")

	coroutine.wrap(function()
		task.wait(.5)
		connection = Player:GetMouse().Button1Down:Connect(function()
			skipped = true
			connection:Disconnect()
		end)
	end)()

	local index = 0
	for first, last in utf8.graphemes(Content) do 
		local grapheme = Content:sub(first, last) 
		index += 1
		-- Uncomment this statement to get a reveal effect that ignores spaces.
		-- if grapheme ~= " " then
		DialogGUI._Content.MaxVisibleGraphemes = index

		if skipped then
			DialogGUI._Content.MaxVisibleGraphemes = -1
			break
		end

		--		if grapheme ~= " " then Sounds.Sounds.DialogPop_alt:Play() end

		if grapheme == "." then
			task.wait(0.3)
		else
			task.wait(0.01)	
		end
		-- end
	end

	if not skipped then task.wait(.3) else return end
end

return DialogsModule

-----// Script made by @Kolbxyz \\-----