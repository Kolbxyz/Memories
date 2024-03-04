-- Open Cloud V2 UserNotification

local module = {}

export type UserNotification = {
	path: string?, 
	id: string?, 
	source: Sources?, 
	payload: Payload?
}
export type Payload = {
	type: string?, 
	messageId: string?, 
	parameters: {[string] : Payload_ParameterValue}?, 
	joinExperience: Payload_JoinExperience?, 
	analyticsData: Payload_AnalyticsData?
}
export type Payload_AnalyticsData = {
	category: string
}
export type Payload_JoinExperience = {
	launchData: string
}
export type Payload_ParameterValue = {
	stringValue: string?, 
	int64Value: number?
}
export type Sources = {
	universe: string
}

export type OpenCloudError = {
	code : string,
	message : string
}

export type UserNotificationResult =
	{
		statusCode : number,
		response : UserNotification,
		error : OpenCloudError
	}

function module.createUserNotification(userId : number, userNotification : UserNotification) : UserNotificationResult
	local oc = game:GetService("OpenCloudService")

	local notLoadedStr = "Open Cloud not loaded."

	local resp
	local success

	local MAX_RETRIES = 20
	local retryCount = 0

	while retryCount < MAX_RETRIES do
		success, resp = pcall(function()
			return oc:InvokeAsync("v2", "userNotification", {
				["user"] = userId, 
				["userNotification"] = userNotification
			})
		end)
		if not success and resp == notLoadedStr then
			wait(0.5)
			retryCount += 1
		else
			break
		end
	end

	if not success then
		return {
			["response"] = nil,
			["statusCode"] = 500,
			["error"] = {
				["code"] = "UNEXPECTED_ERROR",
				["message"] = resp
			}
		}
	end

	if typeof(resp) == "string" then
		return {
			["response"] = nil,
			["statusCode"] = 500,
			["error"] = {
				["code"] = "UNEXPECTED_ERROR",
				["message"] = resp
			}
		}
	end
	local bodyStr = resp["Body"]
	local hs = game:GetService("HttpService")
	if resp["StatusCode"] == 200 then
		return {
			["response"] = hs:JSONDecode(bodyStr),
			["statusCode"] = 200,
			["error"] = nil
		}
	else
		print(bodyStr)
		local sucess, bodyJson = pcall(function()
			return hs:JSONDecode(bodyStr)
		end)
		if not success then
			bodyJson = {
				["code"] = "UNEXPECTED_ERROR",
				["message"] = bodyStr
			}
		end
		return {
			["response"] = nil,
			["statusCode"] = resp["StatusCode"],
			["error"] = bodyJson
		}
	end
end

return module