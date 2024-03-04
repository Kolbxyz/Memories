----// Services
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local frame = script.Parent.mainFrame
local players = game:GetService("Players")

--// Setup
script.Parent.Parent = players.LocalPlayer.PlayerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()
frame.Count.TextColor3 = Color3.new(1, 1, 1)
frame.loadingRing.Image = "rbxassetid://10243942097"

----// Instances
local tweenService = game:GetService("TweenService")

----// Variables
local FACTS = require(script.Parent.facts)

local size = 1
local minQueueSize = 10 -- taille minimale de la file d'attente
local delta = tick()
local previousFact = tick()
local previous percent = 0

local frame = script.Parent.mainFrame

local start_time = os.time()
while task.wait() do
	delta = tick()
	script.Parent.Parent:WaitForChild("MainGui").Enabled = false
	if game:GetService("ContentProvider").RequestQueueSize > size then
		size = game:GetService("ContentProvider").RequestQueueSize
	end
	
	frame.Pattern.Size += UDim2.new(0.001,0,0.001,0)
	frame.Pattern.Position -= UDim2.new(0.001,0,0.001,0)
	
	if tick()-previousFact >= 10 then
		frame.fact.Text = FACTS[math.random(1, #FACTS)]
		previousFact = tick()
	end

	if size > game:GetService("ContentProvider").RequestQueueSize then
		local remaining_time = math.round((game:GetService("ContentProvider").RequestQueueSize * (os.time() - start_time)) / (size - game:GetService("ContentProvider").RequestQueueSize))
		frame.time.Text = "Time remaining: " .. remaining_time .. "s"
	end

	if game:GetService("ContentProvider").RequestQueueSize >= 1 then
		frame.loadingRing.Rotation += 2
		
		if math.round(100-game:GetService("ContentProvider").RequestQueueSize/size*100) >= percent then
			percent = math.round(100-game:GetService("ContentProvider").RequestQueueSize/size*100)
			frame.progressBar.bar.Size = UDim2.new(1-(game:GetService("ContentProvider").RequestQueueSize/size),0,1,0)
		end
		
		frame.Count.Text = string.format("%d/%d object(s) loaded", size-game:GetService("ContentProvider").RequestQueueSize, size)
		frame.value.Text = math.round(100-game:GetService("ContentProvider").RequestQueueSize/size*100).."%"

	elseif game:GetService("ContentProvider").RequestQueueSize < 1 then
		frame.value.Text = "100%"; frame.progressBar.bar.Size = UDim2.new(1,0,1,0)
		tweenService:Create(frame.loadingRing,TweenInfo.new(),{ImageTransparency=1}):Play()
		tweenService:Create(frame.time,TweenInfo.new(),{TextTransparency=1}):Play()
		frame.Count.TextColor3 = Color3.new(0, 0.666667, 0)
		frame.Count.Text = string.format("%d/%d Object(s) loaded", size-game:GetService("ContentProvider").RequestQueueSize, size)
		frame.Title.Text = "Have a good time!"
		task.wait(2.5)
		script.Parent.Enabled = false
		script.Parent.Parent:WaitForChild("MainGui").Enabled = true
		break
	end
end