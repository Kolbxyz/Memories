local tweenService = game:GetService("TweenService")

function detectMusic()
	for i, v in pairs(workspace.musics:GetChildren()) do
		if v:IsA("Sound") and v.IsPlaying then
			return v
		end
	end
end

function handleMusic()
	local sound = detectMusic()
	while not sound do
		task.wait(.05)
		sound = detectMusic()
	end
	while sound.IsPlaying do
		task.wait(.2)
		script.Parent.info.Text = sound.Name
		
		script.Parent.bar.progress.Size  =UDim2.new(sound.TimePosition/sound.TimeLength,0,1,0)
		
		local s = sound.TimePosition
		local convertedTime = string.format("%02i:%02i", s/60%60, s%60)
		script.Parent.time.Text = convertedTime .. "/"
		
		local s = sound.TimeLength
		local convertedTime = string.format("%02i:%02i", s/60%60, s%60)
		script.Parent.time.Text ..= convertedTime
		
	end
	script.Parent.info.Text = "--"
	script.Parent.time.Text = "--/--"
	handleMusic()
end

task.delay(10, handleMusic)