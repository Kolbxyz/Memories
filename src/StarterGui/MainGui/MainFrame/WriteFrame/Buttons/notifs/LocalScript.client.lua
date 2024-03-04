script.Parent.MouseButton1Click:Connect(function()
	script.Parent.Value.Value = not script.Parent.Value.Value
end)

script.Parent.Value:GetPropertyChangedSignal("Value"):Connect(function()
	script.Parent.Text = script.Parent.Value.Value and "ON" or "OFF"
	script.Parent.BackgroundColor3 = script.Parent.Value.Value and Color3.fromRGB(85,170,0) or 
		Color3.fromRGB(170,0,0)
end)