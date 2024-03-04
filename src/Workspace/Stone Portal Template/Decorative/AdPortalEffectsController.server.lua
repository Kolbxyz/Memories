local portalModel = script.Parent.Parent

local stateDependent = script.Parent:WaitForChild("StateDependent")
local blockerFolder = stateDependent:WaitForChild("Blocker")
local fxFolder = stateDependent:WaitForChild("FX")

local basePortalPackage = portalModel:WaitForChild("BasePortal")
local adPortal = basePortalPackage:WaitForChild("Door"):WaitForChild("AdPortal")

local function configureBlockerEffect(instance: Instance, isActive: boolean)
	if instance:IsA("Part") then
		instance.Transparency = if isActive then 1 else 0
		instance.CanCollide = not isActive
	end
end

local function configureVisualEffect(instance: Instance, isActive: boolean)
	if instance:IsA("ParticleEmitter") or instance:IsA("Light") or instance:IsA("Beam") then
		instance.Enabled = isActive
	elseif instance:IsA("UnionOperation") then
		instance.Transparency = if isActive then 0 else 1
		-- Don't update CanCollide property for Arrow unions
		if instance.Name ~= "Arrow" then
			instance.CanCollide = isActive
		end
	elseif instance:IsA("Sound") then
		if isActive then
			instance:Play()
		else
			instance:Stop()
		end
	end
end

local function onAdStatusChange()
	local isActive = (adPortal.Status == Enum.AdUnitStatus.Active)

	-- Configure Blocker parts based on the AdPortalStatus
	for _, instance in pairs(blockerFolder:GetDescendants()) do
		configureBlockerEffect(instance, isActive)
	end

	-- Configure other visual effects based on the AdPortalStatus
	for _, instance in pairs(fxFolder:GetDescendants()) do
		configureVisualEffect(instance, isActive)
	end
end

-- Update when the Status signal changes
adPortal:GetPropertyChangedSignal("Status"):Connect(onAdStatusChange)

-- Catch any Blocker unloaded descendants
blockerFolder.DescendantAdded:Connect(function(instance)
	configureBlockerEffect(instance, adPortal.Status == Enum.AdUnitStatus.Active)
end)
-- Catch any FX unloaded descendants
fxFolder.DescendantAdded:Connect(function(instance)
	configureVisualEffect(instance, adPortal.Status == Enum.AdUnitStatus.Active)
end)

-- Set the portal effects based on the initial Status value
onAdStatusChange()