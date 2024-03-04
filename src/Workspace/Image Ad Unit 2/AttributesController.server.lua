local package = script.Parent
local adGui = package:WaitForChild('ADpart'):WaitForChild('AdGui')

local function updateFallbackImage()
	local fallbackImage = package:GetAttribute('FallbackImage')

	-- prepend "rbxassetid://" if the value is a base 10 number
	if tostring(tonumber(fallbackImage)) == fallbackImage then
		fallbackImage = "rbxassetid://" .. fallbackImage
	end

	adGui.FallbackImage = fallbackImage
end

package:GetAttributeChangedSignal('FallbackImage'):Connect(updateFallbackImage)

-- run for the first time
if package:GetAttribute('FallbackImage') then 
	updateFallbackImage() 
end