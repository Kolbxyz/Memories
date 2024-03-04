local playedMusics = {}

function playMusic()
	task.wait(5)
	if #playedMusics >= #workspace.musics:GetChildren() then
		playedMusics = {}
	else
		local newMusic = math.random(1, #workspace.musics:GetChildren())
		while table.find(playedMusics, workspace.musics:GetChildren()[newMusic]) do
			task.wait()
			newMusic = math.random(1, #workspace.musics:GetChildren())
		end
		newMusic = workspace.musics:GetChildren()[newMusic]
		table.insert(playedMusics, newMusic)
		game:GetService("ReplicatedStorage").Remotes.notify:FireAllClients("Now playing:", newMusic.Name)
		newMusic:Play()
		newMusic.Ended:Connect(playMusic)
	end
end

playMusic()