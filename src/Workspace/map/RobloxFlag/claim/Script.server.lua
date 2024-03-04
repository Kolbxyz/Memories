script.Parent.ProximityPrompt.TriggerEnded:Connect(function(p)
	script.Parent.Parent.text.BillboardGui.TextLabel.Text = string.format("%s was here.", p.Name)
end)