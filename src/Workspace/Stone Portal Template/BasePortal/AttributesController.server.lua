local basePortal = script.Parent
local adGui = basePortal:WaitForChild('Door'):WaitForChild('AdPortal'):WaitForChild('AdGui')

local function updateFallbackImage()
	local fallbackImage = basePortal:GetAttribute('FallbackImage')

	-- prepend "rbxassetid://" if the value is a base 10 number
	if tostring(tonumber(fallbackImage)) == fallbackImage then
		fallbackImage = "rbxassetid://" .. fallbackImage
	end

	adGui.FallbackImage = fallbackImage
end

basePortal:GetAttributeChangedSignal('FallbackImage'):Connect(updateFallbackImage)

-- run for the first time
if basePortal:GetAttribute('FallbackImage') then 
	updateFallbackImage() 
end