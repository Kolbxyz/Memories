local portalTemplate = script.Parent.Parent
local basePortal = portalTemplate:WaitForChild('BasePortal')

local function updateFallbackImage()
	local fallbackImage = portalTemplate:GetAttribute('FallbackImage')
	basePortal:setAttribute('FallbackImage', fallbackImage)
end

portalTemplate:GetAttributeChangedSignal('FallbackImage'):Connect(updateFallbackImage)

-- run for the first time
if portalTemplate:GetAttribute('FallbackImage') then 
	updateFallbackImage() 
end